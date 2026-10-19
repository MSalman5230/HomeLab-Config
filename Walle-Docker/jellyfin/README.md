# Jellyfin on Walle

Compose location: `/srv/compose-project/jellyfin/compose.yaml`.
The relative bind `./data:/config` uses `/srv/compose-project/jellyfin/data/`
for Jellyfin's configuration, databases, metadata, plugins, and plugin settings.
The existing media paths inside the container are preserved.

## Version

The stack runs Jellyfin 12.2 from `lscr.io/linuxserver/jellyfin:12.2ubu2604-ls54`.
The tag names the Jellyfin version (`12.2`), the Ubuntu 26.04 base (`ubu2604`),
and LinuxServer's build number (`ls54`). LinuxServer does not publish a plain
`12.2` or `12` tag.

The tag is pinned on purpose. `latest` follows future major releases, and major
releases can rewrite the database on first start. `version-12.2ubu2604` follows
LinuxServer rebuilds of 12.2 only, if OS patches without tag edits are wanted.

To update, read the Jellyfin release notes, stop the stack, back up `data/`, then
change the tag. Do not stop the container while database migrations run.

### Upgrade from 10.10.7

The stack was upgraded directly from 10.10.7
(`linuxserver/jellyfin:10.10.7ubu2404-ls63@sha256:71e77db4470b44729b9ad0693bd610c43817fd5a637470529e5903735f55bd5c`)
to 12.2. Jellyfin supports this path without an intermediate 10.11 release.
Before the upgrade, `PRAGMA integrity_check` returned `ok` for copies of
`jellyfin.db` and `library.db`.

Changes in 12.x that affect this stack:

- Third-party plugins built for 10.x do not load; install their 12.x builds.
- Usernames are case-insensitive.
- Legacy `/emby/` and `/mediabrowser/` URLs and the deprecated sign-in method are
  removed, so very old clients and scripts may stop working.
- The web client may need a hard refresh after an upgrade. Display Mode →
  Desktop (Legacy) restores the previous layout.

To roll back, stop the stack, restore the pre-upgrade backup of `data/`, and set
the image back to the 10.10.7 reference above. The 12.x upgrade rewrites data on
first start, so a backup is the only way back.

## Migration from the old container

On 2026-10-19, the stopped container's `/docker_data/jellyfin/` directory was
copied into the new `data/` directory using `cp -a`, preserving ownership,
permissions, timestamps, and symlinks. No original data was deleted or moved.

The source NVMe device `/dev/nvme0n1` reported critical medium read errors.
The destination contains all 137,202 directory entries, but five artwork files
are incomplete. SHA-256 verification confirmed that the other 109,576 regular
files (7,195,789,210 bytes) match their originals, including all three `.db`
files and the configuration and plugin files.

These paths are relative to the original config directory and the new `data/`
directory:

| Incomplete artwork file | Source bytes | Copied bytes |
| --- | ---: | ---: |
| `data/metadata/library/32/32022aff3f42001ee620e0e0fe8efa46/backdrop.jpg` | 558669 | 442368 |
| `data/metadata/library/e9/e91921208c583c58cd99481f502e6ed7/poster.jpg` | 32174 | 12288 |
| `data/metadata/library/bd/bdd42a8dc1607eca4323246574680e1b/poster.jpg` | 250155 | 94208 |
| `data/metadata/People/L/Lenny Hernandez/folder.jpg` | 61173 | 32768 |
| `data/metadata/People/S/Stephen Tobolowsky/folder.jpg` | 88827 | 28672 |

These artwork files need to be regenerated, for example by a metadata refresh of
the affected items. The underlying storage read errors also need attention.

## Image and runtime

The stack retains Docker's default `bridge` network, the existing published
ports, `/dev/dri`, and the Intel OpenCL Docker Mod. The restart policy is
`unless-stopped`.

The LinuxServer image does not include the Intel OpenCL runtime. The
`jellyfin-opencl-intel` mod installs it at container start for OpenCL HDR and
Dolby Vision tone mapping. VA-API and QSV transcoding do not need the mod.

The image uses `PUID` and `PGID` to run Jellyfin as UID/GID 1000. A Compose
`user:` override is omitted because LinuxServer's Docker Mods do not run in
that mode; see [LinuxServer's non-root documentation](https://docs.linuxserver.io/misc/non-root/).

## Environment variables

All values are set directly in `compose.yaml`; no `.env` file is required.

| Variable | Required or optional | Configured value | Purpose |
| --- | --- | --- | --- |
| `PUID` | Required | `1000` | Jellyfin process user ID, matching the existing setup. |
| `PGID` | Required | `1000` | Jellyfin process group ID, matching the existing setup. |
| `TZ` | Required | `Asia/Kolkata` | Lab timezone. |
| `DOCKER_MODS` | Optional; retained | `linuxserver/mods:jellyfin-opencl-intel` | Intel OpenCL runtime for tone mapping. |

See the [LinuxServer Jellyfin documentation](https://docs.linuxserver.io/images/docker-jellyfin/)
for image parameters and hardware acceleration details.

## Host paths

| Walle path | Container path |
| --- | --- |
| `./data` | `/config` |
| `/mnt/servo/anime` | `/data/anime` |
| `/mnt/servo/movies` | `/data/movies` |
| `/mnt/servo/othermedia` | `/data/othermedia` |
| `/mnt/servo/tv` | `/data/tvshows` |
| `/dev/dri` | `/dev/dri` (device) |

Jellyfin's databases are under `data/data/data/` on Walle. Published ports are
TCP 8096/8920 and UDP 7359/1900. HTTPS requires the existing Jellyfin
certificate configuration.

The `data/` directory and `.env` files are ignored by Git; keep configuration
data and secrets out of this repository.
