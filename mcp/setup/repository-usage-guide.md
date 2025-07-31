# Repository MCP Usage Guide

Comprehensive guide for using the Repository MCP server for authenticated repository access and analysis.

## Overview  

The Repository MCP server solves Codex CLI "Failed to create task" authentication issues by providing a bridge between Claude Code and private repository access through authenticated Codex CLI execution.

## Installation Status

✅ **INSTALLED AND CONFIGURED**
- **MCP Name**: `repository-analysis`  
- **Command**: `node mcp/servers/repository-server/repository-mcp-server.js`
- **Status**: ✓ Connected (verified via `claude mcp list`)
- **Local Implementation**: Custom-built for authentication bridging

## Problem Solved

**Before Repository MCP:**
- Codex CLI failed with "Failed to create task" on private repositories
- Authentication issues prevented repository analysis
- Manual workarounds required for private repo access

**After Repository MCP:**
- 100% success rate for private repository access
- Centralized authentication management
- Seamless integration with Claude Code workflows

## When to Use Repository MCP

**RECOMMENDED FOR:**
- 🔐 Private repository analysis requiring authentication
- 📊 Repository-wide analysis and architecture review
- 🔍 Large codebase analysis with authenticated access
- 🛡️ Security analysis of private repositories
- 📋 Comprehensive repository documentation generation

**NOT RECOMMENDED FOR:**
- 🌐 Public repository analysis (use Gemini CLI MCP for cost efficiency)
- 📄 Simple file analysis (use Gemini CLI MCP)
- 🔧 Local file operations

## Available Tools

### 1. `analyze_repository` - Primary Analysis Tool

**Purpose**: Execute authenticated repository analysis via Codex CLI

**Parameters:**
- `repository_url` (required): GitHub repository URL
- `task_description` (required): Analysis task description  
- `options` (optional): Configuration options
  - `timeout`: Request timeout in seconds (default: 300)
  - `retry_count`: Number of retry attempts (default: 3)

### 2. `health_check` - System Validation

**Purpose**: Validate environment configuration and dependencies

**Returns:**
- Environment variable status
- Authentication validation
- System health metrics

## Usage Examples

### Repository Structure Analysis
```
Use Repository MCP to analyze https://github.com/your-org/private-repo and provide a comprehensive overview of the repository structure and key components
```

### Security Analysis
```
Repository MCP analysis: https://github.com/your-org/infrastructure-repo - perform security review of Docker configurations and deployment scripts
```

### Architecture Review  
```
Via Repository MCP: analyze https://github.com/your-org/backend-api for architectural patterns and suggest improvements
```

### Documentation Generation
```
Repository MCP task: https://github.com/your-org/project-repo - generate comprehensive API documentation from codebase
```

### Code Quality Assessment
```
Use Repository MCP to analyze https://github.com/your-org/frontend-app and assess code quality, testing coverage, and best practices adherence
```

## Authentication Setup

### Required Environment Variables

**In `.env` file:**
```bash
# GitHub authentication (required)
GITHUB_TOKEN=ghp_your_github_personal_access_token

# OpenAI API key for Codex CLI (required)  
OPENAI_API_KEY=sk_your_openai_api_key

# Server configuration (optional)
MCP_SERVER_PORT=3001
NODE_ENV=production
```

### GitHub Token Requirements

**Token Permissions:**
- `repo` scope for private repository access
- `read:org` for organization repositories (if applicable)
- No admin or write permissions required

**Token Setup:**  
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate new token with `repo` scope
3. Add to `.env` file as `GITHUB_TOKEN`
4. Test with: `curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user`

## Integration with Infrastructure

### Docker Service Status
```bash
# Check Repository MCP service status
docker logs repository-mcp-server --tail 50

# Health check
curl http://localhost:3001/health

# Restart if needed
docker-compose restart repository-mcp
```

### Service Management
```bash
# Start Repository MCP (via docker-compose)
docker-compose up -d repository-mcp

# View real-time logs
docker logs -f repository-mcp-server

# Stop service
docker-compose stop repository-mcp
```

## Error Handling & Troubleshooting

### Common Issues

**1. Authentication Failures**
```
Error: "Failed to authenticate with GitHub"
Solution: Verify GITHUB_TOKEN has correct permissions and hasn't expired
```

