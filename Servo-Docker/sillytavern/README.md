# sillytavern

Docker Compose stack for `sillytavern` based on the official Docker installation guide.

## Required environment variables

- None

## Optional environment variables

- `SILLYTAVERN_VERSION` (default: `latest`)
- `PUBLIC_PORT` (default: `8006`)
- `SILLYTAVERN_HEARTBEATINTERVAL` (default: `30`)
- `PUID` (default: `1000`)
- `PGID` (default: `1000`)

## Notes

 - Main app is exposed on `8006` (`http://localhost:8006`).
- Persistent volumes are mapped for:
  - `/home/node/app/config` (config)
  - `/home/node/app/data` (user data)
  - `/home/node/app/plugins` (server plugins)
  - `/home/node/app/public/scripts/extensions/third-party` (UI extensions)
- Do not expose this service directly to the public internet.
