module cmsed.user.models;
import cmsed.base;

public import cmsed.user.models.user;
public import cmsed.user.models.usergroup;
public import cmsed.user.models.group;
public import cmsed.user.models.userauth;
public import cmsed.user.models.policy;
public import cmsed.user.models.grouppolicy;

shared static this() {
	registerModel!UserModel;
	registerModel!UserGroupModel;
	registerModel!GroupModel;
	registerModel!UserAuthModel;
	registerModel!GroupPolicyModel;
	registerModel!PolicyModel;
}