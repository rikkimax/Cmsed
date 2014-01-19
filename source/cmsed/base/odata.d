module cmsed.base.odata;
import dvorm;
import std.traits : moduleName;

/**
 * Provides bit field for or'ing to say what code to generate
 */
enum ODataProtection : ushort {
	None = 1 << 0,
	Create = 1 << 1,
	Update = 1 << 2,
	Delete = 1 << 4,
	View = 1 << 8,
	All = Create | Update | Delete | View
}

/**
 * Specifies methods that can be added to data models to configure who can do e.g. view/create/update/delete
 * For usage with e.g. user system.
 * 
 * Note:
 * 		This is not required to make odata work on a model.
 */
interface ODataFilters {
	/**
	 * Can the user view this entry?
	 */
	bool canView();
	
	/**
	 * Can the user create a new entry?
	 */
	bool canCreate();
	
	/**
	 * Can the user update this entry?
	 */
	bool canUpdate();
	
	/**
	 * .Can the user delete this entry?
	 */
	bool canDelete();
}

/**
 * Mixes in all code required to support odata on a route
 * 
 * Params:
 * 		protection = 	ODataProtection or'd value
 * 		TYPES = 	The types to provide odata bindings to
 * 
 * See_Also:
 * 		ODataProtection, getODataOneValue
 */
mixin template ODataRoute(ushort protection, TYPES...) {
	import vibe.http.status;
	import dvorm.util : dbIgnore, getNameValue;
	import std.conv : to;
	//pragma(msg, getODataOneValue!(protection, TYPES)());
	mixin(getODataOneValue!(protection, TYPES)());
}

