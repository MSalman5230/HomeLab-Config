# crawl4ai

Docker Compose stack for `crawl4ai`.

Without `CRAWL4AI_API_TOKEN` the 0.9.x server binds loopback inside the container; the published port answers with connection reset. Put the token in a `.env` next to `compose.yaml` (do not commit it). Call the API with `Authorization: Bearer <token>`. `/health` needs no auth.

UI: `http://192.168.11.3:11235/playground` and `/dashboard` — paste the token in the top bar.

## Required environment variables

- `CRAWL4AI_API_TOKEN` (required; generate with `openssl rand -hex 32`)
- `ANTHROPIC_API_KEY` (required)

## Optional environment variables

- `ANTHROPIC_BASE_URL` (default: `https://api.minimax.io/anthropic`)
- `ANTHROPIC_TEMPERATURE` (default: `1.0`)
- `LLM_PROVIDER` (default: `anthropic/MiniMax-M2.7`)
