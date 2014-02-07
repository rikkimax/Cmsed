module cmsed.base.internal.generators.js.model.generate;
import cmsed.base.internal.generators.js.model.defs;
import cmsed.base.internal.generators.js.model.jsface;
import cmsed.base.internal.generators.js.model.prototype;
import dvorm.util;
import std.traits : isBasicType, isBoolean;

string generateJsFunc(T, ushort ajaxProtection)() {
	T t = newValueOfType!T;
	string ret;
	string constructorArgs;
	string constructorSet;
	string props;
	
	string saveprop;
	string removeprop;
	
	string findOneArgs;
	string findOneSet;
	string findOneSetArgs;
	
	handleClassStart!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
	
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
										handleClassPropertyObjectProperty!(T, ajaxProtection, m, n)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
									}
								}
							}
						}
					}
					
					static if (isActualRelationship!(T, m)) {
						handleClassPropertyRelationship!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
					}
				} else {
					handleClassProperty!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
				}
			}
		}
	}
	
	handleClassEnd!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
	handleFileEnd!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
	
	return ret;
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassStart(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassStartJSFace!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassStartPrototype!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
}

/**
 * Finishes the javascript associated with a given OOP handler.
 */
void handleClassEnd(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(ajaxHandler) {
			case AjaxHandler.Prototype:
			handleClassEndPrototype!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassEndJSFace!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
}

/**
 * Finishes the javascript associated with a given OOP handler.
 */
void handleFileEnd(T, ushort ajaxProtection, T t = newValueOfType!T)(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(ajaxHandler) {
			case AjaxHandler.Prototype:
			handleFileEndPrototype!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleFileEndJSFace!(T, ajaxProtection)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
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
                                       )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(ajaxHandler) {
			case AjaxHandler.Prototype:
			handleClassPropertyObjectPropertyPrototype!(T, ajaxProtection, m, n)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyObjectPropertyJSFace!(T, ajaxProtection, m, n)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
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
                         )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(ajaxHandler) {
			case AjaxHandler.Prototype:
			handleClassPropertyPrototype!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyJSFace!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
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
                                     )(ref string ret, ref string constructorArgs, ref string constructorSet, ref string props, ref string saveprop, ref string removeprop, ref string findOneArgs, ref string findOneSet, ref string findOneSetArgs) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassPropertyRelationshipPrototype!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyRelationshipJSFace!(T, ajaxProtection, m)(ret, constructorArgs, constructorSet, props, saveprop, removeprop, findOneArgs, findOneSet, findOneSetArgs);
			break;
		default:
			break;
	}
}