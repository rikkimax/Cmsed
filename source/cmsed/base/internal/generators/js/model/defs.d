module cmsed.base.internal.generators.js.model.defs;
import cmsed.base.internal.registration.staticfiles;
import cmsed.base.registration.onload;

enum OOPHandler : string {
	JSFace2_2_0 = import("jsface2.2.0_min.js"),
	JSFace = JSFace2_2_0
}

enum AjaxHandler : string {
	Prototype1_7_1 = import("prototype1.7.1_min.js"),
	Prototype = Prototype1_7_1
}

/**
 * Properties
 */

private shared {
	string pathToOOPHandler = "/js/oopHandler";
	OOPHandler oopHandler = OOPHandler.JSFace;
	
	string pathToOOPClasses = "/js/models/";
	string pathToLibraries = "/js/";
	
	string pathToAjaxHandler = "/js/ajaxHandler";
	AjaxHandler ajaxHandler = AjaxHandler.Prototype;
}

void pathOfOOPHandler(string path) {
	synchronized {
		pathToOOPHandler = path;
	}
}

void setOopHandler(OOPHandler handler) {
	synchronized {
		oopHandler = handler;
	}
}

void pathOfOOPClasses(string path) {
	synchronized {
		pathToOOPClasses = path;
	}
}

void pathOfLibraries(string path) {
	synchronized {
		pathToLibraries = path;
	}
}

void pathOfAjaxHandler(string path) {
	synchronized {
		pathToAjaxHandler = path;
	}
}

void setAjaxHandler(AjaxHandler handler) {
	synchronized {
		ajaxHandler = handler;
	}
}

/**
 * functions
 */

void generateJavascriptModel(T)() {
	synchronized {
		
	}
}

shared static this() {
	void jsModel(bool isInstall) {
		registerStaticFile(pathToOOPHandler, cast(string)oopHandler, null);
		registerStaticFile(pathToAjaxHandler, cast(string)ajaxHandler, null);
		
		foreach(name; __traits(allMembers, OOPHandler)) {
			registerStaticFile(pathToLibraries ~ name, cast(string)__traits(getMember, OOPHandler, name), null);
		}
		
		foreach(name; __traits(allMembers, AjaxHandler)) {
			registerStaticFile(pathToLibraries ~ name, cast(string)__traits(getMember, AjaxHandler, name), null);
		}
	}
	
	registerOnLoad(&jsModel);
}