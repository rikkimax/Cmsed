module cmsed.user.models.policy;
import cmsed.user.models.group;
import cmsed.base;
import dvorm;

/**
 * A policy which is to be applied to a user(s)
 */
@dbName("Policy")
@shouldNotGenerateJavascriptModel
class PolicyModel {
	@dbId {
		@dbName("")
		PolicyIdModel key;
	}
	
	string comment;
	
	mixin OrmModel!PolicyModel;
	
	/**
	 * Gets all groups that have this policy and are enabled upon this policy.
	 * 
	 * Returns:
	 * 		The groups that have this policy enabled
	 */
	@dbIgnore
	@property GroupModel[] getGroups() {
		import cmsed.user.models.grouppolicy;
		return  GroupPolicyModel.query().policy_name_eq(key.name).enabled_eq(true).find_by_group();
	}
}

struct PolicyIdModel {
	@dbId {
		@dbName("id")
		string name;
	}
	
	@dbIgnore
	PolicyModel getPolicy() {
		return PolicyModel.findOne(name);
	}
}