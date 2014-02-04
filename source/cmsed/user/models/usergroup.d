module cmsed.user.models.usergroup;
public import cmsed.user.models.user : UserIdModel, UserModel;
public import cmsed.user.models.group : GroupIdModel, GroupModel;
import cmsed.base;
import dvorm;
import vbson = vibe.data.bson;

/**
 * A user to group joining model.
 */
@dbName("UserGroup")
@shouldNotGenerateJavascriptModel
class UserGroupModel {
	@dbId {
		@dbName("_id")
		string key;
		
		/**
		 * The user to be joined to
		 */
		@dbDefaultValue(null)
		UserIdModel user = new UserIdModel;
		
		/**
		 * The group to be joined to
		 */
		@dbDefaultValue(null)
		GroupIdModel group = new GroupIdModel;
	}
	
	/**
	 * When did the user join this group?
	 */
	ulong joined;
	
	/**
	 * Generates the key and sets the joined date/time.
	 */
	void generateKey() {
		key = vbson.BsonObjectID.generate().toString();
		joined = utc0Time();
	}
	
	mixin OrmModel!UserGroupModel;
	
	/**
	 * Gets the user based upon the user key.
	 */
	UserModel getUser() {
		return user.getUser();
	}
	
	/**
	 * Gets the group based upon the group key
	 */
	GroupModel getGroup() {
		return group.getGroup();
	}
	
	/**
	 * Get all group joins for a user
	 */
	static UserGroupModel[] getByUser(UserModel user) {
		return UserGroupModel.query()
			.user_key_eq(user.key.key)
				.find();
	}
	
	/**
	 * Get all user joins for a group
	 */
	static UserGroupModel[] getByGroup(GroupModel group) {
		return UserGroupModel.query()
			.group_key_eq(group.key.key)
				.find();
	}
}