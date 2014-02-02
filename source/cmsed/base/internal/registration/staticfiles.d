module cmsed.base.internal.registration.staticfiles;
import cmsed.base.routing;
import cmsed.base.mimetypes;
import vibe.d;
import std.path : extension;

private shared {
	ubyte[][string] staticFiles;
	string[string] staticTypes;
	string staticPath = "/public";
}

void registerStaticFile(string name, ubyte[] text, string mime=null) {
	synchronized {
		if (mime is null) {
			string extension = name.extension();
			if (extension.length > 1) {
				mime = getTemplateForType(extension[1 .. $]);
			}
			if (mime is null) {
				mime = "text/plain";
			}
		}
		
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
			string path = req.path[staticPath.length .. $];
			
			if (path in staticFiles) {
				res.writeBody(cast(ubyte[])staticFiles[path], staticTypes[path]);
			}
		}
		
		getURLRouter().match(HTTPMethod.GET, staticPath ~ "/*", &staticHandler);
	}
}