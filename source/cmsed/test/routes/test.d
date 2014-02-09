module cmsed.test.routes.test;
import cmsed.base.routing;
import cmsed.base.restful;
import cmsed.test.models.book;

class Test : OORoute {
	@RouteGroup(null, "/test.svc") {
		mixin RestfulRoute!(RestfulProtection.All, Book3, Page3);
	}
}

shared static this() {
	import cmsed.base.registration.onload;
	
	void func(bool isInstall) {
		Book3 book = new Book3;
		book.key.isbn = "AS-DF-TF";
		book.edition = 8;
		book.save();
	}
	
	registerOnLoad(&func);
}