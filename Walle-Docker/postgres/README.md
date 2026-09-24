# PostgreSQL Docker Stack

This is a Docker Compose stack for PostgreSQL using the official PostgreSQL image.

## Configuration

- **Image**: postgres:16
- **Port**: 5432
- **Data Persistence**: `/docker_data/postgres`
- **Default Credentials**:
  - Username: postgres
  - Password: postgres
  - Database: postgres

## Usage

1. Start the stack:
```bash
docker-compose up -d
```

2. Stop the stack:
```bash
docker-compose down
```

3. View logs:
```bash
docker-compose logs -f
```

## Connection Details

- Host: localhost
- Port: 5432
- Default credentials are set in the environment variables

## Data Persistence

All PostgreSQL data is persisted in `/docker_data/postgres` on the host machine. 