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
   git clone https://github.com/adambalm/reinventingai-infrastructure.git
   cd reinventingai-infrastructure
   ```

2. **Run Automated Setup**
   ```bash
   ./scripts/setup-environment.sh
   ```
   This script will:
   - Check that Docker is installed
   - Create your .env file from the template
   - Set up backup directories
   - Show you next steps

3. **Configure Environment Variables**
   Open the .env file in your text editor:
   ```bash
   vim .env
   ```
   Or use any text editor you prefer (nano, code, etc.)
   
   **REQUIRED:** Update these values (ask Ed for the actual values):
   - `N8N_ENCRYPTION_KEY` - Secret key for encrypting n8n data
   - `N8N_HOST` - Should be https://r2d2.reinventingai.com
   - `WEBHOOK_URL` - Should be https://r2d2.reinventingai.com/webhook
   
   Save and close the file when done.

## Service Management

4. **Start n8n Service**
   Navigate to the n8n directory and start the service:
   ```bash
   cd docker/n8n
   docker-compose up -d
   ```
   The `-d` flag runs it in the background (detached mode).

5. **Verify Service is Running**
   Check that the container started successfully:
   ```bash
   docker ps
   ```
   You should see a container named `n8n-gabe` in the list.
   
   View the service logs to confirm it's working:
   ```bash
   docker logs n8n-gabe -f
   ```
   Press Ctrl+C to stop viewing logs.

6. **Access n8n Web Interface**
   Open your web browser and go to: https://r2d2.reinventingai.com
   You should see the n8n login/setup page.

7. **Create Initial Backup**
   From the repository root directory:
   ```bash
   ./scripts/daily-backup.sh
   ```
   This creates a backup of all n8n data before you start making changes.

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