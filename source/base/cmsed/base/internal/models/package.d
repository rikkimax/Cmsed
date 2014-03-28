module cmsed.base.internal.models;
import cmsed.base.registration.model;

public import cmsed.base.internal.models.session;

shared static this() {
	registerModel!SessionModel();
}