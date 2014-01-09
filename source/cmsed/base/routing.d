module cmsed.base.routing;
import cmsed.base.config : configuration;

public import vibe.d : HTTPServerRequest, HTTPServerResponse, URLRouter;
//import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
//import vibe.http.router : URLRouter;

import vibe.d : render, compileDietFile, MemoryOutputStream;
//import vibe.http.server : render;
//import vibe.templ.diet : compileDietFile;
//import vibe.stream.memory : MemoryOutputStream;

import std.file : append, write;
import std.traits : moduleName, ReturnType;
import std.string : lastIndexOf;
import std.path : buildPath;

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

struct RouteInformation {
	RouteType type;
	string classModuleName;
	string className;
	string functionName;
	string path;
	
	string toString() {
		return type ~ ":((" ~ classModuleName ~ ").(" ~ className ~ "))." ~ functionName ~ ":" ~ path;
	}
}

RouteInformation currentRoute;
HTTPServerRequest http_request;
HTTPServerResponse http_response;

/*
 * Below is an array that stores the entirity of all routes currently that can be served.
 */

shared(RouteInformation[]) getAllRouteInformation() {
	synchronized {
		return allRouteInformation;
	}
}

shared(RouteInformation[]) getAllRouteInformationByClass(string name) {
	synchronized {
		shared RouteInformation[] ret;
		foreach(ri; allRouteInformation) {
			if (ri.className == name) {
				ret ~= ri;
			}
		}
		return ret;
	}
}

private shared {
	RouteInformation[] allRouteInformation;
}

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
	// bug in dmd 2.064
	/*this(string[] args ...) {
	 //routeNames = args;
	 }*/
	
	string[] routeNames;
}

struct MatchRoute {}

struct RouteTemplate {
	string templateName;
}

interface OORoute {}
interface OOInstallRoute : OORoute {}

URLRouter getURLRouter() {
	synchronized {
		return urlRouter;
	}
}

