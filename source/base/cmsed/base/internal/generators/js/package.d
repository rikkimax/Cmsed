module cmsed.base.internal.generators.js;
public import cmsed.base.internal.generators.js.defs;
public import cmsed.base.internal.generators.js.model;
public import cmsed.base.internal.generators.js.routes;

import cmsed.base.internal.registration.staticfiles;
import cmsed.base.registration.onload;

/**
 * Cyclic module constructor calls. Not cool. Hence moved.
 */

shared static this() {
	void jsLibraryFiles(bool isInstall) {
		registerStaticFile(pathToOOPHandler, cast(string)oopHandler, "javascript");
		registerStaticFile(pathToAjaxHandler, cast(string)ajaxHandler, "javascript");
		
		import std.file;
		append("out.txt", "hit\n");
		
		foreach(name; __traits(allMembers, OOPHandler)) {
			registerStaticFile(pathToLibraries ~ name, cast(string)__traits(getMember, OOPHandler, name), "javascript");
		}
		
		foreach(name; __traits(allMembers, AjaxHandler)) {
			registerStaticFile(pathToLibraries ~ name, cast(string)__traits(getMember, AjaxHandler, name), "javascript");
		}
	}
	
	registerOnLoad(&jsLibraryFiles);
}