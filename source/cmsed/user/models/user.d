module cmsed.user.models.user;
import cmsed.user.models.group;
import cmsed.user.models.usergroup;
import cmsed.base.util;
import dvorm;
import vbson = vibe.data.bson;
import std.string : split;

@dbName("User")
class UserModel {
	@dbId
	@dbName("")
	UserIdModel key = new UserIdModel;
	
	NameModel name = new NameModel;
	
	ulong dateOfBirth;
	ulong createdOn;
	
	void generateKey() {
		key.key = vbson.BsonObjectID.generate().toString();
		createdOn = utc0Time();
	}
	
	mixin OrmModel!UserModel;
	
	GroupModel[] getGroups() {
		GroupModel[] ret;
		foreach(ug; UserGroupModel.query().user_key_eq(key.key).find()) {
			ret ~= ug.getGroup();
		}
		return ret;
	}
}

class UserIdModel {
	@dbId {
		@dbName("id")
		string key;
	}
	
	@dbIgnore
	UserModel getUser() {
		return UserModel.findOne(key);
	}
}

class NameModel {
	@dbId {
		string first;
		string middle;
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