module cmsed.base.internal.templating.evaluator_lua;
import cmsed.base.internal.defs;

static if(SupportsLuaTemplating) {
    import cmsed.base.internal.templating.parser;
    import cmsed.base.templates : RendererControls;
    import cmsed.lua.internal.handler;
    import luad.all;
    import std.outbuffer;

    struct LuaEvaluator {

        this(T...)(ref RendererControls controls, string part, T values) {
            auto L = getState();

            if (controls.passArgs) {
                auto args = L.newTable();
                
                foreach(i, value; values) {
                    import std.traits : isBasicType, isSomeString;
                    
                    static if (isBasicType!(typeof(value)) || isSomeString!(typeof(value))) {
                        args[i + 1] = value;
                    } else {
                        // class/struct/union
                    }
                    
                }
                L["args"] = args;

                // won't change inbetween instance calls
                L["echo_"] = &controls.echo;
            }

            L.doString("include_backups_in_()");

            // context aware include ext.
            L["include_"] = &controls.include;
            L["include_text_"] = &controls.include_text;
            L["peekNext_"] = &controls.peekNext;
            L["consumeNext_"] = &controls.consumeNext;
            L["set"] = &controls.set;

            L.doString(part);
        }
    }
}