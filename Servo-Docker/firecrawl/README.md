# Firecrawl on Servo

Self-hosted Firecrawl API at <http://192.168.11.3:3002>, using official prebuilt
images. The API's harness starts its workers in the same container.
Playwright, Redis, RabbitMQ, and a dedicated NuQ PostgreSQL database run alongside
it. The optional FoundationDB backend is omitted; `NUQ_BACKEND=pg` is explicit.

The API has no authentication in this baseline. Use it on the trusted LAN only.
Binding to Servo's LAN address does not authenticate clients. Database passwords
protect the dependencies, not API requests. Only API port `3002` is published;
worker, browser, database, and RabbitMQ management ports stay private.

## Required environment variables

None. The internal PostgreSQL and RabbitMQ services both default to the password
`firecrawl`, with matching credentials configured in the API. Their ports are
not published to the host. Neither a Firecrawl Cloud API key nor an LLM key is
required for basic scraping.

Optional password overrides can be set in Portainer's stack environment or a
private `.env` for CLI/Dockge. Never stage or commit private overrides or `.env`.

## Optional environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `POSTGRES_PASSWORD` | `firecrawl` | Password shared by the API and its queue database. |
| `RABBITMQ_PASSWORD` | `firecrawl` | Password for the RabbitMQ user `firecrawl`. Use URL-safe characters (for example, a hexadecimal password) because it is inserted into the AMQP URL. |
| `FIRECRAWL_PORT` | `3002` | API port on Servo; the container still listens on `3002`. |
| `NUM_WORKERS_PER_QUEUE` | `8` | Worker count per queue. |
| `CRAWL_CONCURRENT_REQUESTS` | `10` | Crawl concurrency and Playwright's maximum concurrent pages. |
| `MAX_CONCURRENT_JOBS` | `5` | Concurrent job limit. |
| `BROWSER_POOL_SIZE` | `5` | Browser pool setting passed to the API. |
| `HARNESS_STARTUP_TIMEOUT_MS` | `60000` | Worker startup timeout in milliseconds. |

The database name and user are fixed to `postgres` to match the bundled
`pg_cron` configuration. All services use `TZ=Asia/Kolkata`.
The queue administration UI and optional AI/proxy providers are not configured.
Additional provider variables must be explicitly added to the appropriate
service's `environment` mapping; arbitrary `.env` values are not forwarded.

## Deploy

All services use prebuilt images, so no source checkout or build tools are needed:

- `ghcr.io/firecrawl/firecrawl:latest`
- `ghcr.io/firecrawl/playwright-service:latest`
- `ghcr.io/firecrawl/nuq-postgres:latest`
- `redis:alpine`
- `rabbitmq:3-management`

The Firecrawl images follow their independently published `latest` tags; this
stack is not pinned to the self-hosting guide's example release. The upstream
Compose file explicitly lists these prebuilt images as alternatives to builds.

1. Copy this stack directory to Servo. No environment setup is required with the defaults.
2. Create storage directories:

   ```sh
   mkdir -p /mnt/user/appdata/firecrawl/postgres /mnt/user/appdata/firecrawl/redis /mnt/user/appdata/firecrawl/rabbitmq
   ```

3. From the stack directory on Servo, validate and start it:

   ```sh
   docker compose -p firecrawl config --quiet
   docker compose -p firecrawl pull
   docker compose -p firecrawl up -d
   docker compose -p firecrawl ps --all
   ```

   Alternatively, create a stack named `firecrawl` in Servo's Portainer or Dockge,
   paste this compose, set any optional overrides, and deploy directly. Images
   are downloaded from their registries. This file targets Docker Compose,
   not Docker Swarm. Use one manager for this stack to avoid duplicate deployments.

The API waits for RabbitMQ and PostgreSQL readiness. Those dependency healthchecks
are used for startup ordering; there are no API or browser healthchecks.
API/browser CPU and RAM ceilings follow the upstream template (4 CPUs/8 GB and
2 CPUs/4 GB respectively). These are limits, not reservations or verified minimum
host requirements; dependencies need additional capacity.

## Verify on the LAN

Check that the API responds:

```sh
curl --fail --max-time 5 http://192.168.11.3:3002/v0/health/readiness
```

Then verify an actual scrape, including workers and outbound website access:

```sh
curl --fail-with-body --max-time 75 \
  -X POST http://192.168.11.3:3002/v2/scrape \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com","formats":["markdown"],"timeout":60000}'
```

Expect `success: true` and content in `data.markdown`. API readiness alone does
not verify the full scrape pipeline. Inspect failures with
`docker compose -p firecrawl logs --tail=100 api playwright-service nuq-postgres rabbitmq`.
Use the configured host port instead if you override `FIRECRAWL_PORT`.

## Persistence and updates

| Host directory | Container directory | Purpose |
| --- | --- | --- |
| `/mnt/user/appdata/firecrawl/postgres` | `/var/lib/postgresql/data` | Queue database, schema, and pg_cron state |
| `/mnt/user/appdata/firecrawl/redis` | `/data` | Redis data, with append-only persistence enabled |
| `/mnt/user/appdata/firecrawl/rabbitmq` | `/var/lib/rabbitmq` | Broker state, with a stable node hostname |

These mounts preserve service state when containers are replaced; they are not
a permanent archive of scraped content. Let the official database images manage
their directory ownership; do not apply LinuxServer `PUID`/`PGID` settings.

Stop the stack before taking a filesystem backup of all three directories.
Keep deployment credentials securely with your recovery records. Changing
password environment variables does not rotate users already stored in an
initialized PostgreSQL or RabbitMQ data directory.

For upgrades, review the upstream Compose contract, run `docker compose -p
firecrawl pull`, then `docker compose -p firecrawl up -d`. In Portainer or Dockge,
pull updated images when redeploying. Tags can change independently; after a
successful deployment, pin tested image digests if you need reproducible updates.
Preserve database backups and the previous image digests for rollback. Check
the NuQ image's PostgreSQL major version before upgrades; major-version changes
require a database migration rather than simply reusing the data directory.

## Feature scope

This provides the open-source scraping stack. Optional AI extraction requires
a configured model provider. Screenshots, page actions, and advanced anti-bot
capabilities require services absent from this baseline. Consult the current
self-hosting feature matrix before assuming parity with Firecrawl Cloud.

## Sources

- [Self-hosting guide](https://docs.firecrawl.dev/contributing/self-host)
- [Repository self-hosting notes](https://github.com/firecrawl/firecrawl/blob/main/SELF_HOST.md)
- [Upstream Compose](https://github.com/firecrawl/firecrawl/blob/main/docker-compose.yaml)
- [API image](https://github.com/firecrawl/firecrawl/pkgs/container/firecrawl)
- [Playwright image](https://github.com/firecrawl/firecrawl/pkgs/container/playwright-service)
- [NuQ PostgreSQL image](https://github.com/firecrawl/firecrawl/pkgs/container/nuq-postgres)
