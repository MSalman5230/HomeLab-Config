# OpenSpeedTest Stack

This is a Docker Compose stack for running OpenSpeedTest, a self-hosted speed test server.

## Configuration

- Port: 3000
- Data persistence: ./data directory
- Timezone: UTC

## Usage

1. Start the stack:
```bash
docker-compose up -d
```

2. Access the speed test interface:
   - Open your browser and navigate to `http://localhost:3000`

## Features

- Self-hosted speed test server
- No dependencies on external speed test services
- Customizable test parameters
- Data persistence for test results

## Maintenance

- To update the container:
```bash
docker-compose pull
docker-compose up -d
```

- To view logs:
```bash
docker-compose logs -f
``` 