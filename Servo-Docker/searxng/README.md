# searxng

Docker Compose stack for SearXNG on Servo, based on the
[official container installation guidance](https://docs.searxng.org/admin/installation-docker.html).

## Required environment variables

- None

## Optional environment variables

- `FORCE_OWNERSHIP` (default: `true`): ensures SearXNG's mounted files are owned
  by the container's `searxng` user. Set through the stack environment or an
  untracked `.env` beside `compose.yaml`.

`TZ` is set to `Asia/Kolkata` for both services. `SEARXNG_VALKEY_URL` is set
to `valkey://valkey:6379/0` for the bundled Valkey service.

Additional supported `SEARXNG_*` or `GRANIAN_*` overrides must be explicitly
added to the SearXNG service's `environment` mapping, directly or using Compose
variable substitution. Adding arbitrary variables to `.env` or Portainer's
stack environment alone does not forward them to the container. Keep secrets
out of Git.

## Notes

- Main app is exposed on `7777`: <http://192.168.11.3:7777> (container port `8080`).
- Persistent volumes are mapped for:
  - `/etc/searxng` (config)
  - `/var/cache/searxng` (cache)
- `valkey` is included for Redis-compatible backend features.
- Valkey uses `9-alpine` and saves a snapshot after 30 seconds when at least
  one key has changed, matching the current official Compose template.
- All persistent storage is under `/mnt/user/appdata/searxng/`:
  `core-config`, `cache`, and `valkey`.

## Deploy or update

Deploy this compose file in Servo's Portainer or Dockge. With the CLI, run
`docker compose pull` followed by `docker compose up -d` from the stack directory
on Servo.

This update moves Valkey from version 8 to 9. Before upgrading an existing
installation, stop the stack and back up `/mnt/user/appdata/searxng/`, including
Valkey's data. Keep the backup if you need to roll back the image and data together.

Edit SearXNG settings on Servo at
`/mnt/user/appdata/searxng/core-config/settings.yml`. If the existing settings
contain `redis:`, migrate that section to `valkey:` with
`url: valkey://valkey:6379/0`. Restart SearXNG after changing settings.

## OpenWebUI integration

- Query URL format:
  - `http://192.168.11.3:7777/search?q=<query>&format=json`
- Example:
  - `http://192.168.11.3:7777/search?q=test&format=json`

### If `&format=json` returns `Forbidden`

Enable JSON output in `settings.yml`:

```yaml
search:
  formats:
    - html
    - json
```

If it is still blocked, disable limiter for trusted LAN/local usage:

```yaml
server:
  limiter: false
```

After changing `settings.yml`, restart the SearXNG container and test the URL again.
