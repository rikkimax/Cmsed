module cmsed.base.browser_detection;

static if (__traits(compiles, {import browser_detection;})) {
	public import browser_detection;
} else {
	pragma(msg, "Could not compile with browser_detection information. Excluding.");
}