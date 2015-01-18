## Cmsed
Cmsed is a web service framework in D.
It uses a wide ranging technologies to provide an excellent development experience. By utilising compile time heavily to improve runtime efficiency.

### Build status
__Cmsed:base__ [![Build Status](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20base/badge/icon)](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20base/)<br/>
__Cmsed:test__ [![Build Status](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20test/badge/icon)](http://1.vps.cattermole.co.nz/jenkins/job/cmsed%20test/)

## Features
- Router based upon classes.
- Caches (pulls all values from a database reguarly for a model), with thanks to update mechanism.
- Support for Dvorm as ORM.
- Install / normal running modes.
- Node vs all node install configuration differentiation (node in file includes e.g. database vs in database as a cache)
- Session storage resides in database.
- Widget registration and usage support. Contains list of all widgets with routes accessible at runtime.
- Logging of all routes, widgets, data models, access.
- Can be executed in automatic reload mode. Utilising a command argument. For use in production environement where having it able to be reconfigured and rebooted on error is required.

## Examples
### Class based routing
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

### Models

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

## Dependencies
* [https://github.com/rejectedsoftware/vibe.d](Vibe.d) is the heart and soul of Cmsed, it provides IO and threading support.
* [https://github.com/rikkimax/dvorm](Dvorm) is the primary ORM used with Cmsed.

**Optional:**
* [https://github.com/rikkimax/dakka](Dakka) is an Actor framework that supports communication between seperate processes over socket. Provides Cmsed's ability to reload fast.
* [https://github.com/rikkimax/skeleton](Skeleton) creates skeleton directories and files using descriptions from online. Also useful for its support of lua with github and bitbucket.
* [https://github.com/JakobOvrum/LuaD](LuaD) enables usage of lua inside templates.

## Structure of the library
**Most important parts:**
* source/base Majority of code here
* source/minifier Minifies javascript/css
* source/runners Executes the server
* source/lua Provides Lua 5.1 support in templates
* source/test For testing only

**Extra useful code:**<br/>
This code is generally compiled into Cmsed. However it is generated manually and committed into git.

* util_code/browser_detection Provides browser capabilities based upon user agents
* util_code/mime Mime types to file extensions
* util_code/timezone Timezone name to UTC offset