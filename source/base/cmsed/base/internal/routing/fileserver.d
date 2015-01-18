module cmsed.base.internal.routing.fileserver;
import cmsed.base.routing.defs;
import vibe.d : TaskLocal, Path, readFile, existsFile, appendToFile;

TaskLocal!(ubyte[]) buffer;

void delegate() fileServer(string urlPath, string fsPath) {
    import cmsed.base.config;
    import std.path : extension, buildPath;
    Path errorFile = Path(buildPath(configuration.logging.dir, configuration.logging.errorFile));

    void ret() {
        import cmsed.base.mimetypes;
        import cmsed.base.registration.pipeline;

        if (buffer is null) {
            try {
                auto tbuffer = new ubyte[32000000]; // 32mb
                buffer = TaskLocal!(ubyte[])();
                buffer = tbuffer;
            } catch (Error e) {
                // too large of an allocation
                appendToFile(errorFile, "Could not allocate buffer for file server.\n");
            }
        }

        string path = currentTransport.request.path[urlPath.length .. $];
        if (path == "" || path == "/")
            return;
        if (path[0] == '/')
            path = path[1 .. $];

        string ext = extension(path);
        if (ext.length > 0)
            ext = ext[1 .. $];

        Path fsPatht = Path(fsPath) ~ Path(path);
        fsPatht.normalize();

        if (!existsFile(fsPatht))
            return;

        // reenable caching
        currentTransport.response.headers["Last-modified"] = lastModified(fsPatht);
        currentTransport.response.headers["ETag"] = etag(fsPatht);
        currentTransport.response.headers["Cache-control"] = "public";

        pipelineHandle(ext, fsPatht.toNativeString(), fsPath);
    }
    return &ret;
}

string lastModified(Path path) {
    import vibe.d : getFileInfo, FileInfo, toRFC822DateTimeString;
    FileInfo info = getFileInfo(path);
    return toRFC822DateTimeString(info.timeModified);
}

string etag(Path path) {
    import cmsed.base.util : utc0Compiled;
    import vibe.d : getFileInfo, FileInfo;
    import std.conv : to;

    FileInfo info = getFileInfo(path);
    string hashText = info.name ~ to!string(info.size) ~ to!string(info.timeModified);
    string hashText2 = path.toNativeString() ~ to!string(utc0Compiled);
    return info.name ~ "_" ~ to!string(typeid(string).getHash(&hashText)) ~ "_" ~ to!string(typeid(string).getHash(&hashText2));
}