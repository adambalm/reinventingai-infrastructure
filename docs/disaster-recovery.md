# Disaster Recovery Procedures

Emergency procedures for infrastructure recovery and data restoration.

## Critical Data Locations

**Docker Volumes**
- n8n_data_gabe: Contains all n8n workflows, credentials, and configuration

**Backup Locations**
- Local: $HOME/backups/n8n/
- Service-specific backup scripts in docker/n8n/

## Recovery Scenarios

### Complete Service Loss

1. **Verify Backup Availability**
   ```bash
   ls -la $HOME/backups/n8n/
   ```

2. **Restore Infrastructure**
   ```bash
   git clone <repository-url>
   cd reinventingai-infrastructure
   ./scripts/setup-environment.sh
   ```

3. **Restore Service Data**
   ```bash
   cd docker/n8n
   ./restore.sh <backup-file>
   ```

4. **Verify Service Recovery**
   ```bash
   docker-compose up -d
   ./test-persistence.sh
   ```

### Data Corruption

1. **Stop Affected Service**
   ```bash
   docker-compose down
   ```

2. **Restore from Recent Backup**
   ```bash
   ./restore.sh <latest-backup>
   ```

3. **Restart and Verify**
   ```bash
   docker-compose up -d
   ```

### Infrastructure Host Loss

1. **Provision New Host**
2. **Install Prerequisites** (Docker, Docker Compose)
3. **Clone Repository and Restore Data**
4. **Reconfigure Network/DNS** if required

## Recovery Testing

**Monthly Recovery Drills**
- Test backup restoration in isolated environment
- Verify data integrity after restoration
- Document recovery time and issues

**Backup Verification**
- Automated backup integrity checks
- Regular test restores
- Backup retention policy enforcement

## Emergency Contacts

Document team member contact information for infrastructure emergencies.

## Post-Recovery Actions

1. Analyze root cause of failure
2. Update recovery procedures if needed
3. Verify all services are functional
4. Communicate status to stakeholders
5. Schedule post-mortem review