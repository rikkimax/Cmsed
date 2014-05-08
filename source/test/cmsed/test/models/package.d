module cmsed.test.models;
import cmsed.base;

public import cmsed.test.models.book;

mixin CacheQuery!(Book3, q{Book3.query().edition_eq(8)}, "getBooks");

shared static this() {
	registerModel!Book3;
	registerModel!Page3;
	
	void func(bool isInstall) {
		Book3 book = new Book3;
		book.key.isbn = "AS-DF-TF";
		book.edition = 8;
		book.save();
	}
	
	registerOnLoad(&func);
}