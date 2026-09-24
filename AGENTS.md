# Home lab config

This repo is **compose stacks for two hosts**. Put new stacks on the correct host. Do not mix path or compose conventions.

| Host | LAN IP | Folder | OS / tooling | Persistent data |
|------|--------|--------|----------------|-----------------|
| **Servo** | `192.168.11.3` | `Servo-Docker/` | Unraid + Portainer (also Dockge) | `/mnt/user/appdata/<stack>/` |
| **Wally** (dir: `Walle-Docker/`) | `192.168.11.2` | `Walle-Docker/` | Linux Docker + Portainer | `/docker_data/<app>/` |

Timezone: **Asia/Kolkata**. Restart policy: `unless-stopped` or `always`. Never commit secrets (`.env`, passwords, API keys).

## Servo

Unraid. LinuxServer images: `PUID=99`, `PGID=100`, `TZ=Asia/Kolkata`. Prefer `compose.yaml`.

**New stack:** folder named after the app → `compose.yaml` → `README.md` with required vs optional env vars. Volumes only under `/mnt/user/appdata/<stack>/`.

## Wally

Regular Linux host (`user: "1000:1000"` on many stacks). Compose filenames vary (`compose.yaml`, `compose.yml`, `docker-compose.yml`). Cross-stack traffic uses external network **`shared_bridge_1`**. Start **Portainer** first.

**New stack:** folder per app → compose file → bind mounts under `/docker_data/<app>/`. Attach `shared_bridge_1` if other stacks must reach it.

## Agent behavior

- Edit only the host folder the user named. If unclear, ask.
- Reach services at `http://192.168.11.3:<port>` (Servo) or `http://192.168.11.2:<port>` (Wally); ports come from the compose file.
- The same app name can exist on both hosts — keep those stacks independent.
- Per-stack README is the env-var source of truth.
