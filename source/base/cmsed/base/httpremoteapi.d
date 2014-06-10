module cmsed.base.httpremoteapi;
import cmsed.base.internal.routing.defs;
import cmsed.base.internal.routing.checks;
import dvorm.util;
import std.traits;
import std.conv : to;
import cmsed.base.util : split;

/**
 * Creates a duck type that does an http request to a remote server.
 * Supports:
 * 		http/https
 * 		GET/POST
 * 		/myurl/:myarg/*
 * 
 * TODO:
 * 		DELETE/PUT
 */
final class RemoteAPI(T) if(isARouteClass!T) {
	private string __offsetURL;
	
	this(string offset) {
		__offsetURL = offset;
	}
	
	import vibe.d : Json, requestHTTP, HTTPMethod, readAllUTF8;
	
	mixin(handleRemoteAPI!T);
}

private {
	pure string handleRemoteAPI(T, T t = newValueOfType!T)() {
		string ret;
		
		foreach(m; __traits(allMembers, T)) {
			static if (isRoute!(T, m)) {					
				mixin("alias func = t." ~ m ~ ";"); 
				alias returnType = ReturnType!func;
				
				// decl
				ret ~= "    " ~ returnType.stringof;
				ret ~= " " ~ m ~ "(";
				
				size_t argCount = 0;
				
				foreach(i, a; ParameterTypeTuple!func) {
					ret ~= a.stringof ~ " arg" ~ to!string(i) ~ ", ";
					argCount++;
				}
				
				if (ret[$-2] == ',') {
					ret.length -= 2;
				}
				
				ret ~= ") {\n";
				// body
				static if (!is(returnType == void))
					ret ~= "        " ~ returnType.stringof ~ " ret;\n";
				
				ret ~= "        requestHTTP(__offsetURL ~ \"";
				
				// add the path here to ret
				size_t countOfPathArgs;
				
				enum path = getPathFromMethod!(T, m);
			F1: foreach(i, part; path.split("/")) {
					if (part.length > 0) {
						switch(part[0]) {
							case ':':
								ret ~= "/\" ~ arg" ~ to!string(i) ~ " ~ \"";
								countOfPathArgs++;
								break;
							case '*':
								for (size_t j = i; j < argCount; j++) {
									ret ~= "/\" ~ arg"~ to!string(j) ~ " ~ \"";
								}
								break F1;
							default:
								ret ~= "/" ~ part;
								break;
						}
					}
				}
				
				/*
				 * Query Paramaters for GET requests
				 */
				static if (getRouteTypeFromMethod!(T, m) == RouteType.Get) {
					string queryArgs;
					foreach(i, arg; ParameterIdentifierTuple!func) {
						if (!isArgInPath(path, arg)) {
							queryArgs ~= arg ~ "=\" ~ arg" ~ to!string(i) ~ " ~ \" & ";
						}
					}
					if (queryArgs.length > 0) {
						queryArgs.length -= 3;
						ret ~= "?" ~ queryArgs;
					}
				}
				
				ret ~= "\", (scope req) {\n";
				static if (getRouteTypeFromMethod!(T, m) == RouteType.Post) {
					ret ~= "            req.method = HTTPMethod.POST;\n";
					ret ~= "            req.writeJsonBody([";
					
					// add the arguments to the function with names.
					foreach(i, arg; ParameterIdentifierTuple!func) {
						if (!isArgInPath(path, arg))
							ret ~= "\"" ~ arg ~ "\": arg" ~ to!string(i) ~ ", ";
					}
					if (ret[$-2] == ',')
						ret.length -= 2;
					
					ret ~= "]);\n";
				}
				ret ~= "            }, (scope res) {\n";
				
				static if (isSomeString!returnType) {
					ret ~= "                ret = cast(" ~ returnType.stringof ~ ")res.bodyReader.readAllUTF8();\n";
				} else static if (is(returnType == Json)) {
					ret ~= "                ret = res.readJson();\n";
				} else static if (is(returnType == void)) {
					ret ~= "                res.dropBody();\n";
				} else {
					static assert(0, returnType.stringof ~ " cannot be used as a return type of a route for remote api");
				}
				ret ~= "            }\n";
				ret ~= "        );\n";
				
				// end
				static if (!is(returnType == void))
					ret ~= "        return ret;\n";
				ret ~= "    }\n";
			}
		}
		
		return ret;
	}
}