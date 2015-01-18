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

void templatedFiles(string ext, ref string filename, ref string filesPath) {
    import cmsed.base.templates;
    import vibe.d : Path;

    string ppPath = Path(filesPath).parentPath().toNativeString();
    
    Render render = Render([ppPath, filesPath], filename);
    render.handleReturn();
}