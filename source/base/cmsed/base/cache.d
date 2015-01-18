module cmsed.base.cache;
import dvorm;
import std.traits : moduleName;

/**
 * Takes an ORM model, 
 * makes sure that we keep in memory the entirety of them.
 * Updates as per update mechanism.
 * Includes an on update event call if compilable.
 */
template CacheManager(T, string getName = "get", bool frequent = false) if (
	__traits(compiles, {T[] all = T.findAll();})) {
	
	private {
		shared T[] store;
		
		mixin("void " ~ getName ~ q{Update() {
				synchronized {
					store = cast(shared)T.findAll();
					mixin("static if (__traits(compiles, {" ~ getName ~ "OnUpdate(); })) {" ~ q{
						mixin(getName ~ "OnUpdate();");
					} ~ "}");
				}
			}});
	}
	
	mixin("T[] " ~ getName ~ q{() {
			synchronized {
				return cast(T[])store;
			}
		}});
	
	shared static this() {
		import cmsed.base.registration.update;
		
		registerUpdate(&mixin(getName ~ "Update"), frequent);
	}
}

/**
 * Caches a selected result from a given query.
 * Must be a Dvorm query.
 * 
 * Usage:
 * 		mixin CacheQuery!(MyModel, q{MyModel.query().myproperty_eq(0)}, "getModelValues", true);
 */
template CacheQuery(T, string query, string getName = "get", bool frequent = false) {
	static assert(__traits(compiles, {T[] values = mixin(query ~ ".find()");}), "Query for " ~ T.stringof ~ " does not compiled: " ~ query ~ ".find(). Return value must be of type: " ~ T.stringof ~ "[]");
	
	private {
		shared T[] store;
		
		mixin("void " ~ getName ~ q{Update() {
				synchronized {
					store = cast(shared)mixin(query).find();
					mixin("static if (__traits(compiles, {" ~ getName ~ "OnUpdate(); })) {" ~ q{
						mixin(getName ~ "OnUpdate();");
					} ~ "}");
				}
			}});
	}
	
	mixin("T[] " ~ getName ~ q{() {
			synchronized {
				return cast(T[])store;
			}
		}});
	
	shared static this() {
		import cmsed.base.registration.update;
		
		registerUpdate(&mixin(getName ~ "Update"), frequent);
	}
}