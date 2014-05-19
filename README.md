Cmsed
=====

A component library for Vibe that functions as a CMS.<br/>
There is currently a **getting started guide** in the wiki [link](https://github.com/rikkimax/Cmsed/wiki/Tutorial-Getting-started) little incomplete at the moment. But will help a lot if you are new.

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
- Can be executed in automatic reload mode. Utilising a command argument. For use in production environement where having it able to be reconfigured and rebooted on error is required.

Build status:
-------------
__Cmsed:base__ [![Build Status](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20base/badge/icon)](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20base/)<br/>
__Cmsed:test__ [![Build Status](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20test/badge/icon)](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20test/)

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

There are more check out [routing/defs.d](https://github.com/rikkimax/Cmsed/blob/master/source/cmsed/base/internal/routing/base.d).

The current request and response is located in defs.d as well. As http_request and http_response respectively.

You can utilise arguments to route functions to specify parameters. This includes from form (post ext.) and query string for get.

```D
class Test : OORoute {
	@RouteFunction(RouteType.Get, "/someargs")
	void someArgs(string a, string b) {
		http_response.writeBody(a ~ ", " ~ b);
	}
}
```

Forces errors and checks against e.g. string/integer/float/boolean arguments. Enables calling it via: http://example.com/someargs?a=text1&b=text2<br/>
You can further do validation from the arguments.

**Javascript generation**

Javascript is automatically generated to represent the data models and routes. This enables you to not need to write any ajax code.<br/>
Configuration of these features is in the apropriete defs files under [cmsed/base/internal/generators/js](https://github.com/rikkimax/Cmsed/tree/master/source/base/cmsed/base/internal/generators/js)

**Models**

Data models are pretty much as described by [Dvorm](https://github.com/rikkimax/Dvorm).

Except a simple registration is required.

```D
shared static this() {
  registerModel!Book;
}
```

Don't worry about the logMe method on these models! Thats handled and called automatically upon registration.

Note shared is a _required_ part of this. Without it you'll get 8+ registrations of said model (one for each thread).
Same goes for routing. But here it's more important as it is executed and grabbed for values e.g. widgets (route and position/name being requested).
