module cmsed.base;

/**
 * Publically imports all modules under cmsed.base
 */

public import cmsed.base.defs;
public import cmsed.base.main;
public import cmsed.base.util;
public import cmsed.base.cache;
public import cmsed.base.filters;

/**
 * Timezone information generated from the compiler's system.
 * Usefull for getting offsets.
 */
public import cmsed.base.timezones;

/**
 * Browser information and detection comparison
 * Based off of https://github.com/GaryKeith/browscap
 * Can be utilised to determine which browser is accessing the system.
 * Note is proberbly very heavy
 */
public import cmsed.base.browser_detection;

/**
 * Mime type information
 * Based off of the standard at http://www.iana.org/assignments/media-types/media-types.xhtml
 * Can be utilised for the static files
 */
public import cmsed.base.mimetypes;

public import cmsed.base.models;
public import cmsed.base.registration;
public import cmsed.base.caches;

/**
 * It seems the internal api needs to be imported. Humm bug in module constructors?
 * I blame Soaryn (even though he doesn't even know about this repo).
 */

public import cmsed.base.internal;

/**
 * Also a good idea to import the minifier as others may want to use it.
 */

public import cmsed.minifier;

/**
 * 
 */
import dvorm.vibe.providers;
//import dvorm.email.providers;