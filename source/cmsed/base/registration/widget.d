module cmsed.base.registration.widget;
import cmsed.base.models.widgetusage;
import cmsed.base.caches.widgetusage;
import cmsed.base.routing;
public import std.functional : toDelegate;

/**
 * Registers widgets to be available by the template engine.
 */

private shared {
	alias string delegate(WidgetUsageModel wum) widgetDel;
	alias string function(WidgetUsageModel wum) widgetFunc;
	
	widgetDel[string] widgetFuncs;
}

string runWidget(string name, string position, string value) {
	WidgetUsageModel wum  = new WidgetUsageModel;
	wum.route = null;
	wum.position = position;
	wum.name = name;
	wum.widgetInfo = value;
	return runWidget(wum);
}

string runWidget(WidgetUsageModel wum) {
	widgetDel func = widgetFuncs.get(wum.name, cast(shared(widgetDel))null);
	
	if (func !is null) {
		string ret = func(wum);
		if (ret !is null)
			return ret;
	}
	
	return "";
}

string runWidget(string position) {
	WidgetUsageModel wum = getWidgetOnPositionInRoute(position, currentRoute.path);
	
	if (wum !is null) {
		widgetDel func = widgetFuncs.get(wum.name, cast(shared(widgetDel))null);
		
		if (func !is null) {
			string ret = func(wum);
			if (ret !is null)
				return ret;
		}
	}
	
	return "";
}

/**
 * Proceduel based widget registration.
 */

void registerWidget(string name, widgetFunc func) {
	synchronized {
		widgetFuncs[name] = toDelegate(func);
	}
}

void registerWidget(string name, widgetDel func) {
	synchronized {
		widgetFuncs[name] = func;
	}
}

/**
 * OOP based widget registration.
 */

interface OOWidget {
	string source(WidgetUsageModel);
}

void registerWidget(T, string name)() {
	synchronized {
		T t = new T;
		widgetFuncs[name] = &t.source;
	}
}