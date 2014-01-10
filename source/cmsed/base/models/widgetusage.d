module cmsed.base.models.widgetusage;
import dvorm;

/**
 * Stores all currently utilised widgets in all of the routes.
 * Uses cache manager to make sure we got a current copy.
 */

@dbName("Widgets")
class WidgetUsageModel {
	@dbId {
		// the route to actually use it on.
		string route;
		
		// where on the page is it?
		string position;
	}
	
	// name of widget to use
	string name;
	
	// Any information required by the widget to identify its indevidual thing.
	// Can point to key of another model.
	string widgetInfo;
	
	mixin OrmModel!WidgetUsageModel;
}