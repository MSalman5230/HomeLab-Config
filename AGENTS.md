# Home lab config

This repo is **compose stacks for two hosts**. Put new stacks on the correct host. Do not mix path or compose conventions.

| Host | Folder | OS / tooling | Persistent data |
|------|--------|----------------|-----------------|
| **Servo** | `Servo-Docker/` | Unraid + Portainer (also Dockge) | `/mnt/user/appdata/<stack>/` |
| **Wally** (dir: `Walle-Docker/`) | `Walle-Docker/` | Linux Docker + Portainer | `/docker_data/<app>/` |

Timezone: **Asia/Kolkata**. Restart policy: `unless-stopped` or `always`. Never commit secrets (`.env`, passwords, API keys).

## Servo

Unraid. LinuxServer images: `PUID=99`, `PGID=100`, `TZ=Asia/Kolkata`. Prefer `compose.yaml`.

**New stack:** folder named after the app → `compose.yaml` → `README.md` with required vs optional env vars. Volumes only under `/mnt/user/appdata/<stack>/`.

**Role:** apps, AI, media, DBs. Stacks: Open WebUI, Bifrost, Crawl4AI, Hindsight, SillyTavern, Vane, SearXNG, Immich, Brave, Camofox, WARP (`warp` / `warp-docker`), MongoDB, PostgreSQL, Redis, Elastic (ES/Kibana/connectors), Metabase, Databasus, LibreSpeed, Dockge, Tugtainer, Beszel **agent**, gameloot-scrape-alert.

Servo-only rules: `Servo-Docker/AGENT.md`, `Servo-Docker/.cursor/rules/docker-compose-guidelines`.

## Wally

Regular Linux host (`user: "1000:1000"` on many stacks). Compose filenames vary (`compose.yaml`, `compose.yml`, `docker-compose.yml`). Cross-stack traffic uses external network **`shared_bridge_1`**. Start **Portainer** first.

**New stack:** folder per app → compose file → bind mounts under `/docker_data/<app>/`. Attach `shared_bridge_1` if other stacks must reach it.

**Role:** monitoring, home automation, orchestration. Stacks: Grafana, Prometheus, cAdvisor, node-exporter, `monitoring-stack` (includes Traefik), Beszel **hub**, Home Assistant, Prefect, Windmill, MySQL, Postgres, Elasticsearch / elastic-stack, WARP (`cloudflare-wrap-docker`), LibreSpeed, OpenSpeedTest, Portainer.

`monitoring-stack` overlaps the split Grafana/Prometheus/cAdvisor/node-exporter stacks — treat as alternate layouts, not both as source of truth unless the user says so.

## Agent behavior

- Edit only the host folder the user named. If unclear, ask.
- Do not invent IPs/hostnames; use ports from the compose file.
- Duplicate names (WARP, LibreSpeed, Elastic, Postgres) exist **on both hosts** — keep them independent.
- Per-stack README is the env-var source of truth.
