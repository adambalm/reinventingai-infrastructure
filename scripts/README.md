# Utility Scripts

Shared scripts for environment setup, backup operations, and testing.

## Available Scripts

**setup-environment.sh**
- Sets up new development environment
- Creates .env file from template
- Creates backup directories
- Checks prerequisites (Docker, Docker Compose)

**daily-backup.sh**
- Creates timestamped backups of n8n data
- Supports individual service backup or full infrastructure backup
- Manages backup retention (keeps last 7 days)
- Usage: `./daily-backup.sh [service]` where service can be 'n8n' or 'all'

**test-documentation.sh**
- Comprehensive testing framework that validates all documented procedures
- Tests environment setup, backup operations, service health, and file structure
- Generates detailed logs for debugging failed tests
- Should be run before infrastructure changes and releases
- Usage: `./test-documentation.sh`

## Usage Examples

```bash
# Set up new environment
./scripts/setup-environment.sh

# Create backup of n8n service
./scripts/daily-backup.sh n8n

# Test all documented procedures
./scripts/test-documentation.sh
```

## Testing Framework

The test-documentation.sh script validates:
- Environment setup procedures work correctly
- Backup and restore scripts function properly
- Service health checks pass
- Docker configuration is valid
- Script permissions are correct
- Documentation files exist and are accessible

Run this before:
- Making infrastructure changes
- Releasing updates to the team
- Onboarding new team members
- Troubleshooting infrastructure issues

The script generates detailed logs in /tmp/doc-test-*.log for debugging any failures.