module cmsed.test.routes.test;
import cmsed.base;
import cmsed.test.models;

class Test : OORoute {
	@RouteGroup(null, "/.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
}