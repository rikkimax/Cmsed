module cmsed.base.routing.url_router;
import cmsed.base.routing.defs;
import vibe.http.common : HTTPMethod;
import std.functional : toDelegate;

class CmsedURLRouter {
    final CmsedURLRouter match(HTTPMethod method, string path, HTTPCmsedRequestHandler cb) { return match(method, path, &cb.handleRequest); }
    final CmsedURLRouter match(HTTPMethod method, string path, HTTPCmsedRequestFunction cb) { return match(method, path, toDelegate(cb)); }
    final CmsedURLRouter get(string url_match, HTTPCmsedRequestHandler cb) { return get(url_match, &cb.handleRequest); }
    final CmsedURLRouter get(string url_match, HTTPCmsedRequestFunction cb) { return get(url_match, toDelegate(cb)); }
    final CmsedURLRouter get(string url_match, HTTPCmsedRequestDelegate cb) { return match(HTTPMethod.GET, url_match, cb); }
    final CmsedURLRouter post(string url_match, HTTPCmsedRequestHandler cb) { return post(url_match, &cb.handleRequest); }
    final CmsedURLRouter post(string url_match, HTTPCmsedRequestFunction cb) { return post(url_match, toDelegate(cb)); }
    final CmsedURLRouter post(string url_match, HTTPCmsedRequestDelegate cb) { return match(HTTPMethod.POST, url_match, cb); }
    final CmsedURLRouter put(string url_match, HTTPCmsedRequestHandler cb) { return put(url_match, &cb.handleRequest); }
    final CmsedURLRouter put(string url_match, HTTPCmsedRequestFunction cb) { return put(url_match, toDelegate(cb)); }
    final CmsedURLRouter put(string url_match, HTTPCmsedRequestDelegate cb) { return match(HTTPMethod.PUT, url_match, cb); }
    final CmsedURLRouter delete_(string url_match, HTTPCmsedRequestHandler cb) { return delete_(url_match, &cb.handleRequest); }
    final CmsedURLRouter delete_(string url_match, HTTPCmsedRequestFunction cb) { return delete_(url_match, toDelegate(cb)); }
    final CmsedURLRouter delete_(string url_match, HTTPCmsedRequestDelegate cb) { return match(HTTPMethod.DELETE, url_match, cb); }
    final CmsedURLRouter patch(string url_match, HTTPCmsedRequestHandler cb) { return patch(url_match, &cb.handleRequest); }
    final CmsedURLRouter patch(string url_match, HTTPCmsedRequestFunction cb) { return patch(url_match, toDelegate(cb)); }
    final CmsedURLRouter patch(string url_match, HTTPCmsedRequestDelegate cb) { return match(HTTPMethod.PATCH, url_match, cb); }
    final CmsedURLRouter any(string url_match, HTTPCmsedRequestHandler cb) { return any(url_match, &cb.handleRequest); }
    final CmsedURLRouter any(string url_match, HTTPCmsedRequestFunction cb) { return any(url_match, toDelegate(cb)); }
    final CmsedURLRouter any(string url_match, HTTPCmsedRequestDelegate cb) {
        return get(url_match, cb).post(url_match, cb)
            .put(url_match, cb).delete_(url_match, cb).patch(url_match, cb);
    }

    /*
     * Above final functions copied from Vibe.d more or less
     */

    private __gshared {
        HTTPCmsedRequestDelegate[string][HTTPMethod] methodToPathToDelegate;
    }

    void handle() {
        import vibe.core.log : logTrace;

        foreach(method, routes; methodToPathToDelegate) {
            if (method == currentTransport.request.method) {
                foreach(path, cb; routes) {
                    if (matches(path, currentTransport.request.path, currentTransport.request.params)) {
                        logTrace("route match: %s -> %s %s", currentTransport.request.path, method, path);
                        // .. parse fields ..
                        cb(currentTransport);
                        if (currentTransport.response.headerWritten) return;
                    }
                }
            }
        }
    }

    CmsedURLRouter match(HTTPMethod method, string path, HTTPCmsedRequestDelegate cb) {
        methodToPathToDelegate[method][path] = cb;

        return this;
    }
}

private {
    /**
     * Adapted from Vibe.d
     */

    enum maxRouteParameters = 64;

    bool matches(string pattern, string url, ref string[string] params) {
        size_t i, j;
        
        // store parameters until a full match is confirmed
        import std.typecons;
        Tuple!(string, string)[maxRouteParameters] tmpparams;
        size_t tmppparams_length = 0;
        
        for (i = 0, j = 0; i < url.length && j < pattern.length;) {
            if (pattern[j] == '*') {
                foreach (t; tmpparams[0 .. tmppparams_length])
                    params[t[0]] = t[1];
                return true;
            }
            if (url[i] == pattern[j]) {
                i++;
                j++;
            } else if(pattern[j] == ':') {
                j++;
                string name = skipPathNode(pattern, j);
                string match = skipPathNode(url, i);
                assert(tmppparams_length < maxRouteParameters, "Maximum number of route parameters exceeded.");
                tmpparams[tmppparams_length++] = tuple(name, match);
            } else return false;
        }
        
        if ((j < pattern.length && pattern[j] == '*') || (i == url.length && j == pattern.length)) {
            foreach (t; tmpparams[0 .. tmppparams_length])
                params[t[0]] = t[1];
            return true;
        }
        
        return false;
    }

    string skipPathNode(string str, ref size_t idx)
    {
        size_t start = idx;
        while( idx < str.length && str[idx] != '/' ) idx++;
        return str[start .. idx];
    }
}