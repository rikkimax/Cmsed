module cmsed.user.models;
import cmsed.base;

public import cmsed.user.models.user;

shared static this() {
	registerModel!UserModel;
}