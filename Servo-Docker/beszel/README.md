# Beszel on Servo

Fresh Beszel hub and local agent for Servo (Unraid).
Dashboard: <http://192.168.11.3:8090>. No data is imported from Wally.

The hub and agent share `/mnt/user/appdata/beszel/socket` at `/beszel_socket`.
The agent listens on `/beszel_socket/beszel.sock` instead of TCP port `45876`.
Host networking lets the agent monitor Servo's network interfaces and reach
the hub at `http://127.0.0.1:8090`.

## Required environment variables

The hub needs no credentials to start. Create its initial admin account in the
web UI. These variables are required to connect the agent to the new hub:

| Variable | Purpose |
| --- | --- |
| `BESZEL_KEY` | Public key from the new hub's Add System dialog; passed to the agent as `KEY`. |
| `BESZEL_TOKEN` | Token from that dialog; passed to the agent as `TOKEN`. |

Both default to empty to allow initial hub setup. The agent may fail or restart
until they are configured. Set them in Portainer's stack environment, Dockge,
or an untracked `.env` alongside `compose.yaml`, then redeploy the stack.
Never commit tokens or passwords.

## Optional environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `APP_URL` | `http://192.168.11.3:8090` | Hub URL for email and notification links. Override with the public URL when using a reverse proxy. |

`TZ` is fixed to `Asia/Kolkata` for both services. If you change the published
hub port, update `APP_URL` and the agent's `HUB_URL` accordingly. The container
port remains on `8090`.

## Storage

| Host path | Container path | Purpose |
| --- | --- | --- |
| `/mnt/user/appdata/beszel/data` | `/beszel_data` | Hub database and settings |
| `/mnt/user/appdata/beszel/agent` | `/var/lib/beszel-agent` | Agent persistent data |
| `/mnt/user/appdata/beszel/socket` | `/beszel_socket` | Shared local connection |

The agent also mounts the Docker socket read-only and preserves the existing
read-only disk mounts from `/mnt/disk1/.beszel` through `/mnt/disk5/.beszel`.
Cache pools `/mnt/cache_a` and `/mnt/cache_b` are mounted read-only at
`/extra-filesystems/cache_a` and `/extra-filesystems/cache_b` for monitoring.

## Deploy

1. On Servo, remove the old standalone `beszel-agent` stack/container through
   Portainer or Dockge before deploying this combined stack. Stopping it alone
   does not release the container name. Deleting its compose file from this
   repository does not remove the running container. Keep the disk directories.
2. Create the new directories on Servo if needed:

   ```sh
   mkdir -p /mnt/user/appdata/beszel/data /mnt/user/appdata/beszel/agent /mnt/user/appdata/beszel/socket
   ```

3. Create or update the `beszel` stack in Servo's Portainer or Dockge with
   `compose.yaml`, then deploy. For CLI setup, run `docker compose up -d beszel`
   from this stack's directory on Servo to start only the hub first.
4. Open <http://192.168.11.3:8090>, create the admin account, and choose
   **Add System**. Name the system `Servo` and set **Host / IP** to
   `/beszel_socket/beszel.sock`. The port field is not used for this socket.
5. Copy the dialog's public key and token into `BESZEL_KEY` and `BESZEL_TOKEN`
   in the deployment environment. Redeploy the stack to recreate the agent.
   With the CLI and a local `.env`, run `docker compose up -d`.
6. Finish adding Servo in the dialog and confirm it appears online.

Remote hosts such as Wally use their own agents over the network. Configure
them using the new hub's generated settings; old hub credentials do not carry
over. Wally's stack files are unchanged. Once monitoring works in the new hub,
the old Wally hub can be stopped separately.

## References

- [Getting started](https://www.beszel.dev/guide/getting-started)
- [Hub installation](https://www.beszel.dev/guide/hub-installation)
- [Environment variables](https://www.beszel.dev/guide/environment-variables)
