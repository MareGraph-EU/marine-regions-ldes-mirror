# LDES datastore

This system component is used for storing all the LDES members and the surrounding LDES and TREE metadata (nodes and relations). At the time of writing, the [LDES server](https://github.com/rdf-connect/LDES-Solid-Server) can work with 2 different datastores technologies, namely MongoDB and Redis.

## Run MongoDB with Docker

To run a MongoDB instance we can use the following Docker commands:

1. Download the image:

```bash
docker pull mongo:latest
```

2. Run a container:

```bash
docker run \
--name mongo-db \
-p 27017:27017 \
-v ./:/data/db \
-e MONGO_INITDB_ROOT_USERNAME="root" \
-e MONGO_INITDB_ROOT_PASSWORD="mypassword" \
mongo
```

## Run Redis with Docker

To run Redis instance we can use the followig Docker commands:

1. Download the image:

```bash
docker pull redis/redis-stack-server:latest
```

2. Run a container:

```bash
docker run \
--name redis-stack \
-p 6379:6379 \
-v ./:/data \
-e REDIS_ARGS="--requirepass mypassword" \
redis/redis-stack-server
```