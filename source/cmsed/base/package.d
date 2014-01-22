module cmsed.base;

/**
 * Publically imports all modules under cmsed.base
 */

public import cmsed.base.main;
public import cmsed.base.config;
public import cmsed.base.routing;
public import cmsed.base.sessionstorage;
public import cmsed.base.util;
public import cmsed.base.cache;
public import cmsed.base.restful;
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

public import cmsed.base.models;
public import cmsed.base.registration;
public import cmsed.base.caches;