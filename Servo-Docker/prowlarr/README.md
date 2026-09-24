# prowlarr

Indexer manager for Sonarr/Radarr ([linuxserver/prowlarr](https://hub.docker.com/r/linuxserver/prowlarr)).

## Required environment variables

- None

## Optional environment variables

- None (`PUID=99`, `PGID=100`, `TZ=Asia/Kolkata` are hardcoded)

## Notes

- Web UI: `http://192.168.11.3:9696`
- Config: `/mnt/user/appdata/prowlarr`

## Connect to Sonarr

**Settings → Apps → + → Sonarr**

- Prowlarr Server: `http://192.168.11.3:9696`
- Sonarr Server: `http://192.168.11.3:8989`
- API Key: from Sonarr → Settings → General

Indexers added in Prowlarr are then synced to Sonarr automatically.

## Route indexer searches through gluetun (Surfshark)

Useful when the ISP blocks torrent sites.

1. **Settings → Indexers → Indexer Proxies → + → Socks5**
   - Host: `192.168.11.3`
   - Port: `1081`
   - Tag: `vpn`
   - (or **Http** on port `8889` if SOCKS5 isn't available)
2. Add the `vpn` tag to each indexer that should use it.
