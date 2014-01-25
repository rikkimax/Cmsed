module cmsed.base.registration.routes;
import cmsed.base.registration.widgetroute;
import cmsed.base.config;
import cmsed.base.routing;
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
 * Registers a route class to be listend for when in production mode.
 */
void registerRoute(C : OORoute)() {
	synchronized {
		configureRouteFuncs ~= &registerRouteHandler!C;
	}
}

/**
 * Registers a route class to be listend for when in install mode.
 * Allows for having an installer.
 */
void registerRoute(C : OOInstallRoute)() {
	synchronized {
		configureInstallRouteFuncs ~= &registerRouteHandler!C;
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
		
		outputWidgets();
	}
}