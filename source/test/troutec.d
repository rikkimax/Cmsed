module test.troutec;
import cmsed.base.udas;
import cmsed.base.routing.defs;

class Test : OORoute {
    @RouteFunction(RouteType.Get, "/")
    void index() {
        currentTransport.response.writeBody("");
    }
    
    @RouteFunction(RouteType.Get, "/myindex")
    string myindex() {
        return "<html><body>Hi there!</body></html>";
    }
}