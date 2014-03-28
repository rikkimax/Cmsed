module cmsed.base.internal.generators.js.model.generate;
import cmsed.base.internal.generators.js.model.defs;
import cmsed.base.internal.generators.js.model.jsface;
import cmsed.base.internal.generators.js.model.prototype;
import cmsed.base.internal.generators.js.defs;
import dvorm.util;
import std.traits : isBasicType, isBoolean;

string generateJsFunc(T, ushort ajaxProtection)() {
	T t = newValueOfType!T;
	
	GenerateData data;
	
	handleClassStart!(T, ajaxProtection)(data);
	
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
										handleClassPropertyObjectProperty!(T, ajaxProtection, m, n)(data);
									}
								}
							}
						}
					}
					
					static if (isActualRelationship!(T, m)) {
						handleClassPropertyRelationship!(T, ajaxProtection, m)(data);
					}
				} else {
					handleClassProperty!(T, ajaxProtection, m)(data);
				}
			}
		}
	}
	
	handleClassEnd!(T, ajaxProtection)(data);
	handleFileEnd!(T, ajaxProtection)(data);
	
	return data.ret;
}

/**
 * Creates a variable associated with a specific OOP handler in javascript.
 */
void handleClassStart(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassStartJSFace!(T, ajaxProtection)(data);
			break;
		default:
			break;
	}
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassStartPrototype!(T, ajaxProtection)(data);
			break;
		default:
			break;
	}
}

/**
 * Finishes the javascript associated with a given OOP handler.
 */
void handleClassEnd(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassEndPrototype!(T, ajaxProtection)(data);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassEndJSFace!(T, ajaxProtection)(data);
			break;
		default:
			break;
	}
}

/**
 * Finishes the javascript associated with a given OOP handler.
 */
void handleFileEnd(T, ushort ajaxProtection, T t = newValueOfType!T)(ref GenerateData data) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleFileEndPrototype!(T, ajaxProtection)(data);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleFileEndJSFace!(T, ajaxProtection)(data);
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
                                       )(ref GenerateData data) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassPropertyObjectPropertyPrototype!(T, ajaxProtection, m, n)(data);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyObjectPropertyJSFace!(T, ajaxProtection, m, n)(data);
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
                         )(ref GenerateData data) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassPropertyPrototype!(T, ajaxProtection, m)(data);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyJSFace!(T, ajaxProtection, m)(data);
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
                                     )(ref GenerateData data) {
	switch(ajaxHandler) {
		case AjaxHandler.Prototype:
			handleClassPropertyRelationshipPrototype!(T, ajaxProtection, m)(data);
			break;
		default:
			break;
	}
	switch(oopHandler) {
		case OOPHandler.JSFace:
			handleClassPropertyRelationshipJSFace!(T, ajaxProtection, m)(data);
			break;
		default:
			break;
	}
}