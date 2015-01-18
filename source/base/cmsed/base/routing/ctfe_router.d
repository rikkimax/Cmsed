module cmsed.base.routing.ctfe_router;
import cmsed.base.routing.defs;
import cmsed.base.config : configuration;
import vibe.d : HTTPServerRequestHandler, HTTPServerRequest, HTTPServerResponse, Session, HTTPStatus, HTTPMethod, httpStatusText;
import std.file : append;
import std.string : toLower;
import std.conv : to;
import std.path : buildPath;

/*
 * TODO: Idea, create other instance of e.g. secondaryRouters/routes/errorRoutes as TaskLocal
 */
class CTFEURLRouter : HTTPServerRequestHandler {
    private shared {
        struct RouteInternalState {
            bool delegate() check;
            void delegate() route;
        }

        RouteInternalState[RouteInformation] secondaryRouters;

        RouteInternalState[RouteInformation] routes;
        RouteInternalState[RouteInformation][int] errorRoutes;

        string errorFile;
    }

    this() {
        errorFile = cast(shared)buildPath(configuration.logging.dir, configuration.logging.errorAccessFile);
    }

    void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        if (!req.bodyReader.empty) {
            /**
             * Params field under request is empty for e.g. post
             * Will auto parse it, if bodyReader hasn't been emptied
             */

            ubyte[] a;
            a.length = 1;

            string buffer; // TODO: a proper buffer?
            string key = "";
            char last = '0';

            while(!req.bodyReader.empty) {
                req.bodyReader.read(a);

                char c = cast(char)a[0];
                if (c == '=' && last != '\\') {
                    key = buffer;
                    buffer = "";
                } else if (c == '&' && last != '\\') {
                    req.params[key] = buffer;
                    buffer = "";
                    key = "";
                } else
                    buffer ~= c;
            }

            if (buffer.length != 0)
                req.params[key] = buffer;
        }

