module cmsed.test.routes.test;
import cmsed.base;
import cmsed.test.models;
import cmsed.user;
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
	
	mixin TemplatedRoute!("index", "/myindex2");
	
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
	
	@RouteFunction(RouteType.Get, "/myrss")
	auto myRss() {return new RssChannel!Book3([RssCE.Title : "All of my books"]);}
	
	@RouteFunction(RouteType.Get, "/google")
	string searchGoogle() {
		interface GoogleAPI : OORoute {
			@RouteFunction(RouteType.Get, "/?q=Cmsed")
			string search_cmsed();
		}
		
		return new RemoteAPI!GoogleAPI("https://google.com").search_cmsed();
	}
}