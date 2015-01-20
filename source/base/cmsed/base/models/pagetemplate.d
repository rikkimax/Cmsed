module cmsed.base.models.pagetemplate;
import dvorm;

@dbName("PageTemplates")
class PageTemplateModel {
	@dbId {
		/**
		 * The name of the page template.
		 */
		string name;

		/**
		 * UTC+0 time of when this was last edited.
		 */
		ulong lastEdited;
	}

	/**
	 * Optional value of the template.
	 */
	string value;

	mixin OrmModel!PageTemplateModel;
}