module cmsed.base.timezones;

static if (__traits(compiles, {import timezones;})) {
	public import timezones;
} else {
	pragma(msg, "Could not compile with timezone information. Excluding.");
}