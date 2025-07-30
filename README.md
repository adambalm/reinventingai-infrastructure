# ReinventingAI Infrastructure

Infrastructure as code repository containing Docker configurations, automation scripts, and deployment tools.

## Setup

1. Clone this repository
2. Configure environment variables: `cp .env.example .env`
3. Edit `.env` with your actual values (see .env.example for required variables)
4. Navigate to the specific service directory
5. Follow the service-specific README

## Repository Structure

### docker/
Container configurations and orchestration files.
- `n8n/`: Workflow automation platform deployment
- `gohighlevel/`: Not yet implemented

### tunnels/
Cloudflare tunnel configurations and management scripts.
- Setup and configuration files
- Health monitoring scripts

### mcp/
Model Context Protocol configurations and integrations.

### automations/
Client-specific automation templates and configurations.

### scripts/
Shared utility scripts for common operations.

### docs/
Technical documentation and operational procedures.

## Data Volumes

WARNING: The following Docker volumes contain all persistent application data. Data loss will occur if these volumes are deleted.

- Volume name configured via `N8N_VOLUME_NAME` environment variable (default: n8n_data_gabe)

## Backup Operations

Manual backup before infrastructure changes:
```bash
./scripts/daily-backup.sh
```

Automated daily backups are configured for production environments.

## Service Configuration

| Service | URL | Container | Port | Volume |
|---------|-----|-----------|------|--------|
| n8n (test) | See .env N8N_HOST | See .env N8N_CONTAINER_NAME | See .env N8N_EXTERNAL_PORT | See .env N8N_VOLUME_NAME |
| n8n (prod) | Not yet implemented | Not yet implemented | Not yet implemented | Not yet implemented |

## Development Guidelines

1. Test all changes in test environment before production deployment
2. Document infrastructure modifications in relevant README files
3. Update environment variable documentation when adding new configuration
4. Use clear, descriptive commit messages

## License

Private repository for internal use.