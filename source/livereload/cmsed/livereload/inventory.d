module cmsed.livereload.inventory;
import vibe.core.file;

void changesOccured(DirectoryChange[] changes) {
	// TODO which files do each of these depend on?
	// are they templates, route, data model, config or public facing?
	// inform compiler service to recompile them
	// inform noderunner to rerun apropriete nodes
	// inform noderunner to kill off removed nodes
	assert(0);
}

void inventoryService(string pathToFiles) {
	assert(0);
}