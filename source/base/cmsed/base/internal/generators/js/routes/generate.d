module cmsed.base.internal.generators.js.routes.generate;
import cmsed.base.internal.generators.js.routes.checks;
import cmsed.base.internal.generators.js.routes.prototype;
import cmsed.base.internal.generators.js.defs;
import cmsed.base.internal.routing.checks;
import std.traits : isBasicType, isBoolean;
import dvorm.util;

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


string handleClassProperty(T, string m, // params
                           T t = newValueOfType!T // meta info that is needed but not available inside the function
                           )() {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			return handleClassPropertyPrototype!(T, m)();
		default:
			break;
	}
	return "";
}