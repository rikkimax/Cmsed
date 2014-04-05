module cmsed.user.operations;
import cmsed.user.models.user;
import cmsed.user.models.userauth;
import cmsed.user.models.usergroup;
import cmsed.user.registration.auth;
import cmsed.base.defs;

/**
 * Get the currently logged in user.
 * 
 * Returns:
 * 		Returns a UserModel or null if non existant.
 */
UserModel getLoggedInUser() {
	if (session.isKeySet("userId")) {
		return UserModel.findOne(session["userId"]);
	}
	
	return null;
}

/**
 * Try and log a user in. Given a username and password.
 * A username can be an email.
 * A password is not required to work.
 * 
 * Params:
 * 		userName = 	The username of the user. Can be email.
 * 		password = 	The password given. Secret info to identifiy is the user.
 */
bool login(string userName, string password) {
	UserModel um = getUserFromAuth(userName, password);
	if (um is null) return false;
	
	session["userId"] = um.key.key;
	return true;
}

/**
 * Check if the username exists in any of the providers.
 */
bool doesUserExist(string name) {
	return getCheckUserExistsFromAuth(name);
}

/**
 * Check if a user is in a group.
 */
bool isUserInGroup(string group) {
	UserGroupModel[] ugma = UserGroupModel.getByUser(getLoggedInUser());
	foreach(ugm; ugma) {
		GroupModel gm = ugm.getGroup();
		if (gm.key.key == group) return true;
		else if (gm.title == group) return true;
	}
	
	return false;
}

/**
 * Log the current user out.
 */
void logout() {
	session["userId"] = null;
}

private {
	shared static this() {
		UserModel dbAuthProvider(string user, string pass) {
			UserAuthModel[] uams = UserAuthModel.query()
				.username_eq(user).find();
			
			foreach(uam; uams) {
				if (uam.password == pass) {
					if (uam.password.needsToBeUpgraded) {
						uam.password = pass;
						uam.save();
					}
					return uam.user.getUser();
				}
			}
			
			return null;
		}
		
		registerAuthProvider(&dbAuthProvider);
		
		bool dbAuthCheckProvider(string user) {
			size_t uam = UserAuthModel.query()
				.username_eq(user)
					.count();
			
			return (uam > 0);
		}
		
		registerUserExistsProvider(&dbAuthCheckProvider);
	}
}