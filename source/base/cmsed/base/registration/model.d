module cmsed.base.registration.model;
import cmsed.base.config;
//import cmsed.base.internal.generators.js.model;
import dvorm.logging;
import std.file : write;
import std.path : buildPath;

/**
 * Registers models to be configured at runtime for their database.
 * If a model includes an init method with no args it will execute upon loading.
 */

private shared {
	alias void function() configureModelDatabasesFunc;
	alias void delegate() configureModelDatabasesOnInitFunc;
	
	configureModelDatabasesFunc[] configureModelDatabases;
	configureModelDatabasesOnInitFunc[] configureModelDatabasesOnInit;
	
	void configureModelDatabase(C)() {
        import std.traits : fullyQualifiedName;
        C.logMe();
		
        Database db = configuration.modelDatabases.get(__traits(identifier, C), configuration.modelDatabases.get(fullyQualifiedName!C, configuration.globalDatabase));
		
		C.databaseConnection(db.getDbConnections());
	}
}

/**
 * Registers a dvorm data model.
 * To be configured and managed by Cmsed.
 */
void registerModel(C)() if (isDataModel!C) {
    import cmsed.base.internal.defs;

	synchronized {
		configureModelDatabases ~= &configureModelDatabase!C;
		
		static if (__traits(compiles, { configureModelDatabasesOnInitFunc f = &C.init;})) {
			configureModelDatabasesOnInit ~= C.init();
		}
		
		//TODO: generateJavascriptModel!C;
        static if (SupportsLuaTemplating) {
            import cmsed.lua.internal.configure.datamodel;
            configureDataModel!C;
        }
	}
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */
void configureModels() {
	synchronized {
		foreach(func; configureModelDatabases) {
			func();
		}
		
		foreach(func; configureModelDatabasesOnInit) {
			func();
		}
		
		// log it
		write(buildPath(configuration.logging.dir, configuration.logging.ormFile), getOrmLog());
	}
}

pure bool isDataModel(T)() {
    static if (is(T == vibe.data.json.Json))
        return false;
    else
        return __traits(hasMember, T, "databaseConnection");
}