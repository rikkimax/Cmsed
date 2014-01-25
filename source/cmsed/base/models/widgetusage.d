module cmsed.base.models.widgetusage;
import dvorm;

/**
 * Stores all currently utilised widgets in all of the routes.
 * Uses cache manager to make sure we got a current copy.
 */

@dbName("Widgets")
class WidgetUsageModel {
	@dbId {
		/**
		 * The regex of the route that conforms to.
		 * This allows for key paramaters.
		 * Same syntax as URLRouter supports.
		 * 
		 * See_Also:
		 * 		vibe.http.URLRouter
		 */
		string route;
		
		/**
		 * The location on the page to be hooking into.
		 * If route is null/"" it is assumed that this position effects every page.
		 */
		string position;
	}
	
	/**
	 * The name of widgit to hook into.
	 */
	string name;
	
	/**
	 * Any information required by the widget to identify its indevidual thing.
	 * This can be utilised to specify a username or menu item.
	 */
	string widgetInfo;
	
	mixin OrmModel!WidgetUsageModel;
}