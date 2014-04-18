module cmsed.user.registration.auth;
import cmsed.user.models.user;

/**
 * Provides an authentication mechanism.
 */
interface AuthProvider {
	
	/**
	 * Does a check wheather or not an identifier exists in any provider.
	 * 
	 * Params:
	 * 		identifier =		The username or email that is to be checked against
	 * 
	 * Returns:
	 * 		If the identifier exists or not.
	 */
	bool hasIdentifier(string identifier);
	
	/**
	 * Gets a user if can be logged in.
	 * 
	 * Params:
	 * 		identifier = 		The username or email to log the user in by
	 * 		validator  = 		The password to log the user in by
	 * 
	 * Returns:
	 * 		A UserModel given the login information. Or null if not possible.
	 * 
	 * See_Also:
	 * 		UserModel
	 */
	UserModel validCredentials(string identifier, string validator);
	
	/**
	 * Changes the validator value for an identifier
	 * 
	 * Params:
	 * 		identifier = 		The username or email to log the user in by
	 * 		validator  = 		The password to log the user in by
	 * 
	 * Returns:
	 * 		If the change was successful.
	 */
	bool changeValidator(string identifier, string validator);
	
	/**
	 * Identifies an auth provider
	 */
	@property string identifier();
	
	/*
	 * Logging
	 */
	
	/**
	 * Upon login call this.
	 * 
	 * Params:
	 * 		identifier = 		The username or email to log the user in by
	 */
	void logLogin(string identifier);
}

static const AuthChecker checker = new AuthChecker();

/**
 * Registers an auth provider.
 */
void registerAuthProvider(T : AuthProvider)(T provider = new T()) {
	providers ~= provider;
}

private {
	AuthProvider[] providers;
	
	const class AuthChecker : AuthProvider {
		bool hasIdentifier(string identifier) {
			foreach(provider; providers) {
				if (provider.hasIdentifier(identifier)) return true;
			}
			return false;
		}
		
		UserModel validCredentials(string identifier, string validator) {
			foreach(provider; providers) {
				UserModel returned = provider.validCredentials(identifier, validator);
				if (returned !is null)
					return returned;
			}
			return null;
		}
		
		bool changeValidator(string identifier, string validator) {
			foreach(provider; providers) {
				if (provider.hasIdentifier(identifier))
					if (provider.changeValidator(identifier, validator))
						return true;
			}
			return false;
		}
		
		/*
		 * This shouldn't actually be used 
		 */
		@property string identifier() {
			assert(0);
		}
		
		/*
		 * Logging
		 */
		
		/**
		 * Upon login call this.
		 */
		void logLogin(string identifier) {
			foreach(provider; providers) {
				if (provider.hasIdentifier(identifier)) {
					provider.logLogin(identifier);
					return;
				}
			}
		}
		
		/*
		 * Util related not inhertited
		 */
		
		/**
		 * Gets an auth provider base upoon its name
		 * 
		 * Params:
		 * 		identifier	=	The name of the provider
		 * 
		 * Return:
		 * 		The auth provider or null
		 */
		AuthProvider getAuthProvider(string identifier) {
			foreach(provider; providers) {
				if (provider.identifier == identifier)
					return provider;
			}
			
			return null;
		}
		
		/**
		 * Gets all providers for a specific identifier
		 * 
		 * Params:
		 * 		identifier	=	The name of the provider
		 * 
		 * Return:
		 * 		A list of provider identifiers for an identifier
		 */
		string[] providersForIdentifier(string identifier) {
			string[] ret;
			
			foreach(provider; providers) {
				if (provider.hasIdentifier(identifier))
					ret ~= provider.identifier;
			}
			
			return ret;
		}
	}
}