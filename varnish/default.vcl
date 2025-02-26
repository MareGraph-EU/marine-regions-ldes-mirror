vcl 4.1;

import brotli;

# This is the built-in VCL for exposing cache hits and misses.
# But this one uses a custom header called x-cache.
# We instead implement our own header called X-Proxy-Cache in the vcl_deliver subroutine below.

# include "hit-miss.vcl";

backend default {
    .host = "${BACKEND_HOST}";
    .port = "${BACKEND_PORT}";
    .connect_timeout = 600s;
    .first_byte_timeout = 600s;
    .between_bytes_timeout = 600s;
}

# Only allow purging from specific IPs
acl purge {
    "localhost";
    "127.0.0.1";
}

sub vcl_init {
      # Create a compression filter with a reduced quality level,
      # for faster processing, but larger compressed responses
      # (the default quality level is 11).
      new brQ6 = brotli.encoder("brQ6", quality=6);
}


sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.

    # Allow purging
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
           return (synth(405, "This IP is not allowed to send PURGE requests."));
        }
        
        # Forbid further requests from this client
        ban("req.http.host == " + req.http.host + " && req.url ~ " + req.url);
        
        return (purge);
    }

    if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "PATCH" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT */
        return (pipe);
    }

    # Implementing websocket support (https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html)
    if (req.http.Upgrade ~ "(?i)websocket") {
        return (pipe);
    }

    # Only cache GET or HEAD requests. This makes sure the POST requests are always passed.
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Handle compression correctly. Different clients send different
    # "Accept-Encoding" headers, even though they mostly support the same
    # compression mechanisms. By consolidating compression headers into
    # a consistent format, we reduce the cache size and get more hits.
    if (req.http.Accept-Encoding) {
        if (req.http.Accept-Encoding ~ "br") {
            # If the client supports it, we'll use brotli.
            # Here we have to set a custom header to flag that we are using brotli,
            # this is necessary to work around Varnish's default behavior 
            # of enforcing gzip and unsetting any Accept-Encoding header that is not gzip.
            # See the docs: https://varnish-cache.org/docs/trunk/phk/gzip.html#what-does-http-gzip-support-do
            set req.http.X-brotli = "true";
        }
        else if (req.http.Accept-Encoding ~ "gzip") {
            # Otherwise, we'll use gzip if supported.
            set req.http.Accept-Encoding = "gzip";
        }
        else {
            # Unknown algorithm. Remove it and send unencoded.
            unset req.http.Accept-Encoding;
        }
    }

    return (hash);
}

sub vcl_hash {
    if(req.http.X-brotli == "true") {
        // Tell Varnish to store a brotli encoded version of the response in cache
        hash_data("brotli");
    }
}

sub vcl_pipe {
  # Called upon entering pipe mode.
  # In this mode, the request is passed on to the backend, and any further data from both the client
  # and backend is passed on unaltered until either end closes the connection. Basically, Varnish will
  # degrade into a simple TCP proxy, shuffling bytes back and forth. For a connection in pipe mode,
  # no other VCL subroutine will ever get called after vcl_pipe.

  # Implementing websocket support (https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html)
  if (req.http.upgrade) {
    set bereq.http.upgrade = req.http.upgrade;
  }

  return (pipe);
}

sub vcl_backend_fetch {
    # 
    if(bereq.http.X-brotli == "true") {
        # Tell the backend that brotli is supported
        set bereq.http.Accept-Encoding = "br";
        unset bereq.http.X-brotli;
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.

    # Don't cache if no-cache is set
    if (beresp.http.cache-control ~ "no-cache") {
        set beresp.uncacheable = true;
        return (deliver);
    }

    # Don't cache 50x responses
    if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
        return (abandon);
    }

    # Tell Varnish to compress any text, json and explicitly RDF content before storing it in cache
    # according to the client's Accept-Encoding header (either brotli or gzip)
    if (beresp.http.content-type ~ "text" ||
        beresp.http.content-type ~ "n-triples" ||
        beresp.http.content-type ~ "n-quads" ||
        beresp.http.content-type ~ "turtle" ||
        beresp.http.content-type ~ "trig" ||
        beresp.http.content-type ~ "rdf+xml" ||
        beresp.http.content-type ~ "ld+json" ||
        beresp.http.content-type ~ "json") {
        
        if (bereq.http.Accept-Encoding ~ "br") {
            # This activates the brotli VFP to compress the response
            # using the brotli encoder we created in vcl_init.
            # See here https://code.uplex.de/uplex-varnish/libvfp-brotli
            set beresp.filters = "brQ6";
        }
        else if (bereq.http.Accept-Encoding ~ "gzip") {
            set beresp.do_gzip = true;
        }
    }

    # If the backend fails, keep serving out of the cache for 30m
    set beresp.grace = 30m;
    return (deliver);
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.

    # Add debug header to see if it's a HIT/MISS and the number of hits, disable when not needed
    if (obj.hits > 0) { 
        set resp.http.X-Proxy-Cache = "HIT";
    } else {
        set resp.http.X-Proxy-Cache = "MISS";
    }
}

sub vcl_purge {
    # Only handle actual PURGE HTTP methods, everything else is discarded
    if (req.method != "PURGE") {
        # restart request
        set req.http.X-Purge = "Yes";
        return(restart);
    }
}

sub vcl_fini {
    # Called when VCL is discarded only after all requests have exited the VCL.
    # Typically used to clean up VMODs.

    return (ok);
}