#!/bin/sh

# Replace any environment variable in the files
# Using a while loop to handle spaces correctly
printenv | while IFS='=' read -r name value; do
    if [ -n "$name" ]; then
        sed -i "s|\${${name}}|${value}|g" ./config/sds-metadata.ttl
        sed -i "s|\${${name}}|${value}|g" ./rdfc-pipeline.ttl
    fi
done

# Execute the RDF-Connect pipeline
exec npx rdfc rdfc-pipeline.ttl