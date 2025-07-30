# n8n Service Management

This directory contains everything needed to run n8n (workflow automation) in Docker.

## What's Here

- `docker-compose.yml` - Main service configuration
- `backup.sh` - Creates backups of all n8n data
- `restore.sh` - Restores data from a backup file
- `test-persistence.sh` - Verifies your data survives container restarts

## Quick Start

**If this is your first time here, follow the main setup guide first:** `docs/team-onboarding.md`

### Check if n8n is Running
```bash
docker ps
```
Look for a container named `n8n-gabe` in the list.

### View Service Logs
```bash
docker logs n8n-gabe --tail 50
```
This shows the last 50 log messages. Press Ctrl+C to exit.

### Start the Service
```bash
docker-compose up -d
```
The `-d` flag runs it in the background.

### Stop the Service
```bash
docker-compose down
```

## Data Backup and Restore

**Always backup before making changes to the service.**

### Create a Backup
```bash
./backup.sh
```
This creates a backup file with the current date and time in the filename.

### Restore from Backup
```bash
./restore.sh backup-filename.tar.gz
```
Replace `backup-filename.tar.gz` with the actual backup file name.

### Test Data Persistence
```bash
./test-persistence.sh
```
This script verifies that your workflows and settings survive container restarts.

## Accessing n8n Web Interface

Once the service is running, open your web browser and go to:
https://r2d2.reinventingai.com

You'll see the n8n interface where you can create and manage workflows.

## Updating n8n

**Always create a backup first before updating.**

1. **Create backup:**
   ```bash
   ./backup.sh
   ```

2. **Stop current service:**
   ```bash
   docker-compose down
   ```

3. **Get latest version:**
   ```bash
   docker pull n8nio/n8n:latest
   ```

4. **Start updated service:**
   ```bash
   docker-compose up -d
   ```

5. **Verify everything works:**
   ```bash
   ./test-persistence.sh
   ```

## Important Warnings

**Never delete the Docker volume `n8n_data_gabe`** - This contains all your workflows, credentials, and settings. If you delete it, everything is permanently lost.

**Always backup before making changes** - Use `./backup.sh` before updating, restarting, or making any changes to the service.

## Troubleshooting

**Service won't start:**
1. Check Docker is running: `docker ps`
2. Check the logs: `docker logs n8n-gabe`
3. Verify environment variables in `.env` file
4. Make sure port 5678 isn't already in use

**Can't access the web interface:**
1. Verify service is running: `docker ps`
2. Check if you can reach: https://r2d2.reinventingai.com
3. Look at service logs for errors: `docker logs n8n-gabe`