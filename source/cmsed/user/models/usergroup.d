module cmsed.user.models.usergroup;
public import cmsed.user.models.user : UserIdModel, UserModel;
public import cmsed.user.models.group : GroupIdModel, GroupModel;
import cmsed.base;
import dvorm;
import vbson = vibe.data.bson;

@dbName("UserGroup")
class UserGroupModel {
	@dbId {
		@dbName("_id")
		string key;
		
		@dbDefaultValue(null)
		UserIdModel user = new UserIdModel;
		
		@dbDefaultValue(null)
		GroupIdModel group = new GroupIdModel;
	}
	
	ulong joined;
	
	void generateKey() {
		key = vbson.BsonObjectID.generate().toString();
		joined = utc0Time();
	}
	
	mixin OrmModel!UserGroupModel;
	
	UserModel getUser() {
		return user.getUser();
	}
	
	GroupModel getGroup() {
		return group.getGroup();
	}
	
	static UserGroupModel[] getByUser(UserModel user) {
		return UserGroupModel.query()
			.user_key_eq(user.key.key)
				.find();
	}
	
	static UserGroupModel[] getByGroup(GroupModel group) {
		return UserGroupModel.query()
			.group_key_eq(group.key.key)
				.find();
	}
}