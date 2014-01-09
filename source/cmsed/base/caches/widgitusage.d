module cmsed.base.caches.widgitusage;
import cmsed.base.models.widgitusage;
import cmsed.base.cache;


mixin CacheManager!(WidgitUsageModel, "getWidgits");

WidgitUsageModel getWidgetOnPositionInRoute(string position, string route = null) {
	WidgitUsageModel lastRestort = null;
	
	foreach(wum; getWidgits()) {
		if (wum.route == route && wum.position == position) {
			return wum;
		} else if (wum.route is null || wum.route == "") {
			lastRestort = wum;
		}
	}
	
	return lastRestort;
}