protected {
	/**
	 * Produces the code to be mixed in for odata support on a route.
	 * 
	 * Params:
	 * 		protection = 	ODataProtection or'd value
	 * 		TYPES = 	The types to provide odata bindings to
	 * 
	 * See_Also:
	 * 		ODataProtection, ODataRoute
	 */
	pure string getODataOneValue(ushort protection, TYPES...)() {
		string ret;
		
		foreach (C; TYPES) {
			C c = new C;
			
			static if ((protection & ODataProtection.View) == ODataProtection.View) {
				
				// view
				
				// handle ClassName(:key)
				
				ret ~= "@MatchRoute()\n";
				ret ~= "@RouteFunction(RouteType.Get, \"/" ~ getTableName!C() ~ "(:key)\")\n";
				ret ~= "void handleOData" ~ C.stringof ~ "GetSpecificOne1() {\n";
				ret ~= "    import " ~ moduleName!C ~ ";\n";
				ret ~= "    auto value = " ~ C.stringof ~ ".findOne(http_request.params[\"key)\"][0 .. $-1]);\n";
				ret ~= "    if (value !is null) {\n";
				
				// is there a method that says that we are allowed to view it?
				// if so call it
				//  if true do following:
				// if not exist do the following:
				static if (__traits(hasMember, C, "canView") && typeof(&c.canView).stringof == "bool delegate()") {
					ret ~= "        if (value.canView()) {\n";
				} else {
					ret ~= "        if (true) {\n";
				}
				
				// output it
				// what format should we output to?
				//  is it ?format=json
				//  is it ?format=xml
				//  is it ?format=atom
				//  if not specified check for accept header for:
				//   application/json
				//   application/xml
				//   application/atom+xml
				//  default to error 406 Not Acceptable
				ret ~= "            switch(http_request.query.get(\"format\", null)) {\n";
				ret ~= "                case \"json\":\n";
				ret ~= "                    string jsonValue = \"{\";\n";
				ret ~= "                    jsonValue ~= \"\\\"d\\\": {\";\n";
				ret ~= "                    jsonValue ~= \"\\\"results\\\": [{\";\n";
				foreach (m; __traits(allMembers, C)) {
					static if (isUsable!(C, m)() && !shouldBeIgnored!(C, m)()) {
						static if (is(typeof(mixin("c." ~ m)) : Object)) {
							foreach (n; __traits(allMembers, typeof(mixin("c." ~ m)))) {
								static if (isUsable!(typeof(mixin("c." ~ m)), n)() && !shouldBeIgnored!(typeof(mixin("c." ~ m)), n)()) {
									static if (isAnId!(typeof(mixin("c." ~ m)), n)) {
										static if (is(typeof(mixin("c." ~ m ~ "." ~ n)): Object)) {
											assert(0, "Data models cannot have objects with objects as id's.");
										} else static if (is(typeof(mixin("c." ~ m ~ "." ~ n)) == string) ||
										                  is(typeof(mixin("c." ~ m ~ "." ~ n)) == dstring) ||
										                  is(typeof(mixin("c." ~ m ~ "." ~ n)) == wstring)) {
											ret ~= "                    jsonValue ~= \"\\\"\" ~ getNameValue!(typeof(value), \"" ~ m ~ "\") ~ \"_\" ~ getNameValue!(typeof(value." ~ m ~ "), \"" ~ n ~ "\") ~ \"\\\": \\\"\" ~ value." ~ m ~ "." ~ n ~ "~ \"\\\", \";\n";
										} else static if (typeof(mixin("c." ~ m ~ "." ~ n)).stringof != "void") {
											ret ~= "                    jsonValue ~= \"\\\"\" ~ getNameValue!(typeof(value), \"" ~ m ~ "\") ~ \"_\" ~ getNameValue!(typeof(value." ~ m ~ "), \"" ~ n ~ "\") ~ \"\\\": \" ~ to!string(value." ~ m ~ "." ~ n ~ ") ~ \", \";\n";
										}
									}
								}
							}
						} else static if (is(typeof(mixin("c." ~ m)) == string) ||
						                  is(typeof(mixin("c." ~ m)) == dstring) ||
						                  is(typeof(mixin("c." ~ m)) == wstring)) {
							ret ~= "                    jsonValue ~= \"\\\"\" ~ getNameValue!(typeof(value), \"" ~ m ~ "\") ~ \"\\\": \\\"\" ~ value." ~ m ~ " ~ \"\\\", \";\n";
						} else static if (typeof(mixin("c." ~ m)).stringof != "void") {
							ret ~= "                    jsonValue ~=\"\\\"\" ~  getNameValue!(typeof(value), \"" ~ m ~ "\") ~ \"\\\": \" ~ to!string(value." ~ m ~ ") ~ \", \";\n";
						}
					}
				}
				ret ~= "                jsonValue.length -= 2;\n";
				ret ~= "                jsonValue ~= \"}], \\\"__count\\\": 1}}\";\n";
				ret ~= "                http_response.writeBody(cast(string)jsonValue, \"application/json\");";
				ret ~= "                break;\n";
				ret ~= "            default:\n";
				ret ~= "                http_response.statusCode = cast(HTTPStatus)406;\n";
				ret ~= "                break;\n";
				ret ~= "            }\n";
				ret ~= "        }\n";
				
				// check which properties are not allowed.
				// don't output them
				// output rest
				
				
				ret ~= "    }\n";
				ret ~= "}\n";
				
				foreach(m; __traits(allMembers, C)) {
					static if (isUsable!(C, m)() && !shouldBeIgnored!(C, m)()) {
						static if (!is(typeof(mixin("c." ~ m)) == void)) { // for some reason it has a habit of grabbing a few NON types which are void
							static if (is(typeof(mixin("c." ~ m)) : Object)) {
								// ok its an object
								// we have to grab all of its _ids_ just to handle this
								pragma(msg, C.stringof ~ "." ~ m, " ", typeof(mixin("c." ~ m)));
							} else {
								pragma(msg, C.stringof ~ "." ~ m, " ", typeof(mixin("c." ~ m)));
								// we are not an object aka primitive.
								// we're simple to use.
								
								// handle ClassName(:key)/prop
								
								ret ~= "@MatchRoute()\n";
								ret ~= "@RouteFunction(RouteType.Get, \"/" ~ getTableName!C() ~ "(:key)/" ~ getNameValue!(C, m)() ~ "\")\n";
								ret ~= "void handleOData" ~ C.stringof ~ "GetSpecificOne" ~ m ~ "2() {\n";
								ret ~= "    import " ~ moduleName!C ~ ";\n";
								ret ~= "    auto value = " ~ C.stringof ~ ".findOne(http_request.params[\"keyend)\"][0 .. $-1]);\n";
								ret ~= "    if (value !is null) {\n";
								ret ~= "        auto outputValue = value." ~ m ~ ";\n";
								
								// is there a method that says that we are allowed to view it?
								// if so call it
								//  if true do following:
								// if not exist do the following:
								
								// output it
								
								// what format should we output to?
								//  is it ?format=json
								//  is it ?format=xml
								//  is it ?format=atom
								//  if not specified check for accept header for:
								//   application/json
								//   application/xml
								//   application/atom+xml
								//  default to error 406 Not Acceptable
								
								// check which properties are not allowed.
								// don't output them
								// output rest
								
								ret ~= "    } else {\n";
								ret ~= "        http_response.statusCode = HTTPStatus.notFound;\n";
								ret ~= "    }\n";
								ret ~= "}\n";
								
								// handle ClassName(:key)/prop/$value
								
								ret ~= "@MatchRoute()\n";
								ret ~= "@RouteFunction(RouteType.Get, \"/" ~ getTableName!C() ~ "(:key)/" ~ getNameValue!(C, m)() ~ "/$value\")\n";
								ret ~= "void handleOData" ~ C.stringof ~ "GetSpecificOne" ~ m ~ "3() {\n";
								ret ~= "    import " ~ moduleName!C ~ ";\n";
								ret ~= "    auto value = " ~ C.stringof ~ ".findOne(http_request.params[\"key)\"][0 .. $-1]);\n";
								ret ~= "    if (value !is null) {\n";
								ret ~= "        auto outputValue = value." ~ m ~ ";\n";
								// default of writeBody is text/plain which is correct.
								
								// is there a method that says that we are allowed to view it?
								// if so call it
								//  if true do following:
								// if not exist do the following:
								
								// output it
								
								// check which properties are not allowed.
								// don't output them
								// output rest
								
								ret ~= "        http_response.writeBody(to!string(outputValue));\n";
								ret ~= "    } else {\n";
								ret ~= "        http_response.statusCode = HTTPStatus.notFound;\n";
								ret ~= "    }\n";
								ret ~= "}\n";
							}
						}
					}
				}
				
				// handle ClassName?$top=m&$skip=n&$format=type&$count
				
				// view 
			}
			
			static if ((protection & ODataProtection.Delete) == ODataProtection.Delete) {
				// delete
				
				// handle ClassName
				
				// delete
			}
			
			static if ((protection & ODataProtection.Create) == ODataProtection.Create) {
				// create
				
				// handle ClassName
				
				// create
			}
			
			static if ((protection & ODataProtection.Update) == ODataProtection.Update) {
				// update
				
				// handle ClassName
				
				// update
			}
		}
		
		return ret;
	}
}