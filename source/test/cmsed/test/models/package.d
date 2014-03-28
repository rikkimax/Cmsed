module cmsed.test.models;
import cmsed.base.registration.model;
import cmsed.base.registration.onload;

public import cmsed.test.models.book;

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