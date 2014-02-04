module cmsed.base.internal.registration.staticfiles;
import cmsed.base.routing;
import cmsed.base.mimetypes;
import vibe.d;
import std.path : extension;
import std.string : toLower;

private shared {
	ubyte[][string] staticFiles;
	string[string] staticTypes;
	string staticPath = "/public";
}

void registerStaticFile(string name, string text, string mime=null) {
	registerStaticFile(name, cast(ubyte[])text, mime);
}

void registerStaticFile(string name, ubyte[] text, string mime=null) {
	synchronized {
		name = name.toLower();
		
		if (mime is null) {
			string extension = name.extension();
			
			if (extension.length > 1) {
				mime = getNameFromExtension(extension[1 .. $]);
			}
			if (mime is null) {
				mime = "text/plain";
			}
		}
		string mimebk = mime;
		mime = getTemplateForType(mime);
		if (mime is null)
			mime = mimebk;
		
		staticFiles[name] = cast(shared)text;
		staticTypes[name] = mime;
	}
}

void setStaticFilePath(string name) {
	synchronized {
		staticPath = name;
	}
}

void configureStaticFiles() {
	synchronized {
		void staticHandler(HTTPServerRequest req, HTTPServerResponse res) {
			enforce(req.path.length > staticPath.length, "Umm how did this happen?");
			string path = req.path[staticPath.length .. $].toLower();
			
			if (path in staticFiles) {
				res.writeBody(cast(ubyte[])staticFiles[path], staticTypes[path]);
			}
		}
		
		getURLRouter().match(HTTPMethod.GET, staticPath ~ "/*", &staticHandler);
		
		// logging
		
		string oFile;
		foreach(path; staticFiles.keys) {
			oFile ~= "get:" ~ staticPath ~ path ~ "\n";
		}
		
		string logFile = buildPath(configuration.logging.dir, configuration.logging.routeFile);
		append(logFile, "=======-----=======\n" ~ oFile);
	}
}