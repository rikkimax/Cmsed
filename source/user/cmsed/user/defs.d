module cmsed.user.defs;

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