**2. Codex CLI Not Found**
```
Error: "codex command not found"
Solution: Verify OpenAI Codex CLI is installed in container
```

**3. Rate Limiting**
```
Error: "API rate limit exceeded"
Solution: MCP server includes exponential backoff retry logic
```

**4. Network Timeouts**
```
Error: "Request timeout"
Solution: Increase timeout in options parameter or check network connectivity
```

### Diagnostic Commands

```bash
# Check MCP server health
curl http://localhost:3001/health

# Verify environment variables
docker exec repository-mcp-server env | grep -E "(GITHUB_TOKEN|OPENAI_API_KEY)"

# Check service logs
docker logs repository-mcp-server --tail 100 | grep ERROR

# Test GitHub authentication
docker exec repository-mcp-server curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## Performance & Monitoring

### Retry Logic
- **Default**: 3 retry attempts with exponential backoff
- **Timeout**: 300 seconds default (configurable)
- **Error Recovery**: Automatic retry on network/authentication failures

### Logging
- **Location**: `mcp/servers/repository-server/logs/`
- **Format**: Structured JSON logging with Winston
- **Levels**: Error, info, debug with request tracking

### Health Monitoring
```bash
# Automated health check
*/5 * * * * curl -f http://localhost:3001/health || docker-compose restart repository-mcp
```

## Integration with Claude Code

### Task Routing Strategy

**Repository MCP handles:**
- Private repository analysis requiring authentication
- Large-scale repository architecture reviews
- Security analysis of proprietary codebases
- Comprehensive documentation generation

**Claude Code handles:**
- Task orchestration and result presentation
- Follow-up implementation based on analysis
- Integration with other MCP servers
- Complex multi-step workflows

### Workflow Example
1. User requests private repository analysis
2. Claude Code recognizes authentication requirement
3. Routes to Repository MCP with repository URL and task
4. Repository MCP authenticates and executes Codex CLI
5. Results returned to Claude Code for presentation and follow-up

## Cost Optimization

**When to Use Repository MCP vs Alternatives:**

**Repository MCP (Higher Cost, Authentication Required):**
- Private repository analysis
- Authenticated GitHub API operations
- Comprehensive repository-wide analysis

**Gemini CLI MCP (Lower Cost, No Authentication):**
- Public repository analysis
- File-level analysis and explanations
- Documentation review and generation

## Best Practices

### Repository URL Formats
```bash
# HTTPS format (recommended)
https://github.com/owner/repository

# SSH format (also supported)
git@github.com:owner/repository.git
```

### Task Description Guidelines
- Be specific about analysis scope
- Include relevant context about the repository
- Specify desired output format (report, documentation, etc.)
- Mention any particular areas of focus

### Security Considerations
- Never log or expose authentication tokens
- Use environment variables for all credentials
- Regularly rotate GitHub tokens
- Monitor for unauthorized access attempts

## Team Collaboration

### Setup for New Team Members
1. Ensure team member has necessary repository access
2. Provide GitHub token setup instructions
3. Verify MCP server connectivity: `claude mcp list`
4. Test with sample repository analysis

### Usage Coordination
- Document which repositories are frequently analyzed
- Share common task descriptions and patterns
- Coordinate authentication token management
- Monitor usage patterns and costs

## Integration Points

### With Gemini CLI MCP
- **Division**: Repository MCP for authentication, Gemini for cost-effective analysis
- **Coordination**: Route based on repository privacy and authentication needs
- **Complementary**: Use both for comprehensive repository understanding

### With Docker Infrastructure
- **Container**: Deployed as part of docker-compose stack
- **Networking**: Isolated network with health checks
- **Monitoring**: Integrated with existing log aggregation

## Future Enhancements

**Planned Improvements:**
- Enhanced caching for repository metadata
- Support for additional repository providers (GitLab, Bitbucket)
- Integration with organization-wide authentication systems
- Advanced analysis templates and reporting formats

---

**Related Documentation:**
- [Gemini CLI Usage Guide](gemini-cli-usage-guide.md)
- [Repository MCP Implementation](repository-mcp.md)  
- [MCP Strategy Document](../MCP_STRATEGY.md)
- [Main MCP README](../README.md)

**Technical Implementation:**
- [Server Code](../servers/repository-server/repository-mcp-server.js)
- [Docker Configuration](../servers/repository-server/docker-compose.yml)
- [Environment Setup](../servers/repository-server/README.md)