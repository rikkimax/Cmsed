module cmsed.base.restful.defs;
import cmsed.base.restful.get;
import cmsed.base.restful.remove;

/**
 * Provides bit field for or'ing to say what code to generate
 */
enum RestfulProtection : ushort {
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
 * 		This is not required to make data work on a model.
 */
interface RestfulFilters {
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

mixin template RestfulRoute(ushort protection, TYPES...) {
	import dvorm.util;
	import vibe.data.json;
	mixin(restAllCheck!(protection, TYPES));
#line 50 "cmsed.base.restful.defs"
}

pure string restAllCheck(ushort protection, TYPES...)() {
	string ret;
	foreach(C; TYPES) {
		static if ((protection & RestfulProtection.View) != 0) {
			pragma(msg, getRestfulData!C());
			ret ~= getRestfulData!C();
		}
		
		static if ((protection & RestfulProtection.Create) != 0) {
			// ret ~= 
		}
		
		static if ((protection & RestfulProtection.Update) != 0) {
			// ret ~= 
		}
		
		static if ((protection & RestfulProtection.Delete) != 0) {
			pragma(msg, removeRestfulData!C());
			ret ~= removeRestfulData!C();
		}
	}
	return ret;
}