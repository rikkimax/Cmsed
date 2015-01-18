module cmsed.base.routing.defs;
public import cmsed.base.routing.ctfe_router : CTFEURLRouter;
import cmsed.base.internal.defs;
import cmsed.base.routing.url_router;

enum RouteType : string {
    Get = "get",
    Post = "post",
    Put = "put",
    Delete = "delete",
    Any = "any"
}

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

struct IOTransport {
    import vibe.d : HTTPServerRequest, HTTPServerResponse, Session;
        
    static if (Router_Use_Dakka_Client) {
        import dakka.vibe.client : DakkaHTTPRequest, DakkaHTTPResponse, DakkaSession;
        DakkaHTTPRequest request;
        DakkaHTTPResponse response;
        DakkaSession session;
    } else {
        HTTPServerRequest request;
        HTTPServerResponse response;
        Session session;
    }
}

RouteInformation currentRoute;
IOTransport currentTransport;

CTFEURLRouter getRouter() {
    import cmsed.base.config : configuration;
    static __gshared CTFEURLRouter ret;

    if (ret is null) {
        ret = new CTFEURLRouter();

        // URLRouter replacement

        getRouter().registerRouter(new RouteInformation(RouteType.Get, "cmsed.base.routing.url_router", "CmsedURLRouter", ""), null, &getURLRouter().handle);

        void staticRouter() {
            import cmsed.base.internal.routing.fileserver : fileServer;

            bool checkStatic() {
                import std.string : startsWith, toLower;
                return currentTransport.request.path.toLower.startsWith(configuration.publicFiles.toLower);
            }

            string staticPath = "public";

            static if (Router_Use_Dakka_Server)
                staticPath = "../../static/public";
            else static if (Router_Use_Dakka_Client)
                staticPath = "../../dynamic/public";

            ret.registerRouter(new RouteInformation(RouteType.Get, "cmsed.base.internal.routing.fileserver", "", "fileServer"), &checkStatic, fileServer(configuration.publicFiles, staticPath));
        }
        staticRouter();

        static if (Router_Use_Dakka_Server) {
            import cmsed.base.internal.routing.livereload_router;
            add_dakka_router(ret);
        }
    }

    return ret;
}

CmsedURLRouter getURLRouter() {
    static __gshared CmsedURLRouter ret;

    if (ret is null) {
        ret = new CmsedURLRouter;
    }

    return ret;
}

/**
 * Class router interfaces
 */

interface OORoute {}
interface OOInstallRoute {}
interface OOAnyRoute {}

/**
 * Allows for returning of data
 */
interface IRouterReturnable {
    void handleReturn();
}

struct RouterReturnable {
    void delegate() handleReturn;
}

/**
 * Misc alias's
 */

interface HTTPCmsedRequestHandler {
    /// Handles incoming HTTP requests
    void handleRequest(IOTransport transport);
}

alias HTTPCmsedRequestDelegate = void delegate(IOTransport transport);
alias HTTPCmsedRequestFunction = void function(IOTransport transport);