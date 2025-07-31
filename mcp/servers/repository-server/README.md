# Repository MCP Server

MCP server that enables remote repository analysis by bridging authentication between Claude Code and Codex CLI.

## Problem Solved

Resolves Codex CLI "Failed to create task" errors when accessing private repositories by providing centralized authentication management and error handling.

## Quick Start

1. **Environment Setup**
   ```bash
   # From repository root
   cp .env.example .env
   # Edit .env and configure GITHUB_TOKEN and OPENAI_API_KEY
   ```

2. **Start Server**
   ```bash
   cd mcp/servers/repository-server
   docker-compose up -d
   ```

3. **Test Integration**
   ```bash
   # Health check
   curl http://localhost:3001/health
   
   # Repository analysis (via MCP client)
   # See usage examples in ../../setup/repository-mcp.md
   ```

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_TOKEN` | GitHub personal access token with repo read permissions | `your_github_token_here` |
| `OPENAI_API_KEY` | OpenAI API key for Codex CLI | `your_openai_key_here` |
| `MCP_SERVER_PORT` | Server port (default: 3001) | `3001` |
| `NODE_ENV` | Environment mode | `production` |

## Development

```bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run tests
npm test

# Build Docker image
docker build -t repository-mcp .
```

## Monitoring

- **Logs**: Written to `logs/` directory
- **Health Check**: `GET /health`
- **Metrics**: Structured logging with Winston

## Authentication

### GitHub Token Setup
1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Generate token with `repo` scope for private repository access
3. Add token to `.env` file as `GITHUB_TOKEN`

### OpenAI API Key Setup
1. Visit OpenAI API dashboard
2. Create or retrieve API key
3. Add key to `.env` file as `OPENAI_API_KEY`

## Integration

This server integrates with:
- **Claude Code**: Primary client for MCP requests
- **Codex CLI**: Backend service for repository analysis
- **GitHub API**: Repository access and authentication
- **Docker Infrastructure**: Containerized deployment

## Error Handling

- **Retry Logic**: Exponential backoff on failures
- **Timeout Management**: Configurable request timeouts
- **Authentication Validation**: Pre-flight environment checks
- **Structured Logging**: Detailed error tracking and debugging

## Security

- **Token Security**: Environment-based credential storage
- **Container Security**: Non-root user execution
- **Network Security**: Isolated Docker networking
- **Log Security**: Credential redaction in logs

For detailed implementation guide, see `../../setup/repository-mcp.md`.