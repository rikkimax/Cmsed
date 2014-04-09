module cmsed.base.internal.routing.checks;
import cmsed.base.internal.routing.defs;
import cmsed.base.util : split;
import std.conv : to;
import std.traits : ParameterTypeTuple, ParameterIdentifierTuple, isBasicType, ReturnType;

pure RouteType getRouteTypeFromMethod(C, string f)() {
	C c = new C;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			return UDA.type;
		}
	}
	
	return RouteType.Any;
}

pure string getRouteTemplate(C, string f)() {
	C c = new C;
	
	string ret = null;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			static if (UDA.templateName !is null)
				return UDA.templateName;
		} else static if (__traits(compiles, {RouteTemplate rf = UDA; } )) {
			ret = UDA.templateName;
		}
	}
	return ret;
}

pure bool useRenderOptionalFunc(C, string f)() {
	static if (__traits(hasMember, Object, f)) {
		return false;
	}
	
	C c = new C;
	
	static if (is(ReturnType!(mixin("c." ~ f)) == bool)) {
		return true;
	} else {
		return false;
	}
}

pure string getPathFromMethod(C, string f)() {
	C c = new C;
	
	string ret;
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			static if (UDA.route != "")
				ret ~= UDA.route;
		} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
			static if (UDA.routeBase != "")
				ret ~= UDA.routeBase;
		} else static if (__traits(compiles, {RouteGroupId rf = UDA; } )) {
			ret ~= "/:" ~ UDA.routeName;
		} else static if (__traits(compiles, {RouteGroupIds rf = UDA; } )) {
			foreach(rn; UDA.routeNames) {
				ret ~= "/:" ~ rn;
			}
		}
	}
	return ret;
}

pure RouteFilter[] getFiltersFromMethod(C, string f)() {
	C c = new C;
	
	RouteFilter[] ret;
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			static if (UDA.filterFunction !is null)
				ret ~= UDA.filterFunction;
		} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
			static if (UDA.filterFunction !is null)
				ret ~= UDA.filterFunction;
		}
	}
	return ret;
}

pure bool hasFilters(C, string f)() {
	C c = new C;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			static if (UDA.filterFunction !is null)
				return true;
		} else static if (__traits(compiles, {RouteGroup rf = UDA; } )) {
			static if (UDA.filterFunction !is null)
				return true;
		}
	}
	
	return false;
}

pure bool isRoute(C, string f)() {
	C c = new C;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteFunction rf = UDA; } )) {
			return true;
		}
	}
	
	return false;
}

pure bool isErrorRoute(C, string f)() {
	C c = new C;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteErrorHandler rf = UDA; } )) {
			return true;
		}
	}
	
	return false;
}

pure int getErrorRouteError(C, string f)() {
	C c = new C;
	
	foreach(UDA; __traits(getAttributes, mixin("c." ~ f))) {
		static if (__traits(compiles, {RouteErrorHandler rf = UDA; } )) {
			return rf.error;
		}
	}
	
	return 0;
}

/**
 * Does the given class have either, OORoute/OOInstallRoute or OOAnyRoute on it?
 */
pure bool isARouteClass(T)() {
	static if (is(T : OORoute) || is(T : OOInstallRoute) || is(T : OOAnyRoute)) {
		return true;
	} else {
		return false;
	}
}

/**
 * Generates code to check against a specified path.
 * Checks to make sure its valid.
 * If invalid input given, 400 out.
 * 
 * Supported paths for generations:
 * 		/static/path
 * 		/static/path/*
 * 		/static/path/:myparam/:myparam2
 * 		/static/path/:myparam/*
 */
