module cmsed.base.registration.widgit;
import cmsed.base.models.widgitusage;
import cmsed.base.caches.widgitusage;
import cmsed.base.routing;
public import std.functional : toDelegate;

/**
 * Registers widgits to be available by the template engine.
 */

private shared {
	alias string delegate(WidgitUsageModel wum) widgitDel;
	alias string function(WidgitUsageModel wum) widgitFunc;
	
	widgitDel[string] widgitFuncs;
}

string runWidgit(string name, string position, string value) {
	WidgitUsageModel wum  = new WidgitUsageModel;
	wum.route = null;
	wum.position = position;
	wum.name = name;
	wum.widgitInfo = value;
	return runWidgit(wum);
}

string runWidgit(WidgitUsageModel wum) {
	widgitDel func = widgitFuncs.get(wum.name, cast(shared(widgitDel))null);
	
	if (func !is null) {
		string ret = func(wum);
		if (ret !is null)
			return ret;
	}
	
	return "";
}

string runWidgit(string position) {
	WidgitUsageModel wum = getWidgetOnPositionInRoute(position, currentRoute.path);
	
	if (wum !is null) {
		widgitDel func = widgitFuncs.get(wum.name, cast(shared(widgitDel))null);
		
		if (func !is null) {
			string ret = func(wum);
			if (ret !is null)
				return ret;
		}
	}
	
	return "";
}

/**
 * Proceduel based widgit registration.
 */

void registerWidgit(string name, widgitFunc func) {
	synchronized {
		widgitFuncs[name] = toDelegate(func);
	}
}

void registerWidgit(string name, widgitDel func) {
	synchronized {
		widgitFuncs[name] = func;
	}
}

/**
 * OOP based widgit registration.
 */

interface OOWidgit {
	string source(WidgitUsageModel);
}

void registerWidgit(T, string name)() {
	synchronized {
		T t = new T;
		widgitFuncs[name] = &t.source;
	}
}