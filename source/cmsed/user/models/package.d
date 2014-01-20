module cmsed.user.models;
import cmsed.base;

public import cmsed.user.models.user;
public import cmsed.user.models.usergroup;
public import cmsed.user.models.group;
public import cmsed.user.models.userauth;

shared static this() {
	registerModel!UserModel;
	registerModel!UserGroupModel;
	registerModel!GroupModel;
	registerModel!UserAuthModel;
}