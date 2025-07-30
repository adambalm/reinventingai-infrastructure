# n8n Docker Configuration

Docker Compose configuration and management scripts for n8n workflow automation platform.

## Environment Configuration

### Test Environment
- URL: Configured via `N8N_HOST` environment variable
- Container: Configured via `N8N_CONTAINER_NAME` (default: n8n-gabe)
- Port: Configured via `N8N_EXTERNAL_PORT` (default: 5679)
- Volume: Configured via `N8N_VOLUME_NAME` (default: n8n_data_gabe)

## Operations

### Service Status
```bash
docker ps | grep ${N8N_CONTAINER_NAME:-n8n-gabe}
docker logs ${N8N_CONTAINER_NAME:-n8n-gabe} --tail 50
```

### Data Management
```bash
# Create backup
./backup.sh

# Restore from backup
./restore.sh backup-filename.tar.gz

# Test data persistence
./test-persistence.sh
```

## Deployment

### Prerequisites
Configure environment variables before deployment:
```bash
# Copy example environment file
cp ../../.env.example ../../.env

# Required variables:
# - N8N_ENCRYPTION_KEY (generate with: openssl rand -hex 32)
# - N8N_HOST (your domain)
# - WEBHOOK_URL (https://your-domain/)
vim ../../.env
```

### Service Startup
```bash
# Deploy n8n service
docker-compose up -d

# Verify data persistence
./test-persistence.sh
```

### Initial Account Setup
After verifying persistence, access the configured N8N_HOST domain to create the owner account.

## OAuth Integration

OAuth callbacks must be configured to: `https://${N8N_HOST}/rest/oauth2-credential/callback`

Requirements:
1. N8N_HOST must match the actual domain
2. SSL certificate must be valid
3. Test with Google Sheets integration first

## Container Maintenance

### Image Updates
```bash
# 1. Create data backup
./backup.sh

# 2. Stop and remove container
docker stop ${N8N_CONTAINER_NAME:-n8n-gabe}
docker rm ${N8N_CONTAINER_NAME:-n8n-gabe}

# 3. Pull updated image
docker pull n8nio/n8n:latest

# 4. Update N8N_IMAGE_VERSION in .env and restart
docker-compose up -d

# 5. Verify data integrity
docker exec ${N8N_CONTAINER_NAME:-n8n-gabe} ls -la /home/node/.n8n/
```

## Data Volume Warnings

CRITICAL: Data loss will occur if the following operations are performed:

1. `docker volume rm ${N8N_VOLUME_NAME}` - Permanently deletes all workflows and credentials
2. Container deployment without volume mounts - Creates ephemeral storage
3. Volume name changes without data migration - Orphans existing data

Required procedures:
- Create backup before any infrastructure changes
- Verify data persistence after container recreation
- Test volume mounts before production deployment