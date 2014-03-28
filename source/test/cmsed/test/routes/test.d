module cmsed.test.routes.test;
import cmsed.base;
import cmsed.test.models;

class Test : OORoute {
	@RouteFunction(RouteType.Get, "/")
	void index() {
		http_response.writeBody("");
	}
	
	@RouteGroup(null, "/.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
}