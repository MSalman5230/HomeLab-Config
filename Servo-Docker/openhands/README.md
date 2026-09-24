# openhands

OpenHands **Agent Canvas** ([OpenHands/openhands](https://github.com/OpenHands/openhands), [setup docs](https://docs.openhands.dev/openhands/usage/agent-canvas/setup)): a self-hosted control center for coding agents (OpenHands, Claude Code, Codex, Gemini or any ACP agent) plus scheduled/webhook automations. Upstream status: **beta**.

The all-in-one image runs the Canvas frontend, the Agent Server and the Automation backend behind one port. The agent runs **inside this container**, which is its sandbox.

## Required environment variables

- None

## Optional environment variables

- `LOCAL_BACKEND_API_KEY` — session key for the API. Unset: generated on first start and saved to `/mnt/user/appdata/openhands/data/agent-canvas/api-key.txt`. To set your own: `openssl rand -base64 32`

LLM provider keys (OpenAI, Anthropic, etc.) and agent logins are entered in the UI, not here. They're encrypted with `OH_SECRET_KEY`, which is auto-generated and persisted in the data folder. Don't lose that folder.

## Notes

- Web UI: `http://192.168.11.3:8010/canvas`
- `8000` is used by Portainer, so the container's `8000` is published on host `8010`.
- Data (settings, secrets, conversations, automation DB): `/mnt/user/appdata/openhands/data`
- Projects the agent can work on: `/mnt/user/appdata/openhands/projects` → `/projects`. Put or `git clone` repos here.
- Upstream suggests 2 vCPU / 4 GB RAM for a single user.

## First start: folder permissions

The container runs as uid `10001` and writes into both folders on start. On Unraid, before the first start:

```bash
mkdir -p /mnt/user/appdata/openhands/{data,projects}
chown -R 10001:10001 /mnt/user/appdata/openhands
```

## Security

- **The UI on this port has the session key baked in.** Anyone on the LAN who opens `http://192.168.11.3:8010/canvas` gets full control of the agent. Never port-forward it. For remote access, use a VPN or Tailscale, or put a reverse proxy with auth in front.
- The agent can run any shell command, read/write everything under `/projects` and the data folder, and **reach your whole LAN** (all Servo/Wally services).
- The bundled VS Code editor (`/vscode`) shares the Canvas origin, so a malicious extension could read stored backend keys (upstream issue #16492). Don't install untrusted extensions.

## Limitations when running in Docker

- **No Docker inside the agent.** The Docker socket isn't mounted, so the agent can't build or run containers. Mounting `/var/run/docker.sock` would give the agent root on Servo; not recommended.
- **Anything the agent installs is lost on recreate** (apt packages, global tools). Only `/projects` and the data folder persist.
- **Only `/projects` is visible.** To let it work on other shares, add another bind mount.
- **One shared sandbox.** Every conversation and automation runs in this same container, with no isolation between them.
- **Automations need the container running.** Schedules fire only while it's up, and inbound webhooks (GitHub, Slack) need the port reachable from the internet, which conflicts with the LAN-only advice above.
- **`latest` moves fast (beta).** Pin a version (e.g. `:1.23.0`) once it works.
