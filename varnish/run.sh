#!/bin/bash

# Replace any environment variable in the VCL file
envs=`printenv`

for env in $envs
do
    IFS== read name value <<< "$env"
    sed -i "s|\${${name}}|${value}|g" /etc/varnish/default.vcl
done

# Start varnish
exec sh /usr/local/bin/docker-varnish-entrypoint