module cmsed.user.models.user;
import cmsed.user.models.group;
import cmsed.user.models.policy;
import cmsed.base.util;
import cmsed.base.defs;
import dvorm;
import vbson = vibe.data.bson;
import std.string : split;

/**
 * A user.
 */
@dbName("User")
@shouldNotGenerateJavascriptModel
class UserModel {
	/**
	 * A unique identifer.
	 * Automatically generated.
	 * 
	 * See_Also:
	 * 		UserIdModel
	 */
	@dbId
	@dbName("")
	UserIdModel key;
	
	/**
	 * The name of the user.
	 * Example:
	 * 		NameModel name = new NameModel;
	 * 		name = "richard andrew cattermole";
	 * 		assert(name.first == "richard")
	 * 		assert(name.middle == "andrew")
	 * 		assert(name.last == "cattermole")
	 * 
	 * 		name = "richard cattermole";
	 * 		assert(name.first == "richard")
	 * 		assert(name.last == "cattermole")
	 */
	NameModel name;
	
	/**
	 * UTC0 time in unix form of when the user was born.
	 */
	ulong dateOfBirth;
	
	/**
	 * UTC0 time in unix format of when the user joined.
	 */
	ulong createdOn;
	
	/**
	 * Generats the key and sets when the user joined.
	 */
	void generateKey() {
		key.name = vbson.BsonObjectID.generate().toString();
		createdOn = utc0Time();
	}
	
	mixin OrmModel!UserModel;
	
	/**
	 * Get all the groups the user is a member of.
	 * 
	 * See_Also:
	 * 		GroupModel
	 */
	GroupModel[] getGroups() {
		import cmsed.user.models.usergroup;
		
		GroupModel[] ret;
		foreach(ug; UserGroupModel.query().user_name_eq(key.name).find()) {
			ret ~= ug.getGroup();
		}
		return ret;
	}
	
	PolicyModel[] getPolicies() {
		import cmsed.user.models.userpolicy;
		
		PolicyModel[] ret;
		foreach(pm; UserPolicyModel.query().user_name_eq(key.name).enabled_eq(true).find()) {
			ret ~= pm.getPolicy();
		}
		return ret;
	}
}

/**
 * Uniquely identifies a user.
 * Designed to be embbeded. Not a model in its own right.
 * 
 * See_Also:
 * 		UserModel
 */
struct UserIdModel {
	@dbId {
		@dbName("id")
		string name;
	}
	
	@dbIgnore
	UserModel getUser() {
		return UserModel.findOne(name);
	}
}

/**
 * A class that handles a name. Automatically seperates out first/middle/last.
 */
struct NameModel {
	@dbId {
		/**
		 * Persons first name.
		 * Note not optional.
		 */
		string first;
		
		/**
		 * Persons middle name.
		 * Note only supports one. And is optional.
		 */
		string middle;
		
		/**
		 * A persons last name.
		 * Note not optional.
		 */
		string last;
	}
	
	@dbIgnore
	void opAssign(string s) {
		string[] names = s.split(" ");
		if (names.length >= 1)
			first = names[0];
		if (names.length == 2)
			last = names[1];
		if (names.length == 3) {
			middle = names[1];
			last = names[2];
		}
	}
}