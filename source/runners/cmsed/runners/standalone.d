module cmsed.runners.standalone;

/**
 * A main function that makes sure a node stays up
 * Calls all required functions to operate a node correctly.
 * 
 * Requires a base.json file to exist.
 * It drives the configuration system.
 */
 
import cmsed.base.internal.defs;

static if (Cmsed_Standalone) {
    import cmsed.runners.util;

    import cmsed.base.config;
    import cmsed.base.registration.onload;
    import cmsed.base.registration.update;
    import cmsed.base.internal.sessionstorage;
    import cmsed.base.routing.defs : getRouter;
    import cmsed.base.util : utc0CompiledSysTime;
    import vibe.d : lowerPrivileges, sleep, getOption, finalizeCommandLineOptions, runEventLoop, HTTPServerSettings, listenHTTP, HTTPServerOption, createSSLContext, SSLContextKind;
    import std.file : append;
    import std.process : execute;
    import std.string : toLower, split;
    import core.time : dur;

	int main(string[] args) {
		bool runForever;
		bool isInstallMode;
		string mode;
		
		int retHelpValue = handleHelp(runForever, isInstallMode, mode);
		if (retHelpValue < 0) return retHelpValue;
		
		lowerPrivileges();
		if (!runForever) {
			return runIteration(isInstallMode, mode) ? 2 : 1;
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
						sleep(dur!"minutes"(1));  // TODO: Why minutes? may be seconds? 3 or 5? whan manualy shutdown server it is boring to wait 1 minute!
				}
			}
		}
		
		// unknown args blah
		//return -1;
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
     *      mode =          Mode to run program in
     */
    int handleHelp(out bool runForever, out bool isInstallMode, out string mode) {
    	getOption("forever", &runForever, "Runs the web service continuesly even upon error");
    	getOption("install|i", &isInstallMode, "Starts an iteration of the web service in install mode");
    	getOption("mode", &mode, "Sets the mode to start in. Valid modes: Web, Backend");
    	
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
     *      mode =          Mode got from cli options
     * 		isWebMode = 	Should this node start the web server?
     * 		isBackendMode = Should this node care about hosting a backend functionality?
     */
    void handleModeArg(string mode, out bool isWebMode, out bool isBackendMode) {
    	
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
    bool runIteration(bool isInstall, string mode) {
    	bool isWebMode;
    	bool isBackendMode;
    	handleModeArg(mode, isWebMode, isBackendMode);
    	
    	try  {
    		getConfiguration("base.json");
    		
    		configureEmail();
    		
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
    			
    			// There was dependency problems with having this inside config.
    			// As pretty much everything used config at some stage.
    			// Basically module ctors/dtors had cyclic dependencies. Moving here fixed that.
    			// Blame Session storage.
    			HTTPServerSettings settings = new HTTPServerSettings();
    			settings.port = configuration.bind.port;
    			settings.bindAddresses = cast(string[])configuration.bind.ip;
    			
    			if (configuration.logging.accessFile != "")
    				settings.accessLogFile = buildPath(configuration.logging.dir, configuration.logging.accessFile);
    			
    			settings.sessionStore = new DbSessionStore;
                settings.options |= HTTPServerOption.distribute;
    			
    			if (configuration.bind.ssl.cert != "" && configuration.bind.ssl.key != "") {
                    auto sslctx = createSSLContext(SSLContextKind.server);
                    sslctx.useCertificateChainFile(configuration.bind.ssl.cert);
                    sslctx.usePrivateKeyFile(configuration.bind.ssl.key);
                    settings.sslContext = sslctx;
                }

                settings.serverString ~= " compiled with Cmsed " ~ utc0CompiledSysTime().toSimpleString();

                listenHTTP(settings, getRouter());
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
}