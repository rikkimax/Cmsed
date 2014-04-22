module cmsed.base.i18n;
import ctini.common;

/*
 * Internalisation support
 * 
 * Deisgned to work along with isFirstExecute to make sure only
 * language files get registered once.
 */

private {
	__gshared Section[string] sections;
	
	bool canFindSection(string key, string name) {
		foreach(setting; sections[key].settings) {
			if (setting.name == name)
				return true;
		}
		
		return false;
	}
}

/**
 * Registers an language file
 * 
 * Params:
 * 		file 		= The file to register
 */
void registerI18NFile(string file)() {
	foreach(k, v; parseSections(import(file))) {
		if (k !in sections)
			sections[k] = v;
		else {
			foreach(setting; v.settings) {
				if (!canFindSection(k, setting.name))				
					sections[k].settings ~= setting;
			}
		}
	}
}

/**
 * Gets a peice of text for a language.
 * 
 * Params:
 * 		language 	= The language to get
 * 		name 		= The name of text
 * 
 * Returns:
 * 		The text that represents then name
 * 		or the name if not available
 */
string getI18NText(string language, string name) {
	if (language in sections) {
		foreach(setting; sections[language].settings) {
			if (setting.name == name) {
				string value = setting.value;
				if (value[0] == '"' && value[$-1] == '"')
					return value[1 .. $-1];
			}
		}
	}
	
	return name;
}

/**
 * Gets all language names
 * 
 * Returns:
 * 		The names of languages
 */
string[] getI18NLanguages() {
	return sections.keys;
}