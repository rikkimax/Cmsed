module cmsed.base.internal.generators.js.routes.generate;
import cmsed.base.internal.generators.js.routes.defs;
//import cmsed.base.internal.generators.js.routes.prototype;
import cmsed.base.internal.generators.js.defs;
import cmsed.base.internal.routing.checks;
import dvorm.util;
import std.traits : isBasicType, isBoolean;

string generateJsFunc(T)() {
	T t = newValueOfType!T;
	
	string output;
	
	foreach(m; __traits(allMembers, T)) {
		static if (isRoute!(T, m)) {
			static if (!shouldIgnoreGenerateJavascriptRoute!(T, m)) {
				output ~= handleClassProperty!(T, m)();
			}
		}
	}
	
	return output;
}


/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
string handleClassProperty(T, string m, // params
                           T t = newValueOfType!T // meta info that is needed but not available inside the function
                           )() {
	string ret;
	/*switch(ajaxHandler) {
	 case AjaxHandler.Prototype:
	 handleClassPropertyPrototype!(T, ajaxProtection, m)(data);
	 break;
	 default:
	 break;
	 }*/
	return ret;
}