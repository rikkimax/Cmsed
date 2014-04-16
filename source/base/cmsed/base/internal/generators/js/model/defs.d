module cmsed.base.internal.generators.js.model.defs;
import cmsed.base.internal.generators.js.model.generate;
import cmsed.base.internal.generators.js.defs;
import cmsed.base.internal.registration.staticfiles;
import cmsed.base.registration.onload;
import cmsed.base.internal.restful.defs;
import dvorm.util;
import std.traits : isBasicType, isBoolean;
import std.functional : toDelegate;

struct GenerateData {
	string ret;
	string constructorArgs;
	string constructorSet;
	string props;
	
	string saveprop;
	string savepropParams;
	
	string removeprop;
	
	string findOneArgs;
	string findOneSet;
	string findOneSetArgs;
	
	string queryCreator;
	string queryParameters;
}

struct shouldNotGenerateJavascriptModel {}
struct ignoreGenerateJavascriptModel {}

/**
 * Properties
 */

protected shared {
	string pathToOOPClasses = "/js/models/";
	
	alias string delegate() modelBindingGetFunc;
	modelBindingGetFunc[string] bindingFuncs;
	
	bool disableGeneration = false;
	string pathToRestfulRoute = "/.svc/";
}

void pathOfOOPClasses(string path) {
	synchronized {
		pathToOOPClasses = path;
	}
}

void pathOfAjaxHandler(string path) {
	synchronized {
		pathToAjaxHandler = path;
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
void generateJavascriptModel(T, ushort ajaxProtection = RestfulProtection.All, bool overrideChecks = false)() {
	synchronized {
		static if (overrideChecks) {
			bindingFuncs[getTableName!T] = toDelegate(cast(shared)&(generateJsFunc!(T, ajaxProtection)));
		} else static if (shouldGenerateJavascriptModel!T) {
			if (!disableGeneration) {
				bindingFuncs[getTableName!T] = toDelegate(cast(shared)&(generateJsFunc!(T, ajaxProtection)));
			}
		}
	}
}

pure bool shouldGenerateJavascriptModel(T)() {
	foreach(UDA; __traits(getAttributes, T)) {
		static if (is(UDA == shouldNotGenerateJavascriptModel)) {
			return false;
		}
	}
	return true;
}

pure bool shouldIgnoreGenerateJavascriptModel(T, string m)() {
	T c = newValueOfType!T;
	
	static if (__traits(compiles, __traits(getProtection, mixin("c." ~ m))) &&
	           __traits(getProtection, mixin("c." ~ m)) == "public") {
		foreach(UDA; __traits(getAttributes, mixin("c." ~ m))) {
			static if (is(UDA : ignoreGenerateJavascriptModel)) {
				return true;
			}
		}
		return false;
	} else {
		return true;
	}
}

shared static this() {
	void jsModel(bool isInstall) {
		foreach(name, value; bindingFuncs) {
			registerStaticFile(pathToOOPClasses ~ name, value(), "javascript");
		}
	}
	
	registerOnLoad(&jsModel);
}