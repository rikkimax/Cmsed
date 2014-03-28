module cmsed.base.internal.generators.js.defs;

/**
 * Constants
 */
enum OOPHandler : string {
	JSFace2_2_0 = import("jsface2.2.0.js"),
	JSFace = JSFace2_2_0
}

enum AjaxHandler : string {
	Prototype1_7_1 = import("prototype1.7.1.js"),
	Prototype = Prototype1_7_1
}

/**
 * Properties yay
 */

shared {
	OOPHandler oopHandler = OOPHandler.JSFace;
	AjaxHandler ajaxHandler = AjaxHandler.Prototype;
	string pathToLibraries = "/js/";
	
	string pathToOOPHandler = "/js/oopHandler";
	string pathToAjaxHandler = "/js/ajaxHandler";
}