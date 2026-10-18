# Home lab config

This repo is **compose stacks for two hosts**. Put new stacks on the correct host. Do not mix path or compose conventions.

| Host | LAN IP | Folder | OS / tooling | Persistent data |
|------|--------|--------|----------------|-----------------|
| **Servo** | `192.168.11.3` | `Servo-Docker/` | Unraid + Dockhand | `/mnt/user/appdata/<stack>/` |
| **Walle** (dir: `Walle-Docker/`) | `192.168.11.2` | `Walle-Docker/` | Debian 12  + Dockhand | `/srv/compose-project/<stack>/data/` |

Timezone: **Asia/Kolkata**. Restart policy: `unless-stopped` or `always`. Never commit secrets (`.env`, passwords, API keys).

## Servo

Unraid. Prefer LinuxServer images (if available): `PUID=99`, `PGID=100`, `TZ=Asia/Kolkata`. Prefer `compose.yaml`.

**New stack:** folder named after the app → `compose.yaml` → `README.md` with required vs optional env vars. Volumes only under `/mnt/user/appdata/<stack>/`.

## Walle

Debian 12 Linux,  (`user: "1000:1000"` on many stacks). Prefer `compose.yaml`.

**New stack:** folder named after the stack → compose file → persistent data under `/srv/compose-project/<stack>/data/`, using relative bind mounts such as `./data:<image-data-path>`. 

## Agent behavior

- Edit only the host folder the user named. If unclear, ask.
- Reach services at `http://192.168.11.3:<port>` (Servo) or `http://192.168.11.2:<port>` (Walle); ports come from the compose file.
- The same app name can exist on both hosts — keep those stacks independent.
- Per-stack README is the env-var source of truth.
