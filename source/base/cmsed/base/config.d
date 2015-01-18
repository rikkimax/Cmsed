module cmsed.base.config;
import cmsed.base.routing;
import dvorm.connection;
import dvorm.email.config;
import vibe.data.json;
import vibe.stream.ssl;
import std.file : read, exists, isFile, mkdirRecurse, timeLastModified;
import std.path : buildPath;
import std.datetime : SysTime;
import core.time : Duration;

/**
 * A configuration system that configures:
 * - Serving port
 * - Serving ip's
 * - Database connections for both a global and a data model specific connection.
 * - Logging with support for ORM, router.
 */

class Configuration {
    @optional {
        Database globalDatabase = new Database;
		Database[string] modelDatabases;
		
		BindData bind = new BindData;
		BindNodeCommunicationData bindNodeCoummunication = new BindNodeCommunicationData;
		
		Logging logging = new Logging;
		
		EmailServer email = new EmailServer;

        string publicFiles = "/public";
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

    this() {
        type = DbType.Memory;
    }
	
	DbConnection[] getDbConnections() {
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
    SslConfigData ssl;

    this() {
        ip = ["0.0.0.0", "::"];
        port = 8080;
    }
}

class BindNodeCommunicationData {
	ushort port;
	
	@optional
	SslConfigData ssl;
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
        string pipelineFile = "pipeline.log";
		
		string accessFile = "access.log";
		string errorAccessFile = "access_error.log";
		string errorFile = "error.log";
	}
}

class EmailServer {
	@optional {
		EmailReceiveServer receive;
		EmailSenderServer send;
	}
}

enum EmailReceiveServerType : string {
	Pop3 = "pop3"
}

struct EmailReceiveServer {
	EmailReceiveServerType type;
	bool secure = false;
	
	string host;
	@optional {
		ushort port;
	}
	
	@optional {
		string user;
		string password;
	}
}

enum EmailSendServerType : string {
	SMTP = "smtp"
}

struct EmailSenderServer {
	EmailSendServerType type;
	bool secure = false;
	
	string host;
	@optional {
		ushort port;
	}
	
	@optional {
		string user;
		string password;
	}
	
	@optional {
		string defaultFrom;
	}
}

private __gshared {
    Configuration configuration_;
	SysTime lastModifiedTime;
	string lastUsedConfigFile;
}

@property Configuration configuration() {
    synchronized {
        return configuration_;
    }
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */

void getConfiguration(string file = lastUsedConfigFile) {
	if (exists(file) && isFile(file)) {
			string contents = cast(string)read(file);
			Json json = parseJsonString(contents);
			configuration_ = deserializeJson!Configuration(json);
    }
	if (!exists(configuration.logging.dir)) {
		mkdirRecurse(configuration.logging.dir);
	}
			
    synchronized {
		lastModifiedTime = timeLastModified(file);
		lastUsedConfigFile = file;
	}
}

bool hasConfigurationChanged() {
	synchronized {
		return timeLastModified(lastUsedConfigFile) - lastModifiedTime > Duration.zero();
	}
}