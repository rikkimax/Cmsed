module cmsed.user.models.userpolicy;
import cmsed.user.models.user;
import cmsed.user.models.policy;
import cmsed.base;
import dvorm;

/**
 * Applies a policy upon a user
 */
@dbName("UserPolicy")
@shouldNotGenerateJavascriptModel
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