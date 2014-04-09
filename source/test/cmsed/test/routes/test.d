module cmsed.test.routes.test;
import cmsed.base;
import cmsed.test.models;
import vibe.d : Json;

@jsRouteName("test_route")
class Test : OORoute {
	@RouteFunction(RouteType.Get, "/")
	void index() {
		http_response.writeBody("");
	}
	
	@RouteFunction(RouteType.Get, "/myindex", "index")
	bool myindex() {
		return true;
	}
	
	@RouteGroup(null, "/.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
	
	@RouteFunction(RouteType.Get, "/someargs")
	void someArgs(string a, string b) {
		http_response.writeBody(a ~ ", " ~ b);
	}
	
	@RouteFunction(RouteType.Get, "/mytext")
	string myText() {
		return "Hello World!";
	}
	
	@RouteFunction(RouteType.Get, "/myjson")
	Json myJson() {
		Json ret = Json.emptyObject();
		ret["Hello"] = Json("World!");
		return ret;
	}
}