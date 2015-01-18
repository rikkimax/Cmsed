module cmsed.base.internal.models.nodes;
import cmsed.base.util;
import dvorm;

@dbName("SystemNode")
//TODO: @shouldNotGenerateJavascriptModel
class SystemNodesModel {
	@dbId
	@dbName("host")
	SystemNodeId key;
	
	ulong started;
	ulong compiledTime;
	ulong lastTick;
	
	@dbIgnore
	SystemNodeIpModel[] cachedIps;
	
	mixin OrmModel!SystemNodesModel;
	
	void generate() {
		key.hostname = hostname;
		started = utc0Time();
		compiledTime = utc0Compiled();
		
		SystemNodeIpModel.query().key_hostname_eq(hostname).remove();
		
		foreach(ip; ips) {
			SystemNodeIpModel nip = new SystemNodeIpModel();
			nip.key.hostname = hostname;
			nip.ip = ip;
			nip.update();
			
			cachedIps ~= nip;
		}
		
		update();
	}
	
	void update() {
		lastTick = utc0Time();	
		save();
		
		foreach(ip; cachedIps) {
			ip.update();
		}
	}
	
	SystemNodeIpModel[] getIps() {
		return SystemNodeIpModel.query().key_hostname_eq(hostname).find();
	}
}

struct SystemNodeId {
	@dbId {
		@dbName("name")
		string hostname;
	}
}

@dbName("SystemNodeIp")
//TODO: @shouldNotGenerateJavascriptModel
class SystemNodeIpModel {
	@dbId {
		@dbName("host")
		SystemNodeId key;
		string ip;
	}
	
	ulong lastTick;
	
	mixin OrmModel!SystemNodeIpModel;
	
	void update() {
		lastTick = utc0Time();
		save();
	}
}