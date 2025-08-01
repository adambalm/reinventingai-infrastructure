# n8n Community Nodes Incident Report
**Date:** August 1, 2025  
**Time:** 02:00 - 08:30 AM EST  
**Severity:** Medium (Service Degradation)  
**Status:** Resolved  

## Executive Summary
n8n experienced a critical startup failure with "Command 'start' not found" error, leading to investigation and recovery of community node configurations. Issue was resolved through version downgrade and data restoration, with minimal workflow impact but requiring community node reconfiguration.

## Incident Timeline
- **02:00 AM** - Issue detected: n8n failing to start with "Command 'start' not found"
- **02:30 AM** - Initial troubleshooting: Container restarts, volume checks
- **03:00 AM** - Root cause identified: n8n version 1.103.2 regression
- **04:00 AM** - Version downgrade to 1.95.0 implemented
- **05:00 AM** - Data restoration from backup volumes
- **06:00 AM** - Community node investigation initiated
- **07:30 AM** - July 31st backup restoration completed
- **08:30 AM** - Service fully restored and validated

## Root Cause Analysis

### Primary Cause
**n8n version 1.103.2 contains an undocumented breaking change** causing "Command 'start' not found" errors during container startup.

### Evidence Supporting Version Regression:
1. **Multiple user reports**: Online forums show identical errors with 1.103.2
2. **Cross-volume consistency**: Error persisted across different data volumes
3. **Version-specific resolution**: Downgrade to 1.95.0 immediately resolved startup issues
4. **Official documentation gap**: No mention of CLI command changes in 1.103.2 release notes

### Contributing Factors
1. **Encryption key mismatch**: Initial restoration used wrong encryption key from environment
2. **Community node quarantine**: Previous troubleshooting had disabled custom nodes
3. **Backup integrity issues**: July 31st backup had empty checksum file

## Impact Assessment

### Service Impact
- **High**: n8n completely non-functional for 6+ hours
- **Medium**: Community node integrations disrupted
- **Low**: Core workflow data integrity maintained

### Data Impact Analysis
**✅ Data Preserved:**
- All workflow definitions (database: 462KB intact)
- User credentials (Telegram API configuration)
- Community node: n8n-nodes-highlevelv2 v1.0.16
- Environment configurations

**❌ Data Lost/Affected:**
- Community node: n8n-nodes-gotohuman (incomplete installation)
- OAuth credentials for HighLevel (never configured)
- Custom node configurations (quarantined during previous troubleshooting)

### Business Impact
**Minimal workflow disruption** - Database analysis revealed:
- Only 1 active workflow: "My workflow" (persistence test)
- No production workflows affected
- No HighLevel OAuth credentials configured
- Community node setup was in early installation phase

## Technical Investigation Results

### Database Forensics
```sql
-- Workflows: Only test workflow present
SELECT name, active, createdAt, updatedAt FROM workflow_entity;
Result: "My workflow|0|2025-07-30 05:36:31.031|2025-07-31 15:51:47"

-- Credentials: Only basic Telegram config
SELECT name, type FROM credentials_entity;
Result: "Telegram account|telegramApi"

-- Community Packages: HighLevel properly installed
SELECT packageName, installedVersion FROM installed_packages;
Result: "n8n-nodes-highlevelv2|1.0.16"
```

### Community Node Investigation
**n8n-nodes-highlevelv2:**
- ✅ Complete installation with proper file structure
- ✅ Compatible with n8n 1.95.0 (n8nNodesApiVersion: 1)
- ✅ Node.js v20.19.2 meets requirement (>=20.15)
- ✅ Restored and functional

**n8n-nodes-gotohuman:**
- ❌ Empty directory structure in all backups
- ❌ Missing package.json and core files
- ❌ Installation was incomplete/corrupted

## Resolution Steps Implemented

### Phase 1: Service Recovery
1. **Version rollback**: n8n 1.103.2 → 1.95.0
2. **Container recreation**: Fresh container with stable image
3. **Port correction**: Restored proper 5679 mapping for Cloudflare tunnel
4. **Environment variables**: Corrected encryption key from backup data

### Phase 2: Data Restoration
1. **Backup analysis**: Identified July 31st 12:59 PM as most complete
2. **Manual extraction**: Bypassed failed integrity check (empty checksum)
3. **Volume restoration**: Complete data replacement with July 31st snapshot
4. **Permission fixes**: Ensured proper node:node ownership

