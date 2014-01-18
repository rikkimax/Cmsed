module cmsed.test.routes;
import cmsed.base.registration.routes;

public import cmsed.test.routes.test;

shared static this() {
	registerRoute!Test();
}