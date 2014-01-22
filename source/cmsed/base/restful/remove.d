module cmsed.base.restful.remove;
import cmsed.base.restful.defs;
import dvorm;
import std.traits : moduleName;

pure string removeRestfulData(TYPE)() {
	string ret;
	TYPE type = new TYPE;
	ret ~= """
#line 1 \"cmsed.base.restful.remove." ~ TYPE.stringof ~ "\"
@RouteFunction(RouteType.Delete, \"/" ~ getTableName!TYPE ~ "/:key\")
void handleRestfulData" ~ TYPE.stringof ~ "Delete() {
    import " ~ moduleName!TYPE ~ ";
    auto value = " ~ TYPE.stringof ~ ".findOne(http_request.params[\"key\"]);
    if (value !is null) {
        """;
	static if (__traits(hasMember, TYPE, "canDelete") && typeof(&type.canView).stringof == "bool delegate()") {
		ret ~= "if (value.canDelete()) {";
	} else {
		ret ~= "static if (true) {";
	}
	ret ~= """
            value.remove();
            http_response.writeBody(\"\");
        }
    }
}
""";
	return ret;
}