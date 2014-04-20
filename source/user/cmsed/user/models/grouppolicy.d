module cmsed.user.models.grouppolicy;
import cmsed.user.models.group;
import cmsed.user.models.policy;
import cmsed.base;
import dvorm;

/**
 * Applies a policy upon a group of users
 */
@dbName("GroupPolicy")
@shouldNotGenerateJavascriptModel
class GroupPolicyModel {
	@dbId {
		@dbActualModel!(GroupModel, "key")
		GroupIdModel group;
		
		@dbActualModel!(PolicyModel, "key")
		PolicyIdModel policy;
	}
	
	bool enabled;
	
	mixin OrmModel!GroupPolicyModel;
}