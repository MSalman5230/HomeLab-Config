# gameloot-scrape-alert

GameLoot scraper that stores listings in MongoDB and sends Telegram alerts.
Image: `ghcr.io/msalman5230/gameloot-scrape-alert:latest`.

This stack has no published ports. MongoDB is the existing Servo `mongodb` stack
at `192.168.11.3:27017`.

## Required environment variables

Set these in Portainer/Dockge's stack environment or an untracked `.env` beside
the compose file. Never commit them.

- `TELEGRAM_BOT_TOKEN`: Bot token from [@BotFather](https://t.me/BotFather).
- `MONGODB_URI`: Connection string for Servo's MongoDB. Example:

  `mongodb://USER:PASSWORD@192.168.11.3:27017/gamelootScrape?authSource=admin`

  Create the app user and `gamelootScrape` database on the MongoDB stack first
  (see `Servo-Docker/mongodb/readme.md`).

Compose rejects missing or empty required values.

## Optional environment variables

- `LOG_LEVEL`: Default `INFO` (`DEBUG`, `WARNING`, `ERROR`).
- `LOG_FORMAT`: Default `%(levelname)s - %(message)s`.

`TZ` is set to `Asia/Kolkata` in compose.

## Deploy

Set the required variables, then deploy the `gameloot-scrape-alert` stack in
Servo's Portainer or Dockge. Chat IDs are configured in the image, not via env.

## References

- [MSalman5230/Gameloot-scrape-alert](https://github.com/MSalman5230/Gameloot-scrape-alert)
