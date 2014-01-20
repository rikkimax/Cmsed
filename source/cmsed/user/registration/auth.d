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

void registerAuthProvider(userDel del) {
	synchronized {
		funcs ~= del;
	}
}

void registerUserExistsProvider(userExistsDel del) {
	synchronized {
		funcs2 ~= del;
	}
}

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

bool getCheckUserExistsFromAuth(string user) {
	synchronized {
		foreach(del; funcs2) {
			if(del(user))
				return true;
		}
		
		return false;
	}
}