### Phase 3: Community Node Recovery
1. **HighLevel node**: Successfully restored from backup
2. **GoToHuman node**: Identified as incomplete, requires reinstallation
3. **Validation**: Confirmed nodes loading without "packages missing" warnings

## Current System State

### Environment Configuration
- **n8n version**: 1.95.0 (stable, pinned)
- **Node.js**: v20.19.2
- **Container**: Single n8n-gabe container (not compose stack)
- **Port mapping**: 5679→5678 (correct for Cloudflare tunnel)
- **Encryption key**: fcadc85741894b03bf90011e4b1f032498c520c591f2387b0989dcb4fec4c712

### Service Status
- ✅ **n8n core**: Healthy and accessible
- ✅ **Cloudflare tunnel**: r2d2.reinventingai.com accessible
- ✅ **Community node**: HighLevel v1.0.16 functional
- ⚠️ **Community node**: GoToHuman requires reinstallation
- ✅ **Database**: All workflows and credentials intact

## Required Follow-up Actions

### Immediate (For Gabe)
1. **Reinstall GoToHuman node**: ~10 minutes
   ```
   Settings → Community nodes → Install → n8n-nodes-gotohuman
   ```

2. **Configure HighLevel OAuth** (if needed): ~30 minutes
   - Create OAuth app in HighLevel dashboard
   - Configure credentials in n8n
   - Test basic API connection

### Short-term (Infrastructure)
1. **Version pinning**: Update docker-compose.yml to lock n8n at 1.95.0
2. **Backup validation**: Fix checksum generation in backup scripts
3. **Monitoring**: Implement community node health checks
4. **Documentation**: Update team procedures for version updates

### Long-term (Risk Mitigation)
1. **Staging environment**: Test n8n updates before production
2. **Community node backup**: Enhanced backup for custom installations
3. **Alert system**: Monitor for "Command not found" startup failures

## Lessons Learned

### What Worked Well
1. **Multiple backup strategy**: Had July 30th and July 31st recovery points
2. **Data preservation**: No workflow or credential loss during incident
3. **Version flexibility**: Easy rollback capability saved the day
4. **Diagnostic approach**: Systematic investigation identified root cause

### What Could Be Improved
1. **Version testing**: Need staging environment for n8n updates
2. **Community node monitoring**: Better health checks for custom nodes
3. **Backup integrity**: Fix checksum generation for reliable restoration
4. **Documentation**: Version-specific known issues tracking

## Recovery Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|---------|
| Total Downtime | 6.5 hours | <2 hours | ❌ Exceeded |
| Data Loss | Minimal | None | ✅ Acceptable |
| Service Recovery | 100% | 100% | ✅ Complete |
| Community Nodes | 50% (1/2) | 100% | ⚠️ Partial |

## Risk Assessment

### Current Risk Level: **LOW**
- Core n8n functionality fully restored
- Critical data preserved
- Known remediation path for remaining issues

### Future Risk Mitigation
1. **Pin n8n version** in production until 1.103.2+ issues resolved
2. **Test community nodes** in staging before production deployment
3. **Monitor n8n community** for version-specific bug reports
4. **Enhance backup validation** to prevent integrity check failures

## Technical Appendix

### Environment Variables (Production)
```bash
N8N_ENCRYPTION_KEY=fcadc85741894b03bf90011e4b1f032498c520c591f2387b0989dcb4fec4c712
N8N_HOST=https://r2d2.reinventingai.com
WEBHOOK_URL=https://r2d2.reinventingai.com/webhook
```

### Docker Configuration
```bash
docker run -d \
  --name n8n-gabe \
  --restart unless-stopped \
  -p 5679:5678 \
  -v n8n_data_gabe:/home/node/.n8n \
  -e N8N_ENCRYPTION_KEY=fcadc85741894b03bf90011e4b1f032498c520c591f2387b0989dcb4fec4c712 \
  -e N8N_HOST=https://r2d2.reinventingai.com \
  -e WEBHOOK_URL=https://r2d2.reinventingai.com/webhook \
  n8nio/n8n:1.95.0
```

### Community Node Status
```json
{
  "n8n-nodes-highlevelv2": {
    "version": "1.0.16",
    "status": "active",
    "compatibility": "confirmed",
    "oauth_configured": false
  },
  "n8n-nodes-gotohuman": {
    "version": null,
    "status": "missing",
    "requires": "fresh_installation"
  }
}
```

---
**Report Generated:** August 1, 2025 08:30 AM EST  
**Next Review:** August 15, 2025  
**Responsible Team:** Infrastructure (Ed/Gabe)  
**Severity Classification:** Resolved - Medium Impact