module cmsed.base.internal.nodes;
import cmsed.base.internal.models.nodes;
import cmsed.base.util;
import vibe.core.core : sleep;
import std.datetime : SysTime;
import core.time : Duration, dur;

/**
 * Logic for node communication
 */

__gshared private {
	SystemNodesModel node;
}

void configureNodes() {
	node = SystemNodesModel.findOne(hostname);
	if (node is null) {
		node = new SystemNodesModel();
	}
	
	node.generate();
	
	SystemNodesModel.findAll();
	SystemNodeIpModel.findAll();
}

void rebuildNodes() {
	// update our nodes information.
	// makes sure ours is up to date.
	node.update();
	
	// check for all outdated node info.
	// delete it.
	SysTime time = utc0SysTime();
	time -= dur!"minutes"(4);
	ulong tocheck = time.toUnixTime();
	
	SystemNodesModel.query().lastTick_lt(tocheck).remove();
	SystemNodeIpModel.query().lastTick_lt(tocheck).remove();
}