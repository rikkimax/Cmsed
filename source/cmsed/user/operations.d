module cmsed.user.operations;
import cmsed.user.models.user;
import cmsed.user.models.userauth;
import cmsed.user.models.usergroup;
import cmsed.user.registration.auth;
import cmsed.base.routing;

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
			UserPassword up = new UserPassword;
			up = pass;
			UserAuthModel[] uam = UserAuthModel.query()
				.username_eq(user)
					.password_hash_eq(up.hash)
					.find();
			
			if (uam.length == 0) return null;
			
			return uam[0].user.getUser();
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