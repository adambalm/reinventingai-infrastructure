# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Purpose

Infrastructure repository for ReinventingAI Docker services, tunnel management, and automation tools. Designed for team collaboration between Ed and Gabe. All documentation is written for high school computer science student comprehension level while maintaining professionalism.

## Repository Structure

- **docker/**: Container orchestration (n8n active, GoHighLevel planned)
- **tunnels/**: Cloudflare tunnel management (r2d2.reinventingai.com)
- **automations/**: Client automation templates and configurations
- **mcp/**: Model Context Protocol integrations (future)
- **scripts/**: Shared utility scripts, environment setup, and testing framework
- **docs/**: Team documentation and procedures

## Environment Setup

**Initial Setup:**
```bash
./scripts/setup-environment.sh
```
This creates .env file from template and sets up backup directories.

**Configure Environment Variables:**
```bash
# Generate encryption key
openssl rand -hex 32

# Edit .env file with real values
vim .env
```

**Required Environment Variables (must be configured):**
- N8N_ENCRYPTION_KEY (64-character hex string from openssl rand -hex 32)
- N8N_HOST (https://r2d2.reinventingai.com)
- WEBHOOK_URL (https://r2d2.reinventingai.com/webhook)

## Service Management

**Current Active Service: n8n**
```bash
# Status check
cd docker/n8n && docker logs n8n-gabe --tail 50

# Backup (always before changes)
cd docker/n8n && ./backup.sh

# Start/restart service (from docker/n8n directory)
cd docker/n8n && docker-compose up -d

# Test data persistence
cd docker/n8n && echo 'no' | ./test-persistence.sh
```

**Infrastructure Backup:**
```bash
./scripts/daily-backup.sh
```

## Testing and Validation

**Test All Documentation:**
```bash
./scripts/test-documentation.sh
```
This validates that all documented procedures work correctly.

**Key Testing Areas:**
- Environment setup scripts
- Backup and restore procedures  
- Service health checks
- Docker configuration validation
- Script permissions and file structure

## Critical Data Protection

**Docker Volume:** n8n_data_gabe contains all persistent n8n data
**Never delete this volume without verified backup**

**Environment File:** .env contains encryption keys and sensitive configuration
**Never commit .env to version control**

## Team Workflow

1. Always backup before infrastructure changes
2. Run ./scripts/test-documentation.sh before releases
3. Test changes in development environment first
4. Document modifications in relevant README files
5. Use provided scripts for common operations
6. Generate new encryption keys for each environment

## Active Services

| Service | URL | Status | Environment |
|---------|-----|--------|-------------|
| n8n | r2d2.reinventingai.com | Active | Production |
| GoHighLevel | TBD | Planned | - |

## Development Guidelines

- Environment variables configured via .env file in repository root
- Docker Compose references ../../.env from service directories
- All scripts have execution permissions
- Docker Compose orchestrates services with proper health checks
- Backup verification required before major changes
- Documentation maintained at high school CS student comprehension level
- Testing framework validates all documented procedures