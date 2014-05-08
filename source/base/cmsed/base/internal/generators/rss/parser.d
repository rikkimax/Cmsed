module cmsed.base.internal.generators.rss.parser;
import cmsed.base.internal.generators.rss.defs;
import dvorm.util;
import std.traits : isSomeFunction, ReturnType, isSomeString;
import std.conv : to;

string parseRss(T)() {
	string ret;
	foreach(value; getValuesRss!T) {
		ret ~= "        <item>\r\n";
		mixin(generateRssGrabber!T);
		ret ~= "        </item>\r\n";
	}
	
	return ret;
}

string generateRssGrabber(T, T t = newValueOfType!T)() {
	string ret;
	// "            "
	
	foreach(name; __traits(allMembers, RssField)) {
		RssField namev = __traits(getMember, RssField, name);
		if (namev != RssField.Provider) {
			foreach(i, UDA; __traits(getAttributes, T)) {
				static if (__traits(compiles, UDA.fieldType)) {
					static if (__traits(compiles, UDA.provider)) {
						if (UDA.fieldType == namev) {
							string value = cast(string)__traits(getMember, RssField, name);
							static if (isSomeFunction!(ReturnType!(UDA.provider))) {
								ret ~= "ret ~= \"            <" ~ value ~ ">\" ~ __traits(getAttributes, T)[" ~ to!string(i) ~ "].provider(value)() ~ \"</" ~ value ~ ">\r\n\";";
							} else {
								ret ~= "ret ~= \"            <" ~ value ~ ">\" ~ __traits(getAttributes, T)[" ~ to!string(i) ~ "].provider(value) ~ \"</" ~ value ~ ">\r\n\";";
							}
							break;
						}
					} else static if (__traits(compiles, UDA.value)) {
						if (UDA.fieldType == namev) {
							string value = cast(string)__traits(getMember, RssField, name);
							ret ~= "ret ~= \"            <" ~ value ~ ">\" ~ __traits(getAttributes, T)[" ~ to!string(i) ~ "].value ~ \"</" ~ value ~ ">\r\n\";";
							break;
						}
					}
				}
			}
			
			foreach(p; __traits(allMembers, T)) {
				static if (isUsable!(T, p)) {
					foreach(UDA; __traits(getAttributes, __traits(getMember, t, p))) {
						static if (__traits(compiles, UDA.fieldType)) {
							static if (__traits(compiles, UDA.value)) {
								if (UDA.fieldType == namev) {
									string value = cast(string)__traits(getMember, RssField, name);
									static if (isAnObjectType!(typeof(__traits(getMember, t, p)))) {
										ret ~= "ret ~= \"            <" ~ value ~ ">\"";
										
										auto subtype = mixin("t." ~ p);
										
										foreach(m; __traits(allMembers, typeof(subtype))) {
											static if (isUsable!(typeof(subtype), m)) {
												static if (isAnId!(typeof(subtype), m)) {
													static if (isAnObjectType!(typeof(__traits(getMember, subtype, m)))) {
														static assert(0, "Cannot have an object as an id of an object");
													} else {
														ret ~= " ~ value." ~ p ~ "." ~ m;
													}
												}
											}
										}
										
										ret ~= " ~ \"</" ~ value ~ ">\r\n\";";
									} else static if (!isSomeString!(typeof(__traits(getMember, t, p)))) {
										ret ~= "ret ~= \"            <" ~ value ~ ">\" ~ to!string(value." ~ p ~ ") ~ \"</" ~ value ~ ">\r\n\";";
									} else {
										ret ~= "ret ~= \"            <" ~ value ~ ">\" ~ value." ~ p ~ " ~ \"</" ~ value ~ ">\r\n\";";
									}
									break;
								}
							}
						}
					}
				}
			} 
		}
	}
	
	
	return ret;
}

T[] getValuesRss(T)() {
	foreach(UDA; __traits(getAttributes, T)) {
		static if (__traits(compiles, UDA.fieldType) && __traits(compiles, UDA.getData)) {
			static if (UDA.fieldType == RssField.Provider) {
				return UDA.getData();
			}
		}
	}
	
	assert(0, "Type " ~ T.stringof ~ " does not have an rss provider.");
}