module cmsed.base.main;
import cmsed.base.internal.routing;
import cmsed.base.config;
import cmsed.base.registration;
import cmsed.base.sessionstorage;
import vibe.d;
import dvorm;
import std.path : buildPath;
import std.file : write;
import std.process : execute;
import getopt = std.getopt;
import std.string : toLower, split;
import core.time : dur;
import core.runtime;

/**
 * A main function that makes sure a node stays up
 * Calls all required functions to operate a node correctly.
 * 
 * Requires a base.json file to exist.
 * It drives the configuration system.
 */

version(ExcludeCmsedMain) {
} else {
	int main(string[] args) {
		bool runForever;
		bool isInstallMode;
		
		int retHelpValue = handleHelp(runForever, isInstallMode);
		if (retHelpValue < 0) return retHelpValue;
		
		lowerPrivileges();
		if (!runForever) {
			return runIteration(isInstallMode) ? 2 : 1;
		} else {
			while(true) {
				auto result = execute([args[0], "--runIteration"]);
				switch(result.status) {
					case 2:
						// died because of reconfiguration.
						// lets keep going!
						break;
					case -2:
					case -1:
						// tried to print help and died
					case 1:
						// in this case it was forcefull closed
					default:
						// dieing was forcefull :(
						sleep(dur!"minutes"(1));
				}
			}
		}
		
		// unknown args blah
		//return -1;
	}
}

/**
 * Help messages, as well as basic arguments to program.
 * 
 * Good idea to define all arguments here even if not parsed here
 * That way the help message will be helpful!
 * 
 * Params:
 * 		runForever = 	Should this program run forever? Basically auto restart itself.
 * 		isInstallMode = Are we installing ourselves against the stack?
 */
int handleHelp(out bool runForever, out bool isInstallMode) {
	bool modeHelp;
	
	getOption("forever", &runForever, "Runs the web service continuesly even upon error");
	getOption("install|i", &isInstallMode, "Starts an iteration of the web service in install mode");
	getOption("mode", &modeHelp, "Sets the mode to start in. Valid modes: Web, Backend");
	
	try {
		if (finalizeCommandLineOptions()) {
			// worked fine
			return 0;
		} else {
			// DIE (printed help)
			return -2;
		}
	} catch (Exception e) {
		// DIE (something something bye bye)
		return -1;
	}
}

/**
 * Gets the mode being used by this node.
 * 
 * Defaults:
 * 		isWebMode =		true
 * 						By default we assume we host a web server
 * 		isBackendMode = false
 * 						By default we don't serve as a backend
 *                      Communication to backend servers is still available without this
 * 						They cannot communicate with you however
 * 
 * Params:
 * 		isWebMode = 	Should this node start the web server?
 * 		isBackendMode = Should this node care about hosting a backend functionality?
 */
void handleModeArg(out bool isWebMode, out bool isBackendMode) {
	string[] args = Runtime.args;
	string mode;
	getopt.getopt(args, "mode", &mode);
	
	if (mode.length == 0) {
		isWebMode = true;
	} else {
		foreach(m; mode.toLower().split(",")) {
			switch(m) {
				case "web":
					isWebMode = true;
					break;
				case "backend":
					isBackendMode = true;
					break;
				default:
					break;
			}
		}
	}
}

/**
 * Runs a single iteration of the node.
 * Weather this is in the form of a web server or backend node depends solely upon cli arguments.
 */
bool runIteration(bool isInstall) {
	bool isWebMode;
	bool isBackendMode;
	handleModeArg(isWebMode, isBackendMode);
	
	try  {
		getConfiguration("base.json");
		
		runOnLoad(isInstall);
		
		if (!isInstall) {
			// We don't want any update system actually to run.
			// Since its meant as a request -> do system during install.
			addUpdateTask();
		}
		
		if (isBackendMode) {
			// hey look we're a backend node!
		}
		
		// unfortunately runEventLoop blocks, so this is last.
		if (isWebMode) {
			// hey look we're a web node!
			
			void serveFunc() {
				serveStaticFiles("./public/")(http_request, http_response);
			}
			
			// add public directory for static content
			getURLRouter().register(new RouteInformation(RouteType.Get), null, &serveFunc);
			
			// There was dependency problems with having this inside config.
			// As pretty much everything used config at some stage.
			// Basically module ctors/dtors had cyclic dependencies. Moving here fixed that.
			// Blame Session storage.
			HTTPServerSettings settings = new HTTPServerSettings();
			settings.port = configuration.bind.port;
			settings.bindAddresses = cast(string[])configuration.bind.ip;
			settings.accessLogFile = buildPath(configuration.logging.dir, configuration.logging.accessFile);
			settings.sessionStore = new DbSessionStore;
			
			if (configuration.bind.ssl.cert != "" && configuration.bind.ssl.key != "")
				settings.sslContext = new SSLContext(configuration.bind.ssl.cert, configuration.bind.ssl.key);
			
			listenHTTP(settings, getURLRouter());
			runEventLoop();
		}
	} catch (Exception e){ 
		// log this
		if (configuration !is null)
			append(buildPath(configuration.logging.dir, configuration.logging.errorFile), "\n=======-----=======\n" ~ e.toString() ~ "\n");
		else
			throw e;
	} catch (object.Error e) {
		// log this
		if (configuration !is null)
			append(buildPath(configuration.logging.dir, configuration.logging.errorFile), "\n=======-----=======\n" ~ e.toString() ~ "\n");
		else
			throw e;
	}
	
	// did we shutdown by request?
	// if so go through again
	// otherwise sleep for a minute
	return shouldReconfigureSystem();
}