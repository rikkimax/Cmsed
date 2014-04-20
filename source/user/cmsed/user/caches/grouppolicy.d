module cmsed.user.caches.grouppolicy;
import cmsed.user.caches.policy;
import cmsed.user.models.policy;
import cmsed.user.models.grouppolicy;
import cmsed.base;

mixin CacheManager!(GroupPolicyModel, "getGroupPolicies");

/**
 * Gets a groups policy by name
 * 
 * Params:
 * 		name = 		The name of the policy to get
 * 
 * Returns:
 * 		All the policies of a group
 */
PolicyModel[] getAGroupPolicies(string name) {
	synchronized {
		PolicyModel[] ret;
		
		foreach(s; getGroupPolicies) {
			if (s.group.name == name)
				if (s.enabled)
					ret ~= getPolicyByName(s.policy.name);
		}
		
		return ret;
	}
}