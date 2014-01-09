module cmsed.base.registration.model;
import cmsed.base.config;
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
		string clasz = C.stringof;
		shared Database db = configuration.modelDatabases.get(clasz, null);
		if (db is Database.init)
			db = configuration.globalDatabase;
		
		C.databaseConnection(db.getDbConnections());
	}
}

void registerModel(C)() {
	synchronized {
		configureModelDatabases ~= &configureModelDatabase!C;
		
		static if (__traits(compiles, { configureModelDatabasesOnInitFunc f = &C.init;})) {
			configureModelDatabasesOnInit ~= C.init();
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