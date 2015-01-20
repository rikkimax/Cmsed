module cmsed.base.templates;
import vibe.core.core : TaskLocal;

private {
    import cmsed.base.internal.templating.parser;
    TaskLocal!(ParsedTemplate[string]) files;
    TaskLocal!(ubyte[4][string]) fileCRCs;
    TaskLocal!(ulong[string]) fileChangedLast;

    __gshared string defaultRenderer = "lua";
}

void setDefaultRenderer(string value) {
    defaultRenderer = value;
}

struct Render {
    private {
        string[] searchPaths;
    }

    this(T...)(string[] searchPaths, string filename, T values) {
        Render.prerenderFile(filename, searchPaths);
        
        void returnHandler() {
            execute(RendererControls(this, filename), true, values);
        }

        this.searchPaths = searchPaths;
        handleReturn = &returnHandler;
    }

    this(T...)(string filename, T values) {
        this(cast(string[])[], filename, values);
    }

    void delegate() handleReturn;

    static {
        string prerenderText(string text, string file = __FILE__, int line = __LINE__) {
            import std.conv : to;
            import std.digest.crc : crc32Of;

            string filename = "**internal**_" ~ file ~ "_template_" ~ to!string(line) ~ ".tpl";

            if (filename in fileCRCs.storage()) {
                ubyte[4] hash = crc32Of(text);

                if (hash == fileCRCs.storage()[filename]) {
                    return filename;
                }
            }

            prerender(filename, text);

            return filename;
        }

        void prerenderFile(string name, string[] searchPaths...) {
			import cmsed.base.util : utc0Time;
			import cmsed.base.caches;
            import std.file : timeLastModified, readText, exists;
            import std.path : buildPath;

			auto templat = getPageTemplateByName(name);
			if (templat !is null && templat.value !is null) {
				fileChangedLast.storage()[name] = utc0Time();
				prerender(name, templat.value);
			} else {
				string filename = name;
				ulong time;

				if (!exists(name)) {
	                foreach(path; searchPaths) {
	                    string apath = buildPath(path, name);
	                    if (exists(apath))
	                        filename = apath;
	                }
	            }

	            if (name in files.storage()) {
	                if (filename in fileChangedLast.storage()) {
	                    time = timeLastModified(filename).toUnixTime();
	                    ulong whenChanged = fileChangedLast.storage()[filename];

	                    if (whenChanged == time) {
	                        return;
	                    }

	                } else {
	                    return;
	                }
	            }

				if (exists(filename)) {
	            	fileChangedLast.storage()[filename] = time;
	            	prerender(name, readText(filename));
				} else {
					assert(0, "Unknown template"); //TODO: something better?
				}
			}
		}

        private {
            void prerender(string filename, string text) {
                files.storage()[filename] = ParsedTemplate.parse(text);
            }
        }
    }

    private {
        void execute(T...)(RendererControls controls, bool mainCall, T values) {
            import cmsed.base.registration.pipeline : pipelineHandle;
            import cmsed.base.internal.defs;
            import cmsed.base.mimetypes;

            auto templateSST = files.storage()[controls.filename];

            foreach(i, ref part; templateSST.parts) {
                string codeType = part.codeType;
                if (controls.ignoreNext) {
                    controls.ignoreNext = false;
                    continue;
                }

                if (templateSST.parts.length > i + 1) {
                    controls.nextPart = templateSST.parts[i + 1];
                } else {
                    controls.nextPart = null;
                }

                if (part.isCode) {

                    if (codeType == "")
                        codeType = defaultRenderer;

                    if (codeType == "lua") {
                        static if (SupportsLuaTemplating) {
                            import cmsed.base.internal.templating.evaluator_lua;
                            LuaEvaluator(controls, part.text, values);
                        } else {
                            assert(0, "Cannot handle lua template");
                        }
                    }

                } else {
                    controls.buffer.write(part.text);
                }
            }

            if (mainCall) {
                pipelineHandle(getTemplateForType(controls.mime), controls.buffer.toString());
            }
        }
    }
}

struct RendererControls {
    import cmsed.base.internal.templating.parser;
    import std.outbuffer : OutBuffer;
    import std.typecons;

    private {
        Render render;
        OutBuffer buffer_;
        string filename;
        string mime_;
        bool passArgs_;
        int instanceOfText;

        bool ignoreNext;
        ParsedTemplatePart nextPart;
    }

    private this(Render render, string filename, OutBuffer buffer = new OutBuffer, bool passArgs = true) {
        this.render = render;
        this.buffer_ = buffer;
        this.filename = filename;
        this.passArgs_ = passArgs;
        this.mime_ = "html";
    }

    @disable this();

    @property ref string mime() {
        return mime_;
    }

    @property ref OutBuffer buffer() {
        return buffer_;
    }

    @property bool passArgs() {
        return passArgs_;
    }

    void include(string filename) {
        auto render2 = Render(render.searchPaths, filename);
        auto controls = RendererControls(render2, filename, buffer, false);

        render2.execute(controls, false);
    }

    void include_text(string text) {
        auto name = Render.prerenderText(text, filename, instanceOfText);
        instanceOfText++;
        include(name);
    }

    void echo(string text) {
        buffer_.write(text);
    }

    void set(string property, string value) {
        switch(property) {
            case "mime":
            case "mimetype":
                this.mime_ = value;
                break;
            default:
                break;
        }
    }

    Tuple!(string, string) peekNext() {
        if (nextPart is null)
            return tuple("", "");
        else
            return tuple(nextPart.codeType, nextPart.text);
    }

    Tuple!(string, string) consumeNext() {
        ignoreNext = true;
        if (nextPart is null)
            return tuple("", "");
        else
            return tuple(nextPart.codeType, nextPart.text);
    }
}