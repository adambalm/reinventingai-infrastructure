# Claude Code Context Restoration Guide

**Purpose**: Rapidly restore Claude Code session context after updates or new shell sessions  
**Last Updated**: August 1, 2025  
**Session**: Post n8n incident recovery and complete environment analysis  

## Quick Context Restoration Commands

When starting a new Claude Code session, run these commands to instantly restore full system context:

### **1. System Status Check (30 seconds)**
```bash
# Essential status overview
echo "=== SYSTEM STATUS ===" && \
system_profiler SPHardwareDataType | grep -E "Model|Processor|Memory" && \
echo -e "\n=== DOCKER CONTAINERS ===" && \
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" && \
echo -e "\n=== LLM MODELS ===" && \
ollama list && \
echo -e "\n=== STORAGE ===" && \
df -h / | tail -1 && \
echo -e "\n=== CLAUDE CLI ===" && \
claude doctor --quiet 2>/dev/null | head -3
```

### **2. Infrastructure Health Check (15 seconds)**
```bash
# Service health verification
echo "=== SERVICE HEALTH ===" && \
curl -s http://localhost:5679/healthz | jq -r '.status // "n8n: " + .' 2>/dev/null || echo "n8n: needs check" && \
docker inspect openwebui --format='Open WebUI: {{.State.Status}}' 2>/dev/null && \
ps aux | grep -q "ollama serve" && echo "Ollama: running" || echo "Ollama: stopped" && \
docker logs cloudflared-gabe --tail 1 2>/dev/null | grep -q "." && echo "Cloudflare: active" || echo "Cloudflare: check needed"
```

### **3. Recent Context Review (30 seconds)**
```bash
# Review recent work and changes
echo "=== RECENT COMMITS ===" && \
git log --oneline --since="2025-08-01" | head -5 && \
echo -e "\n=== CRITICAL ISSUES ===" && \
head -10 CRITICAL_ISSUES.md 2>/dev/null || echo "No critical issues file" && \
echo -e "\n=== CURRENT BRANCH ===" && \
git status --porcelain | wc -l | xargs echo "Uncommitted changes:" && \
git branch --show-current
```

## Current System State Summary

### **Hardware (Mac Pro 2013)**
- **CPU**: 6-Core Intel Xeon E5-1650 v2 @ 3.5GHz
- **RAM**: 32 GB (excellent for LLMs)
- **GPU**: Dual AMD FirePro D500 (6GB total VRAM)
- **Storage**: ~22GB available (constraint for model expansion)

### **Active Services**
| Service | Status | Access | Purpose |
|---------|--------|--------|---------|
| **n8n-gabe** | ✅ Running | https://r2d2.reinventingai.com | Workflow automation |
| **cloudflared-gabe** | ✅ Running | tunnel | Cloudflare tunnel |
| **ollama** | ✅ Running | localhost:11434 | LLM backend |
| **openwebui** | ⏸️ Stopped | localhost:3000 | LLM web interface |

### **LLM Stack Configuration**
- **Backend**: Ollama 0.9.6 with Gemma 3 (3.3GB)
- **Frontend**: Open WebUI (6.79GB Docker image, ready to start)
- **Integration**: Configured via `host.docker.internal:11434`
- **Data**: Persistent storage in `/Users/Shared/openwebui`

### **Container Architecture**
```bash
# View complete container status
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Expected output:
# n8n-gabe          n8nio/n8n:1.95.0                  Up X hours    0.0.0.0:5679->5678/tcp
# cloudflared-gabe  cloudflare/cloudflared:latest      Up X hours    tunnel
# openwebui         ghcr.io/open-webui/open-webui     Exited        0.0.0.0:3000->8080/tcp
```

## Recent Incident Resolution Summary

### **n8n "Command 'start' not found" Issue (Resolved)**
- **Root Cause**: n8n version 1.103.2 regression
- **Resolution**: Downgrade to stable v1.95.0
- **Data Recovery**: July 31st backup restoration successful
- **Current Status**: Fully functional with HighLevel community node
- **Documentation**: `docs/incident-report-2025-08-01-n8n-community-nodes.md`

