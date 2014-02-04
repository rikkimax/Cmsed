module cmsed.user.models.group;
public import cmsed.user.models.user : UserIdModel, UserModel;
import cmsed.user.models.usergroup;
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
	GroupIdModel key = new GroupIdModel;
	
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
	void generateKey() {
		key.key = vbson.BsonObjectID.generate().toString();
		createdOn = utc0Time();
	}
	
	mixin OrmModel!GroupModel;
	
	/**
	 * Gets all users that are a member of this group.
	 */
	UserModel[] getUsers() {
		UserModel[] ret;
		foreach(ug; UserGroupModel.query().group_key_eq(key.key).find()) {
			ret ~= ug.getUser();
		}
		return ret;
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
class GroupIdModel {
	/**
	 * The unique identifier for this group.
	 */
	@dbId
	@dbName("id")
	string key;
	
	/**
	 * Get the group based on this key.
	 * 
	 * See_Also:
	 * 		GroupModel
	 */
	@dbIgnore
	GroupModel getGroup() {
		return GroupModel.findOne(key);
	}
}