pure string handleCheckofRoute(T, string m, RouteType type, string path, T t = new T)() {
	string ret;
	ret ~= "string[] pathSplit;\n";
	ret ~= "if (http_request.path.length > 1) pathSplit = http_request.path[1 .. $].split(\"/\");\n";
	//ret ~= "string[string] params;";
	
	static if (type == RouteType.Any) {
		ret ~= "if (true) {\n";
	} else static if (type == RouteType.Delete) {
		ret ~= "if (http_request.method == HTTPMethod.DELETE) {\n";
	} else static if (type == RouteType.Get) {
		ret ~= "if (http_request.method == HTTPMethod.GET) {\n";
	} else static if (type == RouteType.Post) {
		ret ~= "if (http_request.method == HTTPMethod.POST) {\n";
	} else static if (type == RouteType.Put) {
		ret ~= "if (http_request.method == HTTPMethod.PUT) {\n";
	} else {
		static assert(0, "A route must have either, Any, Delete, Get, Post or Put as a RouteType.");
	}
	
	size_t prevLength;
	size_t countSplit;
	
	string[] strSplit = path[1 .. $].split("/");
	ret ~= "    if (pathSplit.length == " ~ to!string(strSplit.length) ~ ") {\n";
	
F1: foreach(i, s; strSplit) {
		if (s.length > 0) {
			string iStr = to!string(i);
			
			switch(s[0]) {
				case ':':
					ret ~= "        params[\"" ~ s[1 .. $] ~ "\"] = pathSplit[" ~ iStr ~ "];\n";
					countSplit++;
					break;
				case '*':
					// we don't have to do anything here really.
					break F1;
				default:
					ret ~= "        if (pathSplit[" ~ iStr ~ "] != \"" ~ s ~ "\") return false;\n";
					countSplit++;
					break;
			}
		}
		
		prevLength += s.length;
	}
	
	ret ~= "    } else {\n";
	ret ~= "        return false;\n";
	ret ~= "    }\n";
	
	ret ~= "} else {\n";
	ret ~= "    return false;\n";
	ret ~= "}\n";
	
	
	// check types of values in arguments of function
	// return false if not valid.
	
	enum argN = ParameterIdentifierTuple!(__traits(getMember, t, m));
	
	foreach(i, argT; ParameterTypeTuple!(__traits(getMember, t, m))) {
		ret ~= "if (\"" ~ argN[i] ~ "\" !in http_request.query) {\n";
		ret ~= "    http_response.statusCode = HTTPStatus.badRequest;\n";
		ret ~= "    http_response.statusPhrase = \"Missing parameter: " ~ argN[i] ~ "\";";
		ret ~= "    return true;\n";
		ret ~= "}\n";
		
		static if (is(argT == string) || is(argT == dstring) || is(argT == wstring)) {
		} else static if (isBasicType!argT) {
			ret ~= "try {\n";
			ret ~= "    " ~ argT.stringof ~ "value = to!(" ~ argT.stringof ~ ")(" ~ argN[i] ~ ");\n";
			ret ~= "} catch(Exception e) {\n";
			ret ~= "    http_response.statusCode = HTTPStatus.badRequest;\n";
			ret ~= "    http_response.statusPhrase = \"Parameter "~ argN[i] ~ " must be of type " ~ argT.stringof ~ "\";";
			ret ~= "    return true;\n";
			ret ~= "}\n";
		} else {
			ret ~= "return false;\n";
			static assert(0, "Cannot use type: " ~ argT.stringof ~ " as a route argument type");
		}
	}
	
	
	return ret;
}

/**
 * 
 */
pure string paramsGot(T, string m, T t = new T)() {
	string ret;
	
	enum argN = ParameterIdentifierTuple!(__traits(getMember, t, m));
	foreach(i, argT; ParameterTypeTuple!(__traits(getMember, t, m))) {
		if (is(argT == string) || is(argT == dstring) || is(argT == wstring)) {
			ret ~= "cast(" ~ argT.stringof ~ ")http_request.query[\"" ~ argN[i] ~ "\"], ";
		} else {
			ret ~= "to!" ~ argT.stringof ~ "(http_request.query[\"" ~ argN[i] ~ "\"]), ";
		}
	}
	
	if (ret.length > 0) {
		ret.length -= 2;
	}
	
	return ret;
}