# dockhand

Docker and compose manager ([Dockhand](https://dockhand.pro)). It's an alternative to Portainer or Dockge.

**Dockhand isn't installed from a compose file or from within Dockhand.** It's added by hand in the Unraid web UI (**Docker → Add Container**), without the Community Apps template, so every setting is under your control. This README records what to fill in.

Compose stacks live in `/mnt/user/appdata/_docker_compose`, set as `STACKS_DIR`. Arcane uses the same folder independently; neither app is required for the other.

Image: `fnsys/dockhand:latest`

Web UI: `http://192.168.11.3:3553`

## 1. Before you start

Dockhand needs `STACKS_DIR` to exist and be writable. If it isn't, Dockhand logs a warning and quietly falls back to its own `/app/data/stacks`.

Check it in the Unraid terminal (the `>_` icon, top right):

```bash
ls -ld /mnt/user/appdata/_docker_compose
```

Create the folder if it is missing:

```bash
mkdir -p /mnt/user/appdata/_docker_compose
```

## 2. Generate an encryption key (optional)

Dockhand encrypts the registry, Git, OIDC and other credentials it stores. If you don't set a key, it generates one and saves it as `/mnt/user/appdata/dockhand/data/.encryption_key`. That works fine as long as you back up the whole data folder.

To keep the key in your password manager instead, generate one in the Unraid terminal:

```bash
openssl rand -base64 32
```

On a Windows PC, this PowerShell command makes the same kind of key:

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { [byte](Get-Random -Maximum 256) }))
```

This is a **base64** key (44 characters, ending in `=`). Once `ENCRYPTION_KEY` is set, Dockhand deletes the key file, so the env var becomes the only copy. **Never change or lose it**, or the stored credentials can't be decrypted.

## 3. Fill in the Add Container form

### Top section

| Field | Value |
|---|---|
| Template | leave empty |
| Name | `dockhand` |
| Overview | anything, or blank |
| Repository | `fnsys/dockhand:latest` |
| Registry URL | `https://hub.docker.com/r/fnsys/dockhand` (optional) |
| Icon URL | optional |
| WebUI | `http://[IP]:[PORT:3000]/` |
| Extra Parameters | blank (see [Troubleshooting](#troubleshooting)) |
| Post Arguments | blank |
| Network Type | `Bridge` |
| Privileged | **Off** |

In the WebUI field, `[PORT:3000]` is the **container** port. Unraid swaps in the host port (3553) when you click WebUI.

### Paths

Click **Add another Path, Port, Variable, Label or Device** once for each row.

| Name | Container Path | Host Path | Access |
|---|---|---|---|
| Docker Socket | `/var/run/docker.sock` | `/var/run/docker.sock` | Read/Write |
| Data | `/app/data` | `/mnt/user/appdata/dockhand/data` | Read/Write |
| Stacks | `/mnt/user/appdata/_docker_compose` | `/mnt/user/appdata/_docker_compose` | Read/Write |

The Stacks path is deliberately **the same on both sides**. See [Why the Stacks path matches](#why-the-stacks-path-matches).

Data holds Dockhand's own SQLite database, encryption key, cloned Git repos and scanner cache. Keep it separate from the stacks folder.

### Port

| Name | Container Port | Host Port | Type |
|---|---|---|---|
| WebUI | `3000` | `3553` | TCP |

The host port can't be 3000 because Metabase already uses it on Servo. 3553 doesn't clash with Portainer (8000 / 9000 / 9443).

### Variables

| Key | Value | Password Mask | Required |
|---|---|---|---|
| `STACKS_DIR` | `/mnt/user/appdata/_docker_compose` | No | Yes |
| `PUID` | `99` | No | Yes (Unraid) |
| `PGID` | `100` | No | Yes (Unraid) |
| `TZ` | `Asia/Kolkata` | No | Recommended |
| `ENCRYPTION_KEY` | the key from step 2 | **Yes** | Optional |
| `SKIP_DF_COLLECTION` | `true` | No | Optional |

- `PUID` / `PGID`: Dockhand's entrypoint starts as root, fixes folder ownership, then drops to this user. Without them it runs as `1000:1000`. `99:100` matches Unraid's usual `nobody`/`users` mapping, so files written under `STACKS_DIR` stay consistent with other appdata.
- `SKIP_DF_COLLECTION`: turns off Docker disk-usage collection. Dockhand recommends it on NAS hosts where Docker's `/system/df` call is slow. Leave it out unless the dashboard feels sluggish.

Click **Apply**.

## 4. First login

On first launch, **authentication is off**: anyone who opens the page gets full access. Fix that straight away:

1. Open `http://192.168.11.3:3553`.
2. Go to **Settings → Authentication**, enable authentication and create your admin user.
3. Log out and back in to check it works.

In the free edition, every user who can log in has full admin access. There are no roles.

## Stacks layout

Dockhand uses a flat layout, one folder per stack:

```text
/mnt/user/appdata/_docker_compose/
├── jellyfin/
│   ├── compose.yaml
│   └── .env
└── searxng/
    └── compose.yaml
```

The folder name is the compose project name. Stacks already on disk aren't picked up until you import them:

1. In Dockhand, go to **Stacks → Import**.
2. Browse to `/mnt/user/appdata/_docker_compose` and click **Scan this folder**.
3. Select the stacks and click **Import**.

Running stacks aren't pre-selected in the scan results, so tick them yourself. Import doesn't copy or move anything: the compose and `.env` files stay where they are, and Dockhand edits them in place.

Stack names must be unique. The layout is flat, so Dockhand refuses to create a stack whose folder already exists. Don't edit the same stack in Dockhand and Arcane at once: each app saves the whole file, so the last save wins.

Git-based stacks are cloned under `/app/data`, not `STACKS_DIR`.

**Don't use Dockhand "secret" variables** if Unraid or another process might recreate the containers outside Dockhand. Dockhand keeps secrets encrypted in its own database and injects them only when **Dockhand** deploys. They're never written to `.env`. Use normal `.env` variables instead.

## Troubleshooting

**`permission denied` on `/var/run/docker.sock`, or the local environment won't connect:** user `99` isn't allowed to use the Docker socket. Get the socket's group ID:

```bash
stat -c %g /var/run/docker.sock
```

Then edit the container and set Extra Parameters to `--group-add <that number>`. This is the Unraid equivalent of `group_add` in Dockhand's compose examples.

**The logs show a warning about `STACKS_DIR` and new stacks land in `/mnt/user/appdata/dockhand/data/stacks/`:** the Stacks path is missing or not writable by `99:100`. Check the [Before you start](#1-before-you-start) step and the Stacks path row, then restart the container. Stacks already created in the wrong place aren't moved automatically.

**The dashboard is slow to load:** add `SKIP_DF_COLLECTION=true`.

## Why the Stacks path matches

The Path mapping and `STACKS_DIR` do different jobs:

- **The Path mapping** is for Docker. It makes the host folder visible inside the container.
- **`STACKS_DIR`** is for Dockhand. It tells the app to keep stacks there. Without it, Dockhand uses `/app/data/stacks/<environment>/<stack>/`.

Dockhand doesn't run containers itself. It sends compose requests through the Docker socket to Unraid's Docker, which runs **on the host**. A relative bind mount like `./config` gets resolved to a full path by Dockhand, and the host then uses that path:

| Setup | Dockhand sends | Host result |
|---|---|---|
| Same path both sides (this setup) | `/mnt/user/appdata/_docker_compose/jellyfin/config` | ✅ Correct folder |
| Mounted at a different path, e.g. `/stacks` | `/stacks/jellyfin/config` | ❌ Doesn't exist on the host, unless Dockhand's automatic path translation guesses it right |

Dockhand can sometimes translate mismatched paths on its own, but its docs call matching paths the more reliable option.

## Security

- Mounting the Docker socket gives Dockhand **root-level control of Servo**, the same as Portainer. Anyone who logs in to Dockhand effectively has root.
- Turn on authentication on first launch (step 4). Until you do, anyone on the LAN has that root-level access.
- Keep port 3553 on the LAN only. Never port-forward it.
- Don't commit `ENCRYPTION_KEY` or the admin password to this repo.

## Sources

- [Dockhand user manual](https://dockhand.pro/manual/): quick start, Docker socket permissions, environment variables, custom stacks directory, adopting untracked stacks, secrets