private {
	__gshared URLRouter urlRouter = new URLRouter();
	
	string functionWrapper(T, string f, RouteType type, string path)() {
		string ret;
		
		ret ~= "void " ~ T.stringof ~ "_" ~ f ~ "(HTTPServerRequest req, HTTPServerResponse res) {";
		ret ~= "    import " ~ moduleName!T ~ ";";
		ret ~= "    import cmsed.base.routing : currentRoute, RouteInformation;";
		ret ~= "    currentRoute = RouteInformation(cast(RouteType)\"" ~ type ~ "\", \"" ~ moduleName!T ~ "\", \"" ~ T.stringof ~ "\", \"" ~ f ~  "\", \"" ~ path ~ "\");";
		ret ~= "    http_request = req;";
		ret ~= "    http_response = res;";
		ret ~= "    " ~ T.stringof ~ " t = new " ~ T.stringof ~ ";";
		static if (useRenderOptionalFunc!(T, f)()) {
			ret ~= "    if (t." ~ f ~ "())";
			static if (getRouteTemplate!(T, f)() !is null) {
				ret ~= "        enum isFirstExecute = false;";
				ret ~= "        res.render!(\"" ~ getRouteTemplate!(T, f)() ~ ".dt\", currentRoute, isFirstExecute);";
			}
		} else {
			ret ~= "    t." ~ f ~ "();";
		}
		
		ret ~= "}";
		
		static if (useMatchRouting!(T, f)()) {
			switch(type) {
				case RouteType.Get:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.GET, \"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Post:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.POST, \"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Put:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.PUT,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Delete:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.DELETE,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Any:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.ANY,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				default:
					break;
			}
		} else {
			switch(type) {
				case RouteType.Get:
					ret ~= "(cast(URLRouter)urlRouter).get(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Post:
					ret ~= "(cast(URLRouter)urlRouter).post(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Put:
					ret ~= "(cast(URLRouter)urlRouter).put(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Delete:
					ret ~= "(cast(URLRouter)urlRouter).delete_(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Any:
					ret ~= "(cast(URLRouter)urlRouter).any(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				default:
					break;
			}
		}
		
		return ret;
	}
	
	string filterFunctionWrapper(T, string f, RouteType type, string path)() {
		string ret;
		
		ret ~= "void " ~ T.stringof ~ "_" ~ f ~ "(HTTPServerRequest req, HTTPServerResponse res) {";
		ret ~= "    import " ~ moduleName!T ~ ";";
		ret ~= "    import cmsed.base.routing : currentRoute, RouteInformation;";
		ret ~= "    currentRoute = RouteInformation(cast(RouteType)\"" ~ type ~ "\", \"" ~ moduleName!T ~ "\", \"" ~ T.stringof ~ "\", \"" ~ f ~  "\", \"" ~ path ~ "\");";
		ret ~= "    http_request = req;";
		ret ~= "    http_response = res;";
		ret ~= T.stringof ~ " t = new " ~ T.stringof ~ ";";
		
		ret ~= """    bool result = true;
		foreach(filter; getFiltersFromMethod!(" ~ T.stringof ~ ", \"" ~ f ~ "\")()) {
			if (result)
				result = filter();
		}
		
		if (result) {""";
		
		static if (useRenderOptionalFunc!(T, f)()) {
			ret ~= "        if(t." ~ f ~ "())";
			static if (getRouteTemplate!(T, f)() !is null) {
				ret ~= "            res.render!(\"" ~ getRouteTemplate!(T, f)() ~ ".dt\", currentRoute, isFirstExecute);";
			}
		} else {
			ret ~= "        t." ~ f ~ "();";
		}
		
		ret ~= "    }\n}";
		
		static if (useMatchRouting!(T, f)()) {
			switch(type) {
				case RouteType.Get:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.GET, \"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Post:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.POST, \"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Put:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.PUT,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Delete:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.DELETE,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Any:
					ret ~= "(cast(URLRouter)urlRouter).match(HTTPMethod.ANY,\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				default:
					break;
			}
		} else {
			switch(type) {
				case RouteType.Get:
					ret ~= "(cast(URLRouter)urlRouter).get(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Post:
					ret ~= "(cast(URLRouter)urlRouter).post(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Put:
					ret ~= "(cast(URLRouter)urlRouter).put(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Delete:
					ret ~= "(cast(URLRouter)urlRouter).delete_(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				case RouteType.Any:
					ret ~= "(cast(URLRouter)urlRouter).any(\"" ~ path ~ "\", &" ~ T.stringof ~ "_" ~ f ~ ");";
					break;
				default:
					break;
			}
		}
		
		return ret;
	}
	
	pure RouteType getRouteTypeFromMethod(C, string f)() {
		C c = new C;
		
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				return UDA.type;
			}
		}
		
		return RouteType.Any;
	}
	
	pure string getRouteTemplate(C, string f)() {
		C c = new C;
		
		string ret = null;
		
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				static if (UDA.templateName !is null)
					return UDA.templateName;
			} else static if (__traits(compiles, {RouteTemplate rf = UDA; } )) {
				ret = UDA.templateName;
			}
		}
		return ret;
	}
	
	pure bool useMatchRouting(C, string f)() {
		C c = new C;
		
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {MatchRoute rf = UDA; } )) {
				return true;
			}
		}
		
		return false;
	}
	
	pure bool useRenderOptionalFunc(C, string f)() {
		C c = new C;
		static if (is(ReturnType!(mixin("C." ~ f)) == bool)) {
			return true;
		} else {
			return false;
		}
	}
	
	pure string getPathFromMethod(C, string f)() {
		C c = new C;
		
		string ret;
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				static if (UDA.route != "")
					ret ~= UDA.route;
			} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
				static if (UDA.routeBase != "")
					ret ~= UDA.routeBase;
			} else static if (__traits(compiles, {RouteGroupId rf = UDA; } )) {
				ret ~= "/:" ~ UDA.routeName;
			} else static if (__traits(compiles, {RouteGroupIds rf = UDA; } )) {
				foreach(rn; UDA.routeNames) {
					ret ~= "/:" ~ rn;
				}
			}
		}
		return ret;
	}
	
	pure RouteFilter[] getFiltersFromMethod(C, string f)() {
		C c = new C;
		
		RouteFilter[] ret;
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				static if (UDA.filterFunction !is null)
					ret ~= UDA.filterFunction;
			} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
				static if (UDA.filterFunction !is null)
					ret ~= UDA.filterFunction;
			}
		}
		return ret;
	}
	
	pure bool hasFilters(C, string f)() {
		C c = new C;
		
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				static if (UDA.filterFunction !is null)
					return true;
			} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
				static if (UDA.filterFunction !is null)
					return true;
			}
		}
		
		return false;
	}
	
	pure bool isRoute(C, string f)() {
		C c = new C;
		
		foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
			static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
				return true;
			}
		}
		
		return false;
	}
}

protected {
	void registerRouteHandler(T : OORoute)() {
		string routeOutput = "";
		string ofile = buildPath(configuration.logging.dir, configuration.logging.routeFile);
		
		T t = new T;
		
		foreach(string f; __traits(allMembers, T)) {
			static if (isRoute!(T, f)()) {
				static if (useRenderOptionalFunc!(T, f)()) {
					handleFirstExecute!(T, f);
				}
				
				enum isFirstExecute = false;
				
				static if (hasFilters!(T, f)()) {
					mixin(filterFunctionWrapper!(T, f, getRouteTypeFromMethod!(T, f)(), getPathFromMethod!(T, f)())());
				} else {
					mixin(functionWrapper!(T, f, getRouteTypeFromMethod!(T, f)(), getPathFromMethod!(T, f)())());
				}
				
				routeOutput ~= getRouteTypeFromMethod!(T, f)() ~ ":" ~ T.stringof ~ "." ~ f ~ ":" ~ getPathFromMethod!(T, f)() ~ "\n";
				allRouteInformation ~= RouteInformation(getRouteTypeFromMethod!(T, f)(), moduleName!T, T.stringof, f, getPathFromMethod!(T, f)());
			}
		}
		
		append(ofile, "=======-----=======\n" ~ routeOutput);
	}
}

private {
	void handleFirstExecute(T, string f)() {
		enum isFirstExecute = true;
		auto currentRoute = RouteInformation(getRouteTypeFromMethod!(T, f)(), moduleName!T, T.stringof, f, getPathFromMethod!(T, f)());
		compileDietFile!(getRouteTemplate!(T, f)() ~ ".dt", currentRoute, isFirstExecute)(new MemoryOutputStream());
	}
}