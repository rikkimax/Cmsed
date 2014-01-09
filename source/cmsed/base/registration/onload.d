module cmsed.base.registration.onload;
import cmsed.base.registration.model;
import cmsed.base.registration.routes;

/**
 * Registers functions to be executed pre update registration and listening.
 */

private shared {
	alias void function(bool isInstall) runOnLoadFunc;
	
	runOnLoadFunc[] runOnLoadFuncs;
}

void registerOnLoad(runOnLoadFunc func) {
	synchronized {
		runOnLoadFuncs ~= func;
	}
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */
void runOnLoad(bool isInstall) {
	synchronized {
		configureModels();
		configureRoutes(isInstall);
		
		foreach(func; runOnLoadFuncs) {
			func(isInstall);
		}
	}
}