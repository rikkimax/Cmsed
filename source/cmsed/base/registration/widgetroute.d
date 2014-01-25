module cmsed.base.registration.widgetroute;
import cmsed.base.routing : RouteInformation;
import cmsed.base.config : configuration;
import std.file : write, append;
import std.path : buildPath;

/**
 * Registers positions ext. of widgets in routes.
 */

private shared {
	WidgetRoute[] widgetRoutes;
}

/**
 * A template/route that utilises a widget.
 */
class WidgetRoute {
	/**
	 * The file that the template is.
	 */
	string file;
	
	/**
	 * Route information related to what this is.
	 * 
	 * See_Also:
	 * 		RouteInformation
	 */
	RouteInformation routeInfo;
	
	/**
	 * The name of the widget being asked for.
	 */
	string name;
	
	/**
	 * The widget position being hooked into
	 */
	string position;
	
	/**
	 * Any extra information being provided.
	 */
	string widgetInfo;
}

/**
 * All template/routes that can be hooked into
 */
WidgetRoute[] getWidgetRoutes() {
	synchronized {
		return cast(WidgetRoute[])widgetRoutes;
	}
}

/**
 * Internal: Registers a template/route that has a widget that can be hooked into.
 */
void registerWidgetRoute(string file, RouteInformation routeInfo, string name, string position, string widgetInfo) {
	synchronized {
		bool isIn = false;
		foreach(wr; widgetRoutes) {
			if (wr.file == file && wr.routeInfo.path == routeInfo.path && wr.routeInfo.type == routeInfo.type && wr.position == position) {
				isIn = true;
				break;
			}
		}
		
		if (!isIn) {
			WidgetRoute wr = new WidgetRoute;
			wr.routeInfo = routeInfo;
			wr.file = file;
			wr.name = name;
			wr.position = position;
			wr.widgetInfo = widgetInfo;
			widgetRoutes ~= cast(shared)wr;
		}
	}
}

protected {
	void outputWidgets() {
		shared WidgetRoute[][string] files;
		foreach(wr; widgetRoutes) {
			files[wr.file] ~= wr;
		}
		
		string ofile = buildPath(configuration.logging.dir, configuration.logging.widgetsFile);
		write(ofile, "");
		
		foreach(k, v; files) {
			append(ofile, "== " ~ k ~ " ==");
			foreach(wr; v) {
				append(ofile, """
-- " ~ wr.position ~ " --
Name:     " ~ wr.name ~ "
Value:    " ~ wr.widgetInfo ~ "
Route:    " ~ wr.routeInfo.type ~ ":" ~ wr.routeInfo.path ~ "
Function: " ~ wr.routeInfo.functionName ~ "
Class  Name:   " ~ wr.routeInfo.className ~ "
       Module: " ~ wr.routeInfo.classModuleName ~ "
""");
			}
		}
	}
}