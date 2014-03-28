module cmsed.base.internal.restful.query;
import cmsed.base.internal.restful.defs;
import cmsed.base.internal.routing;
import vibe.data.json;
import dvorm;
import std.traits : moduleName;

/**
 * Binds a dvorm query to database query via a route.
 */
pure string queryRestfulData(TYPE)() {
	string ret;
	TYPE type = newValueOfType!TYPE;
	
	ret ~= """
#line 1 \"cmsed.base.internal.restful.query." ~ TYPE.stringof ~ "\"
@RouteFunction(RouteType.Post, \"/" ~ getTableName!TYPE ~ "\")
void handleRestfulData" ~ TYPE.stringof ~ "Query() {
    import " ~ moduleName!TYPE ~ ";
    auto query = " ~ TYPE.stringof ~ ".query();

    ushort maxAmount = 10;
    ushort offset = 0;
""";
	
	//maxAmount
	ret ~= "    if (http_request.form.get(\"__maxAmount\", null) !is null)\n";
	ret ~= "        maxAmount = to!ushort(http_request.form[\"__maxAmount\"]);\n";
	ret ~= "    if (maxAmount > 100) maxAmount = 10;\n";
	ret ~= "    query.maxAmount(maxAmount);\n";
	//startAt
	ret ~= "    if (\"__offset\" in http_request.form)\n";
	ret ~= "        offset = to!ushort(http_request.form[\"__offset\"]);\n";
	ret ~= "    query.startAt(offset);\n";
	
	ret ~= "\n";
	
	foreach (m; __traits(allMembers, TYPE)) {
		static if (isUsable!(TYPE, m)() && !shouldBeIgnored!(TYPE, m)()) {
			ret ~= outputRestfulTypeQueryHandler!(TYPE, m);
		}
	}
	
	ret ~= """
    Json output = Json.emptyObject;
    Json results = Json.emptyArray;
    size_t count;
    foreach(i, value; query.find()) {
""";
	
	static if (__traits(hasMember, TYPE, "canView") && typeof(&type.canView).stringof == "bool delegate()") {
		ret ~= "        if (value.canView()) {";
	} else {
		ret ~= "        static if (true) {";
	}
	ret ~= "

            Json vOutput = Json.emptyObject;\n";
	foreach (m; __traits(allMembers, TYPE)) {
		static if (isUsable!(TYPE, m)() && !shouldBeIgnored!(TYPE, m)()) {
			ret ~= "            vOutput[\"" ~ getNameValue!(TYPE, m) ~ "\"] = outputRestfulTypeJson!(" ~ TYPE.stringof ~ ", \"" ~ m ~ "\")(value);\n";
		}
	}
	ret ~= """
            results ~= vOutput;
            count = i;
        }
    }

    output[\"results\"] = results;
    output[\"count\"] = count + 1;
    output[\"maxAmount\"] = maxAmount;
    output[\"offset\"] = offset;

    http_response.writeBody(output.toString());
}
""";
	
	return ret;
}

private {
	pure string outputRestfulTypeQueryHandler(TYPE, string m)() {
		string ret;
		TYPE type = newValueOfType!TYPE;
		
		static if (is(typeof(__traits(getMember, type, m)) : Object)) {
			static if (isUsable!(TYPE, m) && !shouldBeIgnored!(TYPE, m)) {
				foreach (n; __traits(allMembers, typeof(__traits(getMember, type, m)))) {
					static if (isUsable!(typeof(__traits(getMember, type, m)), n) && isAnId!(typeof(__traits(getMember, type, m)), n)) {
						
						static if (is(typeof(mixin("type." ~ m ~ "." ~ n)) == string) ||
						           is(typeof(mixin("type." ~ m ~ "." ~ n)) == dstring) ||
						           is(typeof(mixin("type." ~ m ~ "." ~ n)) == wstring)) {
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_eq\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_eq(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_eq\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_neq\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_neq(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_neq\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mt\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_mt(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mt\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lt\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_lt(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lt\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mte\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_mte(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mte\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lte\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_lte(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lte\"]);\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_like\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_like(cast(" ~ typeof(mixin("type." ~ m ~ "." ~ n)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_like\"]);\n";
						} else static if (typeof(mixin("type." ~ m ~ "." ~ n)).stringof != "void") {
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_eq\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_eq(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_eq\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m)  ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n)~ "_neq\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_neq(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_neq\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_mt\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_mt(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mt\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_lt\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_lt(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lt\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_mte\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_mte(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_mte\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_lte\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_lte(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_lte\"]));\n";
							
							ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m ~ "_" ~ n)), n) ~ "_like\" in http_request.form)\n";
							ret ~= "        query." ~ m ~ "_" ~ n ~ "_like(to!" ~ typeof(mixin("type." ~ m ~ "_" ~ n)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_" ~ getNameValue!(typeof(mixin("type." ~ m)), n) ~ "_like\"]));\n";
						}
						
					}
				}
			}
		} else static if (is(typeof(__traits(getMember, type, m)) == string) ||
		                  is(typeof(__traits(getMember, type, m)) == dstring) ||
		                  is(typeof(__traits(getMember, type, m)) == wstring)) {
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_eq\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_eq(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_eq\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_neq\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_neq(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_neq\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_mt\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_mt(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_mt\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_lt\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_lt(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_lt\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_mte\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_mte(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_mte\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_lte\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_lte(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_lte\"]);\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_like\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_like(cast(" ~ typeof(mixin("type." ~ m)).stringof ~ ")http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_like\"]);\n";
		} else static if (typeof(__traits(getMember, type, m)).stringof != "void") {
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_eq\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_eq(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_eq\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_neq\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_neq(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_neq\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_mt\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_mt(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_mt\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_lt\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_lt(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_lt\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_mte\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_mte(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_mte\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_lte\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_lte(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_lte\"]));\n";
			
			ret ~= "    if (\"" ~ getNameValue!(TYPE, m) ~ "_like\" in http_request.form)\n";
			ret ~= "        query." ~ m ~ "_like(to!" ~ typeof(mixin("type." ~ m)).stringof ~ "(http_request.form[\"" ~ getNameValue!(TYPE, m) ~ "_like\"]));\n";
		}
		
		return ret;
	}
}