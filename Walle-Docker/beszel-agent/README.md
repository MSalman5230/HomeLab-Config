# Beszel agent on Wally

Monitors Wally (`192.168.11.2`) and its Docker containers using the Beszel hub
on Servo at <http://192.168.11.3:8090>.
Agent data is stored in the Docker named volume `beszel_agent_data`, mounted
at `/var/lib/beszel-agent`. Compose creates it with the stack's project prefix.

## Required environment variables

| Variable | Purpose |
| --- | --- |
| `KEY` | Public SSH key from the Servo hub's Add System dialog. |
| `TOKEN` | Token from that dialog for the Wally system's outgoing WebSocket connection. |

Set these in Portainer's stack environment or in an untracked `.env` beside
`compose.yaml`. Compose requires nonempty values before deployment.
Never commit tokens or passwords.

## Optional environment variables

| Variable | Default | Purpose |
| --- | --- | --- |
| `HUB_URL` | `http://192.168.11.3:8090` | Servo hub address for the agent's outgoing WebSocket connection. |

`TZ` is fixed to `Asia/Kolkata` and `LISTEN` to `45876` in the compose file.

## Deploy

1. In the Servo hub, choose **Add System**, name it `Wally`, and use
   **Host / IP** `192.168.11.2` with **Port** `45876`.
2. Copy the public key and token into the deployment environment as `KEY`
   and `TOKEN`.
3. With Wally's Portainer running, create a stack named `beszel-agent` using
   `compose.yaml` and deploy it. Alternatively, run `docker compose up -d`
   from this stack's directory on Wally with the local `.env` configured.
   Docker creates the data volume automatically; no host data directory is needed.
4. Finish adding the system in the hub and confirm Wally appears online.

The agent uses host networking to read Wally's network interface statistics.
It listens directly on host TCP port `45876`; no Docker port mapping or
`shared_bridge_1` network is needed. This is an agent protocol endpoint,
not a web dashboard. Host networking cannot be combined with Compose networks.
The Docker socket is mounted read-only for container monitoring. The image's
default user is retained for host and Docker socket access.

The hub can reach the agent at `192.168.11.2:45876`, and the agent can connect
outbound to Servo at `192.168.11.3:8090`. A Unix socket cannot be shared between
these two hosts. No healthcheck is configured.

This stack is independent of Wally's old `beszel` hub stack. Deploying it does
not stop or remove that hub.

## References

- [Agent installation](https://www.beszel.dev/guide/agent-installation)
- [Environment variables](https://www.beszel.dev/guide/environment-variables)