### **Community Nodes Status**
```bash
# Check n8n community nodes
docker exec n8n-gabe sh -c 'ls -la /home/node/.n8n/nodes/node_modules/' 2>/dev/null || echo "Container not running"

# Expected: n8n-nodes-highlevelv2 (working)
# Missing: n8n-nodes-gotohuman (needs reinstall for Gabe)
```

### **Database Status Verified**
- **Workflows**: Only test workflow present (minimal data loss)
- **Credentials**: Telegram API credential preserved
- **Size**: 462KB (July 31st restore point)

## Immediate Actions Available

### **Restore Full LLM Interface (5 seconds)**
```bash
docker start openwebui
# Then access: http://localhost:3000
# Connects automatically to Ollama backend
```

### **Add Recommended Models (Storage Permitting)**
```bash
# High-value, efficient models for your hardware
ollama pull llama3.2:3b        # ~2GB - Excellent general purpose
ollama pull phi4:mini          # ~2.2GB - Microsoft coding specialist
ollama pull qwen2.5-coder:3b   # ~2GB - Programming focused
```

### **Storage Optimization (Free ~4GB)**
```bash
# Safe Docker cleanup
docker system prune -a
docker image rm n8nio/n8n:1.103.2  # Remove problematic version
```

### **For Gabe: Community Node Restoration**
```bash
# In n8n web interface (https://r2d2.reinventingai.com):
# Settings → Community nodes → Install → n8n-nodes-gotohuman
# Then configure HighLevel OAuth credentials if needed
```

## Key Documentation References

### **Complete System Profile**
```bash
cat docs/environment-profile-macpro-2025-08-01.md
# Comprehensive hardware, software, and integration analysis
```

### **Incident Details**
```bash
cat docs/incident-report-2025-08-01-n8n-community-nodes.md  
# Complete timeline, root cause analysis, and resolution steps
```

### **Critical Issues Tracker**
```bash
cat CRITICAL_ISSUES.md
# Current high-priority infrastructure fixes needed
```

## Advanced Context Restoration

### **Deep Database Analysis**
```bash
# Copy and examine n8n database (if needed for debugging)
docker cp n8n-gabe:/home/node/.n8n/database.sqlite ./temp_db.sqlite
sqlite3 ./temp_db.sqlite "SELECT name, active FROM workflow_entity;"
sqlite3 ./temp_db.sqlite "SELECT name, type FROM credentials_entity;"
sqlite3 ./temp_db.sqlite "SELECT packageName, installedVersion FROM installed_packages;"
rm ./temp_db.sqlite  # cleanup
```

### **Container Network Analysis**
```bash
# Verify container networking and integration
docker network ls
docker inspect openwebui --format='{{.NetworkSettings.Networks}}'
docker inspect n8n-gabe --format='{{range .Config.Env}}{{println .}}{{end}}' | grep -E "HOST|KEY|URL"
```

### **Performance Baseline**
```bash
# System performance check
top -l 1 | grep -E "CPU usage|PhysMem"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## Session Handoff Protocol

### **When Ending a Claude Code Session**
1. **Commit any changes**: Ensure all work is in git
2. **Update this document**: If significant changes occurred
3. **Note critical status**: Update any service states that changed

### **When Starting a New Claude Code Session**
1. **Run status check**: Execute the system status commands above
2. **Review recent commits**: Check what changed since last session
3. **Read this document**: Understand current context and capabilities
4. **Proceed with confidence**: Full system state is documented and recoverable

## Quick Reference Commands

```bash
# The "big three" for instant context
docker ps && ollama list && git status

# Full system health in one command
curl -s http://localhost:5679/healthz && docker inspect openwebui --format='{{.State.Status}}' && ollama list | wc -l | xargs echo "Ollama models:"

# Emergency restoration
git log --oneline -5 && cat docs/environment-profile-macpro-2025-08-01.md | head -50

# Start everything
docker start openwebui && docker ps --format "table {{.Names}}\t{{.Status}}"
```

---
**Context Snapshot**: August 1, 2025 - Post-incident recovery, complete LLM stack analysis  
**System Status**: Production-ready n8n + Ollama/Open WebUI hybrid architecture  
**Next Session**: Full context restorable in <60 seconds using commands above  
**Maintainer**: Infrastructure Team (Ed/Gabe)