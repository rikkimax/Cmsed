module cmsed.base.filters;
import cmsed.base.internal.routing;

/**
 * Checks to make sure the session has already been started.
 */
bool hasSessionStart() {
	if (http_request.session is Session.init ||
	    http_request.session.id == "") {
		return false;
	}
	
	return true;
}