module cmsed.base.registration.update;
import cmsed.base.util;
import cmsed.base.config : hasConfigurationChanged;
import cmsed.base.timezones : rebuildTimeZones;
import vibe.core.core : exitEventLoop, runTask, sleep, setTaskEventCallback, TaskEvent;
import vibe.core.driver : getEventDriver;
import core.time : dur;
import core.thread : Fiber;

/**
 * Registers updates to be done every hour or five minutes.
 */

alias void function() UpdateFunction;

private shared {	
	UpdateFunction[] updateFuncs;
	UpdateFunction[] updateFrequentFuncs;
	
	bool shouldReconfigure;
}

void registerUpdate(UpdateFunction func, bool frequent = false) {
	synchronized {
		if (frequent)
			updateFrequentFuncs ~= func;
		else
			updateFuncs ~= func;
	}
}

void reconfigureSystem() {
	synchronized {
		shouldReconfigure = true;
	}
}

/**
 * If we were talking about only using our main then these would be protected.
 * But since no public.
 */

void addUpdateTask() {
	runTask({
		// runs all the updates then sleeps so it runs every hour.
		// also runs them when starting.
		while(true) {
			runUpdates();
			sleep(dur!"minutes"(utc0SysTime().minute));
		}
	});
	runTask({
		// runs all the updates then sleeps so it runs every hour.
		// also runs them when starting.
		while(true) {
			runFrequentUpdates();
			sleep(dur!"minutes"(5));
		}
	});
}

bool shouldReconfigureSystem() {
	synchronized {
		return shouldReconfigure;
	}
}

void resetShouldReconfigureSystem() {
	synchronized {
		shouldReconfigure = false;
	}
}

private {
	void runUpdates() {
		synchronized {
			// if configuration has changed set to should be reconfigured.
			shouldReconfigure = hasConfigurationChanged();
			
			// cmsed base stuff
			rebuildTimeZones(); // every hour check if we changed UTC+offset's for every time zone we know of.
			
			foreach(func; updateFuncs) {
				func();
			}
			
			if(shouldReconfigureSystem()) {
				exitEventLoop(true);
			}
		}
	}
	
	void runFrequentUpdates() {
		synchronized {
			// if configuration has changed set to should be reconfigured.
			shouldReconfigure = hasConfigurationChanged();
			
			foreach(func; updateFrequentFuncs) {
				func();
			}
			
			if(shouldReconfigureSystem()) {
				exitEventLoop(true);
			}
		}
	}
}