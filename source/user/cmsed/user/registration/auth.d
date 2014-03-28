module cmsed.user.registration.auth;
import cmsed.user.models.user;

/**
 * Registers functions that provide authentication.
 */

private {
	alias UserModel delegate(string username, string password) userDel;
	alias bool delegate(string username) userExistsDel;
	userDel[] funcs;
	userExistsDel[] funcs2;
}

/**
 * Register an auth provider.
 * Note:
 * 		Does not login a user.
 */
void registerAuthProvider(userDel del) {
	synchronized {
		funcs ~= del;
	}
}

/**
 * Registers an auth check against a user/pass combination.
 */
void registerUserExistsProvider(userExistsDel del) {
	synchronized {
		funcs2 ~= del;
	}
}

/**
 * Gets a user if can be logged in.
 * 
 * Params:
 * 		user = 		The username or email to log the user in by
 * 		pass = 		The password to log the user in by
 * 
 * Returns:
 * 		Gets a UserModel given the login information. Or null if not possible.
 * 
 * See_Also:
 * 		UserModel
 */
UserModel getUserFromAuth(string user, string pass) {
	synchronized {
		foreach(del; funcs) {
			UserModel um = del(user, pass);
			if (um !is null)
				return um;
		}
		
		return null;
	}
}

/**
 * Does a check wheather or not a username exists in any provider.
 * 
 * Params:
 * 		user =		The username or email that is to be checked against
 * 
 * Returns:
 * 		If the username/email exists or not.
 */
bool getCheckUserExistsFromAuth(string user) {
	synchronized {
		foreach(del; funcs2) {
			if(del(user))
				return true;
		}
		
		return false;
	}
}