module cmsed.test.routes.test;
import cmsed.base;
import cmsed.test.models;

@jsRouteName("test_route")
class Test : OORoute {
	@RouteFunction(RouteType.Get, "/")
	void index() {
		http_response.writeBody("");
	}
	
	@RouteGroup(null, "/.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
	
	@RouteFunction(RouteType.Get, "/someargs")
	void someArgs(string a, string b) {
		http_response.writeBody(a ~ ", " ~ b);
	}
}