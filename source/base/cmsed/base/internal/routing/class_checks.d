module cmsed.base.internal.routing.class_checks;
import cmsed.base.routing.defs;

/**
 * Does the given class have either, OORoute/OOInstallRoute or OOAnyRoute on it?
 */
pure bool isARouteClass(T)() {
    static if (is(T : OORoute) || is(T : OOInstallRoute) || is(T : OOAnyRoute)) {
        return true;
    } else {
        return false;
    }
}