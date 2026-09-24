# searxng

Docker Compose stack for `searxng` based on the official container installation guidance.

## Required environment variables

- None

## Optional environment variables

- `FORCE_OWNERSHIP` (default: `true`)
- `SEARXNG_*` variables for SearXNG config overrides
- `GRANIAN_*` variables for Granian server options

## Notes

- Main app is exposed on `8888` (`http://localhost:8888`).
- Persistent volumes are mapped for:
  - `/etc/searxng` (config)
  - `/var/cache/searxng` (cache)
- `valkey` is included for Redis-compatible backend features.

## OpenWebUI integration

- Query URL format:
  - `http://<host>:8888/search?q=<query>&format=json`
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
