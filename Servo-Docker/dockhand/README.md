# dockhand

Docker and compose manager ([Dockhand](https://dockhand.pro)). It's an alternative to Portainer, Dockge or Arcane.

**Dockhand isn't installed from a compose file or from within Dockhand.** It's added by hand in the Unraid web UI (**Docker → Add Container**), without the Community Apps template, so every setting is under your control. This README records what to fill in.

It shares **Arcane's projects folder** (`/mnt/user/appdata/arcane/projects`) through `STACKS_DIR`, so the same compose stacks can be managed from either app. See [Sharing stacks with Arcane](#sharing-stacks-with-arcane).

Image: `fnsys/dockhand:latest`

Web UI: `http://192.168.11.3:3553`

## 1. Before you start

Arcane must already be installed, so that `/mnt/user/appdata/arcane/projects` exists. Dockhand needs `STACKS_DIR` to exist and be writable. If it isn't, Dockhand logs a warning and quietly falls back to its own `/app/data/stacks`.

Check it in the Unraid terminal (the `>_` icon, top right):

```bash
ls -ld /mnt/user/appdata/arcane/projects
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

This is a **base64** key (44 characters, ending in `=`), not the hex format Arcane uses. Don't reuse Arcane's key. Once `ENCRYPTION_KEY` is set, Dockhand deletes the key file, so the env var becomes the only copy. **Never change or lose it**, or the stored credentials can't be decrypted.

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
| Stacks | `/mnt/user/appdata/arcane/projects` | `/mnt/user/appdata/arcane/projects` | Read/Write |

The Stacks path is deliberately **the same on both sides**, for the same reason Arcane's Projects path is. See [Why the Stacks path matches](#why-the-stacks-path-matches).

Data holds Dockhand's own SQLite database, encryption key, cloned Git repos and scanner cache. It's Dockhand-only and must not point at Arcane's folders.

### Port

| Name | Container Port | Host Port | Type |
|---|---|---|---|
| WebUI | `3000` | `3553` | TCP |

The host port can't be 3000 because Metabase already uses it on Servo. 3553 sits next to Arcane (3552) and doesn't clash with Portainer (8000 / 9000 / 9443).

### Variables

| Key | Value | Password Mask | Required |
|---|---|---|---|
| `STACKS_DIR` | `/mnt/user/appdata/arcane/projects` | No | Yes (for sharing with Arcane) |
| `PUID` | `99` | No | Yes (Unraid) |
| `PGID` | `100` | No | Yes (Unraid) |
| `TZ` | `Asia/Kolkata` | No | Recommended |
| `ENCRYPTION_KEY` | the key from step 2 | **Yes** | Optional |
| `SKIP_DF_COLLECTION` | `true` | No | Optional |

- `PUID` / `PGID`: Dockhand's entrypoint starts as root, fixes folder ownership, then drops to this user. Without them it runs as `1000:1000`. `99:100` is also what Arcane uses, so files written by either app are owned by the same user.
- `SKIP_DF_COLLECTION`: turns off Docker disk-usage collection. Dockhand recommends it on NAS hosts where Docker's `/system/df` call is slow. Leave it out unless the dashboard feels sluggish.

Click **Apply**.

## 4. First login

On first launch, **authentication is off**: anyone who opens the page gets full access. Fix that straight away:

1. Open `http://192.168.11.3:3553`.
2. Go to **Settings → Authentication**, enable authentication and create your admin user.
3. Log out and back in to check it works.

In the free edition, every user who can log in has full admin access. There are no roles.

## Sharing stacks with Arcane

Both apps use the same flat layout, one folder per stack:

```text
/mnt/user/appdata/arcane/projects/
├── jellyfin/
│   ├── compose.yaml
│   └── .env
└── searxng/
    └── compose.yaml
```

Arcane gets there with `PROJECTS_DIRECTORY`, Dockhand with `STACKS_DIR`. Both use the folder name as the compose project name, so they're controlling the **same** containers, not copies.

### Stacks created in Arcane

Dockhand doesn't pick these up by itself. `STACKS_DIR` only controls where Dockhand **writes new** stacks. Running Arcane stacks show up in Dockhand as **Untracked** (start/stop only, no editing). To manage them fully:

1. In Dockhand, go to **Stacks → Import**.
2. Browse to `/mnt/user/appdata/arcane/projects` and click **Scan this folder**.
3. Select the stacks and click **Import**.

Running stacks aren't pre-selected in the scan results, so tick them yourself. Import doesn't copy or move anything: the compose and `.env` files stay where they are, and Dockhand edits them in place. Repeat the import each time you create a new stack in Arcane.

### Stacks created in Dockhand

Dockhand writes them to `/mnt/user/appdata/arcane/projects/<stack>/`, so they appear in Arcane's projects list as well.

Stack names must be unique. The layout is flat, so Dockhand refuses to create a stack whose folder already exists.

### Rules for shared stacks

- **Don't use Dockhand "secret" variables** in a stack you also manage from Arcane. Dockhand keeps secrets encrypted in its own database and injects them only when **Dockhand** deploys. They're never written to `.env`. If Arcane redeploys the stack, or Unraid restarts the containers after a reboot, those values come through empty. Use normal `.env` variables instead.
- **Don't edit the same stack in both apps at once.** Each app saves the whole file, so the last save wins. Reload the editor after changing a stack in the other app.
- **Git stacks stay in Dockhand.** Dockhand clones Git-based stacks under `/app/data`, not `STACKS_DIR`, so Arcane can't see them.

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
- **`STACKS_DIR`** is for Dockhand. It tells the app to keep stacks there. Without it, Dockhand uses `/app/data/stacks/<environment>/<stack>/`, which Arcane never sees.

Dockhand doesn't run containers itself. It sends compose requests through the Docker socket to Unraid's Docker, which runs **on the host**. A relative bind mount like `./config` gets resolved to a full path by Dockhand, and the host then uses that path:

| Setup | Dockhand sends | Host result |
|---|---|---|
| Same path both sides (this setup) | `/mnt/user/appdata/arcane/projects/jellyfin/config` | ✅ Correct folder, the same one Arcane uses |
| Mounted at a different path, e.g. `/stacks` | `/stacks/jellyfin/config` | ❌ Doesn't exist on the host, unless Dockhand's automatic path translation guesses it right |

Dockhand can sometimes translate mismatched paths on its own, but its docs call matching paths the more reliable option.

## Security

- Mounting the Docker socket gives Dockhand **root-level control of Servo**, the same as Arcane and Portainer. Anyone who logs in to Dockhand effectively has root.
- Turn on authentication on first launch (step 4). Until you do, anyone on the LAN has that root-level access.
- Keep port 3553 on the LAN only. Never port-forward it.
- Don't commit `ENCRYPTION_KEY` or the admin password to this repo.

## Sources

- [Dockhand user manual](https://dockhand.pro/manual/): quick start, Docker socket permissions, environment variables, custom stacks directory, adopting untracked stacks, secrets
