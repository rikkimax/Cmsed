module cmsed.test;
import cmsed.test.models.book;

shared static this() {
	import cmsed.base.registration.onload;
	
	void func(bool isInstall) {
		Book3 book = new Book3;
		book.key.isbn = "AS-DF-TF";
		book.edition = 8;
		book.save();
	}
	
	registerOnLoad(&func);
}