module cmsed.base.cache;

/**
 * Takes an ORM model, 
 * makes sure that we keep in memory the entirety of them.
 * Updates as per update mechanism.
 * Includes an on update event call if compilable.
 */

mixin template CacheManager(T, string getName = "get", bool frequent = false) if (
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
	
	mixin(q{
		shared static this() {
			import cmsed.base.registration.update;
			
			registerUpdate(&mixin(getName ~ "Update"), frequent);
		}
	});
}