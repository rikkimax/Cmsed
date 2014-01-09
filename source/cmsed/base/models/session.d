module cmsed.base.models.session;
import dvorm;

/**
 * Dvorm based data model for usage with the session storage.
 */

@dbName("Session")
class SessionModel {
	@dbId {
		string key;
		string name;
	}
	
	string value;
	
	mixin OrmModel!SessionModel;
	
	static SessionModel[] getSessionById(string id) {
		return SessionModel.query()
			.key_eq(id)
				.find();
	}
	
	static void removeBySessionid(string id) {
		foreach(sm; getSessionById(id)) {
			sm.remove();
		}
	}
}