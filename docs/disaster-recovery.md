# Emergency Recovery Guide

What to do if something goes wrong with our infrastructure.

## What Could Go Wrong

The main things that could break:
1. **Complete service failure** - n8n stops working entirely
2. **Data corruption** - Your workflows or settings get corrupted
3. **Server/computer failure** - The whole machine crashes or dies

## Where Our Important Data Lives

**Critical Data:** All n8n workflows, credentials, and settings are stored in a Docker volume called `n8n_data_gabe`

**Backups:** We store backup copies in:
- Your home directory: `$HOME/backups/n8n/`
- The backup scripts are in: `docker/n8n/`

## Recovery Steps

### Scenario 1: n8n Service Completely Stops Working

**Step 1: Check if you have backups**
```bash
ls -la $HOME/backups/n8n/
```
You should see backup files with dates in their names.

**Step 2: Get a fresh copy of this repository**
```bash
git clone https://github.com/adambalm/reinventingai-infrastructure.git
cd reinventingai-infrastructure
./scripts/setup-environment.sh
```

**Step 3: Restore your data from backup**
```bash
cd docker/n8n
./restore.sh <backup-filename.tar.gz>
```
Replace `<backup-filename.tar.gz>` with the actual name of your most recent backup.

**Step 4: Start the service and test**
```bash
docker-compose up -d
./test-persistence.sh
```

### Scenario 2: Data Gets Corrupted

If your workflows are acting weird or settings are wrong:

**Step 1: Stop the service**
```bash
cd docker/n8n
docker-compose down
```

**Step 2: Restore from your most recent backup**
```bash
./restore.sh <latest-backup-filename.tar.gz>
```

**Step 3: Restart and check**
```bash
docker-compose up -d
```
Then check https://r2d2.reinventingai.com to see if your workflows are back.

### Scenario 3: Entire Server/Computer Dies

If the whole computer crashes or gets destroyed:

1. **Get a new computer/server** with Docker installed
2. **Clone this repository** and set it up (follow the team onboarding guide)
3. **Restore from backup** (if you have backups stored elsewhere)
4. **Update DNS settings** if needed (coordinate with whoever manages the domain)

## Testing Your Recovery Plan

**Practice recovering every month** - Don't wait for a real emergency to find out if your backups work.

**Automated Testing:**
Run the documentation test suite to verify all procedures work:
```bash
./scripts/test-documentation.sh
```

**Manual Recovery Testing:**
1. Set up a test environment (separate from production)
2. Try restoring from a backup using: `cd docker/n8n && ./restore.sh backup-filename.tar.gz`
3. Make sure all your workflows work correctly
4. Time how long the recovery takes
5. Document any problems you encounter

**Check your backups regularly:**
- Run `./scripts/daily-backup.sh` to create fresh backups
- Verify backup files exist: `ls -la ~/backups/n8n/`
- Test backup integrity with restore process
- Keep backups for at least 30 days

**Verify your environment configuration:**
- Make sure .env file has proper encryption key: `grep N8N_ENCRYPTION_KEY .env`
- Test tunnel connectivity: `./tunnels/scripts/tunnel-health.sh r2d2.reinventingai.com`
- Verify service health: `docker ps | grep n8n-gabe`

## Emergency Contacts

Write down contact information for:
- Team members who know how to fix infrastructure problems
- Domain/DNS administrator (if different from team)
- Anyone else who needs to know about outages

## After You Fix Everything

Once you've recovered from an emergency:

1. **Figure out what went wrong** - Look at logs, investigate the root cause
2. **Update this guide** if you learned anything new during recovery
3. **Test everything** - Make sure all services work correctly
4. **Tell people** - Communicate with anyone affected by the outage
5. **Schedule a review** - Meet as a team to discuss what happened and how to prevent it