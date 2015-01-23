module cmsed.base.registration.routes;
import cmsed.base.routing.defs;
import cmsed.base.config;
import cmsed.base.internal.routing.class_parser;
import cmsed.base.internal.routing.class_checks;
import cmsed.base.internal.routing.function_parser;
import cmsed.base.internal.routing.function_checks;
//TODO: import cmsed.base.internal.generators.js.routes.defs;
import std.file : write;

/**
 * Registers routes to be configured at runtime for their urlRouter.
 */

private shared {
    alias void function() configureRouteFunc;
    
    configureRouteFunc[] configureRouteFuncs;
    configureRouteFunc[] configureInstallRouteFuncs;
}

/**
 * Registers a route class
 */
void registerRoute(C)() if (isARouteClass!C) {
    synchronized {
        static if (is(C : OORoute) || is(C : OOAnyRoute)) {
            configureRouteFuncs ~= &registerRouteHandler!C;
        }
        static if (is(C : OOInstallRoute) || is(C : OOAnyRoute)) {
            configureInstallRouteFuncs ~= &registerRouteHandler!C;
        }
        
        //TODO: generateJavascriptRoute!C;
    }
}

/**
 * Registers a route (free function)
 */
void registerRoute(alias SYMBL, string file)() if (isARouteFunction!SYMBL) {
    synchronized {
		static if (isARouteOnInstallFunction!SYMBL)
			configureInstallRouteFuncs ~= &registerRouteHandler!(SYMBL, file);
		else
			configureRouteFuncs ~= &registerRouteHandler!(SYMBL, file);

        //TODO: generateJavascriptRoute!SYMBL;
    }
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */

void configureRoutes(bool isInstall) {
    synchronized {
        string ofile = buildPath(configuration.logging.dir, configuration.logging.routeFile);
        write(ofile,"");
        
        foreach(func; isInstall ? configureInstallRouteFuncs : configureRouteFuncs) {
            func();
        }
    }
}