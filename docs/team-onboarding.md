# Team Onboarding Guide

Setup instructions for new team members accessing ReinventingAI infrastructure.

## Prerequisites

- Git access to repository
- Docker and Docker Compose installed
- SSH access to deployment servers
- Access to environment configuration values

## Initial Setup

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd reinventingai-infrastructure
   ```

2. **Environment Configuration**
   ```bash
   ./scripts/setup-environment.sh
   ```

3. **Configure Environment Variables**
   ```bash
   vim .env
   ```
   Update with actual values for:
   - N8N_ENCRYPTION_KEY
   - N8N_HOST
   - WEBHOOK_URL

## Service Management

**Start n8n Service**
```bash
cd docker/n8n
docker-compose up -d
```

**View Service Status**
```bash
docker ps
docker logs n8n-gabe -f
```

**Create Backup**
```bash
./scripts/daily-backup.sh
```

## Common Operations

**Update Service**
1. Create backup
2. Pull latest image
3. Restart service
4. Verify functionality

**Troubleshooting**
1. Check service logs
2. Verify environment variables
3. Test network connectivity
4. Review documentation in service directories

## Security Guidelines

- Never commit .env files
- Use secure environment variable storage
- Regular backup verification
- Monitor service access logs

## Team Responsibilities

- Document infrastructure changes
- Test modifications in development environment
- Maintain backup procedures
- Follow deployment guidelines

## Support Resources

- Service-specific README files in each directory
- Troubleshooting guides in docs/
- Team communication channels for infrastructure issues