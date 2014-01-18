module cmsed.test.models;
import cmsed.base.registration.model;

public import cmsed.test.models.book;

shared static this() {
	registerModel!Book3;
	registerModel!Page3;
}