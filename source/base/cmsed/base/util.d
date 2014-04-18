module cmsed.base.util;
import std.datetime : SysTime, Clock;
import std.string : indexOf, toUpper, toLower;
import std.conv : to;
import core.time : Duration;

/**
 * Get UTC+0 time
 */

ulong utc0Time() {
	SysTime curr = Clock.currTime();
	curr -= curr.utcOffset;
	return curr.toUnixTime();
}

SysTime utc0SysTime() {
	SysTime curr = Clock.currTime();
	curr -= curr.utcOffset;
	return curr;
}

string utc0CompiledTimeStamp() {
	string timestamp = __TIMESTAMP__;
	string[] values = timestamp.split(" ");
	
	string timeo;
	timeo ~= values[4] ~ "-";
	timeo ~= values[1] ~ "-";
	timeo ~= values[2] ~ " ";
	timeo ~= values[3];
	
	SysTime time = SysTime.fromSimpleString(timeo);
	auto durr = Clock.currTime().utcOffset;
	time -= durr;
	
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

ulong utc0Time(Duration offset) {
	SysTime curr = Clock.currTime();
	curr += (-curr.utcOffset) + offset;
	return curr.toUnixTime();
}

SysTime utc0SysTime(Duration offset) {
	SysTime curr = Clock.currTime();
	curr += (-curr.utcOffset) + offset;
	return curr;
}

/**
 * String replacement
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
 * Split a string up
 */

pure string[] split(string text, string delimater) {
	string[] ret;
	ptrdiff_t i;
	while((i = text.indexOf(delimater)) >= 0) {
		ret ~= text[0 .. i];
		text = text[i + delimater.length .. $];
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
 * Hex conversion
 */

pure ubyte hexValue(char c) {
	if (c >= 'A' && c <= 'Z') return cast(ubyte)((c - 'A') + 170);
	if (c >= 'a' && c <= 'z') return cast(ubyte)((c - 'a') + 170);
	if (c >= '0' && c <= '9') return cast(ubyte)(c - '0');
	return 0;
}

pure ubyte[] hexValue(string s)
in {
	assert(s.length == 3 || s.length == 6);
} body {
	ubyte[] ret;
	if (s.length == 6) {
		ret ~= hexValue(s[0]);
		ret ~= hexValue(s[2]);
		ret ~= hexValue(s[4]);
	} else {
		ret ~= hexValue(s[0]);
		ret ~= hexValue(s[1]);
		ret ~= hexValue(s[2]);
	}
	return ret;
}