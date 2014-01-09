module cmsed.base.main;
import cmsed.base.routing;
import cmsed.base.config;
import cmsed.base.registration;
import vibe.d;
import dvorm;
import std.path : buildPath;
import std.file : write;
import std.process : execute;
import core.time : dur;

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
		bool runAnIteration = false;
		bool isInstallMode = false;
		getOption("runIteration|ri", &runAnIteration, "Runs an iteration of the web service");
		getOption("install|i", &isInstallMode, "Starts an iteration of the web service in install mode");
		
		try {
			if (finalizeCommandLineOptions()) {
				// worked fine
			} else {
				// DIE (printed help)
				return 0;
			}
		} catch (Exception e) {
			// DIE (something something bye bye)
			return 0;
		}
		
		lowerPrivileges();
		if (runAnIteration) {
			return runIteration(isInstallMode) ? 2 : 1;
		} else {
			while(true) {
				auto result = execute([args[0], "--runIteration"]);
				switch(result.status) {
					case 2:
						// died because of reconfiguration.
						// lets keep going!
						break;
					case -1:
						// umm shouldn't be touched
					case 0:
						// printed out help :/
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

bool runIteration(bool isInstall) {
	try  {
		getConfiguration("base.json");
		
		runOnLoad(isInstall);
		
		if (!isInstall) {
			// We don't want any update system actually to run.
			// Since its meant as a request -> do system during install.
			addUpdateTask();
		}
		
		// add public directory for static content
		getURLRouter().get("*", serveStaticFiles("./public/",));
		
		listenHTTP(getWebServerSettings(), getURLRouter());
		runEventLoop();
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