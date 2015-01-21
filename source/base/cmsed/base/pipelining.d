module cmsed.base.pipelining;
import cmsed.base.routing.defs;
import vibe.d : Json;

/**
 * Utlity functions that can be reused
 */

version(Have_cmsed_minifier) {
    void minifyJson(string mime, ref Json value) {
        import cmsed.minifier.jsmin;
        import std.conv : to;

        currentTransport.response.writeBody(cast(ubyte[])to!string(minify(to!wstring(value.toString()))), mime);
    }

    void minifyHtmlJS(string mime, ref string value) {
        import cmsed.minifier.jsmin;
        import std.conv : to;
        
        currentTransport.response.writeBody(cast(ubyte[])to!string(minify(to!wstring(value))), mime);
    }

    void minifyHtmlJS(string mime, ref dstring value) {
        import cmsed.minifier.jsmin;
        import std.conv : to;

        currentTransport.response.writeBody(cast(ubyte[])to!dstring(minify(to!wstring(value))), mime);
    }

    void minifyHtmlJS(string mime, ref wstring value) {
        import cmsed.minifier.jsmin;
        
        currentTransport.response.writeBody(cast(ubyte[])minify(value), mime);
    }
}

version(Have_cssexpand) {
	void cssExpanderDenest(string mime, ref string value) {
		import cmsed.base.util : replace;
		import cssexpand : CssMacroExpander;
		static CssmacroExpander cme = new CssMacroExpander();

		value = cme.expandAndDenest(value.replace("$", "¤").replace("__DOLLAR__", "$"));
	}
}

void templatedFiles(string ext, ref string filename, ref string filesPath) {
    import cmsed.base.templates;
    import vibe.d : Path;

    string ppPath = Path(filesPath).parentPath().toNativeString();
    
    Render render = Render([ppPath, filesPath], filename);
    render.handleReturn();
}

void defaults(string mime, ref Json value) {
	currentTransport.response.writeBody(cast(ubyte[])value.toString(), mime);
}

void defaults_file(string ext, ref string value, ref string extra) {
	import cmsed.base.registration.pipeline;
	import cmsed.base.mimetypes : getNameFromExtension;
	import std.file : read;
	
	string mime = getNameFromExtension(ext);
	auto data = read(value);
	
	if (mime in stringPipeLine)
		pipelineHandle(mime, cast(string)data);
	else if (mime in dstringPipeLine)
		pipelineHandle(mime, cast(dstring)data);
	else if (mime in wstringPipeLine)
		pipelineHandle(mime, cast(wstring)data);
	else
		pipelineHandle(mime, cast(ubyte[])data);
}

void defaults(string mime, ref string value) {
	currentTransport.response.writeBody(cast(ubyte[])value, mime);
}

void defaults(string mime, ref wstring value) {
	currentTransport.response.writeBody(cast(ubyte[])value, mime);
}

void defaults(string mime, ref dstring value) {
	currentTransport.response.writeBody(cast(ubyte[])value, mime);
}

void defaults(string mime, ref ubyte[] value) {
	currentTransport.response.writeBody(value, mime);
}