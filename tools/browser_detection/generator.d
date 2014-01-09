import io = std.stdio;

import std.file;
import std.uni;
import std.datetime;
import std.string;
import std.conv;
import std.traits : isBasicType;

void main(string[] args) {
    string moduleName;
    string fileName;
    if (args.length == 2) {
        moduleName = args[1];
        ptrdiff_t lio = moduleName.lastIndexOf(".");
        if (lio > 0 && lio + 1 < moduleName.length) {
            fileName = moduleName[lio + 1 .. $] ~ ".d";
        } else if (lio == -1) {
            fileName = moduleName ~ ".d";
        }
    } else {
        io.writeln("You can specify a module name to generate with");
        io.writeln("Syntax: rdmd generator <moduleName>");
        return;
    }
    
    assert(exists("browscap.ini"), "browscap.ini does not exist");
    assert(isFile("browscap.ini"), "browscap.ini does not exist");
    
    BrowserInfo blah = new BrowserInfo;
    
    BrowserInfo last;
    BrowserInfo[] all;
    
    foreach(cline; (new io.File("browscap.ini")).byLine()) {
        string line = cast(string)cline.dup;
        line = line.strip();
        if (line.length > 0) {
            if (line[0] == '[') {
                size_t endOf = line.lastIndexOf("]");
                if (endOf > 0) {
                    if (line != "[GJK_Browscap_Version]") {
                        if (last !is null)
                            all ~= last;
                        last = new BrowserInfo;
                        last.userAgent = line[1 .. endOf];
                    }
                }
            } else if(line[0] != ';' && last !is null) {
                size_t equalLoc = line.indexOf("=");
                if (equalLoc > 0 && equalLoc < line.length) {
                    string preEquals = line[0 .. equalLoc].strip();
                    string postEquals = line[equalLoc + 1 .. $].strip();
                    foreach(m; __traits(allMembers, BrowserInfo)) {
                        if (m == preEquals) {
                            static if (!__traits(hasMember, Object, m) &&
                                       !__traits(isAbstractFunction, Object, m) &&
                                       !__traits(isStaticFunction, mixin("blah." ~ m)) &&
                                       !__traits(isOverrideFunction, mixin("blah." ~ m)) &&
                                       !__traits(isFinalFunction, mixin("blah." ~ m)) &&
                                       !__traits(isVirtualMethod, mixin("blah." ~ m))) {
                                static if (is(typeof(mixin("blah." ~ m)) == BoolType)) {
                                    if (postEquals.toLower() != "true" || postEquals.toLower() != "false")
                                        mixin("last." ~ m) = BoolType.Default;
                                    else
                                        mixin("last." ~ m) = to!(bool)(postEquals.toLower()) ? BoolType.True : BoolType.False;
                                } else static if (isBasicType!(typeof(mixin("blah." ~ m)))) {
                                    if (m == preEquals) {
                                        mixin("last." ~ m) = to!(typeof(mixin("blah." ~ m)))(postEquals);
                                    }
                                } else static if (is(typeof(mixin("blah." ~ m)) == string)) {
                                    mixin("last." ~ m) = postEquals;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    string values;
    values ~= """
class BrowserInfo {
    string userAgent;
    
    string Parent;
    string Comment;
    string Browser;
    string Version;
    string MajorVer;
    string MinorVer;
    string Platform;
    string Platform_Version;
    bool Alpha;
    bool Beta;
    bool Win16;
    bool Win32;
    bool Win64;
    bool Frames;
    bool IFrames;
    bool Tables;
    bool Cookies;
    bool BackgroundSounds;
    bool JavaScript;
    bool VBScript;
    bool JavaApplets;
    bool ActiveXControls;
    bool isMobileDevice;
    bool isSyndicationReader;
    bool Crawler;
    string CssVersion;
    string AolVersion;
}

static this() {
    const string text = import(\"resource.csv\");
    foreach(record; text.split(\"\\n\")) {
        string[] values = record.split(\",\");
        if (values.length == 28) {
            shared BrowserInfo value = new shared BrowserInfo;
            
            value.userAgent = values[0];
            value.Parent = values[1];
            value.Comment = values[2];
            value.Browser = values[3];
            value.Version = values[4];
            value.MajorVer = values[5];
            value.MinorVer = values[6];
            value.Platform = values[7];
            value.Platform_Version = values[8];
            value.Alpha = values[9] == \"true\";
            value.Beta = values[10] == \"true\";
            value.Win16 = values[11] == \"true\";
            value.Win32 = values[12] == \"true\";
            value.Win64 = values[13] == \"true\";
            value.Frames = values[14] == \"true\";
            value.IFrames = values[15] == \"true\";
            value.Tables = values[16] == \"true\";
            value.Cookies = values[17] == \"true\";
            value.BackgroundSounds = values[18] == \"true\";
            value.JavaScript = values[19] == \"true\";
            value.VBScript = values[20] == \"true\";
            value.JavaApplets = values[21] == \"true\";
            value.ActiveXControls = values[22] == \"true\";
            value.isMobileDevice = values[23] == \"true\";
            value.isSyndicationReader = values[24] == \"true\";
            value.Crawler = values[25] == \"true\";
            value.CssVersion = values[26];
            value.AolVersion = values[27];
            
            browsers ~= value;
        }
    }
}
private {
    import std.string : indexOf;

    string[] split(string text, string delimater) {
        string[] ret;
        ptrdiff_t i;
        while((i = text.indexOf(delimater)) >= 0) {
            ret ~= text[0 .. i];
            text = text[i + delimater.length .. $];
        }
        if (text.length >= 0) {
            ret ~= text;	
        }
        return ret;
    }
}
""";
    
    values ~= "private shared BrowserInfo[] browsers;\n\n";
    string rfile;
    foreach(bi; all) {
        string val = bi.getCode(all);
        if (val != "") {
            rfile ~= val;
        }
    }
    
    write(fileName, "module " ~ moduleName ~ ";");
    append(fileName, values);
    
    write("resource.csv", rfile);
}

enum BoolType {
    False,
    True,
    Default
}

class BrowserInfo {
    string userAgent;
    
    string Parent;
    string Comment;
    string Browser;
    string Version;
    string MajorVer;
    string MinorVer;
    string Platform;
    string Platform_Version;
    BoolType Alpha;
    BoolType Beta;
    BoolType Win16;
    BoolType Win32;
    BoolType Win64;
    BoolType Frames;
    BoolType IFrames;
    BoolType Tables;
    BoolType Cookies;
    BoolType BackgroundSounds;
    BoolType JavaScript;
    BoolType VBScript;
    BoolType JavaApplets;
    BoolType ActiveXControls;
    BoolType isMobileDevice;
    BoolType isSyndicationReader;
    BoolType Crawler;
    string CssVersion;
    string AolVersion;
    
    string getCode(BrowserInfo[] all) {
        BrowserInfo parent;
        if (Parent != "") {
            foreach(p; all) {
                if (p.userAgent == Parent) {
                    parent = p;
                }
            }
        }
        
        string ret;
        
        if (parent !is null) {
            foreach(m; __traits(allMembers, BrowserInfo)) {
                static if (!__traits(hasMember, Object, m) &&
                           !__traits(isAbstractFunction, Object, m) &&
                           !__traits(isStaticFunction, mixin("this." ~ m)) &&
                           !__traits(isOverrideFunction, mixin("this." ~ m)) &&
                           !__traits(isFinalFunction, mixin("this." ~ m)) &&
                           !__traits(isVirtualMethod, mixin("this." ~ m))) {
                    static if (is(typeof(mixin("this." ~ m)) == BoolType)) {
                        if (mixin("parent." ~ m) != BoolType.Default && mixin(m) == BoolType.Default)
                            ret ~= (mixin("parent." ~ m) == BoolType.True ? "true" : "false") ~ ",";
                        else
                            ret ~= (mixin(m) == BoolType.True ? "true" : "false") ~ ",";
                    } else {
                        ret ~= mixin(m) ~ ",";
                    }
                }
            }
            ret = ret[0 .. $-1];
            ret ~= "\n";
        }
        
        return ret;
    }
}