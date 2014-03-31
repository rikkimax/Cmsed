module cmsed.base.internal.generators.js.routes.defs;
import cmsed.base.internal.generators.js.routes.generate;
import cmsed.base.internal.generators.js.routes.checks;
import cmsed.base.internal.generators.js.defs;
import cmsed.base.internal.registration.staticfiles;
import cmsed.base.registration.onload;
import cmsed.base.internal.restful.defs;
import dvorm.util;
import std.traits : isBasicType, isBoolean;
import std.functional : toDelegate;

struct GenerateData {
	string ret;
}

struct shouldNotGenerateJavascriptRoute {}
struct ignoreGenerateJavascriptRoute {}

struct jsRouteName {
	string name;
}

struct jsRouteParameters {
	/*this(string[] args ...) {
	 params = args;
	 }*/
	
	string[] params;
}

/**
 * Properties
 */

protected shared {
	string pathToRouteClasses = "/js/routes/";
	
	alias string delegate() modelBindingGetFunc;
	modelBindingGetFunc[string] bindingFuncs;
	
	bool disableGeneration = false;
	string pathToRestfulRoute = "/.svc/";
}

void pathOfRouteClasses(string path) {
	synchronized {
		pathToRouteClasses = path;
	}
}

void pathOfLibraries(string path) {
	synchronized {
		pathToLibraries = path;
	}
}

void disableJavascriptGeneration() {
	synchronized {
		disableGeneration = true;
	}
}

void pathOfRestfulRoute(string path) {
	synchronized {
		pathToRestfulRoute = path;
	}
}

/**
 * functions
 */

/**
 * Creates a javascript model from a data model
 * 
 * Compliant with a dvorm data model.
 * Wraps a dvorm query and hooking it via ajax.
 * 
 * Params:
 * 		T = 				The data model to be based upon
 * 		ajaxProtection = 	The restful protection to work with for generation
 * 		overrideChecks = 	Forces the generation of this model. Meant for manual generation
 */
void generateJavascriptRoute(T, bool overrideChecks = false)() {
	synchronized {
		static if (overrideChecks) {
			bindingFuncs[getJSRouteName!T] = toDelegate(cast(shared)&(generateJsFunc!(T)));
		} else static if (shouldGenerateJavascriptRoute!T) {
			if (!disableGeneration) {
				bindingFuncs[getJSRouteName!T] = toDelegate(cast(shared)&(generateJsFunc!(T)));
			}
		}
	}
}

shared static this() {
	void jsRoutes(bool isInstall) {
		foreach(name, value; bindingFuncs) {
			registerStaticFile(pathToRouteClasses ~ name, value(), "javascript");
		}
	}
	
	registerOnLoad(&jsRoutes);
}