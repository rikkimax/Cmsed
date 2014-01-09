module cmsed.base.test;
import cmsed.base.routing;
import cmsed.base.registration.routes;

class Test : OORoute {
	@RouteFunction(RouteType.Get, "/", "index")
	bool test() {return true;}
}

shared static this() {
	registerRoute!Test();
}