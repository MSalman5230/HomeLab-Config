# arcane

Docker and compose manager ([getarcaneapp/arcane](https://github.com/getarcaneapp/arcane)). It's an alternative to Portainer or Dockge.

**Arcane isn't installed from a compose file or from within Arcane.** It's added by hand in the Unraid web UI (**Docker → Add Container**), without the Community Apps template, so every setting is under your control. This README records what to fill in.

Image: `ghcr.io/getarcaneapp/manager:latest`. The old `ofkm/arcane` image is outdated.

Web UI: `http://192.168.11.3:3552`

## 1. Generate an encryption key

In the Unraid terminal (the `>_` icon, top right):

```bash
openssl rand -hex 32
```

On a Windows PC, this PowerShell command makes the same kind of key:

```powershell
-join ((1..32) | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
```

Save the 64-character result in your password manager. Arcane uses it to encrypt the registry and login credentials it stores. **Never change or lose it:** Arcane can't decrypt what it already stored without it.

## 2. Fill in the Add Container form

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
| Projects | `/mnt/user/appdata/arcane/projects` | `/mnt/user/appdata/arcane/projects` | Read/Write |

The Projects path is deliberately **the same on both sides**. See [Why the Projects path matches](#why-the-projects-path-matches).

### Port

| Name | Container Port | Host Port | Type |
|---|---|---|---|
| WebUI | `3552` | `3552` | TCP |

3552 doesn't clash with Portainer (8000 / 9000 / 9443).

### Variables

| Key | Value | Password Mask | Required |
|---|---|---|---|
| `ENCRYPTION_KEY` | the key from step 1 | **Yes** | Yes |
| `APP_URL` | `http://192.168.11.3:3552` | No | Yes |
| `PROJECTS_DIRECTORY` | `/mnt/user/appdata/arcane/projects` | No | Yes |
| `PUID` | `99` | No | Yes (Unraid) |
| `PGID` | `100` | No | Yes (Unraid) |
| `TZ` | `Asia/Kolkata` | No | Recommended |

Arcane's docs list all three of `PUID`, `PGID` and `TZ` as supported. Without them it runs as `65532:65532` and uses the `Local` timezone for scheduled jobs.

Click **Apply**.

## 3. First login

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
| Same path both sides (this setup) | `/mnt/user/appdata/arcane/projects/jellyfin/config` | ✅ Correct folder |
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
