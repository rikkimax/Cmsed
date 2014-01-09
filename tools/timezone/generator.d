import io = std.stdio;

import std.file;
import std.uni;
import std.datetime;
import std.string;

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
    }
    
    string enu = "enum TimeZones {\n";
    string names = "\nconst string[] TimeZoneNames = [\n";
    
    string getVal = "\n\nshared Duration[TimeZones] utcOffset;\n\n";
    
    getVal ~= "static this() {\n";
    getVal ~= "    rebuildTimeZones();\n";
    getVal ~= "}\n\n";
    
    getVal ~= "void rebuildTimeZones() {\n";
    getVal ~= "    auto currentTime = Clock.currTime().toUnixTime();\n";
    
	foreach(s; TimeZone.getInstalledTZNames()) {
		if (s.length > 5)
			if (s[0 .. 5] != "right" &&
				s[0 .. 5] != "posix" &&
				s[0 .. 3] != "Etc" &&
				s[0 .. 3] != "ETC" &&
				s[0 .. 3] != "GB-" &&
				s[0 .. 3] != "PST" &&
				s[0 .. 3] != "CST" &&
				s[0 .. 3] != "MST" &&
				s[0 .. 3] != "EST" &&
				s[0 .. 3] != "utc" &&
				s != "NZ-CHAT" &&
				s != "Universal") {
                
                string name = s.replace("/", "_");
                
                if (enu.indexOf(name) == -1) {
                    enu ~= "    " ~ name ~ ",\n";
                    getVal ~= "    utcOffset[TimeZones." ~ name ~ "] = TimeZone.getTimeZone(\""~ s ~ "\").utcOffsetAt(currentTime);\n";
                    names ~= "    \"" ~ s ~ "\",\n";
                }
			}
	}
    
    enu ~= "}\n";
    getVal ~= "}";
    names ~= "];\n";

    if (fileName == "") {
        io.writeln(enu);
        io.writeln(names);
        io.writeln(getVal);
    } else {
        write(fileName, 
"""module " ~ moduleName ~ ";
import std.datetime;

""");
        append(fileName, enu);
        append(fileName, names);
        append(fileName, getVal);
    }
}

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