# cloudflared

Cloudflare Tunnel connector on Servo (`cloudflare/cloudflared`). This is a remotely managed tunnel: public hostnames and origin URLs are set in the Zero Trust dashboard, not in this repo.

Create the tunnel in [Cloudflare Zero Trust](https://one.dash.cloudflare.com/) → Networks → Tunnels. The dashboard’s Docker command is equivalent to this stack; the token is passed as `TUNNEL_TOKEN` instead of `--token` so it is not visible in the process list.

Point dashboard origins at Servo LAN URLs, for example `http://192.168.11.3:<port>`. There is no published port and no web UI on this container.

This stack is not `cloudflare-warp` (WARP SOCKS proxy).

## Required environment variables

- `TUNNEL_TOKEN` — tunnel token from the Cloudflare dashboard (do not commit it)

Put it in Portainer/Dockge stack env or in an untracked `.env` next to `compose.yaml`.

## Optional environment variables

- None (`TZ=Asia/Kolkata` is hardcoded)
