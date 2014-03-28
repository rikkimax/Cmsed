module cmsed.base.internal.sessionstorage;
import cmsed.base.internal.models.session;
import vibe.http.session;
import vibe.db.mongo.mongo;
import std.conv : to;
import std.variant;

/**
 * Session storage backed by a Dvorm model.
 */

class DbSessionStore : SessionStore {
	Session create() {
		return createSessionInstance(null);
	}
	
	/// Opens an existing session.
	Session open(string id) {
		return createSessionInstance(id);
	}
	
	/// Sets a name/value pair for a given session.
	void set(string id, string name, Variant value) {
		SessionModel sm = new SessionModel;
		sm.key = id;
		sm.name = name;
		sm.value = value.get!string();
		sm.save();
	}
	
	/// Returns the value for a given session key.
	Variant get(string id, string name, lazy Variant defaultVal = null) {
		if (id !is null && name !is null) {
			SessionModel[] sm = SessionModel.find(id, name);
			if (sm.length == 1) {
				return Variant(sm[0].value);
			} else {
				return defaultVal;
			}
		}
		
		return defaultVal;
	}
	
	/// Determines if a certain session key is set.
	bool isKeySet(string id, string key) const {
		return SessionModel.find(id, key).length == 1;
	}
	
	/// Terminates the given sessiom.
	void destroy(string id) {
		if (id != "")
			SessionModel.removeBySessionid(id);
	}
	
	/// Iterates all key/value pairs stored in the given session. 
	int delegate(int delegate(ref string key, ref Variant value)) iterateSession(string id) {
		int iterator(int delegate(ref string key, ref Variant value) del) {
			foreach(ref sm; SessionModel.getSessionById(id)) {
				auto value = Variant(sm.value);
				if (auto ret = del(sm.name, value) != 0)
					return ret;
			}
			return 0;
		}
		return &iterator;
	}
}