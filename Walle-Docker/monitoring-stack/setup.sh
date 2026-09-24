#!/bin/bash

# Create a temporary container to copy the config file
docker run --rm -v monitoring_prometheus_config:/config -v $(pwd)/prometheus.yml:/prometheus.yml alpine cp /prometheus.yml /config/prometheus.yaml

# Start the stack
docker compose up -d 