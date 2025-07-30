# ReinventingAI Infrastructure

This repository contains all infrastructure code, scripts, and documentation for the ReinventingAI collaboration between Ed and Gabe.

## Quick Start

1. Clone this repository
2. Check the specific service you need in the appropriate directory
3. Follow the README in that directory

## Repository Structure

### `/docker`
Container configurations and management scripts for our services:
- **n8n**: Workflow automation platform (r2d2.reinventingai.com)
- **gohighlevel**: Coming soon

### `/tunnels`
Cloudflare tunnel configurations and management:
- Setup guides
- Tunnel configurations
- Health check scripts

### `/mcp`
Model Context Protocol configurations and integrations (future)

### `/automations`
Client automation templates and configurations

### `/scripts`
Utility scripts for common operations

### `/docs`
General documentation and best practices

## Critical Information

### Data Volumes
**NEVER DELETE THESE VOLUMES** - They contain all persistent data:
- `n8n_data_gabe` - Gabe's n8n test environment data

### Backup Policy
Daily backups are automated. Manual backup before any major changes:
```bash
./scripts/daily-backup.sh
```

### Active Services

| Service | URL | Container | Port | Volume |
|---------|-----|-----------|------|--------|
| n8n (test) | https://r2d2.reinventingai.com | n8n-gabe | 5679 | n8n_data_gabe |
| n8n (prod) | https://n8n.reinventingai.com | TBD | TBD | TBD |

## Emergency Contacts

- Ed: [contact]
- Gabe: [contact]

## Contributing

1. Always test changes in test environment first
2. Document any infrastructure changes
3. Update relevant READMEs
4. Commit with clear messages

## License

Private repository - ReinventingAI internal use only
