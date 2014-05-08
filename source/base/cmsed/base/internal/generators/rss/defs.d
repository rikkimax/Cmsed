module cmsed.base.internal.generators.rss.defs;
import cmsed.base.internal.generators.rss.parser;
import cmsed.base.internal.routing.defs;
import cmsed.base.mimetypes;
import std.traits : ReturnType, isArray, isSomeString, ParameterIdentifierTuple, isSomeFunction;

/*
 * Constants
 */

enum RssField {
	Title = "title",
	Link = "link",
	Description = "description",
	
	Author = "author",
	Category = "category",
	Comments = "comments",
	Enclosure = "enclosure",
	Guid = "guid",
	PubDate = "pubDate",
	Source = "source",
	
	/*
	 * Private don't use! 
	 */
	Provider = "provider"
}

alias RssCE = RssChannelElements;
enum RssChannelElements {
	Title = "title",
	Link = "link",
	Description = "description",
	
	Language = "language",
	Copyright = "copyright",
	ManagingEditor = "managingEditor",
	WebMaster = "webMaster",
	PublicationDate = "pubDate",
	LastModificationDate = "lastBuildDate",
	Category = "category",
	Cloud = "cloud",
	TimeToLive = "ttl",
	Image = "image",
	Rating = "rating",
	TextInput = "textInput",
	SkipHours = "skipHours",
	SkipDays = "skipDays"
}

/*
 * Definitions 
 */

/**
 * Provides meta information for rss fields.
 * 
 * Params:
 * 		func		=	The function to use to get the value.
 */
struct rssValue(alias func) if (checkRssNormalType!func) {
	RssField fieldType;
	
	/**
	 * Should have the type of:
	 * 		string function(T t)
	 * 		dstring function(T t)
	 * 		wstring function(T t)
	 * 		string delegate(T t)
	 * 		dstring delegate(T t)
	 * 		wstring delegate(T t)
	 */
	static if (isSomeFunction!(ReturnType!func))
		auto provider = func;
	else
		auto provider = &func;
	
	void* getData(){return null;}
}

/**
 * Provides meta information for rss provider fields.
 * Its purpose is to be able to get a store of type T to be used as RSS data.
 * 
 * Params:
 * 		func		=	The function to use to get the values.
 */
struct rssProvider(alias func) if (checkRssProviderType!func) {
	RssField fieldType = RssField.Provider;
	
	/**
	 * Should have the type of:
	 * 		T[] function()
	 * 		T[] delegate()
	 */
	auto getData = &func; // 0 arg, returns an array of values of type T
}

struct rss {
	RssField fieldType;
	string value;
	
	void* getData(){return null;}
}


/**
 * 
 */
class RssChannel(T) : IRouterReturnable {
	string[RssChannelElements] elements;
	
	this(string[RssChannelElements] elements) {
		this.elements = elements;
	}
	
	this(string title, string link = null, string description = null) {
		elements[RssChannelElements.Title] = title;
		if (link !is null)
			elements[RssChannelElements.Link] = link;
		if (description !is null)
			elements[RssChannelElements.Description] = description;
	}
	
	void handleReturn() {
		string output;
		
		output ~= "<rss version=\"2.0\">\r\n";
		output ~= "    <channel>\r\n";
		
		foreach(name; __traits(allMembers, RssChannelElements)) {
			RssChannelElements namev = __traits(getMember, RssChannelElements, name);
			if (namev in elements) {
				string value = cast(string)__traits(getMember, RssChannelElements, name);
				output ~= "        <" ~ value ~ ">" ~ elements[namev] ~ "</" ~ value ~ ">\r\n";
			}
		}
		
		output ~= "        <generator>Cmsed a web service framework for D</generator>\n";
		
		// ok so now to get the actual data..
		// this is the tricky bit
		output ~= parseRss!T;
		
		output ~= "    </channel>\r\n";
		output ~= "</rss>";
		
		http_response.writeBody(output, getTemplateForType("rss"));
	}
}

private {
	pure bool checkRssNormalType(alias t, T = typeof(t))() {
		static if ([ParameterIdentifierTuple!T].length != 1) return false;
		else static if (isSomeFunction!(ReturnType!T))
			return isSomeString!(ReturnType!(ReturnType!(T)));
		else
			return isSomeString!(ReturnType!(T));
	}
	
	pure bool checkRssProviderType(alias t, T = typeof(t))() {
		static if ([ParameterIdentifierTuple!T].length != 0) return false;
		else static if (isSomeFunction!(ReturnType!T))
			return isArray!(ReturnType!(ReturnType!(T)));
		else
			return isArray!(ReturnType!(T));
	}
}