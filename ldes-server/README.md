# LDES Server

This system component provides a container with an implementation of an LDES server. The implementation used by this component is available at <https://github.com/rdf-connect/LDES-Solid-Server>.

## Run with Docker

1. First build the server image as follows:

```bash
docker build -t ldes-server .
```

2. Now, run a container of the server (using a Redis data store) with the following command:

```bash
docker run \
--name ldes-server \
-p 3000:3000 \
-e STORE_TYPE=redis \
-e STORE_URL=default:mypassword@localhost:6379 \
-e LDES_MIRROR_BASE_URL=http://localhost:8080 \
-e LDES_MIRROR_URL_PATH=/marine-regions-mirror \
ldes-server
```

An example using a MongoDB data store is as follows:

```bash
docker run \
--name ldes-server \
-p 3000:3000 \
-e STORE_TYPE=mongodb \
-e STORE_URL=root:mypassword@localhost:27017/mr-ldes?authSource=admin \
-e LDES_MIRROR_BASE_URL=http://localhost:8080 \
-e LDES_MIRROR_URL_PATH=/marine-regions-mirror \
ldes-server
```
