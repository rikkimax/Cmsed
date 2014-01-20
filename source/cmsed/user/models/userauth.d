module cmsed.user.models.userauth;
public import cmsed.user.models.user : UserModel, UserIdModel;
import cmsed.base.util;
import dvorm;
import vbson = vibe.data.bson;
import std.digest.ripemd;

@dbName("User")
class UserAuthModel {
	@dbId {
		@dbName("")
		UserIdModel user = new UserIdModel;
		
		string username;
	}
	
	UserPassword password = new UserPassword;
	
	mixin OrmModel!UserAuthModel;
}

class UserPassword {
	@dbId {
		string hash;
	}
	
	void opAssign(string text) {
		hash = hashText(text);
	}
	
	bool opCmp(string op)(string text) {
		return hash == hashText(text);
	}
	
	private {
		string hashText(string text) {
			return toHexString(ripemd160Of(text));
		}
	}
}