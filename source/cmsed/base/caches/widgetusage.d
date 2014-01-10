module cmsed.base.caches.widgetusage;
import cmsed.base.models.widgetusage;
import cmsed.base.cache;


mixin CacheManager!(WidgetUsageModel, "getWidgets");

WidgetUsageModel getWidgetOnPositionInRoute(string position, string route = null) {
	WidgetUsageModel lastRestort = null;
	
	foreach(wum; getWidgets()) {
		if (wum.route == route && wum.position == position) {
			return wum;
		} else if (wum.route is null || wum.route == "") {
			lastRestort = wum;
		}
	}
	
	return lastRestort;
}