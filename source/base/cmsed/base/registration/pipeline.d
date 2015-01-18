module cmsed.base.registration.pipeline;
import cmsed.base.util;
import cmsed.base.routing.defs;
import cmsed.base.mimetypes;
import vibe.d : Json;

private __gshared {
    void function(string, ref Json) jsonPipeLine;

    void function(string, ref string, ref string)[string] filePipeLine;
    void function(string, ref string)[string] stringPipeLine;
    void function(string, ref wstring)[string] wstringPipeLine;
    void function(string, ref dstring)[string] dstringPipeLine;

    void function(string, ref ubyte[])[string] anyPipeLine;
}

/*
 * Assign handlers 
 */

/**
 * Assigns a handler for a json.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 */
void assignJsonHandler(funcs...)() {
    synchronized {
        jsonPipeLine = &Multi!(string, Json).call!funcs;
    }
}

/**
 * Assigns a handler for a mime types values.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 *      ext     =   The extension of the file
 */
void assignFileHandler(funcs...)(string ext) {
    synchronized {
        filePipeLine[ext] = &Multi!(string, string, string).call!funcs;
    }
}

/**
 * Assigns a handler for a mime types values.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 *      mime    =   The mime type that the function set handles
 */
void assignStringHandler(funcs...)(string mime) {
    synchronized {
        stringPipeLine[mime] = &Multi!(string, string).call!funcs;
    }
}

/**
 * Assigns a handler for a mime types values.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 *      mime    =   The mime type that the function set handles
 */
void assignWStringHandler(funcs...)(string mime) {
    synchronized {
        wstringPipeLine[mime] = &Multi!(string, wstring).call!funcs;
    }
}

/**
 * Assigns a handler for a mime types values.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 *      mime    =   The mime type that the function set handles
 */
void assignDStringHandler(funcs...)(string mime) {
    synchronized {
        dstringPipeLine[mime] = &Multi!(string, dstring).call!funcs;
    }
}

/**
 * Assigns a handler for a mime types values.
 * 
 * Params:
 *      funcs   =   A variadic list of delegates/functions to call in order
 *      mime    =   The mime type that the function set handles
 */
void assignHandler(funcs...)(string mime) {
    synchronized {
        dstringPipeLine[mime] = &Multi!(string, ubyte[]).call!funcs;
    }
}

/*
 * Use handlers
 */

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * 
 * Params:
 *      mime    =   The mime type of the data
 *      value   =   The data to output
 */
void pipelineHandle(Json value) {
    if (jsonPipeLine is null) {
        defaults(getTemplateForType("json"), value);
    } else {
        jsonPipeLine(getTemplateForType("json"), value);
    }
}

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * 
 * Params:
 *      ext         =   The extension of the filename
 *      filename    =   Filename of file to handle
 *      fsPath      =   The path to where the file is under
 */
void pipelineHandle(string ext, string filename, string fsPath) {
    filePipeLine.get(ext, &defaults_file)(ext, filename, fsPath);
}

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * 
 * Params:
 *      mime    =   The mime type of the data
 *      value   =   The data to output
 */
void pipelineHandle(string mime, string value) {
    stringPipeLine.get(mime, &defaults)(mime, value);
}

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * 
 * Params:
 *      mime    =   The mime type of the data
 *      value   =   The data to output
 */
void pipelineHandle(string mime, wstring value) {
    wstringPipeLine.get(mime, &defaults)(mime, value);
}

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * 
 * Params:
 *      mime    =   The mime type of the data
 *      value   =   The data to output
 */
void pipelineHandle(string mime, dstring value) {
    dstringPipeLine.get(mime, &defaults)(mime, value);
}

/**
 * Ensures the output that would normally go into response is e.g. minified and handled correctly.
 * 
 * Outputs the given data into the stream reguardless of if its handleable.
 * Defaults to null mime type handler and if that doesn't exist defaults to straight output.
 * 
 * Params:
 *      mime    =   The mime type of the data
 *      value   =   The data to output
 */
void pipelineHandle(string mime, ubyte[] value) {
    anyPipeLine.get(mime, anyPipeLine.get(null, &defaults))(mime, value);
}

package {
    void logOnLoad() {
        import cmsed.base.config;
        import vibe.core.file : writeFile, appendToFile;
        import vibe.inet.path;
        import std.conv;

        Path path = Path(configuration.logging.dir) ~ Path(configuration.logging.pipelineFile);
        writeFile(path, []);

        appendToFile(path, jsonPipeLine is null ? "Does not have a json handler\n" : "Has a json handler\n");
        appendToFile(path, "string handlers " ~ to!string(stringPipeLine.keys));
        appendToFile(path, "wstring handlers " ~ to!string(wstringPipeLine.keys));
        appendToFile(path, "dstring handlers " ~ to!string(dstringPipeLine.keys));
        appendToFile(path, "any handlers " ~ to!string(anyPipeLine.keys));
    }
}

private {
    void defaults(string mime, ref Json value) {
        currentTransport.response.writeBody(cast(ubyte[])value.toString(), mime);
    }

    void defaults_file(string ext, ref string value, ref string extra) {
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
}