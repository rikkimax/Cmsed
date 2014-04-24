module cmsed.user.models.group;
import cmsed.user.models.user;
import cmsed.user.models.policy;
import cmsed.base;
import dvorm;
import vbson = vibe.data.bson;

/**
 * A group model to contain a list of users with.
 */
@dbName("Group")
@shouldNotGenerateJavascriptModel
class GroupModel {
	/**
	 * The id to use. Is generated.
	 * 
	 * See_Also:
	 * 		GroupIdModel
	 */
	@dbId
	@dbName("")
	GroupIdModel key;
	
	/**
	 * The title the group.
	 * 
	 * Example:
	 * 		Administrator
	 *      Moderator
	 */
	string title;
	
	/**
	 * When the group was created on.
	 */
	ulong createdOn;
	
	/**
	 * Generates the key and sets when it was created.
	 */
	@dbIgnore
	void generateKey() {
		key.name = vbson.BsonObjectID.generate().toString();
		createdOn = utc0Time();
	}
	
	mixin OrmModel!GroupModel;
	
	/**
	 * Gets all users that are a member of this group.
	 * 
	 * Returns:
	 * 		The users in the group
	 */
	@dbIgnore
	UserModel[] getUsers() {
		import cmsed.user.models.usergroup;
		return UserGroupModel.query().group_name_eq(key.name).find_by_user();
	}
	
	/**
	 * Gets all the policies which apply to this group.
	 * 
	 * Returns:
	 * 		All the policies for this group
	 */
	@dbIgnore
	PolicyModel[] getPolicies() {
		import cmsed.user.models.grouppolicy;
		return GroupPolicyModel.query().group_name_eq(key.name).enabled_eq(true).find_by_policy();
	}
}

/**
 * A reusable model that identifies a group.
 * Is not a model that can be directly used.
 * Designed to be embedded in others.
 * 
 * See_Also:
 * 		GroupModel
 */
struct GroupIdModel {
	/**
	 * The unique identifier for this group.
	 */
	@dbId
	@dbName("id")
	string name;
	
	/**
	 * Get the group based on this key.
	 * 
	 * See_Also:
	 * 		GroupModel
	 */
	@dbIgnore
	GroupModel getGroup() {
		return GroupModel.findOne(name);
	}
}