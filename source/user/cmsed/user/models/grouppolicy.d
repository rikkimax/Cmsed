module cmsed.user.models.grouppolicy;
import cmsed.user.models.group;
import cmsed.user.models.policy;
import dvorm;

@dbName("GroupPolicy")
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