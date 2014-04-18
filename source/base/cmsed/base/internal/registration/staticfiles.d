module cmsed.base.internal.registration.staticfiles;
import cmsed.base.internal.routing;
import cmsed.base.mimetypes;
import cmsed.minifier.jsmin;
import vibe.d;
import std.path : extension;
import std.string : toLower;

private shared {
	ubyte[][string] staticFiles;
	string[string] staticTypes;
	string staticPath = "/public";
}

void registerStaticFile(string name, string text, string mime=null) {
	debug {
	} else {
		if (mime == getTemplateForType("javascript") || mime == "javascript") {
			text = to!string(minify(to!wstring(text)));
		}
	}
	
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
		void staticHandler() {
			string path = http_request.path[staticPath.length .. $].toLower();
			
			if (path in staticFiles) {
				http_response.writeBody(cast(ubyte[])staticFiles[path], staticTypes[path]);
			}
		}
		
		bool func() {
			return http_request.path.length > staticPath.length && http_request.path[0 .. staticPath.length] == staticPath;
		}
		
		auto info = new RouteInformation(RouteType.Get, null, null, "staticHandler", staticPath);
		getURLRouter().register(info, &func, &staticHandler);
		
		// logging
		
		string oFile;
		foreach(path; staticFiles.keys) {
			oFile ~= "get:" ~ staticPath ~ path ~ "\n";
		}
		
		string logFile = buildPath(configuration.logging.dir, configuration.logging.routeFile);
		append(logFile, "=======-----=======\n" ~ oFile);
	}
}