module cmsed.base.internal.routing.function_handler;
import cmsed.base.internal.routing.function_checks;
import cmsed.base.routing.defs;
import cmsed.base.registration.pipeline;
import cmsed.base.util;
import cmsed.base.mimetypes;
import vibe.d : Json, HTTPMethod, HTTPStatus;
import std.traits : isSomeString, ReturnType, moduleName, isBasicType, ParameterIdentifierTuple, ParameterTypeTuple;
import std.conv : to;

/**
 * Creates a delegate specifically for checking if a route is current
 */
void delegate() getFuncOfRoute(alias SYMBL)() {
    void func() {
        static if (is(ReturnType!SYMBL : Json)) {
            pipelineHandle(mixin("SYMBL(" ~ paramsGot!SYMBL ~ ")"));
        } else static if (is(ReturnType!SYMBL : IRouterReturnable) || is(ReturnType!SYMBL == RouterReturnable) || (__traits(compiles, { mixin("SYMBL(" ~ paramsGot!SYMBL ~ ")").handleReturn(); }))) {
            mixin("SYMBL(" ~ paramsGot!SYMBL ~ ")").handleReturn();
        } else static if (isSomeString!(ReturnType!SYMBL)) {
            pipelineHandle(getTemplateForType("html"), mixin("SYMBL(" ~ paramsGot!SYMBL ~ ")"));
        } else {
            mixin("SYMBL(" ~ paramsGot!SYMBL ~ ");");
        }
    }
    
    return &func;
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
bool delegate() getCheckFuncOfRoute(RouteType type, string path)() {
    bool func() {
        mixin(handleCheckofRoute!(type, path));

        return true;
    }

    return &func;
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
bool delegate() getCheckFuncOfRoute(alias SYMBL, string file)() {
    bool func() {
        mixin("static import " ~ file ~ ";");
        mixin(handleCheckofRoute!(SYMBL, getRouteTypeFromFunction!SYMBL(), getPathFromFunction!SYMBL()));

        static if (hasFilters!SYMBL) {
            foreach(filter; getFiltersFromFunction!SYMBL) {
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
 * Generates code to check against a specified path.
 * Checks to make sure its valid.
 * If invalid input given, 400 out.
 * 
 * Supported paths for generations:
 *      /static/path
 *      /static/path/*
 *      /static/path/:myparam/:myparam2
 *      /static/path/:myparam/*
 * 
 * TODO:
 *      Arguments can be in any position. Aka /myurl/?q=:keyword&r=:something
 */
pure string handleCheckofRoute(alias SYMBL, RouteType type, string path)() {
    string ret;
    ret ~= "string[] pathSplit;\n";
    ret ~= "if (currentTransport.request.path.length > 1) pathSplit = currentTransport.request.path[1 .. $].split(\"/\");\n";
    
    static if (type == RouteType.Any) {
        ret ~= "if (true) {\n";
    } else static if (type == RouteType.Delete) {
        ret ~= "if (currentTransport.request.method == HTTPMethod.DELETE) {\n";
    } else static if (type == RouteType.Get) {
        ret ~= "if (currentTransport.request.method == HTTPMethod.GET) {\n";
    } else static if (type == RouteType.Post) {
        ret ~= "if (currentTransport.request.method == HTTPMethod.POST) {\n";
    } else static if (type == RouteType.Put) {
        ret ~= "if (currentTransport.request.method == HTTPMethod.PUT) {\n";
    } else {
        static assert(0, "A route must have either, Any, Delete, Get, Post or Put as a RouteType.");
    }
    
    size_t prevLength;
    size_t countSplit;
    
    string[] strSplit = path[1 .. $].split("/");
    ret ~= "    if (pathSplit.length == " ~ to!string(strSplit.length) ~ ") {\n";
    
F1: foreach(i, s; strSplit) {
        if (s.length > 0) {
            string iStr = to!string(i);
            
            switch(s[0]) {
                case ':':
                    ret ~= "        currentTransport.request.params[\"" ~ s[1 .. $] ~ "\"] = pathSplit[" ~ iStr ~ "];\n";
                    countSplit++;
                    break;
                case '*':
                    // we don't have to do anything here really.
                    break F1;
                default:
                    ret ~= "        if (pathSplit[" ~ iStr ~ "] != \"" ~ s ~ "\") return false;\n";
                    countSplit++;
                    break;
            }
        }
        
        prevLength += s.length;
    }
    
    ret ~= "    } else {\n";
    ret ~= "        return false;\n";
    ret ~= "    }\n";
    
    ret ~= "} else {\n";
    ret ~= "    return false;\n";
    ret ~= "}\n";

    // check types of values in arguments of function
    // return false if not valid.
    
    enum argN = ParameterIdentifierTuple!SYMBL;
    
    foreach(i, argT; ParameterTypeTuple!SYMBL) {
        static if (type == RouteType.Get)
            ret ~= "if (\"" ~ argN[i] ~ "\" !in currentTransport.request.query) {\n";
        else
            ret ~= "if (\"" ~ argN[i] ~ "\" !in currentTransport.request.params) {\n";
        ret ~= "    currentTransport.response.statusCode = HTTPStatus.badRequest;\n";
        ret ~= "    currentTransport.response.statusPhrase = \"Missing parameter: " ~ argN[i] ~ "\";";
        ret ~= "    return true;\n";
        ret ~= "}\n";
        
        static if (isSomeString!argT) {
        } else static if (isBasicType!argT) {
            ret ~= "try {\n";
            ret ~= "    " ~ argT.stringof ~ "value = to!(" ~ argT.stringof ~ ")(" ~ argN[i] ~ ");\n";
            ret ~= "} catch(Exception e) {\n";
            ret ~= "    currentTransport.response.statusCode = HTTPStatus.badRequest;\n";
            ret ~= "    currentTransport.response.statusPhrase = \"Parameter "~ argN[i] ~ " must be of type " ~ argT.stringof ~ "\";";
            ret ~= "    return true;\n";
            ret ~= "}\n";
        } else {
            ret ~= "return false;\n";
            static assert(0, "Cannot use type: " ~ argT.stringof ~ " as a route argument type");
        }
    }

    return ret;
}