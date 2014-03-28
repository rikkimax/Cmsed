module cmsed.base.internal.routing.parser;
import cmsed.base.internal.routing.defs;
import cmsed.base.internal.routing.checks;
import cmsed.base.config : configuration;

import vibe.d : render, compileDietFile, MemoryOutputStream, HTTPMethod;

import std.file : append, write;
import std.traits : moduleName, ReturnType;
import std.string : lastIndexOf;
import std.path : buildPath;

/**
 * Registers a route given a class
 */
void registerRouteHandler(T)() if (isARouteClass!T()) {
	string routeOutput = "";
	string ofile = buildPath(configuration.logging.dir, configuration.logging.routeFile);
	
	T t = new T;
	
	foreach(string f; __traits(allMembers, T)) {
		static if (isRoute!(T, f)()) {
			static if (useRenderOptionalFunc!(T, f)()) {
				handleFirstExecute!(T, f);
			}
			
			static if (isErrorRoute!(T, f)) {
				getURLRouter().register(getErrorRouteError!(T, f), new RouteInformation(getRouteTypeFromMethod!(T, f), moduleName!T, T.stringof, f, getPathFromMethod!(T, f)),
				                        getCheckFuncOfRoute!(T, f), getFuncOfRoute!(T, f));
			} else {
				getURLRouter().register(new RouteInformation(getRouteTypeFromMethod!(T, f), moduleName!T, T.stringof, f, getPathFromMethod!(T, f)),
				                        getCheckFuncOfRoute!(T, f), getFuncOfRoute!(T, f));
			}
			
			routeOutput ~= getRouteTypeFromMethod!(T, f)() ~ ":" ~ T.stringof ~ "." ~ f ~ ":" ~ getPathFromMethod!(T, f)() ~ "\n";
		}
	}
	
	append(ofile, "=======-----=======\n" ~ routeOutput);
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
bool delegate() getCheckFuncOfRoute(T, string m)() {
	bool func() {
		string[string] params;
		mixin("import " ~ moduleName!T ~ ";");
		mixin(handleCheckofRoute!(getRouteTypeFromMethod!(T, m), getPathFromMethod!(T, m)));
		http_request.params = params;
		
		static if (hasFilters!(T, m)) {
			foreach(filter; getFiltersFromMethod(T, m)) {
				if (!filter()) {
					return false;
				}
			}
		}
		
		return true;
	}
	
	return &func;
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
bool delegate() getCheckFuncOfRoute(RouteType type, string path)() {
	bool func() {
		string[string] params;
		mixin(handleCheckofRoute!(type, path));
		http_request.params = params;
		return true;
	}
	
	return &func;
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
pure void delegate() getFuncOfRoute(T, string m)() {
	void func() {
		T t = new T;
		static if (useRenderOptionalFunc!(T, m)) {
			if (mixin("t." ~ m)()) {
				enum isFirstExecute = false;
				http_response.render!(getRouteTemplate!(T, f)() ~ ".dt", currentRoute, isFirstExecute);
			}
		} else {
			mixin("t." ~ m)();
		}
	}
	
	return &func;
}

/**
 * Upon adding a template for a specific route execute it, this is used for e.g. getting all widgets
 */
pure void handleFirstExecute(T, string f)() {
	enum isFirstExecute = true;
	auto currentRoute = RouteInformation(getRouteTypeFromMethod!(T, f)(), moduleName!T, T.stringof, f, getPathFromMethod!(T, f)());
	compileDietFile!(getRouteTemplate!(T, f)() ~ ".dt", currentRoute, isFirstExecute)(new MemoryOutputStream());
}