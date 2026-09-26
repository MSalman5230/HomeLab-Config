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

## References

- [Installation](https://hindsight.vectorize.io/developer/installation#docker)
- [Supported models](https://hindsight.vectorize.io/developer/models)
