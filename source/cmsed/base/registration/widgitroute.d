module cmsed.base.registration.widgitroute;
import cmsed.base.routing : RouteInformation;
import cmsed.base.config : configuration;
import std.file : write, append;
import std.path : buildPath;

/**
 * Registers positions ext. of widgits in routes.
 */

private shared {
	WidgitRoute[] widgitRoutes;
}

class WidgitRoute {
	string file;
	RouteInformation routeInfo;
	string name;
	string position;
	string widgitInfo;
}

WidgitRoute[] getWidgitRoutes() {
	synchronized {
		return cast(WidgitRoute[])widgitRoutes;
	}
}

void registerWidgitRoute(string file, RouteInformation routeInfo, string name, string position, string widgitInfo) {
	synchronized {
		bool isIn = false;
		foreach(wr; widgitRoutes) {
			if (wr.file == file && wr.routeInfo.path == routeInfo.path && wr.routeInfo.type == routeInfo.type && wr.position == position) {
				isIn = true;
				break;
			}
		}
		
		if (!isIn) {
			WidgitRoute wr = new WidgitRoute;
			wr.routeInfo = routeInfo;
			wr.file = file;
			wr.name = name;
			wr.position = position;
			wr.widgitInfo = widgitInfo;
			widgitRoutes ~= cast(shared)wr;
		}
	}
}

protected {
	void outputWidgits() {
		shared WidgitRoute[][string] files;
		foreach(wr; widgitRoutes) {
			files[wr.file] ~= wr;
		}
		
		string ofile = buildPath(configuration.logging.dir, configuration.logging.widgitsFile);
		write(ofile, "");
		
		foreach(k, v; files) {
			append(ofile, "== " ~ k ~ " ==");
			foreach(wr; v) {
				append(ofile, """
-- " ~ wr.position ~ " --
Name:     " ~ wr.name ~ "
Value:    " ~ wr.widgitInfo ~ "
Route:    " ~ wr.routeInfo.type ~ ":" ~ wr.routeInfo.path ~ "
Function: " ~ wr.routeInfo.functionName ~ "
Class  Name:   " ~ wr.routeInfo.className ~ "
       Module: " ~ wr.routeInfo.classModuleName ~ "
""");
			}
		}
	}
}