# arcane

Docker and compose manager ([getarcaneapp/arcane](https://github.com/getarcaneapp/arcane)). It's an alternative to Portainer or Dockge.

**Arcane isn't installed from a compose file or from within Arcane.** It's added by hand in the Unraid web UI (**Docker → Add Container**), without the Community Apps template, so every setting is under your control. This README records what to fill in.

Compose stacks live in `/mnt/user/appdata/_docker_compose`, set as `PROJECTS_DIRECTORY`. Dockhand uses the same folder independently; neither app is required for the other.

Image: `ghcr.io/getarcaneapp/manager:latest`. The old `ofkm/arcane` image is outdated.

Web UI: `http://192.168.11.3:3552`

## 1. Before you start

Arcane needs `PROJECTS_DIRECTORY` to exist and be writable.

Check it in the Unraid terminal (the `>_` icon, top right):

```bash
ls -ld /mnt/user/appdata/_docker_compose
```

Create the folder if it is missing:

```bash
mkdir -p /mnt/user/appdata/_docker_compose
```

## 2. Generate an encryption key

In the Unraid terminal (the `>_` icon, top right):

```bash
openssl rand -hex 32
```

On a Windows PC, this PowerShell command makes the same kind of key:

```powershell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
```

Save the 64-character result in your password manager. Arcane uses it to encrypt the registry and login credentials it stores. **Never change or lose it:** Arcane can't decrypt what it already stored without it.

## 3. Fill in the Add Container form

### Top section

| Field | Value |
|---|---|
| Template | leave empty |
| Name | `arcane` |
| Overview | anything, or blank |
| Repository | `ghcr.io/getarcaneapp/manager:latest` |
| Registry URL | `https://github.com/getarcaneapp/arcane/pkgs/container/manager` (optional) |
| Icon URL | optional |
| WebUI | `http://[IP]:[PORT:3552]/` |
| Extra Parameters | `--cgroupns=host` |
| Post Arguments | blank |
| Network Type | `Bridge` |
| Privileged | **Off** |

`--cgroupns=host` matches `cgroup: host` in Arcane's official compose example.

### Paths

Click **Add another Path, Port, Variable, Label or Device** once for each row.

| Name | Container Path | Host Path | Access |
|---|---|---|---|
| Docker Socket | `/var/run/docker.sock` | `/var/run/docker.sock` | Read/Write |
| Data | `/app/data` | `/mnt/user/appdata/arcane/data` | Read/Write |
| Projects | `/mnt/user/appdata/_docker_compose` | `/mnt/user/appdata/_docker_compose` | Read/Write |

The Projects path is deliberately **the same on both sides**. See [Why the Projects path matches](#why-the-projects-path-matches).

Data holds Arcane's own database and encrypted credentials. Keep it separate from the compose folder.

### Port

| Name | Container Port | Host Port | Type |
|---|---|---|---|
| WebUI | `3552` | `3552` | TCP |

3552 doesn't clash with Portainer (8000 / 9000 / 9443).

### Variables

| Key | Value | Password Mask | Required |
|---|---|---|---|
| `ENCRYPTION_KEY` | the key from step 2 | **Yes** | Yes |
| `APP_URL` | `http://192.168.11.3:3552` | No | Yes |
| `PROJECTS_DIRECTORY` | `/mnt/user/appdata/_docker_compose` | No | Yes |
| `PUID` | `99` | No | Yes (Unraid) |
| `PGID` | `100` | No | Yes (Unraid) |
| `TZ` | `Asia/Kolkata` | No | Recommended |

Arcane's docs list all three of `PUID`, `PGID` and `TZ` as supported. Without them it runs as `65532:65532` and uses the `Local` timezone for scheduled jobs.

Click **Apply**.

## 4. First login

1. Open `http://192.168.11.3:3552`.
2. Log in with username **`arcane`** and password **`arcane-admin`**.
3. Arcane forces a password change. The default policy (`strong`) needs 12+ characters with upper, lower, a number and a symbol.

### Relaxing the password policy (optional)

You can't reach Settings until you've changed the password, so:

1. Set a temporary password that meets the rule, e.g. `Temp-Arcane-2026!`.
2. Go to **Settings → Authentication → Password Policy** and pick a lower level.
3. Change your password again from your account/profile page.

| Policy | Requirement |
|---|---|
| `basic` | 8+ characters, nothing else |
| `standard` | 10+ characters, upper + lower + number |
| `strong` (default) | 12+ characters, upper + lower + number + symbol |

`basic` is the lowest. The policy can't be turned off. There's also an `AUTH_PASSWORD_POLICY=basic` env var, but it only works with `UI_CONFIGURATION_DISABLED=true`, which locks every setting in the UI, so don't use it.

Keep the password reasonably strong anyway. See [Security](#security).

## Projects layout

Arcane uses a flat layout, one folder per project:

```text
/mnt/user/appdata/_docker_compose/
├── jellyfin/
│   ├── compose.yaml
│   └── .env
└── searxng/
    └── compose.yaml
```

The folder name is the compose project name. Don't edit the same stack in Arcane and Dockhand at once: each app saves the whole file, so the last save wins.

## Troubleshooting

**`permission denied` on `/var/run/docker.sock` in the logs:** user `99` isn't allowed to use the Docker socket. Get the socket's group ID:

```bash
stat -c %g /var/run/docker.sock
```

Then edit the container and change Extra Parameters to `--cgroupns=host --group-add <that number>`.

## Why the Projects path matches

The Path mapping and `PROJECTS_DIRECTORY` do different jobs:

- **The Path mapping** is for Docker. It makes the host folder visible inside the container.
- **`PROJECTS_DIRECTORY`** is for Arcane. It tells the app where its compose projects are. Without it, Arcane uses `/app/data/projects` and ignores the Projects mount.

Arcane doesn't run containers itself. It sends compose requests through the Docker socket to Unraid's Docker, which runs **on the host**. A relative bind mount like `./config` gets resolved to a full path by Arcane, and the host then uses that path:

| Setup | Arcane sends | Host result |
|---|---|---|
| Same path both sides (this setup) | `/mnt/user/appdata/_docker_compose/jellyfin/config` | ✅ Correct folder |
| Default `/app/data/projects` | `/app/data/projects/jellyfin/config` | ❌ Doesn't exist on the host, so Docker creates an empty folder in the wrong place |

## What `APP_URL` is for

`APP_URL` is the address Arcane uses when it builds links to itself: SSO/OIDC redirects (Authentik, Authelia, Pocket ID and so on) and links in notifications. Arcane can't work out its own address from inside a container, and the default `http://localhost:3552` points at your own PC.

Without SSO a wrong value mostly goes unnoticed, but set it correctly anyway. If you later put Arcane behind a reverse proxy, change it to that URL (e.g. `https://arcane.yourdomain.lan`).

## Security

- Mounting the Docker socket gives Arcane **root-level control of Servo**. Portainer works the same way. Anyone who logs in to Arcane effectively has root.
- Keep port 3552 on the LAN only. Never port-forward it.
- Don't commit `ENCRYPTION_KEY` or the admin password to this repo.

## Sources

- [Arcane installation docs](https://getarcane.app/docs/setup/installation)
- [Environment variable reference](https://getarcane.app/docs/configuration/environment)
- [Official compose example](https://raw.githubusercontent.com/getarcaneapp/arcane/main/docker/examples/compose.basic.yaml)
- [Account recovery and password policy](https://getarcane.app/docs/security/account-recovery)
