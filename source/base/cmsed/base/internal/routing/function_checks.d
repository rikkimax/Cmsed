module cmsed.base.internal.routing.function_checks;
import cmsed.base.udas;
import std.traits : ParameterIdentifierTuple, ParameterTypeTuple;

pure bool isARouteFunction(alias SYMBL)() {
    static if (is(typeof(SYMBL) == function) || is(typeof(SYMBL) == delegate)) {
        foreach(UDA; __traits(getAttributes, SYMBL)) {
            static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
                return true;
            }
        }
    }
    
    return false;
}

pure RouteType getRouteTypeFromFunction(alias SYMBL)() {
    foreach(UDA; __traits(getAttributes, SYMBL)) {
        static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
            return UDA.type;
        }
    }
    
    return RouteType.Any;
}

pure string getPathFromFunction(alias SYMBL)() {
    string ret;
    foreach(UDA; __traits(getAttributes, SYMBL)) {
        static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
            if (UDA.route != "")
                ret ~= UDA.route;
        } else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
            if (UDA.routeBase != "")
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

pure bool isErrorRoute(alias SYMBL)() {
    foreach(UDA; __traits(getAttributes, SYMBL)) {
        static if (__traits(compiles, {RouteErrorHandler rf = UDA; } )) {
            return true;
        }
    }
    
    return false;
}

pure int getErrorRouteError(alias SYMBL)() {
    foreach(UDA; __traits(getAttributes, SYMBL)) {
        static if (__traits(compiles, {RouteErrorHandler rf = UDA; } )) {
            return rf.error;
        }
    }
    
    return 0;
}

/**
 * 
 */
pure string paramsGot(alias SYMBL)() {
    string ret;
    
    enum argN = ParameterIdentifierTuple!SYMBL;
    enum isGet = getRouteTypeFromFunction!SYMBL == RouteType.Get;

    foreach(i, argT; ParameterTypeTuple!SYMBL) {
        if (is(argT == string) || is(argT == dstring) || is(argT == wstring)) {
            static if (isGet)
                ret ~= "cast(" ~ argT.stringof ~ ")currentTransport.request.query[\"" ~ argN[i] ~ "\"], ";
            else
                ret ~= "cast(" ~ argT.stringof ~ ")currentTransport.request.params[\"" ~ argN[i] ~ "\"], ";
        } else {
            static if (isGet)
                ret ~= "to!" ~ argT.stringof ~ "(currentTransport.request.query[\"" ~ argN[i] ~ "\"]), ";
            else
                ret ~= "to!" ~ argT.stringof ~ "(currentTransport.request.params[\"" ~ argN[i] ~ "\"]), ";
        }
    }
    
    if (ret.length > 0) {
        ret.length -= 2;
    }
    
    return ret;
}

pure bool hasFilters(alias SYMBL)() {
    foreach(UDA; __traits(getAttributes, SYMBL)) {
        static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
            if (UDA.filterFunction !is null)
                return true;
        } else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
            if (UDA.filterFunction !is null)
                return true;
        }
    }
    
    return false;
}

pure RouteFilter[] getFiltersFromFunction(alias SYMBL)() {
    RouteFilter[] ret;
    foreach(UDA; __traits(getAttributes, SYMBL)) {
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