module cmsed.livereload.app;
import cmsed.livereload.monitor : monitorService;
import cmsed.livereload.compiler : compilerService;
import cmsed.livereload.inventory : inventoryService;


import vibe.d;
import std.file : getcwd;
import std.process : execute;

void main(string[] args) {
	string pathToFiles = getcwd();
	getOption("path", &pathToFiles, "Path of the files to operate on");

	finalizeCommandLineOptions();

	string compiler;
	if (testFor("dmd")) {
		compiler = "dmd";
	} else if (testFor("gdc")) {
		compiler = "gdc";
	} else if (testFor("ldc")) {
		compiler = "ldc";
	} else {
		logError("No compiler on PATH variable");
	}

	if (!testFor("dub"))
		logError("Dub is not on the PATH variable");

	monitorService(pathToFiles);
	compilerService(pathToFiles);
	inventoryService(pathToFiles);
}

bool testFor(string app) {
	try {
		auto ret = execute(app);
		return true;
	} catch(Exception e) {
		return false;
	}
}