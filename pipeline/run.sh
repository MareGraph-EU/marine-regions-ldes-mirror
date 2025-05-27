#!/bin/sh

# Replace any environment variable in the config-ldes.json file
envs=`printenv`

for env in $envs
do
    echo "$env" | { 
        IFS='=' read name value;
        sed -i "s|\${${name}}|${value}|g" ./config/sds-metadata.ttl;
        sed -i "s|\${${name}}|${value}|g" ./rdfc-pipeline.ttl;
    }
done

# Execute the RDF-Connect pipeline with the JS-Runner
exec npx @rdfc/js-runner rdfc-pipeline.ttl