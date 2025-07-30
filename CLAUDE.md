# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is an infrastructure repository for ReinventingAI's Docker services, tunnels, and automation tools. The architecture follows a service-oriented approach with each major component in its own directory:

- **docker/**: Container orchestration for services (n8n workflow automation)  
- **tunnels/**: Cloudflare tunnel configurations and management
- **automations/**: Client automation templates and configurations
- **mcp/**: Model Context Protocol configurations (future integrations)
- **scripts/**: Shared utility scripts
- **docs/**: Documentation and best practices

## Environment Setup

**CRITICAL: Configure environment variables before any operations:**
```bash
# Copy example file and configure with your values
cp .env.example .env
vim .env  # Set N8N_ENCRYPTION_KEY, N8N_HOST, WEBHOOK_URL
```

## Common Commands

### n8n Service Management
The primary service is n8n (workflow automation) running in containers.

**Check service status:**
```bash
cd docker/n8n
# Service names are configured via environment variables
docker ps | grep ${N8N_CONTAINER_NAME:-n8n-gabe}
docker logs ${N8N_CONTAINER_NAME:-n8n-gabe} --tail 50
```

**Backup n8n data (CRITICAL - always backup before changes):**
```bash
cd docker/n8n
./backup.sh
```

**Restore n8n data:**
```bash
cd docker/n8n
./restore.sh backup-filename.tar.gz
```

**Test data persistence:**
```bash
cd docker/n8n
./test-persistence.sh
```

**Start/restart n8n service:**
```bash
cd docker/n8n
docker-compose up -d
```

**Update n8n container:**
```bash
cd docker/n8n
# Always backup first
./backup.sh
docker stop n8n-gabe
docker rm n8n-gabe
docker pull n8nio/n8n:latest
docker-compose up -d
```

### Daily Operations
```bash
# Daily backup (run from repository root)
./scripts/daily-backup.sh
```

## Critical Data Volumes

**NEVER DELETE THESE DOCKER VOLUMES** - They contain all persistent data:
- Volume name configured via `N8N_VOLUME_NAME` (default: n8n_data_gabe) - Contains all n8n workflows, credentials, and configuration data

## Active Services

| Service | URL | Container | Port | Volume |
|---------|-----|-----------|------|--------|
| n8n (test) | ${N8N_HOST} | ${N8N_CONTAINER_NAME} | ${N8N_EXTERNAL_PORT} | ${N8N_VOLUME_NAME} |

## Development Workflow

1. **Always test in the test environment first** (r2d2.reinventingai.com)
2. **Create backups before any infrastructure changes**
3. **Verify data persistence after container recreation**
4. **Document changes in relevant READMEs**
5. **Never create containers without proper volume mounts**

## Container Configuration

The n8n service uses specific environment variables for OAuth and webhook functionality:
- N8N_HOST must match the actual domain for OAuth callbacks
- WEBHOOK_URL configured for external integrations
- Encryption keys are environment-specific

OAuth callbacks are configured to: `https://${N8N_HOST}/rest/oauth2-credential/callback`