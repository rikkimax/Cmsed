module cmsed.base.udas;

/**
 * Dvorm
 */

public import dvorm.util : dbId, dbDefaultValue, dbIgnore, dbName, dbActualModel;

/**
 * Javascript generation
 */

struct ShouldNotGenerateJavascriptModel {}

struct JsRouteName {
    string name;
}

struct JsRouteParameters {
    this(string[] args ...) {
        params = args;
    }
    
    string[] params;
}

/**
 * Routing
 */

public import cmsed.base.routing.defs : RouteType;

alias RouteFilter = bool function();

struct RouteFunction {
    RouteType type;
    string route = "";
    RouteFilter filterFunction = null;
}

struct RouteGroup {
    RouteFilter filterFunction = null;
    string routeBase = "";

    this(RouteFilter filter, string base="") {
        filterFunction = filter;
        routeBase = base;
    }

    this(string base) {
        routeBase = base;
    }
}

struct RouteGroupId {
    string routeName = "";
}

struct RouteGroupIds {
    // GRR GRR this _was_ working
    /*this(string[] args ...) {
     routeNames = args;
     }*/
    
    string[] routeNames;
}

struct RouteErrorHandler {
    int error;
}

struct RouteOnInstall {}
