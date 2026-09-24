# Elasticsearch and Kibana Stack

This directory contains the Docker Compose configuration for running Elasticsearch and Kibana.

## Default Credentials

### Elasticsearch Superuser
- Username: elastic
- Password: changeme

### Kibana Service Account
- Username: kibana_system
- Password: kibana_password

## Ports

- Elasticsearch: 9200, 9300
- Kibana: 5601

## Volumes

Data is stored in:
- `/docker_data/elastic-stack/elasticsearch/data` - Elasticsearch data
- `/docker_data/elastic-stack/kibana` - Kibana data

## Network

Uses the `shared_bridge_1` external network.

## Volume Permissions

When you deploy this stack for the first time, Docker will create the volume directories with root ownership. Since the containers run as user 1000:1000, you need to fix the permissions:

```bash
# Create directories first (if they don't exist)
mkdir -p /docker_data/elastic-stack/elasticsearch/data
mkdir -p /docker_data/elastic-stack/kibana

# Set correct ownership
sudo chown -R 1000:1000 /docker_data/elasticsearch/
sudo chown -R 1000:1000 /docker_data/elastic-stack/
sudo chmod -R 755 /docker_data/elastic-stack/
sudo chmod -R 755 /docker_data/elasticsearch/

# Then deploy or restart the stack
``` 