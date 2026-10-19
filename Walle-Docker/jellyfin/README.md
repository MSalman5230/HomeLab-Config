# Jellyfin on Walle

Compose location: `/srv/compose-project/jellyfin/compose.yaml`.
The relative bind `./data:/config` uses `/srv/compose-project/jellyfin/data/`
for Jellyfin's configuration, databases, metadata, plugins, and plugin settings.
The existing media paths inside the container are preserved.

## Migration status: copied with five artwork read errors

On 2026-10-19, the stopped container's `/docker_data/jellyfin/` directory was
copied into the new `data/` directory using `cp -a`, preserving ownership,
permissions, timestamps, and symlinks. No original data was deleted or moved.
The original container remains stopped and has not been removed or renamed.
No image was pulled and no container was created or started.

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

The migration is not fully verified until these artwork files are recovered or
regenerated. The original files and the partial destination copies remain in
place. The underlying storage read errors also need attention.

## Image and runtime

The image is pinned to LinuxServer `10.10.7ubu2404-ls63`, using the RepoDigest
recorded by Docker for Walle's existing image:
`sha256:71e77db4470b44729b9ad0693bd610c43817fd5a637470529e5903735f55bd5c`.
The complete tag-and-digest reference was checked locally and resolves to the
same image ID as the stopped container. It replaces the different digest in
the initial draft.

The stack retains Docker's default `bridge` network, the existing published
ports, `/dev/dri`, and the Intel OpenCL Docker Mod. The restart policy is
`unless-stopped`.

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
| `DOCKER_MODS` | Optional; retained | `linuxserver/mods:jellyfin-opencl-intel` | Existing Intel OpenCL support. |

See the [LinuxServer Jellyfin documentation](https://docs.linuxserver.io/images/docker-jellyfin/)
for image parameters and hardware acceleration details.

## Host paths and validation

| Walle path | Container path |
| --- | --- |
| `./data` | `/config` |
| `/mnt/servo/anime` | `/data/anime` |
| `/mnt/servo/movies` | `/data/movies` |
| `/mnt/servo/othermedia` | `/data/othermedia` |
| `/mnt/servo/tv` | `/data/tvshows` |
| `/dev/dri` | `/dev/dri` (device) |

The media directories and GPU device were present during preparation. Published
ports remain TCP 8096/8920 and UDP 7359/1900. HTTPS still requires its existing
Jellyfin certificate configuration.

`docker compose -f /srv/compose-project/jellyfin/compose.yaml config --quiet`
passed without creating or starting a container.

The existing stopped container still owns the name `jellyfin`. A future start
through Compose requires resolving that container-name conflict first.
The `data/` directory and `.env` files are ignored by Git; keep configuration
data and secrets out of this repository.
