module cmsed.base.internal.generators.js.model.generate;
import cmsed.base.internal.generators.js.model.defs;
import cmsed.base.internal.generators.js.model.jsface;
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
			handleClassStartJSFace!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props);
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
			handleClassEndJSFace!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props);
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
			handleClassPropertyObjectPropertyJSFace!(T, ajaxProtection, m, n)(ret, constructorArgs, constructorSet, props);
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
			handleClassPropertyJSFace!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props);
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
			handleClassPropertyRelationshipJSFace!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props);
			break;
		default:
			break;
	}
}