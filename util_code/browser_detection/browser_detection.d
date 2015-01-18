module browser_detection;
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
    const string text = import("resource.csv");
    foreach(record; text.split("\n")) {
        string[] values = record.split(",");
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
            value.Alpha = values[9] == "true";
            value.Beta = values[10] == "true";
            value.Win16 = values[11] == "true";
            value.Win32 = values[12] == "true";
            value.Win64 = values[13] == "true";
            value.Frames = values[14] == "true";
            value.IFrames = values[15] == "true";
            value.Tables = values[16] == "true";
            value.Cookies = values[17] == "true";
            value.BackgroundSounds = values[18] == "true";
            value.JavaScript = values[19] == "true";
            value.VBScript = values[20] == "true";
            value.JavaApplets = values[21] == "true";
            value.ActiveXControls = values[22] == "true";
            value.isMobileDevice = values[23] == "true";
            value.isSyndicationReader = values[24] == "true";
            value.Crawler = values[25] == "true";
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
    
    shared BrowserInfo[] browsers;
}

shared(BrowserInfo) getBrowser(string UA) {
    import std.regex;
    foreach(b; browsers) {
        if (!matchAll(UA, regex(b.userAgent)).empty) {
            return b;
        }
    }
    return null;
}
