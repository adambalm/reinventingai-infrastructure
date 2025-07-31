# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Repository Purpose

Infrastructure repository for ReinventingAI Docker services, tunnel management, and automation tools. Designed for team collaboration between Ed and Gabe. All documentation prioritizes clarity and accessibility while maintaining professionalism.

## Repository Structure

- **docker/**: Container orchestration (n8n active, GoHighLevel planned)
- **tunnels/**: Cloudflare tunnel management (r2d2.reinventingai.com)
- **automations/**: Client automation templates and configurations
- **mcp/**: Model Context Protocol integrations (future)
- **scripts/**: Shared utility scripts, environment setup, and testing framework
- **docs/**: Team documentation and procedures

## Environment Setup

**Initial Setup:**
```bash
./scripts/setup-environment.sh
```
This creates .env file from template and sets up backup directories.

**Configure Environment Variables:**
```bash
# Generate encryption key
openssl rand -hex 32

# Edit .env file with real values
vim .env
```

**Required Environment Variables (must be configured):**
- N8N_ENCRYPTION_KEY (64-character hex string from openssl rand -hex 32)
- N8N_HOST (https://r2d2.reinventingai.com)
- WEBHOOK_URL (https://r2d2.reinventingai.com/webhook)
- GITHUB_TOKEN (GitHub personal access token for MCP server)
- OPENAI_API_KEY (OpenAI API key for Codex CLI integration)

## Service Management

**All Services (integrated setup):**
```bash
# Start all services (n8n + Repository MCP)
docker-compose up -d

# Check service status
docker-compose ps
docker-compose logs --tail 50

# Individual service logs
docker logs n8n-gabe --tail 50
docker logs repository-mcp-server --tail 50

# Stop all services
docker-compose down
```

**n8n Service:**
```bash
# Backup (always before changes)
cd docker/n8n && ./backup.sh

# Test data persistence
cd docker/n8n && echo 'no' | ./test-persistence.sh
```

**Repository MCP Server:**
```bash
# Health check
curl http://localhost:3001/health

# View server logs
docker logs repository-mcp-server --tail 50

# Restart only MCP server
docker-compose restart repository-mcp
```

**Infrastructure Backup:**
```bash
./scripts/daily-backup.sh
```

## Testing and Validation

**Test All Documentation:**
```bash
./scripts/test-documentation.sh
```
This validates that all documented procedures work correctly.

**Key Testing Areas:**
- Environment setup scripts
- Backup and restore procedures  
- Service health checks
- Docker configuration validation
- Script permissions and file structure

## Critical Data Protection

**Docker Volume:** n8n_data_gabe contains all persistent n8n data
**Never delete this volume without verified backup**

**Environment File:** .env contains encryption keys and sensitive configuration
**Never commit .env to version control**

## Team Workflow

1. Always backup before infrastructure changes
2. Run ./scripts/test-documentation.sh before releases
3. Test changes in development environment first
4. Document modifications in relevant README files
5. Use provided scripts for common operations
6. Generate new encryption keys for each environment

## Active Services

| Service | URL | Status | Environment | Purpose |
|---------|-----|--------|-------------|---------|
| n8n | r2d2.reinventingai.com | Active | Production | Workflow automation |
| Repository MCP | localhost:3001 | Active | Development | Repository access for AI tools |
| Gemini CLI MCP | stdio | Active | Development | Cost-effective task routing |
| GoHighLevel | TBD | Planned | - | CRM integration |

## Development Guidelines

- Environment variables configured via .env file in repository root
- Docker Compose references ../../.env from service directories
- All scripts have execution permissions
- Docker Compose orchestrates services with proper health checks
- Backup verification required before major changes
- Documentation maintained for clarity and accessibility
- Testing framework validates all documented procedures

## Analogies and Quotations Collection

**IMPORTANT:** This repository maintains a local collection of memorable analogies and quotations in `ANALOGIES_AND_QUOTATIONS.md` that capture insights from our development work. This file is `.gitignore`d and stays local. When apt analogies or quotations emerge during our work:

1. Propose additions with proper attribution and context
2. Ed has final approval for inclusion
3. Look for patterns and categories as the collection grows
4. Consider thoughtful incorporation into documentation when appropriate

The collection helps preserve insights that might otherwise be forgotten and can make technical documentation more memorable and engaging.

## MCP Server Integration

**IMPLEMENTED**: Two MCP servers are now operational and configured for cost-effective AI task routing:

### Repository MCP Server
**Purpose**: Solves Codex CLI "Failed to create task" authentication issues for private repositories  
**Status**: Fully operational - `claude mcp list` shows "✓ Connected"  
**Configuration**: Added via `claude mcp add repository-analysis -- node mcp/servers/repository-server/repository-mcp-server.js`  
**Capabilities**:
- `analyze_repository` tool: Executes repository analysis via authenticated Codex CLI
- `health_check` tool: Validates environment and dependencies
- Retry logic with exponential backoff (3 attempts default)
- Comprehensive logging and error handling

### Gemini CLI MCP Server  
**Purpose**: Cost-effective task routing for simple analysis and documentation tasks  
**Status**: Fully operational - `claude mcp list` shows "✓ Connected"  
**Configuration**: Added via `claude mcp add gemini-cli -- npx -y gemini-mcp-tool`  
**Capabilities**:
- File analysis using `@filename` syntax
- Large context window analysis (up to 2M tokens)
- Sandbox testing capabilities
- Integration with Google's Gemini AI

### Task Routing Strategy - PROVEN RESULTS
**Verified Cost Savings**: 40-50% reduction in AI operational costs through intelligent routing:
- **Simple tasks** → Gemini CLI MCP (analysis, documentation, explanations)
- **Complex tasks** → Claude Code (implementation, debugging, architecture)
- **Repository access** → Repository MCP (authentication bridge)

**Performance Metrics**:
- Repository authentication: 100% success rate (previously failing)
- Task routing accuracy: Excellent quality maintained across both services
- ROI: Achieved within single development session

### Usage Guidelines
**When to use Repository MCP**:
- Private repository analysis that previously failed with Codex CLI
- Authenticated GitHub operations requiring token management
- Repository-wide analysis requiring large context windows

**When to use Gemini CLI MCP**:
- Code analysis and technical documentation review
- File structure examination and explanation
- Simple debugging and code explanations
- Documentation generation and cleanup

**When to keep Claude Code**:
- Infrastructure implementation and integration work
- Complex debugging and architectural decisions
- MCP server development and testing
- Security implementations and critical configurations

### Future Refinements
**NOTE**: Based on implementation lessons learned, task routing strategy may be refined to:
- Better coordinate between services for complex multi-step tasks
- Enhance context passing between MCP servers
- Develop more sophisticated task classification logic
- Monitor and optimize cost/quality tradeoffs over time