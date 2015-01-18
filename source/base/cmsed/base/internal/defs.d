module cmsed.base.internal.defs;

version(Have_dakka_vibe_d_wrappers) {
    version(CmsedStaticBuilt) {
        enum Router_Use_Dakka_Server = true;
		enum Router_Use_Dakka_Client = false;
        enum Cmsed_Standalone = false;
    } else version(CmsedDynamicBuilt) {
		enum Router_Use_Dakka_Server = false;
		enum Router_Use_Dakka_Client = true;
        enum Cmsed_Standalone = false;
    } else {
		enum Router_Use_Dakka_Server = false;
		enum Router_Use_Dakka_Client = false;
        enum Cmsed_Standalone = true;
    }
} else {
	enum Router_Use_Dakka_Server = false;
	enum Router_Use_Dakka_Client = false;
    enum Cmsed_Standalone = true;
}

version(Have_cmsed_lua) {
    enum SupportsLuaTemplating = true;
} else {
    enum SupportsLuaTemplating = false;
}

/**
 * Default configuration for cmsed.base.registration.pipeline
 * With minifier
 */

shared static this() {
    import cmsed.base.pipelining;
    import cmsed.base.registration.pipeline;
    import cmsed.base.mimetypes;

    version(Have_cmsed_minifier) {
        assignJsonHandler!(minifyJson);
        
        assignStringHandler!(minifyHtmlJS)(getTemplateForType("html"));
        assignDStringHandler!(minifyHtmlJS)(getTemplateForType("html"));
        assignWStringHandler!(minifyHtmlJS)(getTemplateForType("html"));
        
        assignStringHandler!(minifyHtmlJS)(getTemplateForType("javascript"));
        assignDStringHandler!(minifyHtmlJS)(getTemplateForType("javascript"));
        assignWStringHandler!(minifyHtmlJS)(getTemplateForType("javascript"));
        
        assignStringHandler!(minifyHtmlJS)(getTemplateForType("css"));
        assignDStringHandler!(minifyHtmlJS)(getTemplateForType("css"));
        assignWStringHandler!(minifyHtmlJS)(getTemplateForType("css"));
    }

    assignFileHandler!templatedFiles("tpl");
}