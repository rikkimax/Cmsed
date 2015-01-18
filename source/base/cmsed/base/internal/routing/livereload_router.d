module cmsed.base.internal.routing.livereload_router;
import cmsed.base.internal.defs;
import cmsed.base.routing.defs;
import cmsed.base.routing.ctfe_router;
import vibe.d : HTTPServerRequest, HTTPServerResponse, HTTPServerRequestHandler, logInfo;
import std.functional : toDelegate;

static if (Router_Use_Dakka_Server) {
    void add_dakka_router(CTFEURLRouter router) {
        router.registerRouter(new RouteInformation(RouteType.Any, "cmsed.routing.livereload_router", null, "remoteHandler"), null, toDelegate(&remoteHandler));

        version(LiveReload_Built) {
            registerAllTypes();
        }
    }

    void remoteHandler() {
        static AllActorRefs!CmsedRemoteRouter remoteRouter;
        static HTTPReqResp transport;

        if (remoteRouter is null) {
            remoteRouter = new AllActorRefs!CmsedRemoteRouter;
            transport = new HTTPReqResp();
        }

        transport.assignData(currentTransport.request, currentTransport.response, currentTransport.session);
        remoteRouter.handle(transport);
    }

    private {
        version(LiveReload_Built) {
            pure void registerAllTypes() {
                import livereload.bininfo;

                foreach(DFILE; DFILES) {
                    if (__traits(compiles, {mixin("import " ~ DFILE ~ ";");})) {
                        autoRegister!DFILE;
                    }
                }
            }
        }
    }
}

static if (Router_Use_Dakka_Server || Router_Use_Dakka_Client) {
    import dakka.base.defs;
    import dakka.vibe.server : HTTPReqResp;

    @DakkaSingleton
    class CmsedRemoteRouter : Actor {

        @DakkaCall(DakkaCallStrategy.Sequentially)
        void handle(HTTPReqResp transport) {
            static if (Router_Use_Dakka_Client) {
                getRouter().handleRequest(IOTransport(transport.client_request, transport.client_response));
            }
        }
    }
}