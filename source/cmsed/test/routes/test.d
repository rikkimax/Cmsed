module cmsed.test.routes.test;
import cmsed.base.routing;
import cmsed.base.restful;
import cmsed.test.models.book;

class Test : OORoute {
	@RouteGroup(null, "/.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
}