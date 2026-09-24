# MySQL Stack

This directory contains the Docker Compose configuration for running MySQL database server.

## Default Credentials

- Root Password: changeme (set via MYSQL_ROOT_PASSWORD environment variable)

## Ports

- MySQL: 3306

## Remote Connections

This MySQL instance is configured to accept remote connections:
- The bind-address is set to 0.0.0.0 (listen on all interfaces) via command line argument
- MYSQL_ROOT_HOST is set to % (allowing root user to connect from any host)
- Port 3306 is exposed for external access

To connect from a remote client, use:
```
mysql -h [server_ip] -P 3306 -u root -p
```

### DBeaver Connection Issues

If you encounter a "Public Key Retrieval is not allowed" error when connecting with DBeaver, follow these steps:

1. In DBeaver, right-click on your MySQL connection and select "Edit Connection"
2. Go to the "Driver Properties" or "Connection Properties" tab
3. Add a new property:
   - Name: `allowPublicKeyRetrieval` 
   - Value: `true`

Alternatively, you can also add:
- Name: `useSSL`
- Value: `false`

If you can't find the Driver Properties tab:
1. Navigate to "Connection Settings" → "Driver properties" or "Edit Driver Settings"
2. Click on the "+" icon to add a new property
3. Add the properties mentioned above

## Volumes

Data is stored in:
- `/docker_data/mysql` - MySQL data directory

## Network

Uses the `shared_bridge_1` external network.

## Volume Permissions

When you deploy this stack for the first time, Docker will create the volume directories with root ownership. Since the container runs as user 1000:1000, you need to fix the permissions:

```bash
# Create directory first (if it doesn't exist)
mkdir -p /docker_data/mysql

# Set correct ownership
sudo chown -R 1000:1000 /docker_data/mysql
sudo chmod -R 755 /docker_data/mysql

# Then deploy or restart the stack
```

## Additional Configuration

You can modify the compose.yaml file to add:
- A specific database (MYSQL_DATABASE)
- A non-root user (MYSQL_USER)
- A password for that user (MYSQL_PASSWORD) 