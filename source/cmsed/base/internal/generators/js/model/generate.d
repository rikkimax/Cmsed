module cmsed.base.internal.generators.js.model.generate;
import cmsed.base.internal.generators.js.model.defs;
import dvorm.util;
import std.traits : isBasicType, isBoolean;

string generateJsFunc(T, ushort ajaxProtection)() {
	T t = newValueOfType!T;
	string ret;
	string constructorArgs;
	string constructorSet;
	string props;
	
	handleClassStart!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props);
	
	foreach(m; __traits(allMembers, T)) {
		static if (isUsable!(T, m) && !shouldBeIgnored!(T, m)) {
			static if (!shouldIgnoreGenerateJavascriptModel!(T, m)) {
				static if (isAnObjectType!(typeof(mixin("t." ~ m)))) {
					foreach(n; __traits(allMembers, typeof(mixin("t." ~ m)))) {
						static if (isUsable!(typeof(mixin("t." ~ m)), n) && !shouldBeIgnored!(typeof(mixin("t." ~ m)), n)) {
							static if (!shouldIgnoreGenerateJavascriptModel!(typeof(mixin("t." ~ m)), n)) {
								static if (isAnId!(typeof(mixin("t." ~ m)), n)) {
									static if (isAnObjectType!(typeof(mixin("t." ~ m ~ "." ~ n)))) {
									} else {
										handleClassPropertyObjectProperty!(T, ajaxProtection, m, n)(ret, constructorArgs, constructorSet, props);
									}
								}
							}
						}
					}
					
					static if (isActualRelationship!(T, m)) {
						handleClassPropertyRelationship!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props);
					}
				} else {
					handleClassProperty!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props);
				}
			}
		}
	}
	
	handleClassEnd!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props);
	
	return ret;
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassStart(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			ret ~= "var " ~ getTableName!T ~ " = Class({\n";
			constructorArgs ~= "    constructor: function(";
			break;
		default:
			break;
	}
}

/**
 * Finishes the javascript associated with a given OOP handler.
 */
void handleClassEnd(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			if (constructorArgs[$-2] == ',')
				constructorArgs.length -= 2;
			constructorArgs ~= ") {\n";
			
			ret ~= constructorArgs;
			ret ~= constructorSet;
			ret ~= "    },\n";
			
			if (props.length > 2) {
				if (props[$-2] == ',') {
					props.length -= 2;
					props ~= '\n';
				}
			}
			ret ~= props;
			
			if (ret[$-2] == ',') {
				ret.length -= 2;
				ret ~= '\n';
			}
			
			ret ~= "});";
			break;
		default:
			break;
	}
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassPropertyObjectProperty(T, ushort ajaxProtection, string m, string n, // params
                                       T t = newValueOfType!T, U = typeof(mixin("t." ~ m)), V = typeof(mixin("t." ~ m ~ "." ~ n)) // meta info that is needed but not available inside the function
                                       )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			string name1 = getNameValue!(T, m);
			string name2 = getNameValue!(U, n);
			
			constructorArgs ~= name1 ~ "_" ~ name2 ~ ", ";
			static if (isBoolean!V) {
				constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = Boolean(" ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ");\n";
			} else static if (isBasicType!V) {
				constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = Number(" ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ");\n";
			} else {
				constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = " ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ";\n";
			}
			break;
		default:
			break;
	}
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassProperty(T, ushort ajaxProtection, string m, // params
                         T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                         )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			string name = getNameValue!(T, m);
			if (name == "")
				name = "_";
			
			constructorArgs ~= name ~ ", ";
			
			static if (isBoolean!U) {
				constructorSet ~= "        this." ~ name ~ " = Boolean(" ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ");\n";
			} else static if (isBasicType!U) {
				constructorSet ~= "        this." ~ name ~ " = Number(" ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ");\n";
			} else {
				constructorSet ~= "        this." ~ name ~ " = " ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ";\n";
			}
			break;
		default:
			break;
	}
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassPropertyRelationship(T, ushort ajaxProtection, string m, // params
                                     T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                     )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			mixin("import " ~ getRelationshipClassModuleName!(T, m) ~ ";");
			string name = getTableName!(mixin(getRelationshipClassName!(T, m)));
			
			props ~= "    " ~ getterName!(getNameValue!(T, m)) ~ ": function() {\n";
			props ~= "        return " ~ name ~ ".findOne(";
			
			foreach(n; __traits(allMembers, U)) {
				static if (isUsable!(U, n) && !shouldBeIgnored!(U, n)) {
					static if (isAnId!(U, n)) {
						static if (isAnObjectType!(typeof(mixin("t." ~ m ~ "." ~ n)))) {
						} else {
							string name1 = getNameValue!(T, m);
							string name2 = getNameValue!(U, n);
							props ~= "this." ~ name1 ~ "_" ~ name2 ~ ", ";
						}
					}
				}
			}
			if (props[$-2] == ',')
				props.length -= 2;
			props ~= ");\n";
			props ~= "    },\n";
			
			props ~= "    " ~ setterName!(getNameValue!(T, m)) ~ ": function(value) {\n";
			foreach(n; __traits(allMembers, U)) {
				static if (isUsable!(U, n) && !shouldBeIgnored!(U, n)) {
					static if (isAnId!(U, n)) {
						static if (isAnObjectType!(typeof(mixin("t." ~ m ~ "." ~ n)))) {
						} else {
							string name1 = getNameValue!(T, m);
							string name2 = getNameValue!(U, n);
							props ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = value." ~ getRelationshipPropertyName!(T, m) ~ "_" ~ name2 ~ ";\n";
						}
					}
				}
			}
			props ~= "    },\n";
			break;
		default:
			break;
	}
}