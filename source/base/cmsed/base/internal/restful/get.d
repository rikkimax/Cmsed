module cmsed.base.internal.restful.get;
import cmsed.base.internal.restful.defs;
import cmsed.base.internal.routing;
import vibe.data.json;
import dvorm;
import std.traits : moduleName;

/**
 * Dedicated to getting data models from the database.
 */
pure string getRestfulData(TYPE)() {
	string ret;
	TYPE type = newValueOfType!TYPE;
	
	ret ~= """
#line 1 \"cmsed.base.internal.restful.get." ~ TYPE.stringof ~ "\"
@RouteFunction(RouteType.Get, \"/" ~ getTableName!TYPE ~ "/:key\")
void handleRestfulData" ~ TYPE.stringof ~ "Get() {
    import " ~ moduleName!TYPE ~ ";
    auto value = " ~ TYPE.stringof ~ ".findOne(http_request.params[\"key\"]);
    if (value !is null) {
        """;
	static if (__traits(hasMember, TYPE, "canView") && typeof(&type.canView).stringof == "bool delegate()") {
		ret ~= "if (value.canView()) {";
	} else {
		ret ~= "static if (true) {";
	}
	ret ~= "
	    Json output = Json.emptyObject;\n";
	foreach (m; __traits(allMembers, TYPE)) {
		static if (isUsable!(TYPE, m)() && !shouldBeIgnored!(TYPE, m)()) {
			ret ~= "            output[\"" ~ getNameValue!(TYPE, m) ~ "\"] = outputRestfulTypeJson!(" ~ TYPE.stringof ~ ", \"" ~ m ~ "\")(value);\n";
		}
	}
	ret ~= """
            http_response.writeBody(output.toString());
        }
    }
}
""";
	return ret;
}

Json outputRestfulTypeJson(TYPE, string m)(TYPE value) {
	Json output = Json.emptyObject();
	
	static if (is(typeof(__traits(getMember, value, m)) : Object)) {
		static if (isUsable!(TYPE, m) && !shouldBeIgnored!(TYPE, m)) {
			foreach (n; __traits(allMembers, typeof(__traits(getMember, value, m)))) {
				static if (isUsable!(typeof(__traits(getMember, value, m)), n) && isAnId!(typeof(__traits(getMember, value, m)), n)) {
					
					static if ((is(typeof(mixin("value." ~ m ~ "." ~ n)) == string) ||
					            is(typeof(mixin("value." ~ m ~ "." ~ n)) == dstring) ||
					            is(typeof(mixin("value." ~ m ~ "." ~ n)) == wstring)) ||
					           typeof(mixin("value." ~ m ~ "." ~ n)).stringof != "void") {
						output[getNameValue!(typeof(mixin("value." ~ m)), n)] = mixin("value." ~ m ~ "." ~ n);
					}
					
				}
			}
		}
	} else static if ((is(typeof(__traits(getMember, value, m)) == string) ||
	                   is(typeof(__traits(getMember, value, m)) == dstring) ||
	                   is(typeof(__traits(getMember, value, m)) == wstring)) ||
	                  typeof(__traits(getMember, value, m)).stringof != "void") {
		output = __traits(getMember, value, m);
	}
	
	return output;
}