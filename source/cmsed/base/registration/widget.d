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

/**
 * Given a widget name, position and value run it.
 * 
 * Returns:
 * 		A string to be included into a template.
 * 		Will be some form of html/css/js combo.
 *      If no widget exists, returns ""
 * 
 * See_also:
 * 		runWidget
 */
string runWidget(string name, string position, string value) {
	WidgetUsageModel wum  = new WidgetUsageModel;
	wum.route = null;
	wum.position = position;
	wum.name = name;
	wum.widgetInfo = value;
	return runWidget(wum);
}

/**
 * Given a WidgetUsageModel run a widget.
 * 
 * Params:
 * 		wum = 	The WidgetUsageModel containing the name, position and possibly the value.
 *              Route is not required. It is ignored.
 * 
 * Returns:
 * 		A string to be included into a template.
 * 		Will be some form of html/css/js combo.
 *      If no widget exists, returns ""
 * 
 * See_also:
 * 		runWidget
 */
string runWidget(WidgetUsageModel wum) {
	widgetDel func = widgetFuncs.get(wum.name, cast(shared(widgetDel))null);
	
	if (func !is null) {
		string ret = func(wum);
		if (ret !is null)
			return ret;
	}
	
	return "";
}

/**
 * Given a WidgetUsageModel run a widget.
 * 
 * Params:
 * 		position = 		The position on the route to use.
 * 
 * Returns:
 * 		A string to be included into a template.
 * 		Will be some form of html/css/js combo.
 *      If no widget exists, returns ""
 * 
 * See_also:
 * 		runWidget, getWidgetOnPositionInRoute
 */
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

/**
 * Interface which defines the required functions to be hooked into
 */
interface OOWidget {
	/**
	 * Handles a usage of a widget.
	 * 
	 * Params:
	 * 		wum = 	WidgetUsageModel to be compared and worked from.
	 * 
	 * Returns:
	 * 		Get the html/css/js combo based upon a WidgetUsageModel or null if not doable.
	 */
	string source(WidgetUsageModel wum);
}

/**
 * Name to change the widget handler to.
 * Defaults to class name.
 */
struct WidgetName {
	string name;
}

/**
 * Registers a widget handler.
 * See_Also:
 * 		WidgetName
 */
void registerWidget(T : OOWidget)() {
	synchronized {
		T t = new T;
		widgetFuncs[getWidgetClassName!T] = &t.source;
	}
}

private {
	pure string getWidgetClassName(T : OOWidget)() {
		foreach(UDA; __traits(getAttributes, T)) {
			static if (__traits(compiles, {WidgetName v = UDA;})) {
				return UDA.name;
			}
		}
		return T.stringof;
	}
}