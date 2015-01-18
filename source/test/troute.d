module test.troute;
import cmsed.base.udas;

@RouteGroup("/test") {

    @RouteFunction(RouteType.Get, "/first")
    string first() {
        return "hi there!";
    }

}