module cmsed.user.models.userauth;
import cmsed.user.models.user;
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
		UserIdModel user;
		
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

// change the hash version as the hash algorithym changes.
// allows for 'upgrading' of passwords as needed.
enum CURRENT_HASH_ALG_VERSION = 0;

/**
 * A simple ripemd 160 hashed password to authenticate against.
 * Stores a hash and can compare and set via a non hashed string.
 */
class UserPassword {
	@dbId {
		string hash;
		ubyte hashVersion;
	}
	
	void opAssign(string text) {
		hashVersion = CURRENT_HASH_ALG_VERSION;
		hash = hashText(text);
	}
	
	bool opEquals(string text) {
		return hash == hashText(text);
	}
	
	@property bool needsToBeUpgraded() {
		// automatically upgrade the hash to current version.
		return hashVersion < CURRENT_HASH_ALG_VERSION;
	}
	
	private {
		string hashText(string text) {
			if (hashVersion == 0) {
				return Base64.encode(ripemd160Of(text));
			}
			
			assert(0);
		}
	}
}