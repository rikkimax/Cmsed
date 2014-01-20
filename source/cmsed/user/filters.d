module cmsed.user.filters;
import cmsed.base.routing;
import cmsed.base.filters;
import cmsed.user.operations;
import vibe.http.session;

/**
 * Filters are very important.
 * They are to be used with the router.
 * It enables for disabling whole routes depending on user info.
 * Can check against groups, logged in ext.
 */

/**
 * Checks to make sure that in a request that the user has already been authenticated.
 */
bool isAuthed(string redirectUrl = null)() {
	if(!hasSessionStart() || getLoggedInUser() is null) {
		static if (redirectUrl !is null) {
			http_response.redirect(redirectUrl);
		}
		return false;
	} else {
		return true;
	}
}

/**
 * Is the current user a part of a given group?
 */
bool isUserInGroup(string groupName)() {
	return false;
}