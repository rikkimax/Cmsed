module cmsed.base.caches.widgetusage;
import cmsed.base.models.widgetusage;
import cmsed.base.cache;

/**
 * Caches all widgets with the ability to get it based upon position and route.
 */

mixin CacheManager!(WidgetUsageModel, "getWidgets", true);

/**
 * Get a widget
 * 
 * Params:
 * 		position = 		The position on a route to work from. Required
 * 		route = 		The route to search on.
 *                      Defualt value is null.
 * 
 * Returns: Returns any information required to make a widget work on a route/position.
 * See_Also:
 * 		WidgetUsageModel
 */
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