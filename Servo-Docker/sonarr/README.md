# sonarr

TV series manager ([linuxserver/sonarr](https://hub.docker.com/r/linuxserver/sonarr)).

## Required environment variables

- None

## Optional environment variables

- None (`PUID=99`, `PGID=100`, `TZ=Asia/Kolkata` are hardcoded)

## Notes

- Web UI: `http://192.168.11.3:8989`
- Config: `/mnt/user/appdata/sonarr`

## Folders

| Host | Container | Purpose |
|------|-----------|---------|
| `/mnt/user/downloads` | `/downloads` | qbittorrent downloads (`torrent/` complete, `torrent_incomplete/` in progress) |
| `/mnt/user/tvshows` | `/tv` | TV library, one folder per show |

`/downloads` is the same container path as in the `qbittorrent` stack, so Sonarr finds completed files without a remote path mapping.

Downloads and TV are separate Unraid shares mounted separately, so imports are **copies**, not hardlinks. While a torrent is still seeding, the episode uses disk space twice. Remove finished torrents in qbittorrent to free it.

## Setup

1. **Settings → Media Management → Root Folders** → add `/tv`
2. Existing shows: **Series → Library Import** → `/tv`
3. **Settings → Download Clients → + → qBittorrent**
   - Host: `192.168.11.3`
   - Port: `8080`
   - Username / password: from qbittorrent
   - Category: `tv-sonarr`

## Indexers

Add indexers in Prowlarr (see `../prowlarr/README.md`), not in Sonarr. Prowlarr syncs them here.
