module cmsed.base.util;
import std.datetime : SysTime, Clock;
import std.string : indexOf, toUpper, toLower;
import std.conv : to;
import core.time : Duration;

/**
 * Gets the current time in UTC+0 encoded as unix time
 * 
 * Returns:
 *      Unix time representation of the current time
 */
ulong utc0Time() {
    SysTime curr = Clock.currTime();
    curr -= curr.utcOffset;
    return curr.toUnixTime();
}

/**
 * Gets the current time in UTC+0
 * 
 * Returns:
 *      The current time with no offset
 */
SysTime utc0SysTime() {
    SysTime curr = Clock.currTime();
    curr -= curr.utcOffset;
    return curr;
}

/**
 * Gets the time this program was compiled in UTC+0 encoded as unix time
 * 
 * Returns:
 *      Unix time representation when this program was compiled
 */
ulong utc0Compiled() {
    return utc0CompiledSysTime().toUnixTime();
}

/**
 * Gets the time this program was compiled in UTC+0 encoded
 * 
 * Returns:
 *      The time when this program was compiled
 */
SysTime utc0CompiledSysTime() {
    string timestamp = __TIMESTAMP__.replace("  ", " ");
    string[] values = timestamp.split(" ");
    
    string timeo;
    timeo ~= values[4] ~ "-";
    timeo ~= values[1] ~ "-";
    
    if (values[2].length == 1)
        timeo ~= "0";
    timeo ~= values[2] ~ " ";
    
    timeo ~= values[3];
    
    SysTime curr = SysTime.fromSimpleString(timeo);
    curr -= curr.utcOffset;
    return curr;
}

/**
 * Turns a SysTime structure into a human readable one
 * 
 * Params:
 *      time    =   The time to convert from
 * 
 * Returns:
 *      Monday 1 January 1970 01:02:03 GMT
 */
string timeStamp(SysTime time) {
    string dayOfWeek = to!string(time.dayOfWeek);
    string month = to!string(time.month);
    dayOfWeek = cast(char)toUpper(dayOfWeek[0]) ~ dayOfWeek[1 .. $];
    month = cast(char)toUpper(month[0]) ~ month[1 .. $];
    
    string output;
    output ~= dayOfWeek ~ ", ";
    output ~= to!string(time.day) ~ " ";
    output ~= month ~ " ";
    output ~= to!string(time.year) ~ " ";
    output ~= time.toSimpleString().split(" ")[1] ~ " GMT";
    
    return output;
}

/**
 * Get the UTC+offset time
 */

/**
 * Converts a duration into UTC+0 encoded unix time
 * 
 * Params:
 *      offset  =   Duration to convert from
 * 
 * Returns:
 *      Unix time version of the offset
 */
ulong utc0Time(Duration offset) {
    SysTime curr = Clock.currTime();
    curr += (-curr.utcOffset) + offset;
    return curr.toUnixTime();
}

/**
 * Converts a duration into UTC+0
 * 
 * Params:
 *      offset  =   Duration to convert from
 * 
 * Returns:
 *      The duration converted into SysTime
 */
SysTime utc0SysTime(Duration offset) {
    SysTime curr = Clock.currTime();
    curr += (-curr.utcOffset) + offset;
    return curr;
}

/**
 * Simple find and replace with support for case sensistivity
 * 
 * Params:
 *      text            =   The text to work from
 *      oldText         =   The text to remove
 *      newText         =   The text to replace with
 *      caseSensitive   =   Replace 'i' when 'I' is specified. Default: true
 *      first           =   Only do one replacement. Default: false
 * 
 * Returns:
 *      A string with its oldText replaced with the newText
 */
pure string replace(string text, string oldText, string newText, bool caseSensitive = true, bool first = false) {
    string ret;
    string tempData;
    bool stop;
    foreach(char c; text) {
        if (tempData.length > oldText.length && !stop) {
            ret ~= tempData;
            tempData = "";
        }
        if (((oldText[0 .. tempData.length] != tempData && caseSensitive) || (oldText[0 .. tempData.length].toLower() != tempData.toLower() && !caseSensitive)) && !stop) {
            ret ~= tempData;
            tempData = "";
        }
        tempData ~= c;
        if (((tempData == oldText && caseSensitive) || (tempData.toLower() == oldText.toLower() && !caseSensitive)) && !stop) {
            ret ~= newText;
            tempData = "";
            stop = first;
        }
    }
    if (tempData != "") {
        ret ~= tempData;    
    }
    return ret;
}

/**
 * Simple find and replace with support for case sensistivity
 * 
 * Params:
 *      text            =   The text to work from
 *      oldText         =   The text to remove
 *      newText         =   The text to replace with
 *      caseSensitive   =   Replace 'i' when 'I' is specified. Default: true
 *      first           =   Only do one replacement. Default: false
 * 
 * Returns:
 *      A string with its oldText replaced with the newText
 */
