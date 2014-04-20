module cmsed.base.internal.nodes;
import cmsed.base.internal.models.nodes;
import cmsed.base.util;
import vibe.core.core : runTask, sleep;
import std.datetime : SysTime;
import core.time : Duration, dur;

/**
 * Logic for node communication
 */

void configureNodes() {
	SystemNodesModel node = SystemNodesModel.findOne(hostname);
	if (node is null) {
		node = new SystemNodesModel();
	}
	
	node.generate();
	
	SystemNodesModel.findAll();
	SystemNodeIpModel.findAll();
}

void rebuildNodes() {
	SystemNodesModel node = SystemNodesModel.findOne(hostname);
	
	runTask({
		// update our nodes information.
		// makes sure ours is up to date.
		while(true) {
			node.update();
			sleep(dur!"minutes"(2));
		}
	});
	
	runTask({
		// check for all outdated node info.
		// delete it.
		while(true) {
			SysTime time = utc0SysTime();
			time -= dur!"minutes"(4);
			ulong tocheck = time.toUnixTime();
			
			SystemNodesModel.query().lastTick_lt(tocheck).remove();
			SystemNodeIpModel.query().lastTick_lt(tocheck).remove();
			
			sleep(dur!"minutes"(5));
		}
	});
}