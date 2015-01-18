module cmsed.base.internal.templating.parser;
import std.string : strip;

struct ParsedTemplate {
    ParsedTemplatePart[] parts;
    string[] evaluators;
    
    static ParsedTemplate parse(string text) {
        import std.algorithm : canFind;

        ParsedTemplate ret;
        
        string buffer;
        string codeType = null;
        bool startedCode = false;
        bool[2] isOnlyWhiteSpace = true;
        size_t inOutBrackets = 0;
        
        void startOfNew() {
            if (buffer.length == 2) {
                // do nothing
            } else if(!isOnlyWhiteSpace[0]) {
                // save previous part

                if (!canFind(ret.evaluators, codeType)) {
                    if (codeType == "DEFAULT") {
                        if (!canFind(ret.evaluators, ""))
                            ret.evaluators ~= "";
                    } else if (codeType !is null)
                        ret.evaluators ~= codeType;
                }

                ret.parts ~= new ParsedTemplatePart(codeType, buffer[0 .. $-2]);
            }
            
            buffer = "";
            codeType = "";
            startedCode = true;
            isOnlyWhiteSpace = true;
        }
        
        void endOfNew() {
            if (buffer.length == 2) {
                // do nothing
            } else if(!isOnlyWhiteSpace[0]) {
                // save previous part
                if (!canFind(ret.evaluators, codeType)) {
                    if (codeType == "DEFAULT") {
                        if (!canFind(ret.evaluators, ""))
                            ret.evaluators ~= "";
                    } else if (codeType !is null)
                        ret.evaluators ~= codeType;
                }

                ret.parts ~= new ParsedTemplatePart(codeType, buffer[0 .. $-2]);
            }
            
            buffer = "";
            codeType = null;
            startedCode = false;
            isOnlyWhiteSpace = true;
        }
        
        foreach(ref c; text) {
            buffer ~= c;
            
            if (buffer.length >= 2) {
                if (buffer[$-2 .. $] == "<?") {
                    if (inOutBrackets == 0) {
                        buffer = buffer.strip();
                        if (buffer.length > 0)
                            startOfNew();

                        inOutBrackets++;
                        continue;
                    } else {
                        isOnlyWhiteSpace[0] = isOnlyWhiteSpace[1];
                        isOnlyWhiteSpace[1] = false;
                        inOutBrackets++;
                    }
                } else if (buffer[$-2 .. $] == "?>") {
                    if (inOutBrackets == 1) {
                        buffer = buffer.strip();
                        if (buffer.length > 0)
                            endOfNew();

                        inOutBrackets--;
                        continue;
                    } else {
                        isOnlyWhiteSpace[0] = isOnlyWhiteSpace[1];
                        isOnlyWhiteSpace[1] = false;
                        inOutBrackets--;
                    }
                } else if (!(c == ' ' || c == "\n"[0] || c == "\r"[0] || c == "\t"[0])) {
                    isOnlyWhiteSpace[0] = isOnlyWhiteSpace[1];
                    isOnlyWhiteSpace[1] = false;
                }
            }
            
            if (startedCode) {
                buffer.length -= 1;
                
                if (c == ' ' || c == "\n"[0] || c == "\r"[0] || c == "\t"[0])
                    startedCode = false;
                else
                    codeType ~= c;
            }
        }

        buffer = buffer.strip();
        if (buffer.length > 0)
            ret.parts ~= new ParsedTemplatePart(codeType, buffer);
        
        return ret;
    }
    
    string toString() {
        string ret = "[";
        
        foreach(part; parts) {
            ret ~= part.toString();
            ret ~= ", ";
        }
        
        if (ret.length > 1)
            ret.length -= 2;
        
        return ret ~ "]";
    }
}

class ParsedTemplatePart {
    this(string codeType, string text) {
        this.codeType = codeType;
        this.text = text;
    }
    
    string codeType;
    string text;
    
    @property bool isCode() {
        return codeType !is null;
    }
    
    override string toString() {
        return "[" ~ codeType ~ ", " ~ text ~ "]";  
    }
}

unittest {
    auto v = ParsedTemplate.parse("""
    hi
    123
    <?
        echo(\"boo\")
    ?>
    <?lua
        echo(\"boo\")
    ?>
    <?
        echo(\"<? ?>\")
    ?>
    end
""");

    assert(v.parts.length == 5);

    assert(!v.parts[0].isCode);
    assert(v.parts[1].isCode);
    assert(v.parts[2].isCode);
    assert(v.parts[3].isCode);
    assert(!v.parts[4].isCode);

    assert(v.evaluators.length == 2);

    assert(v.evaluators[0] == "");
    assert(v.evaluators[1] == "lua");
}

unittest {
    auto v = ParsedTemplate.parse("""
hi
<?lua

echo(\"there\")

?>
!
""");
    
    assert(v.parts.length == 3);
    
    assert(!v.parts[0].isCode);
    assert(v.parts[1].isCode);
    assert(!v.parts[2].isCode);

    assert(v.evaluators.length == 1);
    
    assert(v.evaluators[0] == "lua");
}