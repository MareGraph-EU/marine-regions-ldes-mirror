# Varnish

In this setup, we use [Varnish](https://github.com/varnishcache/varnish-cache) as a reverse proxy and HTTP cache for the LDES server. We also enable `brotli` (thanks to this [Varnish extension](https://gitlab.com/uplex/varnish/libvfp-brotli.git) for Brotli) and `gzip` (supported natively by Varnish) compression for any RDF content. 

## Run with Docker

We can run an instance of Varnish with the following Docker commands:

1. Build the docker image:

```bash
docker build -t varnish-cache .
```

2. Run a docker container:

```bash
docker run \
--tmpfs /var/lib/varnish/varnishd:exec \
--ulimit=memlock=-1 \
-p 8080:80 \
-e VARNISH_SIZE=1G \
-e BACKEND_HOST=localhost \
-e BACKEND_PORT=3000 \
varnish-cache
```
The `--tmpfs /var/lib/varnish/varnishd:exec` mounts this Varnish folder in memory and gives execution permissions for performance reasons ([see here](https://www.varnish-software.com/developers/tutorials/running-varnish-docker/#loading-varlibvarnish-into-memory)).

The `--ulimit=memlock=-1` parameter is required in order for Varnish to work in Docker, [according to the docs](https://varnish-cache.org/docs/trunk/reference/vsm.html#containers-and-memory-locking).

Use the environment variable `VARNISH_SIZE` to define the size of the cache.

The host and port of the LDES server are defined with the `BACKEND_HOST` and the `BACKEND_PORT` environment variables.

For more details on how Varnish is configured, check the [`default.vcl`](https://github.com/MareGraph-EU/marine-regions-ldes-mirror/blob/main/varnish/default.vcl) file.