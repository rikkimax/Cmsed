module cmsed.base.registration.onload;
import cmsed.base.registration.model;
import cmsed.base.registration.routes;

/**
 * Registers functions to be executed pre update registration and listening.
 */

private shared {
	alias void delegate(bool isInstall) runOnLoadFunc;
	
	runOnLoadFunc[] runOnLoadFuncs;
}

/**
 * Registers functions to be executed upon load aka pre socket listening.
 * This can be utilised to modify data models.
 * 
 * The function is passed wheather its an install node or a production mode.
 * This enables only install based addition e.g. example data to be added.
 */
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