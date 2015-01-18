module cmsed.base.internal.routing.class_handler;
import cmsed.base.internal.routing.function_handler;
import cmsed.base.internal.routing.function_checks;
import cmsed.base.internal.routing.class_checks;
import cmsed.base.routing.defs;
import cmsed.base.registration.pipeline;
import cmsed.base.util;
import cmsed.base.mimetypes;
import vibe.d : Json;
import std.traits : isSomeString, ReturnType, moduleName, isBasicType, ParameterIdentifierTuple, ParameterTypeTuple;

/**
 * Creates a delegate specifically for checking if a route is current
 */
void delegate() getFuncOfRoute(T, string m, alias rFunc)() {
    T t = new T;

    void func() {
        static if (is(ReturnType!(mixin("t." ~ m)) : Json)) {
            pipelineHandle(getTemplateForType("json"), mixin("t." ~ m ~ "(" ~ paramsGot!rFunc ~ ")"));
        } else static if (is(ReturnType!(mixin("t." ~ m)) : IRouterReturnable) || is(ReturnType!SYMBL == RouterReturnable)) {
            mixin("t." ~ m ~ "(" ~ paramsGot!SYMBL ~ ")").handleReturn();
        } else static if (isSomeString!(ReturnType!(mixin("t." ~ m)))) {
            pipelineHandle(getTemplateForType("html"), mixin("t." ~ m ~ "(" ~ paramsGot!rFunc ~ ")"));
        } else {
            mixin("t." ~ m ~ "(" ~ paramsGot!rFunc ~ ");");
        }
    }
    
    return &func;
}

/**
 * Creates a delegate specifically for checking if a route is current
 */
bool delegate() getCheckFuncOfRoute(T, string m, alias rFunc)() {
    bool func() {
        string[string] params;
        mixin("static import " ~ moduleName!T ~ ";");
        mixin(handleCheckofRoute!(rFunc, getRouteTypeFromFunction!rFunc(), getPathFromFunction!rFunc()));
        currentTransport.request.params = params;
        
        static if (hasFilters!rFunc()) {
            foreach(filter; getFiltersFromFunction!rFunc) {
                if (!filter()) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    return &func;
}