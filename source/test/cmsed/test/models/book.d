module cmsed.test.models.book;
import cmsed.test.models;
import cmsed.base;
import dvorm;

string bookLink(Book3 book) {
	return "/mybook/" ~ book.key.isbn;
}

@dbName("Books3")
@rssProvider!getBooks()
@rss(RssField.Author, "Me, myself and I")
@rssValue!bookLink(RssField.Link)
@rssValue!((Book3 book) => {return "some new book here!";})(RssField.Description)
class Book3 {
	@dbId
	@dbName("")
	@rss(RssField.Title)
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