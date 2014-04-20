module cmsed.user.models.userpolicy;
import cmsed.user.models.user;
import cmsed.user.models.policy;
import dvorm;

@dbName("UserPolicy")
class UserPolicyModel {
	@dbId {
		@dbActualModel!(UserModel, "key")
		UserIdModel user;
		
		@dbActualModel!(PolicyModel, "key")
		PolicyIdModel policy;
	}
	
	bool enabled;
	
	mixin OrmModel!UserPolicyModel;
}