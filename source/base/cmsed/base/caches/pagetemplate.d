module cmsed.base.caches.pagetemplate;
import cmsed.base.models.pagetemplate;
import cmsed.base.cache;

/**
 * Provides a cache model that is for page templates, allows for database assigned templates
 * Updates all template locations every five minutes.
 */

mixin CacheManager!(PageTemplateModel, "getPageTemplates", true);

/**
 * Gets a page template setting by template name
 * 
 * Params:
 * 		name    = 	The name of the template to get
 * 		lastEdited	=	The time to get. Default latest
 * 
 * Returns:
 * 		A data model containing the page template model. Which can be updated.
 */
PageTemplateModel getPageTemplateByName(string name, ulong lastEdited = 0) {
	synchronized {
		if (lastEdited > 0) {
			foreach(s; getPageTemplates) {
				if (s.name == name && s.lastEdited == lastEdited)
					return s;
			}
		} else {
			PageTemplateModel latest;

			foreach(s; getPageTemplates) {
				if (s.name == name) {
					if ((latest !is null && s.lastEdited > latest.lastEdited) || latest is null) {
						latest = s;
					}
				}
			}

			return latest;
		}
		
		return null;
	}
}