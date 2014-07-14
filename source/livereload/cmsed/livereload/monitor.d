module cmsed.livereload.monitor;
import cmsed.livereload.inventory : changesOccured;
import cmsed.livereload.compiler : isCompiling;
import vibe.d;

void monitorService(string pathToFiles) {
	runTask({
		DirectoryWatcher watcher = watchDirectory(pathToFiles);

		while(true) {
			DirectoryChange[] changes;

			if (watcher.readChanges(changes)) {
				while(isCompiling(pathToFiles))
					sleep(500.msecs);
				changesOccured(changes);
			}

			sleep(1.seconds);
		}
	});
}