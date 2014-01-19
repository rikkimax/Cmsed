module cmsed.user.models.group;
public import cmsed.user.models.user : UserIdModel, UserModel;
import cmsed.user.models.usergroup;
import cmsed.base;
import dvorm;
import vbson = vibe.data.bson;

@dbName("Group")
class GroupModel {
	@dbId
	@dbName("")
	GroupIdModel key = new GroupIdModel;
	
	string title;
	
	ulong createdOn;
	
	void generateKey() {
		key.key = vbson.BsonObjectID.generate().toString();
		createdOn = utc0Time();
	}
	
	mixin OrmModel!GroupModel;
	
	UserModel[] getUsersByGroup() {
		UserModel[] ret;
		foreach(ug; UserGroupModel.query().group_key_eq(key.key).find()) {
			ret ~= ug.getUser();
		}
		return ret;
	}
}

class GroupIdModel {
	@dbId {
		@dbName("id")
		string key;
	}
	
	@dbIgnore
	GroupModel getGroup() {
		return GroupModel.findOne(key);
	}
}