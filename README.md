# ReinventingAI Infrastructure

Infrastructure repository for Docker services, tunnel management, and automation tools.

## Quick Start

**New team members:** See `docs/team-onboarding.md` for complete setup instructions.

**Quick setup:**
1. Clone repository: `git clone https://github.com/adambalm/reinventingai-infrastructure.git`
2. Run setup script: `./scripts/setup-environment.sh`
3. Configure environment variables in `.env` file
4. Start services: `cd docker/n8n && docker-compose up -d`

## Repository Structure

**docker/**
Container orchestration and service configurations.

**tunnels/**  
Cloudflare tunnel setup and management scripts.

**automations/**  
Client automation templates and configurations.

**mcp/**  
Model Context Protocol integration configurations.

**scripts/**  
Shared utility scripts and environment setup tools.

**docs/**  
Technical documentation and operational procedures.

## Services

| Service | Environment | Status |
|---------|-------------|--------|
| n8n | r2d2.reinventingai.com | Active |
| GoHighLevel | TBD | Planned |

## Data Protection

Critical Docker volumes contain persistent application data. Always backup before infrastructure changes.

## Team Access

Repository provides shared infrastructure management for team collaboration. See `docs/team-onboarding.md` for setup instructions.

## Support

For infrastructure issues, refer to service-specific documentation in respective directories.