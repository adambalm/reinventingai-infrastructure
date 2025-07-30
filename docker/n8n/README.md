# n8n Docker Setup

This directory contains all configurations and scripts for managing n8n instances.

## Current Instances

### Test Environment (r2d2)
- **URL**: https://r2d2.reinventingai.com
- **Container**: n8n-gabe
- **Port**: 5679
- **Volume**: n8n_data_gabe
- **Purpose**: Safe testing environment for Gabe

## Quick Commands

### Check Status
```bash
docker ps | grep n8n-gabe
docker logs n8n-gabe --tail 50
```

### Backup Data
```bash
./backup.sh
```

### Restore Data
```bash
./restore.sh backup-filename.tar.gz
```

### Test Persistence
```bash
./test-persistence.sh
```

## Initial Setup

### 1. Create Container with Persistent Volume

```bash
docker run -d \
  --name n8n-gabe \
  -p 5679:5678 \
  -v n8n_data_gabe:/home/node/.n8n \
  -e N8N_RUNNERS_ENABLED=true \
  -e N8N_DIAGNOSTICS_ENABLED=false \
  -e N8N_PUBLIC_API_SWAGGERUI_DISABLED=true \
  -e N8N_PORT=5678 \
  -e N8N_PUBLIC_API_DISABLED=true \
  -e GENERIC_TIMEZONE=America/New_York \
  -e N8N_ENCRYPTION_KEY=fcadc85741894b03bf90011e4b1f032498c520c591f2387b0989dcb4fec4c712 \
  -e N8N_HOST=r2d2.reinventingai.com \
  -e WEBHOOK_URL=https://r2d2.reinventingai.com/ \
  -e N8N_VERSION_NOTIFICATIONS_ENABLED=false \
  -e N8N_PROTOCOL=https \
  -e NODE_ENV=production \
  n8nio/n8n:1.103.2
```

### 2. Verify Persistence
Always test persistence before starting work:
```bash
./test-persistence.sh
```

### 3. Set Up Owner Account
Only after persistence is verified, access https://r2d2.reinventingai.com and create the owner account.

## OAuth Configuration

For OAuth to work properly:
1. Ensure N8N_HOST matches the actual domain
2. Configure OAuth callbacks to: `https://r2d2.reinventingai.com/rest/oauth2-credential/callback`
3. Test with a simple Google Sheets connection first

## Maintenance

### Container Updates
```bash
# 1. Backup current data
./backup.sh

# 2. Stop and remove container (data is safe in volume)
docker stop n8n-gabe
docker rm n8n-gabe

# 3. Pull new image
docker pull n8nio/n8n:latest

# 4. Recreate container with same volume
# Use the docker run command above with updated image tag

# 5. Verify data persisted
docker exec n8n-gabe ls -la /home/node/.n8n/
```

### Troubleshooting
See [troubleshooting.md](troubleshooting.md) for common issues and solutions.

## ⚠️ CRITICAL WARNINGS

1. **NEVER** run `docker volume rm n8n_data_gabe`
2. **ALWAYS** backup before major changes
3. **ALWAYS** test persistence after container recreation
4. **NEVER** create containers without volume mounts
