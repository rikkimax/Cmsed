module test;
public import test.troute;
public import test.troutec;
public import test.turlroute;
public import test.trestful;
public import test.ttemplateroute;

shared static this() {
    import cmsed.base.registration.autoregister;
    autoRegister!__MODULE__;

    import cmsed.base.routing.defs;
    getURLRouter().get("/turlroute", &myurlroute);
}