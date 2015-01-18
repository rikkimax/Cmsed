module cmsed.base.internal.restful.create;
import cmsed.base.restful;
import cmsed.base.internal.routing;
import vibe.data.json;
import dvorm;
import std.traits : moduleName;

/**
 * Creates a route dedicated to creating data, and saving to the database.
 */
pure string createRestfulData(TYPE)() {
	string ret;
	TYPE type = newValueOfType!TYPE;
	
	ret ~= """
#line 1 \"cmsed.base.internal.restful.create." ~ TYPE.stringof ~ "\"
@RouteFunction(RouteType.Put, \"/" ~ getTableName!TYPE ~ "\")
@JsRouteParameters([" ~ valueOps!TYPE ~ "])
void handleRestfulData" ~ TYPE.stringof ~ "Create() {
    import " ~ moduleName!TYPE ~ ";
    auto value = newValueOfType!" ~ TYPE.stringof ~ ";
    string formVal;
""";
	
	foreach (m; __traits(allMembers, TYPE)) {
		static if (isUsable!(TYPE, m)() && !shouldBeIgnored!(TYPE, m)()) {
			static if (is(typeof(mixin("type." ~ m)) : Object)) {
				foreach (n; __traits(allMembers, typeof(mixin("type." ~ m)))) {
					static if (isUsable!(typeof(mixin("type." ~ m)), n)() && !shouldBeIgnored!(typeof(mixin("type." ~ m)), n)()) {
						static if (is(typeof(mixin("type." ~ m ~ "." ~ n)) == string) ||
						           is(typeof(mixin("type." ~ m ~ "." ~ n)) == dstring) ||
						           is(typeof(mixin("type." ~ m ~ "." ~ n)) == wstring)) {
							ret ~= """
    formVal = currentTransport.request.form.get(\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "\", null);
    if (formVal !is null)
        value." ~ m ~ "." ~ n ~ " = cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")formVal;
""";
						} else static if (typeof(mixin("type." ~ m ~ "." ~ n)).stringof != "void") {
							ret ~= """
    formVal = currentTransport.request.form.get(\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "\", null);
    if (formVal !is null)
        value." ~ m ~ "." ~ n ~ " = to!(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")(formVal);
""";
						}
					}
				}
			} else static if (is(typeof(mixin("type." ~ m)) == string) ||
			                  is(typeof(mixin("type." ~ m)) == dstring) ||
			                  is(typeof(mixin("type." ~ m)) == wstring)) {
				ret ~= """
    formVal = currentTransport.request.form.get(\"" ~ getNameValue!(TYPE, m) ~ "\", null);
    if (formVal !is null)
        value." ~ m ~ " = cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")formVal;
""";
			} else static if (typeof(mixin("type." ~ m)).stringof != "void") {
				ret ~= """
    formVal = currentTransport.request.form.get(\"" ~ getNameValue!(TYPE, m) ~ "\", null);
    if (formVal !is null)
        value." ~ m ~ " = to!(" ~ typeof(mixin("type." ~ m)).stringof ~ ")(formVal);
""";
			}
		}
	}
	
	static if (__traits(hasMember, TYPE, "canCreate") && typeof(&type.canView).stringof == "bool delegate()") {
		ret ~= "\n    if (value.canCreate()) {";
	} else {
		ret ~= "\n    static if (true) {";
	}
	
	ret ~= """
        value.save();
        currentTransport.response.writeVoidBody();
    }
""";
	ret ~= """
}
""";
	
	return ret;
}

private {
	pure string valueOps(T)() {
		string ret;
		foreach (m; __traits(allMembers, T)) {
			static if (isUsable!(T, m)() && !shouldBeIgnored!(T, m)()) {
				static if (is(typeof(__traits(getMember, T, m)) : Object)) {
					
					foreach (n; __traits(allMembers, typeof(__traits(getMember, T, m)))) {
						static if (isUsable!(typeof(__traits(getMember, T, m)), n)) {
							ret ~= "\"" ~ getNameValue!(T, m) ~ "_" ~ getNameValue!(typeof(__traits(getMember, T, m)), n) ~ "\", ";
						}
					}
					
				} else {
					ret ~= "\"" ~ getNameValue!(T, m) ~ "\", ";
				}
			}
		}
		
		if (ret.length > 0)
			ret.length -= 2;
		
		return ret;
	}
}