pure wstring replace(wstring text, wstring oldText, wstring newText, bool caseSensitive = true, bool first = false) {
    wstring ret;
    wstring tempData;
    bool stop;
    foreach(wchar c; text) {
        if (tempData.length > oldText.length && !stop) {
            ret ~= tempData;
            tempData = ""w;
        }
        if (((oldText[0 .. tempData.length] != tempData && caseSensitive) || (oldText[0 .. tempData.length].toLower() != tempData.toLower() && !caseSensitive)) && !stop) {
            ret ~= tempData;
            tempData = ""w;
        }
        tempData ~= c;
        if (((tempData == oldText && caseSensitive) || (tempData.toLower() == oldText.toLower() && !caseSensitive)) && !stop) {
            ret ~= newText;
            tempData = ""w;
            stop = first;
        }
    }
    if (tempData != ""w) {
        ret ~= tempData;    
    }
    return ret;
}

/**
 * Simple find and replace with support for case sensistivity
 * 
 * Params:
 *      text            =   The text to work from
 *      oldText         =   The text to remove
 *      newText         =   The text to replace with
 *      caseSensitive   =   Replace 'i' when 'I' is specified. Default: true
 *      first           =   Only do one replacement. Default: false
 * 
 * Returns:
 *      A string with its oldText replaced with the newText
 */
pure dstring replace(dstring text, dstring oldText, dstring newText, bool caseSensitive = true, bool first = false) {
    dstring ret;
    dstring tempData;
    bool stop;
    foreach(dchar c; text) {
        if (tempData.length > oldText.length && !stop) {
            ret ~= tempData;
            tempData = ""d;
        }
        if (((oldText[0 .. tempData.length] != tempData && caseSensitive) || (oldText[0 .. tempData.length].toLower() != tempData.toLower() && !caseSensitive)) && !stop) {
            ret ~= tempData;
            tempData = ""d;
        }
        tempData ~= c;
        if (((tempData == oldText && caseSensitive) || (tempData.toLower() == oldText.toLower() && !caseSensitive)) && !stop) {
            ret ~= newText;
            tempData = ""d;
            stop = first;
        }
    }
    if (tempData != ""d) {
        ret ~= tempData;    
    }
    return ret;
}

/**
 * Splits a string by a delimiter
 * 
 * Params:
 *      text        =   The text to split upon
 *      delimiter   =   The delimiter to split upon
 * 
 * Returns:
 *      Array of the newly splitted text
 */
pure string[] split(string text, string delimiter) {
    string[] ret;
    ptrdiff_t i;
    while((i = text.indexOf(delimiter)) >= 0) {
        ret ~= text[0 .. i];
        text = text[i + delimiter.length .. $];
    }
    if (text.length > 0) {
        ret ~= text;    
    }
    return ret;
}

unittest {
    string test = "abcd|efgh|ijkl";
    assert(test.split("|") == ["abcd", "efgh", "ijkl"]);
    string test2 = "abcd||efgh||ijkl";
    assert(test2.split("||") == ["abcd", "efgh", "ijkl"]);
}

/**
 * Simple array check
 */

/**
 * Checks to see if paramaters are in the given array
 * 
 * Params:
 *      t   =   The base array to check against
 *      t2  =   Variadic array of values to compare against
 * 
 * Returns:
 *      Are any of the values in t2 in t
 * 
 * See_Also:
 *      std.algorithm.canFind
 */
bool arrayContains(T)(T[] t, T[] t2...) {
    foreach (T t3; t) {
        foreach(T t4; t2) {
            if (t3 == t4)
                return true;    
        }
    }
    return false;   
}

/**
 * Gets the hostname of the current machine
 * 
 * Returns:
 *      The hostname of the machine
 */
@property string hostname() {
    static string ret;
    
    if (ret is null) {
        import std.socket : Socket;
        ret = Socket.hostName();
    }
    
    return ret;
}

/**
 * Gets all the ips that this machine has
 * 
 * Returns:
 *      Array of the ips this machine has which are not localhost
 */
@property string[] ips() {
    static string[] ret;
    
    if (ret.length == 0) {
        import std.socket : getAddress;
        foreach(address; getAddress(hostname)) {
            string addr = address.toAddrString();
            switch(addr) {
                case "127.0.0.1":
                case "::1":
                    break;
                default:
                    ret ~= addr;
                    break;
            }
        }
    }
    
    return ret;
}

template Multi(V, U) {
    void call(funcs...)(V base, ref U value) {
        foreach(func; funcs) {
            func(base, value);
        }
    }
}

template Multi(V, U, W) {
    void call(funcs...)(V base, ref U value, ref W extra) {
        foreach(func; funcs) {
            func(base, value, extra);
        }
    }
}