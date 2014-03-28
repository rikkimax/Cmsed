module cmsed.base.internal.restful.remove;
import cmsed.base.internal.restful.defs;
import dvorm;
import std.traits : moduleName;

/**
 * Dedicated to removing data in the database.
 */
pure string removeRestfulData(TYPE)() {
	string ret;
	TYPE type = newValueOfType!TYPE;
	ret ~= """
#line 1 \"cmsed.base.internal.restful.remove." ~ TYPE.stringof ~ "\"
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