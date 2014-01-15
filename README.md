Cmsed
=====

A component library for Vibe that functions as a CMS.

Features:
---------
- Router based upon classes.
- Caches (pulls all values from a database reguarly for a model), with thanks to update mechanism.
- Support for Dvorm as ORM.
- Install / normal running modes.
- Node vs all node install configuration differentiation (node in file includes e.g. database vs in database as a cache)
- Session storage resides in database.
- Widget registration and usage support. Contains list of all widgets with routes accessible at runtime.
- Logging of all routes, widgets, data models, access.
- Automatic running in reload mode. In which it keeps itself up even if it were to fail (unless arg is passed).

Examples:
---------

**Routes**

```D
import cmsed.base;

class Home : OORoute {
    @RouteFunction(RouteType.Get, "/", "index")
    bool index() {return true;}
}

shared static this() {
  registerRoute!Home;
}
```

You can utilise RouteGroups to append e.g. path values on.

```D
class Home : OORoute {
  @RouteGroup(null, "/myhome") {
    @RouteFunction(RouteType.Get, "", "index")
    bool index() {return true;}
  }
}
```
Note UDAs (or attributes) are stackable. This means you can have quite a lot of those RouteGroups!

There are more check out [routing.d](https://github.com/rikkimax/Cmsed/blob/master/source/cmsed/base/routing.d).

The current request and response is located in routing.d as well. As http_request and http_response respectively.


**Models**

Data models are pretty much as described by [Dvorm](https://github.com/rikkimax/Dvorm).

Except a simple registration is required.

```D
shared static this() {
  registerModel!Book;
}
```

Note shared is a _required_ part of this. Without it you'll get 8+ registrations of said model (one for each thread).
Same goes for routing. But here it's more important as it is executed and grabbed for values e.g. widgets (route and position/name being requested).
