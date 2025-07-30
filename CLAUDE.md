# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Purpose

Infrastructure repository for ReinventingAI Docker services, tunnel management, and automation tools. Designed for team collaboration between Ed and Gabe.

## Repository Structure

- **docker/**: Container orchestration (n8n active, GoHighLevel planned)
- **tunnels/**: Cloudflare tunnel management (r2d2.reinventingai.com)
- **automations/**: Client automation templates and configurations
- **mcp/**: Model Context Protocol integrations (future)
- **scripts/**: Shared utility scripts and environment setup
- **docs/**: Team documentation and procedures

## Environment Setup

**Initial Setup:**
```bash
./scripts/setup-environment.sh
vim .env  # Configure actual values
```

**Required Environment Variables:**
- N8N_ENCRYPTION_KEY
- N8N_HOST (https://r2d2.reinventingai.com)
- WEBHOOK_URL

## Service Management

**Current Active Service: n8n**
```bash
# Status check
cd docker/n8n && docker logs n8n-gabe --tail 50

# Backup (always before changes)
cd docker/n8n && ./backup.sh

# Start/restart service
cd docker/n8n && docker-compose up -d

# Test data persistence
cd docker/n8n && ./test-persistence.sh
```

**Infrastructure Backup:**
```bash
./scripts/daily-backup.sh
```

## Critical Data Protection

**Docker Volume:** n8n_data_gabe contains all persistent n8n data
**Never delete this volume without verified backup**

## Team Workflow

1. Always backup before infrastructure changes
2. Test changes in development environment
3. Document modifications in relevant README files
4. Use provided scripts for common operations

## Active Services

| Service | URL | Status | Environment |
|---------|-----|--------|-------------|
| n8n | r2d2.reinventingai.com | Active | Production |
| GoHighLevel | TBD | Planned | - |

## Development Guidelines

- Environment variables configured via .env file
- All scripts have execution permissions
- Docker Compose orchestrates services
- Backup verification required before major changes