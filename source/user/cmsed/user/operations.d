module cmsed.user.operations;
import cmsed.user;
import cmsed.user.models;
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
	UserModel um = checker.validCredentials(userName, password);
	if (um is null) return false;
	
	session["userId"] = um.key.key;
	return true;
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
	class ModelAuthProvider : AuthProvider {
		bool hasIdentifier(string identifier) {
			size_t uam = UserAuthModel.query()
				.username_eq(identifier)
					.count();
			
			return (uam > 0);
		}
		
		UserModel validCredentials(string identifier, string validator) {
			UserAuthModel[] uams = UserAuthModel.query()
				.username_eq(identifier).find();
			
			foreach(uam; uams) {
				if (uam.password == validator) {
					if (uam.password.needsToBeUpgraded) {
						uam.password = validator;
						uam.save();
					}
					return uam.user.getUser();
				}
			}
			
			return null;
		}
		
		bool changeValidator(string identifier, string validator) {
			return false;
		}
		
		@property string identifier() {
			return BUILT_IN_DB_AUTH;
		}
		
		GroupModel[] identifierGroups(string identifier) {
			UserAuthModel[] uams = UserAuthModel.query()
				.username_eq(identifier).find();
			
			if (uams.length > 0) {
				UserAuthModel uam = uams[0];
				return uam.user.getUser().getGroups();
			}
			
			return null;
		}
		
		void logLogin(string identifier) {
			// this may be a good idea to do something with.
		}
	}
	
	shared static this() {
		registerAuthProvider!ModelAuthProvider;
	}
}