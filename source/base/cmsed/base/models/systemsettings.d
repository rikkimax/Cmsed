module cmsed.base.models.systemsettings;
import cmsed.base.internal.generators.js.model.defs;
import dvorm;

/**
 * Provides storage settings of all nodes.
 * These settings are per installation based and not per node.
 */

@dbName("SystemSettings")
@shouldNotGenerateJavascriptModel
class SystemSettingModel {
	@dbId {
		/**
		 * The name of the setting
		 */
		string name;
	}
	
	/**
	 * The value of the setting
	 */
	string value;
	
	mixin OrmModel!SystemSettingModel;
}