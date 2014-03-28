module cmsed.user.models.userauth;
public import cmsed.user.models.user : UserModel, UserIdModel;
import cmsed.base.util;
import cmsed.base.defs;
import dvorm;
import vbson = vibe.data.bson;
import std.digest.ripemd;
import std.base64;

/**
 * Provides database storage for the default user authentication provider.
 */
@dbName("UserAuth")
@shouldNotGenerateJavascriptModel
class UserAuthModel {
	@dbId {
		/**
		 * The user to authenticate against.
		 * 
		 * See_Also:
		 * 		UserModel, UserIdModel
		 */
		@dbName("")
		UserIdModel user = new UserIdModel;
		
		/**
		 * The username/email to identify for.
		 */
		string username;
	}
	
	/**
	 * The password to utilise.
	 * 
	 * Example:
	 * 		UserPassword password = new UserPassword;
	 * 		password = "hi";
	 * 		if (password == "bye") assert(0);
	 * 		else if (password == "hi")
	 * 			writeln("yay password is correct");
	 *      else assert(0);
	 */
	UserPassword password = new UserPassword;
	
	mixin OrmModel!UserAuthModel;
}

/**
 * A simple ripemd 160 hashed password to authenticate against.
 * Stores a hash and can compare and set via a non hashed string.
 */
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
			return Base64.encode(ripemd160Of(text));
		}
	}
}