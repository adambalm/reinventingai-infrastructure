# ReinventingAI Infrastructure

Infrastructure repository for Docker services, tunnel management, and automation tools.

## Quick Start

**New team members:** See `docs/team-onboarding.md` for complete setup instructions.

**Quick setup:**
1. Clone repository: `git clone https://github.com/adambalm/reinventingai-infrastructure.git`
2. Run setup script: `./scripts/setup-environment.sh`
3. Generate encryption key: `openssl rand -hex 32`
4. Configure environment variables in `.env` file with real values
5. Start all services: `docker-compose up -d`
6. Verify setup: `./scripts/test-documentation.sh`

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

| Service | Environment | Status | Purpose |
|---------|-------------|--------|---------|
| n8n | r2d2.reinventingai.com | Active | Workflow automation |
| Repository MCP | stdio/Docker | Active | Repository access for AI tools |
| Gemini CLI MCP | stdio | Active | Cost-effective AI task routing |
| GoHighLevel | TBD | Planned | CRM integration |

## Data Protection

Critical Docker volumes contain persistent application data. Always backup before infrastructure changes.

**Backup Strategy:** Repository contains backup scripts and procedures. Actual backup files are stored locally (not in version control) for security - they contain sensitive operational data, API keys, and production configurations.

## Testing and Validation

**Test all documentation and procedures:**
```bash
./scripts/test-documentation.sh
```

This validates:
- Environment setup scripts work correctly
- Backup and restore procedures function properly
- Service health checks pass
- All documented commands execute successfully

**Run tests before:**
- Making infrastructure changes
- Releasing updates
- Onboarding new team members

## Team Access

Repository provides shared infrastructure management for team collaboration. See `docs/team-onboarding.md` for setup instructions.

All documentation prioritizes clarity and accessibility while maintaining professionalism.

## Support

For infrastructure issues, refer to service-specific documentation in respective directories. Use the testing framework to verify procedures work correctly before reporting issues.