# Repository MCP Server Implementation

Technical implementation guide for Phase 1: Repository access via MCP server.

## Problem Statement

Codex CLI fails with "Failed to create task" when accessing private repositories due to authentication and permission issues. This MCP server acts as an authentication bridge.

## Architecture

```
Claude Code → Repository MCP Server → Codex CLI → GitHub API → Results
```

## Technical Implementation

### MCP Server Structure
```javascript
// repository-mcp-server.js
const { MCPServer } = require('@modelcontextprotocol/server');
const { exec } = require('child_process');
const { promisify } = require('util');

class RepositoryMCPServer extends MCPServer {
  constructor() {
    super('repository-analysis', '1.0.0');
    this.setupTools();
  }

  setupTools() {
    this.addTool({
      name: 'analyze_repository',
      description: 'Analyze remote repository using Codex CLI',
      inputSchema: {
        type: 'object',
        properties: {
          repository_url: {
            type: 'string',
            description: 'GitHub repository URL'
          },
          task_description: {
            type: 'string', 
            description: 'Analysis task description'
          }
        },
        required: ['repository_url', 'task_description']
      }
    });
  }

  async handleToolCall(name, arguments) {
    if (name === 'analyze_repository') {
      return await this.analyzeRepository(arguments);
    }
  }

  async analyzeRepository({ repository_url, task_description }) {
    try {
      // Authenticate with GitHub using stored tokens
      const authToken = process.env.GITHUB_TOKEN;
      
      // Execute Codex CLI with proper authentication
      const command = `codex create --repo ${repository_url} --prompt "${task_description}"`;
      const result = await this.executeCodex(command, authToken);
      
      return {
        success: true,
        result: result,
        repository: repository_url,
        task: task_description
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
        repository: repository_url
      };
    }
  }

  async executeCodex(command, authToken) {
    // Set environment variables for authentication
    const env = {
      ...process.env,
      GITHUB_TOKEN: authToken,
      OPENAI_API_KEY: process.env.OPENAI_API_KEY
    };

    const execAsync = promisify(exec);
    const { stdout, stderr } = await execAsync(command, { env });
    
    if (stderr) {
      throw new Error(`Codex CLI error: ${stderr}`);
    }
    
    return stdout;
  }
}

module.exports = RepositoryMCPServer;
```

### Environment Configuration
```bash
# MCP server environment variables
GITHUB_TOKEN=ghp_your_github_token_here
OPENAI_API_KEY=sk-your_openai_key_here
MCP_SERVER_PORT=3001
```

### Docker Configuration
```dockerfile
# Dockerfile for Repository MCP Server
FROM node:18-alpine

WORKDIR /app

# Install Codex CLI
RUN npm install -g @openai/codex

# Copy package files
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

EXPOSE 3001

CMD ["node", "repository-mcp-server.js"]
```

### Integration with Infrastructure
```yaml
# docker-compose.yml addition
services:
  repository-mcp:
    build: ./mcp/repository-server
    ports:
      - "3001:3001"
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    volumes:
      - ./mcp/logs:/app/logs
    restart: unless-stopped
```

## Authentication Setup

### GitHub Token Requirements
- **Permissions:** repo:read for private repositories
- **Scope:** Full repository access for analysis
- **Storage:** Secure environment variable storage

### OpenAI API Key
- **Purpose:** Codex CLI authentication
- **Storage:** Encrypted environment variables
- **Rotation:** Regular key rotation schedule

## Usage Examples

### Basic Repository Analysis
```javascript
// Claude Code integration
const mcp = new MCPClient('http://localhost:3001');

const result = await mcp.call('analyze_repository', {
  repository_url: 'https://github.com/adambalm/reinventingai-infrastructure',
  task_description: 'Analyze the repository structure and identify key components'
});
```

### Complex Analysis Tasks
```javascript
// Security analysis
const securityAnalysis = await mcp.call('analyze_repository', {
  repository_url: 'https://github.com/adambalm/reinventingai-infrastructure',
  task_description: 'Perform security analysis of Docker configurations and scripts'
});

// Architecture review
const architectureReview = await mcp.call('analyze_repository', {
  repository_url: 'https://github.com/adambalm/reinventingai-infrastructure', 
  task_description: 'Review repository architecture and suggest improvements'
});
```

## Error Handling

### Common Issues and Solutions
- **Authentication Failures:** Verify GitHub token permissions
- **Rate Limiting:** Implement exponential backoff
- **Network Timeouts:** Configure appropriate timeout values
- **Codex CLI Errors:** Parse and handle specific error types

### Monitoring and Logging
```javascript
// Structured logging
const logger = require('winston');

logger.info('Repository analysis started', {
  repository: repository_url,
  task: task_description,
  timestamp: new Date().toISOString()
});
```

## Testing Strategy

### Unit Tests
- MCP server functionality
- Authentication handling
- Error scenarios
- Result parsing

### Integration Tests
- End-to-end repository analysis
- Claude Code integration
- Error handling workflows
- Performance benchmarks

### Manual Testing
- Private repository access
- Various analysis tasks
- Error recovery scenarios
- Load testing

## Deployment Checklist

- [ ] MCP server development complete
- [ ] GitHub token configured with proper permissions
- [ ] OpenAI API key configured
- [ ] Docker configuration tested
- [ ] Integration with existing infrastructure
- [ ] Monitoring and logging setup
- [ ] Error handling tested
- [ ] Documentation updated
- [ ] Team training completed

## Performance Optimization

- **Caching:** Cache repository metadata and analysis results
- **Rate Limiting:** Respect GitHub and OpenAI API limits
- **Connection Pooling:** Reuse connections for efficiency
- **Async Processing:** Handle multiple requests concurrently

This implementation provides a robust solution for repository access issues while laying the foundation for future MCP integrations.