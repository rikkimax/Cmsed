module cmsed.base.internal.routing.defs;
import cmsed.base.config : configuration;
import cmsed.base.internal.routing.parser;
public import vibe.d : HTTPServerRequest, HTTPServerResponse, URLRouter, Session, HTTPServerRequestHandler, HTTPStatus, HTTPMethod;

import std.string : toLower, split;
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
	this(string[] args ...) {
		routeNames = args;
	}
	
	string[] routeNames;
}

struct RouteTemplate {
	string templateName;
}

interface OORoute {}
interface OOInstallRoute {}
interface OOAnyRoute {}

private {
	__gshared CTFEURLRouter urlRouter_ = new CTFEURLRouter;
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
	}
	
	void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
		synchronized {
			http_request = req;
			http_response = res;
			
			auto tempVal = req.headers.get("X-HTTP-Method-Override", null);
			if (tempVal !is null) {
				switch(tempVal.toLower()) {
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
			
			bool hit = false;
			
			foreach	(k, v; routes) {
				if (v.check !is null && v.check()) {
					currentRoute = cast(RouteInformation)k;
					v.route();
					
					if (http_response.headerWritten) {
						// we succedded in the request
						hit = true;
						// now its time to break
						break;
					} else {
						// we failed in our request
						// try again
						// or we didn't write any headers
						// (just in case another route is listening on this exact path / http type)
					}
				}
			}
			
			if (!hit) {
				// error 404
				res.statusCode = HTTPStatus.notFound;
			}
			
			if (res.statusCode != HTTPStatus.ok && !http_response.headerWritten) {
				// TODO: we had an error, handle it!
				// if headers are already written we can't exactly rewrite them. Oh well.
				
				// for temporary usage
				res.writeBody("");
				
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
		}
	}
	
	void register(RouteInformation info, bool delegate() check, void delegate() route) {
		synchronized {
			routes[info] = RouteInternalState(check, route);
		}
	}
	
	void register(RouteInformation info, bool delegate() check, void function() route) {
		synchronized {
			routes[info] = RouteInternalState(check, toDelegate(route));
		}
	}
	
	void register(RouteInformation info, bool function() check, void function() route) {
		synchronized {
			routes[info] = RouteInternalState(toDelegate(check), toDelegate(route));
		}
	}
	
	void register(RouteInformation info, bool function() check, void delegate() route) {
		synchronized {
			routes[info] = RouteInternalState(toDelegate(check), route);
		}
	}
	
	void unregister(RouteInformation info) {
		synchronized {
			routes.remove(info);
		}
	}
	
	@property {
		shared(RouteInformation[]) allRouteInformation() {
			synchronized {
				return routes.keys;
			}
		}
		
		shared(RouteInformation[]) allRouteInformationByClass(string name) {
			synchronized {
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
}