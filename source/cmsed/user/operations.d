module cmsed.user.operations;
import cmsed.user.models.user;
import cmsed.base.routing;

/**
 * Get the currently logged in user.
 * 
 * Returns:
 * 		Returns a UserModel or null if non existant.
 */
UserModel getLoggedInUser() {
	if (http_request.session.isKeySet("userId")) {
		return UserModel.findOne(http_request.session["userId"]);
	}
	
	return null;
}

/**
 * Try and log a user in. Given a username and password.
 * A username can be an email.
 */
bool login(string userName, string password) {
	// should proberbly have some form of auth provider?
	return false;
}

/**
 * Log the current user out.
 */
void logout() {
}