# qbittorrent

Torrent client ([linuxserver/qbittorrent](https://hub.docker.com/r/linuxserver/qbittorrent)). Downloads directly over the home connection (not through gluetun).

## Required environment variables

- None

## Optional environment variables

- None (`PUID=99`, `PGID=100`, `TZ=Asia/Kolkata`, `WEBUI_PORT=8080` are hardcoded)

## Notes

- Web UI: `http://192.168.11.3:8080`
- Config: `/mnt/user/appdata/qbittorrent`
- Downloads: `/mnt/user/downloads` → `/downloads`

## First login

Username is `admin`. A temporary password is printed in the logs on first start:

```bash
docker logs qbittorrent 2>&1 | grep -i password
```

Set a permanent one under **Tools → Options → Web UI**.

## Download folders

**Tools → Options → Downloads**

- Default Save Path: `/downloads/torrent`
- Keep incomplete torrents in: ✅ `/downloads/torrent_incomplete`

The torrenting port is not published: the ISP doesn't support port forwarding, so peers can't connect in anyway. Downloads work through outgoing connections.
