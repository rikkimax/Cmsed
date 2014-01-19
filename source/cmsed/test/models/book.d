module cmsed.test.models.book;
import cmsed.base.routing;
import dvorm;

@dbName("Books3")
class Book3 {
	@dbId
	@dbName("")
	Book3Id key = new Book3Id;
	
	@dbDefaultValue("0")
	ubyte edition;
	
	void t() {}
	
	@dbIgnore
	string something;
	
	mixin OrmModel!Book3;
}

class Book3Id {
	@dbId {
		@dbName("id")
		string isbn;
	}
}

class Page3 {
	@dbId
	@dbName("_id")
	string id;
	
	@dbName("book")
	@dbActualModel!(Book3, "key")
	Book3Id book = new Book3Id;
	
	mixin OrmModel!Page3;
}