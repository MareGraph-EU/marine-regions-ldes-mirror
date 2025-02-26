#!/bin/sh

# Replace any environment variable in the config-ldes.json file
envs=`printenv`

for env in $envs
do
    echo "$env" | { 
        IFS='=' read name value;
        sed -i "s|\${${name}}|${value}|g" ./config-ldes.json;
    }
done

# Start the LDES server
 npx @solid/community-server -c ./config-ldes.json -b ${LDES_BASE_URL}