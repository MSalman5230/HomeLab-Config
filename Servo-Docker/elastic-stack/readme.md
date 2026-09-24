# Elastic Stack (Elasticsearch + Kibana + Logstash)

## Before first deploy

Create the data directories on the host (Unraid) and set permissions so the containers can write. Elasticsearch runs as UID 1000 inside the container.

On the Unraid host (SSH or terminal):

```bash
mkdir -p /mnt/user/appdata/elastic-stack/data/elasticsearch
mkdir -p /mnt/user/appdata/elastic-stack/data/kibana
mkdir -p /mnt/user/appdata/elastic-stack/data/logstash
mkdir -p /mnt/user/appdata/elastic-stack/config/logstash/pipeline
chown -R 1000:1000 /mnt/user/appdata/elastic-stack/data/elasticsearch
chown -R 1000:1000 /mnt/user/appdata/elastic-stack/data/kibana
chown -R 1000:1000 /mnt/user/appdata/elastic-stack/data/logstash
```

**Logstash pipeline config:** Logstash needs at least one pipeline config file (`.conf`) in the pipeline directory. Copy the sample from this repo:

```bash
cp elastic-stack/config/logstash/pipeline/logstash.conf /mnt/user/appdata/elastic-stack/config/logstash/pipeline/
```

(Adjust the path to `elastic-stack` if you're not in the repo root.) The config file defines **input** (where data comes from, e.g. Beats on port 5044), optional **filter** (transformations), and **output** (e.g. Elasticsearch). Edit it as needed for your use case.

## Linux: vm.max_map_count (if Elasticsearch still exits with 1)

Elasticsearch may refuse to start if `vm.max_map_count` is too low. On the host:

```bash
# Check current value (should be at least 262144)
sysctl vm.max_map_count

# Set for current boot
sudo sysctl -w vm.max_map_count=262144

# Make permanent (Unraid: add to /boot/syslinux/syslinux.cfg append line, or use Go script)
# echo "vm.max_map_count=262144" >> /etc/sysctl.conf
```

Then redeploy the stack.

## Ports

- **9200** — Elasticsearch HTTP
- **9300** — Elasticsearch transport
- **5601** — Kibana
- **5044** — Logstash Beats input (Filebeat, Metricbeat, etc.)
- **9600** — Logstash monitoring API
