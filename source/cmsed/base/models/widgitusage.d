module cmsed.base.models.widgitusage;
import dvorm;

/**
 * Stores all currently utilised widgits in all of the routes.
 * Uses cache manager to make sure we got a current copy.
 */

@dbName("Widgits")
class WidgitUsageModel {
	@dbId {
		// the route to actually use it on.
		string route;
		
		// where on the page is it?
		string position;
	}
	
	// name of widgit to use
	string name;
	
	// Any information required by the widgit to identify its indevidual thing.
	// Can point to key of another model.
	string widgitInfo;
	
	mixin OrmModel!WidgitUsageModel;
}