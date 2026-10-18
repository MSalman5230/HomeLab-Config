# Home lab compose

Two hosts. Docker is managed in **Dockhand** (GUI). Dockhand picks up compose files from each host's stacks dir — ignore how Dockhand works; just write a normal compose stack. If the user says Servo or Walle, write the stack only in this repo folder (`Servo-Docker/` or `Walle-Docker/`). If they don't say which host, ask. Same app name can exist on both — keep those stacks independent.

Prefer a LinuxServer image if available. Prefer `compose.yaml`. `TZ=Asia/Kolkata`. `restart: unless-stopped`. Never commit secrets (`.env`, passwords, API keys). Per-stack README lists required vs optional env vars.

| Host | LAN | Repo | OS | Compose files (Dockhand `STACKS_DIR`) | Persistent data |
|------|-----|------|----|----------------------------------------|-----------------|
| **Servo** | `192.168.11.3` | `Servo-Docker/` | Unraid | `/mnt/user/appdata/_docker_compose/<stack>/` | `/mnt/user/appdata/<stack>/` |
| **Walle** | `192.168.11.2` | `Walle-Docker/` | Debian 12 | `/srv/compose-project/<stack>/` | `./data` → `/srv/compose-project/<stack>/data/` |

Git holds the compose; deploy it into that host `STACKS_DIR`.

**Servo:** `PUID=99`, `PGID=100`. Bind volumes only under `/mnt/user/appdata/<stack>/`.

**Walle:** `user: "1000:1000"` when the image allows. Relative binds, e.g. `./data:<image-data-path>`.

