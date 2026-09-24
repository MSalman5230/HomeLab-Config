# flaresolverr

Solves Cloudflare "checking your browser" challenges for Prowlarr ([FlareSolverr/FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)).

## Required environment variables

- None

## Optional environment variables

- None (`LOG_LEVEL=info`, `PROXY_URL=http://192.168.11.3:8889`, `TZ=Asia/Kolkata` are hardcoded)

Use `LOG_LEVEL=debug` temporarily when troubleshooting.

## Notes

- API: `http://192.168.11.3:8191` (no web UI; opening it shows a JSON status)
- No persistent data.
- Its browser goes through the `gluetun` HTTP proxy, so start gluetun first. Cloudflare ties the clearance cookie to the IP, so FlareSolverr and Prowlarr's indexer proxy must use the same exit IP. Both go through gluetun here.
- Upstream warns that captcha solvers currently don't work. It handles the automatic browser check, not hCaptcha/Turnstile puzzles.

## Connect to Prowlarr

1. **Settings → Indexers → Indexer Proxies → + → FlareSolverr**
   - Host: `http://192.168.11.3:8191/`
   - Tag: `flaresolverr`
2. Add the `flaresolverr` tag only to indexers that are behind Cloudflare. Prowlarr usually warns when an indexer needs it.

For a Cloudflare-protected indexer that is also ISP-blocked, add both the `vpn` and `flaresolverr` tags, then use the indexer's **Test** button to confirm it works.
