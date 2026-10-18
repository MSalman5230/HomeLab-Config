# Dockhand (Walle)

Compose definition for Dockhand on Walle (`192.168.11.2`), using SQLite and
the official `fnsys/dockhand:latest` image.

## Intended Debian location

```text
/srv/compose-project/
└── dockhand/
    ├── compose.yaml
    ├── README.md
    ├── .gitignore
    └── data/                 # Created when deployed; excluded from Git
```

The repository copy lives under `Walle-Docker/dockhand/`. Deploy its files at
`/srv/compose-project/dockhand/` on Walle.

## Storage and Docker access

- `./data` is a relative bind mount for Dockhand's persistent state, including
  its database, encryption key, and Git repositories. It resolves to
  `/srv/compose-project/dockhand/data/` when deployed at the intended location.
- `./data` is mounted at Dockhand's default `/app/data` path inside the
  container. `DATA_DIR` is not overridden.
- `STACKS_DIR` is set to `/srv/compose-project` inside the container. The host
  directory `/srv/compose-project` is mounted read/write at that same container
  path, so local projects and their relative binds use matching paths.
  Existing project files are not moved automatically when this setting changes.
- `/var/run/docker.sock` gives Dockhand management access to the local Docker
  daemon. This definition uses the image's default root execution; it does not
  force `user: "1000:1000"` or assume a host Docker group ID.
- No external network is required for local Docker socket management. Add
  `shared_bridge_1` if another Walle stack needs to reach Dockhand directly.
- This definition assumes standard rootful Docker on Debian.

## Environment variables

Required user-supplied variables: **none**. A `.env` file is optional.

| Variable | Required | Default | Purpose |
| --- | --- | --- | --- |
| `DOCKHAND_PORT` | No | `3001` | Published host port; avoids the existing Grafana port `3000`. |

The Compose file sets the following container variables:

| Variable | Value | Purpose |
| --- | --- | --- |
| `TZ` | `Asia/Kolkata` | Container timezone. |
| `STACKS_DIR` | `/srv/compose-project` | Parent directory for locally managed projects. |

## Access after deployment

Default URL: <http://192.168.11.2:3001>.

On first launch, enable authentication and create an administrator in
**Settings > Authentication**. The Docker socket grants administrative control
of the host; keep this management interface on a trusted network.

Keep `.env` and `data/` out of Git. Back up Dockhand's database and hidden
encryption key together using a consistent backup of the data directory.

## Official references

- [Dockhand quick start](https://dockhand.pro/)
- [Dockhand manual](https://dockhand.pro/manual/)
