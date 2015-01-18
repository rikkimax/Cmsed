module cmsed.base.internal.routing.function_parser;
import cmsed.base.internal.routing.function_checks;
import cmsed.base.internal.routing.function_handler;
import cmsed.base.config : configuration;
import cmsed.base.routing.defs;

import std.file : append, write;
import std.path : buildPath;

/**
 * Registers a route given a function symbol
 */
void registerRouteHandler(alias SYMBL, string file)() if (isARouteFunction!SYMBL) {
    string routeOutput = "";
    string ofile = buildPath(configuration.logging.dir, configuration.logging.routeFile);

    RouteInformation routeInfo = new RouteInformation(getRouteTypeFromFunction!SYMBL, file, "", __traits(identifier, SYMBL), getPathFromFunction!SYMBL);

    static if (isErrorRoute!SYMBL) {
        getRouter().register(getErrorRouteError!SYMBL, routeInfo, getCheckFuncOfRoute!SYMBL, getFuncOfRoute!SYMBL);
    } else {
        getRouter().register(routeInfo, getCheckFuncOfRoute!(SYMBL, file), getFuncOfRoute!SYMBL);
    }
    
    routeOutput ~= getRouteTypeFromFunction!SYMBL ~ ":" ~ __traits(identifier, SYMBL) ~ ":" ~ getPathFromFunction!SYMBL ~ "\n";
    
    append(ofile, "=======-----=======\n" ~ routeOutput);
}