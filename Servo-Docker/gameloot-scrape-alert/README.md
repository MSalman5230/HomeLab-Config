# gameloot-scrape-alert

GameLoot scraper that stores listings in MongoDB, sends Telegram alerts, and
serves a dashboard. Image: `ghcr.io/msalman5230/gameloot-scrape-alert:latest`.

Dashboard: `http://192.168.11.3:8000` (no auth; keep it on the LAN). MongoDB is
the existing Servo `mongodb` stack at `192.168.11.3:27017`.

## Required environment variables

Set these in Portainer/Dockge's stack environment or an untracked `.env` beside
the compose file. Never commit them. Compose rejects missing or empty values.

- `TELEGRAM_BOT_TOKEN`: Bot token from [@BotFather](https://t.me/BotFather).
- `TELEGRAM_CHAT_IDS`: Comma-separated chat IDs that receive alerts.
- `MONGODB_URI`: Connection string for Servo's MongoDB. Example:

  `mongodb://USER:PASSWORD@192.168.11.3:27017/gamelootScrape?authSource=admin`

  The database name comes from the URI path. Create the app user and
  `gamelootScrape` database on the MongoDB stack first
  (see `Servo-Docker/mongodb/readme.md`).

## Optional environment variables

- `LOG_LEVEL`: Default `INFO` (`DEBUG`, `WARNING`, `ERROR`).
- `DEFAULT_MAX_CONCURRENT_RUNS`: Default `5`. Initial value only; later edited in the dashboard.
- `RUN_TIMEOUT_SECONDS`: Default `900`.
- `SCHEDULER_TICK_SECONDS`: Default `60`.

`TZ` is set to `Asia/Kolkata` in compose.

## Deploy

Set the required variables, then deploy the `gameloot-scrape-alert` stack in
Servo's Portainer or Dockge.

## References

- [MSalman5230/Gameloot-scrape-alert](https://github.com/MSalman5230/Gameloot-scrape-alert)
