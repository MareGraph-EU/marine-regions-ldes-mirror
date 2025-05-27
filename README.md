# Marine Regions LDES mirror

This repository contains the code and configuration to produce and publish a _mirrored_ LDES for the [Marine Regions (MR) dataset](https://marineregions.org/).

The MR dataset is maintained and already published as a (Linked Data Event Stream (LDES))[https://w3id.org/ldes/specification] by VLIZ on <https://marineregions.org/feed>. However, our republishing of this dataset is only intended as an academic exercise to study alternative LDES data structures and their impact on replication efficiency. Also as a demonstrator of how a derived LDES may be generated and published.

To republish the MR LDES, we define a data pipeline using the [RDF-Connect framework](https://github.com/rdf-connect) ([see here](https://ceur-ws.org/Vol-3830/paper1.pdf) for more information).

## What is different from the original?

- LDES structure: `TODO:` explain that we use a B+Tree-based fragmentation for higher replication efficiency and better traversability

## System components and architecture

`TODO:` Diagram and description of pipeline components.

## How to run it?

This pipeline and the necessary data storage and interface components are containerized using Docker and can be executed altogether using `docker-compose` as follows:

```bash
$ docker-compose up --build 
```

The [`.env`](https://github.com/rdf-connect/marine-regions-ldes-mirror/blob/main/.env) file contains the main configuration variables to be set.