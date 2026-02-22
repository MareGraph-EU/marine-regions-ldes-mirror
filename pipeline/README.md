# RDF-Connect pipeline

This system component is an RDF-Connect pipeline that performs the followin steps:

1. Reads a source LDES (continuosly).
2. Bucketizes the extracted Members in a B+Tree data structure.
3. Writes down the buckets and members into a data store, over which a new LDES can be published.

This is acomplished by piecing together the following set of RDF-Connect processors

- rdfc:GlobRead
- rdfc:LdesClient
- rdfc:Bucketize
- rdfc:Ingest

# Run it with Docker

We can execute the pipeline using the following Docker commands:

1. First build a container from the [`Dockerfile`](https://github.com/MareGraph-EU/marine-regions-ldes-mirror/blob/main/pipeline/Dockerfile) present in this repository:

```bash
docker build -t rdfc-pipeline .
```

2. Run a Docker container:

```bash
docker run \
-e SOURCE_LDES_URL=https://marineregions.org/feed \
-e LDES_MIRROR_BASE_URL=http://localhost:8080 \
-e LDES_MIRROR_URL_PATH=/marine-regions-mirror \
-e STORE_TYPE=redis \
-e STORE_URL=default:mypassword@[REDIS_IP]:6379 \
-v ./state:/rdfc-pipeline/state \
marine-regions-pipeline
-
```

The above command executes the pipeline, which will: 

1. replicate the Marine Regions LDES (`SOURCE_LDES_URL`), 
2. apply a different fragmentation strategy (a time-based B+Tree) 
3. that will be persisted in a data store (`STORE_TYPE`://`STORE_URL`) and,
4. that can be published as a mirrored LDES using a given URL (`LDES_MIRROR_BASE_URL`+`LDES_MIRROR_URL`).    