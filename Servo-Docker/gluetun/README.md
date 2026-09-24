# gluetun

VPN client container ([passteque/gluetun](https://github.com/passteque/gluetun), formerly `qdm12/gluetun`). Other containers can route all their traffic through it, and it exposes HTTP and SOCKS5 proxies for LAN clients.

Image: `qmcgaw/gluetun:v3` (tracks the latest v3.x release).

Hardcoded: Surfshark, WireGuard, Singapore servers, HTTP proxy on, SOCKS5 proxy on, Shadowsocks off, LAN `192.168.11.0/24` reachable.

## Required environment variables

- `WIREGUARD_PRIVATE_KEY` — Surfshark private key
- `WIREGUARD_ADDRESSES` — the `Address` line from a Surfshark WireGuard config, e.g. `10.14.0.2/16`

To get both: Surfshark account → **VPN → Manual Setup → Desktop or mobile → WireGuard** → **I don't have a keypair** → **Generate a new keypair**. Copy the private key, then download any server's config file and take its `Address` value (it is the same for all servers).

## Optional environment variables

- `HTTPPROXY_USER`, `HTTPPROXY_PASSWORD` — set both to require HTTP proxy auth
- `SOCKS5_USER`, `SOCKS5_PASSWORD` — set both to require SOCKS5 proxy auth

Leave them unset for no auth (LAN only — never port-forward these).

## Ports

| Host | Container | Purpose |
|------|-----------|---------|
| `8889/tcp` | `8888` | HTTP proxy (`http://192.168.11.3:8889`) |
| `1081/tcp+udp` | `1080` | SOCKS5 proxy (`socks5://192.168.11.3:1081`) — `1080` is used by `cloudflare-warp` |
If the logs don't show a SOCKS5 server starting, the image version doesn't include it yet; the HTTP proxy still works.

`8888` is used by `hindsight` and `8000` by Portainer, so the control server (container port `8000`) is not published. If you need it, map it to a free host port and set up auth first. Since v3.40 all control-server routes require it (`HTTP_CONTROL_SERVER_AUTH_DEFAULT_ROLE` or `/gluetun/auth/config.toml`).

## Routing another container through gluetun

Same compose stack:

```yaml
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    network_mode: service:gluetun
    depends_on:
      gluetun:
        condition: service_healthy
```

Separate stack (gluetun must already be running):

```yaml
    network_mode: container:gluetun
```

The routed container has no network of its own:

- Publish its ports on the **gluetun** service, not on the app.
- If gluetun is recreated, restart the routed containers too.
- If the VPN drops, the routed container's traffic is blocked (kill switch).

## Verify

```bash
docker exec gluetun wget -qO- https://ipinfo.io
```

The IP should be a Surfshark Singapore address, not your home IP.

From another machine on the LAN:

```bash
curl -x http://192.168.11.3:8889 https://ipinfo.io
curl --socks5-hostname 192.168.11.3:1081 https://ipinfo.io
```
