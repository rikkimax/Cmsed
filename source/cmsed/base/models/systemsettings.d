module cmsed.base.models.systemsettings;
import dvorm;

/**
 * Provides storage settings of all nodes.
 * These settings are per installation based and not per node.
 */

@dbName("SystemSettings")
class SystemSettingModel {
	@dbId {
		string name;
	}
	
	string value;
	
	mixin OrmModel!SystemSettingModel;
}