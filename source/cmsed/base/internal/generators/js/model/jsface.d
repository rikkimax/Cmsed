module cmsed.base.internal.generators.js.model.jsface;
import cmsed.base.internal.generators.js.model.defs;
import dvorm.util;

void handleClassStartJSFace(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	data.ret ~= "var " ~ getTableName!T ~ " = Class({\n";
	data.constructorArgs ~= "    constructor: function(";
}

void handleClassEndJSFace(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	if (data.constructorArgs[$-2] == ',')
		data.constructorArgs.length -= 2;
	data.constructorArgs ~= ") {\n";
	
	data.ret ~= data.constructorArgs;
	data.ret ~= data.constructorSet;
	data.ret ~= "    },\n";
	
	if (data.props.length > 2) {
		if (data.props[$-2] == ',') {
			data.props.length -= 2;
			data.props ~= '\n';
		}
	}
	data.ret ~= data.props;
	
	if (data.ret[$-2] == ',') {
		data.ret.length -= 2;
		data.ret ~= '\n';
	}
	
	data.ret ~= "});\n";
}

void handleFileEndJSFace(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
}

void handleClassPropertyObjectPropertyJSFace(T, ushort ajaxProtection, string m, string n, // params
                                             T t = newValueOfType!T, U = typeof(mixin("t." ~ m)), V = typeof(mixin("t." ~ m ~ "." ~ n)) // meta info that is needed but not available inside the function
                                             )(ref GenerateData data) {
	string name1 = getNameValue!(T, m);
	string name2 = getNameValue!(U, n);
	
	data.constructorArgs ~= name1 ~ "_" ~ name2 ~ ", ";
	static if (isBoolean!V) {
		data.constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = Boolean(" ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ");\n";
	} else static if (isBasicType!V) {
		data.constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = Number(" ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ");\n";
	} else {
		data.constructorSet ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = " ~ name1 ~ "_" ~ name2 ~ " === undefined ? \"" ~ getDefaultValue!(U, n) ~ "\" : " ~ name1 ~ "_" ~ name2 ~ ";\n";
	}									   
}

void handleClassPropertyJSFace(T, ushort ajaxProtection, string m, // params
                               T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                               )(ref GenerateData data) {
	string name = getNameValue!(T, m);
	if (name == "")
		name = "_";
	
	data.constructorArgs ~= name ~ ", ";
	
	static if (isBoolean!U) {
		data.constructorSet ~= "        this." ~ name ~ " = Boolean(" ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ");\n";
	} else static if (isBasicType!U) {
		data.constructorSet ~= "        this." ~ name ~ " = Number(" ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ");\n";
	} else {
		data.constructorSet ~= "        this." ~ name ~ " = " ~ name ~ " === undefined ? \"" ~ getDefaultValue!(T, m) ~ "\" : " ~ name ~ ";\n";
	}
}

void handleClassPropertyRelationshipJSFace(T, ushort ajaxProtection, string m, // params
                                           T t = newValueOfType!T, U = typeof(mixin("t." ~ m)) // meta info that is needed but not available inside the function
                                           )(ref GenerateData data) {
	mixin("import " ~ getRelationshipClassModuleName!(T, m) ~ ";");
	string name = getTableName!(mixin(getRelationshipClassName!(T, m)));
	
	data.props ~= "    " ~ getterName!(getNameValue!(T, m)) ~ ": function() {\n";
	data.props ~= "        return " ~ name ~ ".findOne(";
	
	foreach(n; __traits(allMembers, U)) {
		static if (isUsable!(U, n) && !shouldBeIgnored!(U, n)) {
			static if (isAnId!(U, n)) {
				static if (isAnObjectType!(typeof(mixin("t." ~ m ~ "." ~ n)))) {
				} else {
					string name1 = getNameValue!(T, m);
					string name2 = getNameValue!(U, n);
					data.props ~= "this." ~ name1 ~ "_" ~ name2 ~ ", ";
				}
			}
		}
	}
	if (data.props[$-2] == ',')
		data.props.length -= 2;
	data.props ~= ");\n";
	data.props ~= "    },\n";
	
	data.props ~= "    " ~ setterName!(getNameValue!(T, m)) ~ ": function(value) {\n";
	foreach(n; __traits(allMembers, U)) {
		static if (isUsable!(U, n) && !shouldBeIgnored!(U, n)) {
			static if (isAnId!(U, n)) {
				static if (isAnObjectType!(typeof(mixin("t." ~ m ~ "." ~ n)))) {
				} else {
					string name1 = getNameValue!(T, m);
					string name2 = getNameValue!(U, n);
					data.props ~= "        this." ~ name1 ~ "_" ~ name2 ~ " = value." ~ getRelationshipPropertyName!(T, m) ~ "_" ~ name2 ~ ";\n";
				}
			}
		}
	}
	data.props ~= "    },\n";
}