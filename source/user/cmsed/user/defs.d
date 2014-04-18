module cmsed.user.defs;
import cmsed.user.operations : ModelAuthProvider;
import std.traits : moduleName;

/**
 * A bunch of user group titles.
 */
enum UserGroup : string {
	Admin = "administrator",
	Administrator = Admin,
	Mod = "moderator",
	Moderator = Mod,
	User = "user",
	Guest = "guest"
}

enum BUILT_IN_DB_AUTH = moduleName!ModelAuthProvider;