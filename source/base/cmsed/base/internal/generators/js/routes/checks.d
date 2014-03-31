module cmsed.base.internal.generators.js.routes.checks;
import cmsed.base.internal.generators.js.routes.defs;
import dvorm.util;
import std.traits : ParameterIdentifierTuple;

pure bool shouldGenerateJavascriptRoute(T)() {
	foreach(UDA; __traits(getAttributes, T)) {
		static if (is(UDA == shouldNotGenerateJavascriptRoute)) {
			return false;
		}
	}
	return true;
}

pure bool shouldIgnoreGenerateJavascriptRoute(T, string m)() {
	T c = newValueOfType!T;
	
	static if (__traits(compiles, __traits(getProtection, mixin("c." ~ m))) &&
	           __traits(getProtection, mixin("c." ~ m)) == "public") {
		foreach(UDA; __traits(getAttributes, mixin("c." ~ m))) {
			static if (is(UDA : ignoreGenerateJavascriptRoute)) {
				return true;
			}
		}
		return false;
	} else {
		return true;
	}
}

pure string getJSRouteName(C)() {
	foreach(UDA; __traits(getAttributes, C)) {
		static if (__traits(compiles, {jsRouteName rf = UDA; } )) {
			return UDA.name;
		}
	}
	
	return C.stringof;
}

pure string[] getRouteParams(C, string f)() {
	C c = new C;
	string[] ret;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {jsRouteParameters rp = UDA;})) {
			ret ~= UDA.params;
		}
	}
	
	if (ret.length == 0) {
		foreach(arg; ParameterIdentifierTuple!(__traits(getMember, C, f))) {
			ret ~= arg;
		}
	}
	
	return ret;
}