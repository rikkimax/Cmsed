module cmsed.base.internal.routing.defs;
import cmsed.base.internal.config : configuration;
import cmsed.base.internal.routing.parser;
import cmsed.base.util : split, replace;
public import vibe.d : HTTPServerRequest, HTTPServerResponse, URLRouter, Session, HTTPServerRequestHandler, HTTPStatus, HTTPMethod, httpStatusText;

import std.string : toLower;
import std.file : append;
import std.path : buildPath;
import std.conv : to;
import std.functional : toDelegate;

/**
 * Below is a per thread variable which is set upon hitting the function wrapper.
 * It contains the current function, class, module, path and type of route being utilised.
 * 
 * To use it extend either OORoute or OOInstallRoute. Where the former is for normal routes and the later install only.
 * All route classes must be registered. By:
 * shared static this() {
 * 		registerRoute!<class type>;
 * }
 * 
 * Route functions can either return bool or not. Boolean returns signify whether to or not render the template given.
 * If void it will not render.
 * 
 * UDA's are utilised to produce: the filter list, path and type of request.
 * The main one is RouteFunction.
 *  RouteFunction contains the type aka RouteType.Get, the route to append e.g. /books, the template name to use e.g.
 *   book_list (adds .dt to end) and the filter function to call to determine if to use said route function.
 * 
 * Other valid UDA's are:
 *  RouteGroup
 *  RouteGroupId
 *  RouteGroupIds
 *  MatchRoute
 *  RouteTemplate
 * 
 * MatchRoute is the only one that isn't too obvious. It performs a straight regex match with no id recognition.
 * RouteGroupId(s) specifies ids to append on to the path. Basically only makes it easier to read without colons required.
 */

class RouteInformation {
	RouteType type;
	string classModuleName;
	string className;
	string functionName;
	string path;
	
	this(RouteType type, string classModuleName = "", string className = "", string functionName = "", string path = "") {
		this.type = type;
		this.classModuleName = classModuleName;
		this.className = className;
		this.functionName = functionName;
		this.path = path;
	}
	
	override string toString() {
		return type ~ ":((" ~ classModuleName ~ ").(" ~ className ~ "))." ~ functionName ~ ":" ~ path;
	}
}

RouteInformation currentRoute;
HTTPServerRequest http_request;
HTTPServerResponse http_response;
Session session;

/**
 * Provides a class based router based upon Vibe's URLRouter.
 * Includes UDA's to support method to request binding.
 * Also includes filters.
 */

enum RouteType : string {
	Get = "get",
	Post = "post",
	Put = "put",
	Delete = "delete",
	Any = "any"
}

alias bool function() RouteFilter;

struct RouteFunction {
	RouteType type;
	string route = "";
	string templateName = null;
	RouteFilter filterFunction = null;
}

struct RouteGroup {
	RouteFilter filterFunction = null;
	string routeBase = "";
}

struct RouteGroupId {
	string routeName = "";
}

struct RouteGroupIds {
	// GRR GRR this _was_ working
	/*this(string[] args ...) {
	 routeNames = args;
	 }*/
	
	string[] routeNames;
}

struct RouteTemplate {
	string templateName;
}

struct RouteErrorHandler {
	int error;
}

interface OORoute {}
interface OOInstallRoute {}
interface OOAnyRoute {}

/**
 * Template to provide a function that only renders a template
 * 
 * Params:
 * 		templ		= The template to render
 * 		path 		= The path to give the template. Default: ""
 * 		funcname	= The function name to generate for. Default: Based upon the template and path given
 */
mixin template TemplatedRoute(string templ, string path = "",
                              string funcname = "templatedRoute" ~ templ ~ (path.replace(":", "").replace("/", "").replace("*", ""))) {
	
	@RouteFunction(RouteType.Get, path, templ)
	mixin("bool " ~ funcname ~ "() { return true; }\n");
}

private {
	__gshared CTFEURLRouter urlRouter_;
	
	static this() {
		urlRouter_ = new CTFEURLRouter();
	}
}

CTFEURLRouter getURLRouter() {
	return urlRouter_;
}

/**
 * Handles routing.
 * 
 * Utilises heavily delegates to do the actual checking of route urls.
 */
class CTFEURLRouter : HTTPServerRequestHandler {
	private shared {
		struct RouteInternalState {
			bool delegate() check;
			void delegate() route;
		}
		
		RouteInternalState[RouteInformation] routes;
		RouteInternalState[RouteInformation][int] errorRoutes;
	}
	
	void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
		http_request = req;
		http_response = res;
		
		http_response.statusCode = HTTPStatus.ok;
		
		bool runErrorRouteFunc() {
			if (res.statusCode in errorRoutes) {
				// basically this current status code (from the above set of routes or notFound)
				// is in the errorRoutes list.
				// to handle this we run the checks like a normal route and execute
				// allows for a much more advanced form of control i.e. on a specific path!
				
				// however the below code is only for IF there is route info
				foreach	(k, v; errorRoutes[res.statusCode]) {
					if (k !is null && (v.check !is null && v.check())) {
						currentRoute = cast(RouteInformation)k;
						v.route();
						
						if (http_response.headerWritten) {
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
					
					if (http_response.headerWritten) {
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
						http_request.method = HTTPMethod.GET;
						break;
					case "post":
						http_request.method = HTTPMethod.POST;
						break;
					case "put":
						http_request.method = HTTPMethod.PUT;
						break;
					case "delete":
						http_request.method = HTTPMethod.DELETE;
						break;
					default:
						res.statusCode = HTTPStatus.badRequest;
						res.writeVoidBody();
						return;
				}
			}
			
			foreach	(k, v; routes) {
				if (v.check is null || (v.check !is null && v.check())) {
					if (http_response.statusCode != HTTPStatus.ok)
						break;
					
					currentRoute = cast(RouteInformation)k;
					v.route();
					
					if (http_response.headerWritten) {
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
		
		string oFile = buildPath(configuration.logging.dir, configuration.logging.errorAccessFile);
		if (http_request.method == HTTPMethod.GET)
			append(oFile, "get:" ~ http_request.path ~ "?" ~ http_request.queryString ~ "\n");
		else if (http_request.method == HTTPMethod.POST)
			append(oFile, "post:" ~ http_request.path ~ "?" ~ http_request.queryString ~ "\n");
		else if (http_request.method == HTTPMethod.PUT)
			append(oFile, "put:" ~ http_request.path ~ "?" ~ http_request.queryString ~ "\n");
		else if (http_request.method == HTTPMethod.DELETE)
			append(oFile, "delete:" ~ http_request.path ~ "?" ~ http_request.queryString ~ "\n");
	}
	
	void register(RouteInformation info, bool delegate() check, void delegate() route) {
		routes[info] = RouteInternalState(check, route);
	}
	
	void unregister(RouteInformation info) {
		routes.remove(info);
	}
	
	/**
	 * Registers an error route.
	 * 
	 * Params:
	 * 		error	= 	The error to handle
	 * 		info	=	The route information. If null is a global error handler.
	 * 		check	= 	The check to perform if should use this error handler
	 * 		route	= 	The actual error route handler.
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