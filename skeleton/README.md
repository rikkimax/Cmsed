## Cmsed Hello World directory skeleton

**Why should you use it?**
It gets you going with all the joys of live reloading with D, without the pain of setting it all up!

**How should I use it?**
If you haven't already run:
> Tip! You may want to do this in an empty directory

```bash
$ dub run skeleton cmsed@rikkimax#cmsed_livereload/skeleton
```

Now into the created directory structure run:
```bash
$ dub run livereload
```
And you're done!
This will start up livereload given the configuration in ``deps/dub.json``.
You can add your dependencies here.

Now its configured to work in two different ways.
Static and dynamic seperations. There is almost no difference. Only how livereload uses those directories.
Statis is for a host application, this should be your base/stable code.
Dynamic is for code that is changing a lot.