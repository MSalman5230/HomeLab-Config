# hindsight

Hindsight on Servo, running the API, web UI, and embedded PostgreSQL in one
container with MiniMax-M2.7 as the LLM.

- API: <http://192.168.11.3:8888>
- Web UI: <http://192.168.11.3:9999>
- Database storage: `/mnt/user/appdata/hindsight`, mounted at `/home/hindsight/.pg0`.

## Required environment variables

- `MINIMAX_API_KEY`: MiniMax API key, passed to `HINDSIGHT_API_LLM_API_KEY`.
  Compose rejects missing or empty values. Set it in Portainer/Dockge's stack
  environment or an untracked `.env` beside the compose file. Never commit it.

## Optional environment variables

- None

The compose file sets `TZ=Asia/Kolkata` and a stable
`HINDSIGHT_API_WORKER_ID=servo-hindsight` so the worker can recover its work
after container recreation. Shared memory is allocated with `shm_size: "1gb"`.

## Prepare storage and deploy

The image runs as UID/GID `1000:1000`. Its database directory must be writable
by that user; do not override the container user with Unraid's `99:100` IDs.

On Servo, create the directory and set ownership before the first deployment:

```sh
mkdir -p /mnt/user/appdata/hindsight
chown -R 1000:1000 /mnt/user/appdata/hindsight
```

For an existing installation, stop the Hindsight container before correcting
ownership. This command changes ownership of the existing database files; it
does not migrate or delete them.

Set `MINIMAX_API_KEY`, then deploy or update the `hindsight` stack in Servo's
Portainer or Dockge. With the CLI, run `docker compose up -d` from this stack's
directory on Servo. Check the container logs for database startup or LLM errors.

This stack uses embedded PostgreSQL. It does not use the separate AlloyDB Omni
and ScaNN deployment. Hindsight recommends external PostgreSQL for production;
switching database backends requires a separate deployment and data migration.

## Troubleshooting: database directory is not writable

If startup reports that `/home/hindsight/.pg0` is not writable by UID `1000`,
fix the bind-mounted directory in **Servo's Unraid terminal**:

```sh
docker stop hindsight
chown -R 1000:1000 /mnt/user/appdata/hindsight
chmod -R u+rwX /mnt/user/appdata/hindsight
docker start hindsight
docker logs --tail 100 hindsight
```

These commands preserve existing data and grant the owner read/write access
and directory traversal permissions.

Docker supports a `user:` override, but Hindsight's image expects its built-in
`hindsight` user (UID `1000`). An arbitrary UID such as Unraid's `99` has no
matching user entry in the image and can cause startup failures. Keep the image's
default user and fix host-directory permissions instead. `PUID` and `PGID`
environment variables are not supported by this image.

A Docker named volume is an alternative: Docker initializes its ownership for
the image's user. The current Servo stack uses a bind mount; switching to a named
volume would require copying existing database data if it needs to be retained.

## References

- [Installation](https://hindsight.vectorize.io/developer/installation#docker)
- [Supported models](https://hindsight.vectorize.io/developer/models)
