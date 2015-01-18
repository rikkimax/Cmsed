module cmsed.base.caches.settings;
import cmsed.base.models.systemsettings;
import cmsed.base.cache;

/**
 * Provides a cache model that is for system settings.
 * Updates all system settings every five minutes.
 */

mixin CacheManager!(SystemSettingModel, "getSystemSettings", true);

/**
 * Gets a key/value pair setting value.
 * 
 * Params:
 * 		name    = 		The name of the setting to get
 * 
 * Returns:
 * 		A data model containing the system model. Which can be updated.
 */
SystemSettingModel getSettingByName(string name) {
	synchronized {
		foreach(s; getSystemSettings) {
			if (s.name == name)
				return s;
		}
		
		return null;
	}
}