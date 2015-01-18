module cmsed.base.registration.autoregister;

private {
    string[] autoRegisterModules;
}

void autoRegister(string DFILE)() {
    import std.algorithm : canFind;
    import cmsed.base.registration.model : isDataModel, registerModel;
    import cmsed.base.registration.routes : registerRoute;
    import cmsed.base.internal.routing.class_checks : isARouteClass;
    import cmsed.base.internal.routing.function_checks : isARouteFunction;

    mixin("static import " ~ DFILE ~ ";");

    static if (ignorePackages(DFILE))
        return;
    else {
        if (autoRegisterModules.canFind(DFILE))
            return;

        autoRegisterModules ~= DFILE;

        foreach(SYMBL; __traits(allMembers, mixin(DFILE))) {
            static if (__traits(compiles, {mixin("alias symbl = " ~ DFILE ~ "." ~ SYMBL ~ ";");})) {

                mixin("alias symbl = " ~ DFILE ~ "." ~ SYMBL ~ ";");

                static if (__traits(compiles, { import cmsed.overrides.registration.autoregister;})) {
                    import overrides = cmsed.overrides.registration.autoregister;
                    overrides.autoRegister!(DFILE, SYMBL);
                }

                static if (is(symbl == class) || is(symbl == struct)) {
                    // class or struct

                    static if (isARouteClass!symbl) {
                        // register routes

                        registerRoute!symbl;
                    }

                    version(Have_Dakka_Base) {
                        // register actors

                        import dakka.base.defs;
                        import dakka.base.registration.actors;

                        static if (is(symbl : Actor)) {
                            registerActor!symbl;
                        }
                    }

                    static if (isDataModel!symbl) {
                        // register data models

                        registerModel!symbl;
                    }
                } else static if (__traits(compiles, {mixin("static import " ~ SYMBL ~ ";");}) &&
                                  __traits(compiles, {mixin("static import " ~ SYMBL ~ ";"); auto v = __traits(allMembers, mixin(SYMBL));})) {
                    // auto register modules

                    static if (!ignorePackages(SYMBL))
                        if (!autoRegisterModules.canFind(SYMBL))
                            autoRegister!SYMBL();
                } else static if (!__traits(compiles, {alias x = typeof(symbl);})) {
                } else static if (isARouteFunction!symbl) {
                    // free function / delegate pointer and is a route
                    registerRoute!(symbl, DFILE);
                }
            }
        }
    }
}

pure bool ignorePackages(string name) {
    import std.algorithm : startsWith;
    return name.startsWith("std.", "core.") ||
        name == "object";
}