        /*if (req.session.id.length == 0)
            handleRequest(IOTransport(req, res, res.startSession()));
        else*/
            handleRequest(IOTransport(req, res, req.session));
    }

    void handleRequest(IOTransport transport) {
        currentTransport = transport;
        auto res = transport.response;
        auto req = transport.request;
        
        res.statusCode = HTTPStatus.ok;

        // disable caching
        res.headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
        res.headers["Pragma"] = "no-cache";
        res.headers["Expires"] = "0";

        bool runErrorRouteFunc() {
            if (res.statusCode in errorRoutes) {
                // basically this current status code (from the above set of routes or notFound)
                // is in the errorRoutes list.
                // to handle this we run the checks like a normal route and execute
                // allows for a much more advanced form of control i.e. on a specific path!
                
                // however the below code is only for IF there is route info
                foreach (k, v; errorRoutes[res.statusCode]) {
                    if (k !is null && (v.check !is null && v.check())) {
                        currentRoute = cast(RouteInformation)k;
                        v.route();
                        
                        if (res.headerWritten) {
                            // we succedded in the request
                            // now its time to stop
                            return true;
                        } else {
                            // we failed in our request
                            // try again
                            // or we didn't write any headers
                            // (just in case another route is listening on this exact path / http type)
                        }
                    }
                }
                
                // however if there wasn't there,
                // then lets use null if its there.
                
                if (null in errorRoutes[res.statusCode]) {
                    auto iData = errorRoutes[res.statusCode][null];
                    
                    currentRoute = null;
                    iData.route();
                    
                    if (res.headerWritten) {
                        // we succedded in the request
                        // now its time to stop
                        return true;
                    } else {
                        // oh dammit
                        // next fail through :(
                    }
                }
            }
            
            return false;
        }
        
        try {
            if ("X-HTTP-Method-Override" in req.headers) {
                switch(req.headers["X-HTTP-Method-Override"].toLower()) {
                    case "get":
                        req.method = HTTPMethod.GET;
                        break;
                    case "post":
                        req.method = HTTPMethod.POST;
                        break;
                    case "put":
                        req.method = HTTPMethod.PUT;
                        break;
                    case "delete":
                        req.method = HTTPMethod.DELETE;
                        break;
                    default:
                        res.statusCode = HTTPStatus.badRequest;
                        res.writeVoidBody();
                        return;
                }
            }

            void tryRoutes(shared(RouteInternalState[RouteInformation]) routes) {
                foreach (k, v; routes) {
                    if (v.check is null || (v.check !is null && v.check())) {
                        if (res.statusCode != HTTPStatus.ok)
                            break;
                        
                        currentRoute = cast(RouteInformation)k;
                        v.route();
                        
                        if (res.headerWritten) {
                            // we succedded in the request
                            // now its time to stop
                            return;
                        } else {
                            // we failed in our request
                            // try again
                            // or we didn't write any headers
                            // (just in case another route is listening on this exact path / http type)
                        }
                    }
                }
            }

            tryRoutes(routes);
            if (!res.headerWritten)
                tryRoutes(secondaryRouters);

            if (res.headerWritten)
                return;

            // if we've reached this point then we just don't have the requested route.
            // so now we'll work from our error handling code
            
            // error 404
            if (res.statusCode == HTTPStatus.ok)
                res.statusCode = HTTPStatus.notFound;
            if (runErrorRouteFunc()) return;
            
            if (res.statusCode == HTTPStatus.notFound) {
                res.writeBody("Error " ~ to!string(res.statusCode) ~ ": " ~
                              (res.statusPhrase.length ? res.statusPhrase : httpStatusText(res.statusCode)));
                return;
            } else {
                res.statusCode = HTTPStatus.internalServerError;
                if (runErrorRouteFunc()) return;
            }
            
        } catch (Exception e) {
            // one last time try to push it into the error routes.
            try {
                synchronized { // stops more then one task local write to file
                    append(errorFile, "\nLast resort on route exception " ~ e.toString());
                }

                res.statusCode = HTTPStatus.internalServerError;
                if (runErrorRouteFunc()) return;
            } catch(Exception e) {
                // just let it error out *sigh*
            }
        }

        // we hit an error we didn't know how to handle in ANY FORM
        // Log it to file.
        // output nothing to client.
        // Make sure they know something bad happend.
        
        res.writeBody("Last resort error " ~ to!string(res.statusCode) ~ ": " ~
              (res.statusPhrase.length ? res.statusPhrase : httpStatusText(res.statusCode)));

        synchronized { // stops more then one task local write to file
            if (req.method == HTTPMethod.GET)
                append(errorFile, "get:" ~ req.path ~ "?" ~ req.queryString ~ "\n");
            else if (req.method == HTTPMethod.POST)
                append(errorFile, "post:" ~ req.path ~ "?" ~ req.queryString ~ "\n");
            else if (req.method == HTTPMethod.PUT)
                append(errorFile, "put:" ~ req.path ~ "?" ~ req.queryString ~ "\n");
            else if (req.method == HTTPMethod.DELETE)
                append(errorFile, "delete:" ~ req.path ~ "?" ~ req.queryString ~ "\n");
        }
    }
    
    void register(RouteInformation info, bool delegate() check, void delegate() route) {
        routes[info] = RouteInternalState(check, route);
    }
    
    void unregister(RouteInformation info) {
        routes.remove(info);
    }

    void registerRouter(RouteInformation info, bool delegate() check, void delegate() route) {
        secondaryRouters[info] = RouteInternalState(check, route);
    }
    
    void unregisterRouter(RouteInformation info) {
        secondaryRouters.remove(info);
    }
    
    /**
     * Registers an error route.
     * 
     * Params:
     *      error   =   The error to handle
     *      info    =   The route information. If null is a global error handler.
     *      check   =   The check to perform if should use this error handler
     *      route   =   The actual error route handler.
     */
    void register(int error, RouteInformation info, bool delegate() check, void delegate() route) {
        if (info.path == "")
            errorRoutes[error][null] = RouteInternalState(check, route);
        else
            errorRoutes[error][info] = RouteInternalState(check, route);
    }
    
    void unregister(int error, RouteInformation info) {
        if (error in errorRoutes)
            errorRoutes[error].remove(info);
    }
    
    @property {
        shared(RouteInformation[]) allRouteInformation() {
            return cast(shared)routes.keys;
        }
        
        shared(RouteInformation[]) allRouteInformationByClass(string name) {
            RouteInformation[] ret;
            foreach(ri; routes.keys) {
                if (ri.className == name) {
                    ret ~= ri;
                }
            }
            return cast(shared)ret;
        }
    }
}