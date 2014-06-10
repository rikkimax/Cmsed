module cmsed.base.mimetypes;

static if (__traits(compiles, {import mimetypes;})) {
	public import mimetypes;
} else {
	pragma(msg, "Could not compile with mimetypes information. Excluding.");
}