module cmsed.base.internal.routing.class_parser;
import cmsed.base.internal.routing.class_checks;
import cmsed.base.internal.routing.function_handler;
import cmsed.base.internal.routing.function_checks;
import cmsed.base.internal.routing.class_handler;
import cmsed.base.config : configuration;
import cmsed.base.routing.defs;

import std.file : append, write;
import std.traits : moduleName;
import std.path : buildPath;

/**
 * Registers a route given a class
 */
void registerRouteHandler(T)() if (isARouteClass!T()) {
    string routeOutput = "";
    string ofile = buildPath(configuration.logging.dir, configuration.logging.routeFile);

    T t = new T;
    
    foreach(string f; __traits(allMembers, T)) {
        mixin("alias rFunc = t." ~ f ~ ";");

        static if (isARouteFunction!rFunc()) {
            RouteInformation routeInfo = new RouteInformation(getRouteTypeFromFunction!rFunc, moduleName!T, T.stringof, f, getPathFromFunction!rFunc);

            static if (isErrorRoute!rFunc) {
                getRouter().register(getErrorRouteError!rFunc(), routeInfo, getCheckFuncOfRoute!(T, f, rFunc)(), getFuncOfRoute!(T, f, rFunc)());
            } else {
                getRouter().register(routeInfo, getCheckFuncOfRoute!(T, f, rFunc)(), getFuncOfRoute!(T, f, rFunc)());
            }
            
            routeOutput ~= getRouteTypeFromFunction!rFunc ~ ":" ~ T.stringof ~ "." ~ f ~ ":" ~ getPathFromFunction!rFunc() ~ "\n";
        }
    }
    
    append(ofile, "=======-----=======\n" ~ routeOutput);
}