module cmsed.base.internal.generators.js.routes.prototype;
import cmsed.base.internal.generators.js.routes.defs;
import cmsed.base.internal.routing.checks;
import cmsed.base.util : split;
import dvorm.util;
import std.conv : to;

string handleClassPropertyPrototype(T, string m, // params
                                    T t = newValueOfType!T // meta info that is needed but not available inside the function
                                    )() {
	string ret;
	
	string arguments;
	string valueArgs;
	
	enum string path = getPathFromMethod!(T, m);
	enum string[] strSplit = path.split("/");
	
	foreach(i, s; strSplit) {
		if (s.length > 0) {
			if (s[0] == ':') {
				string arg = s[1 .. $];
				arguments ~= ", " ~ arg;
				valueArgs ~= "\"/\" + " ~ arg ~ " + ";
			} else if (s[0] == '*') {
				break;
			} else {
				valueArgs ~= "\"/" ~ s ~ "\" + ";
			}
		}
	}
	
	string parameters;
	
	foreach(param; getRouteParams!(T, m)) {
		parameters ~= "            \"" ~ param ~ "\": " ~ param ~ ",\n";
		arguments ~= ", " ~ param;
	}
	
	if (arguments.length > 1)
		arguments = arguments[2 .. $];
	if (valueArgs.length > 2)
		valueArgs = valueArgs[0 .. $-3];
	else
		valueArgs = "\"/\"";
	if (parameters.length > 0)
		parameters = parameters[0 .. $-2] ~ "\n";
	
	ret ~= "function " ~ m ~ "(" ~ arguments ~ ") {\n";
	ret ~= "    var ret = new Ajax.Request(" ~ valueArgs ~ ", {\n";
	
	ret ~= "        method: \"" ~ (cast(string)getRouteTypeFromMethod!(T, m)) ~ "\",\n";
	ret ~= "        parameters: {\n";
	ret ~= parameters;
	ret ~= "        }\n";
	
	ret ~= "    });\n";
	ret ~= "    return ret.responseText()\n";
	ret ~= "}\n";
	
	return ret;
}