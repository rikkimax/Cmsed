module cmsed.user.caches.policy;
import cmsed.user.models.policy;
import cmsed.base;

mixin CacheManager!(PolicyModel, "getPolicies");

/**
 * Gets a policy by name
 * 
 * Params:
 * 		name = 		The name of the policy to get
 * 
 * Returns:
 * 		A data model containing the policy. Which can be updated.
 */
PolicyModel getPolicyByName(string name) {
	synchronized {
		foreach(s; getPolicies) {
			if (s.key.name == name)
				return s;
		}
		
		return null;
	}
}