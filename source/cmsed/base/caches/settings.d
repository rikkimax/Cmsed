module cmsed.base.caches.settings;
import cmsed.base.models.systemsettings;
import cmsed.base.cache;

/**
 * Provides a cache model that is for system settings.
 * Updates all system settings every five minutes.
 */

mixin CacheManager!(SystemSettingModel, "getSystemSettings", true);

SystemSettingModel getSettingByName(string name) {
	synchronized {
		foreach(s; getSystemSettings) {
			if (s.name == name)
				return s;
		}
		
		return null;
	}
}