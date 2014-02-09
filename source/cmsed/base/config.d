module cmsed.base.config;
import cmsed.base.routing;
import dvorm.connection;
import vibe.data.json;
import vibe.stream.ssl;
import std.file : read, exists, isFile, mkdirRecurse, timeLastModified;
import std.path : buildPath;
import core.time : Duration;

/**
 * A configuration system that configures:
 * - Serving port
 * - Serving ip's
 * - Database connections for both a global and a data model specific connection.
 * - Logging with support for ORM, router.
 */

class Configuration {
	Database globalDatabase = new Database;
	
	@optional {
		Database[string] modelDatabases;
		
		BindData bind = new BindData;
		BindNodeCommunicationData bindNodeCoummunication = new BindNodeCommunicationData;
		
		Logging logging = new Logging;
	}
}

class Database {
	DbType type;
	@optional {
		string database;
		string username;
		string password;
		ShardDatabase[] connections;
	}
	
	shared DbConnection[] getDbConnections() {
		DbConnection[] ret;
		bool first = true;
		foreach(sd; connections) {
			if (first) {
				ret ~= DbConnection(type, sd.ip, sd.port, username, password, database);
				first = false;
			} else {
				ret ~= DbConnection(null, sd.ip, sd.port, sd.username, sd.password, "");
			}
		}
		return ret;
	}
}

class ShardDatabase {
	string ip;
	@optional ushort port;
	@optional string username;
	@optional string password;
}

class BindData {
	string[] ip;
	ushort port;
	
	@optional
	SslConfigData ssl;// = new SslConfigData;
}

class BindNodeCommunicationData {
	ushort port;
	
	@optional
	SslConfigData ssl;// = new SslConfigData;
}

struct SslConfigData {
	string cert;
	string key;
}

class Logging {
	@optional {
		string dir = "logs";
		string routeFile = "route.log";
		string ormFile = "orm.log";
		string accessFile = "access.log";
		string errorFile = "error.log";
		string widgetsFile = "widgets.log";
	}
}

shared(Configuration) configuration;
private __gshared {
	SysTime lastModifiedTime;
	string lastUsedConfigFile;
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */

void getConfiguration(string file = lastUsedConfigFile) {
	if (exists(file)) {
		if (isFile(file)) {
			string contents = cast(string)read(file);
			Json json = parseJsonString(contents);
			configuration = cast(shared)deserializeJson!Configuration(json);
			
			if (!exists(configuration.logging.dir)) {
				mkdirRecurse(configuration.logging.dir);
			}
			
			synchronized {
				lastModifiedTime = timeLastModified(file);
				lastUsedConfigFile = cast(shared)file;
			}
		} else {
			assert(0, "Configuration file " ~ file ~ " does not exist");
		}
	} else {
		assert(0, "Configuration file " ~ file ~ " does not exist");
	}
}

bool hasConfigurationChanged() {
	synchronized {
		return timeLastModified(lastUsedConfigFile) - lastModifiedTime > Duration.zero();
	}
}