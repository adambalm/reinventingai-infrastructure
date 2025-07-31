# Quick Start Guide

For experienced developers who need to get the infrastructure running quickly.

## Prerequisites

- Docker & Docker Compose
- Git
- OpenAI API key
- GitHub personal access token (repo scope)

## Setup

```bash
git clone https://github.com/adambalm/reinventingai-infrastructure.git
cd reinventingai-infrastructure

# Environment setup
cp .env.example .env
openssl rand -hex 32  # Copy output to N8N_ENCRYPTION_KEY in .env

# Edit .env - Required:
# N8N_ENCRYPTION_KEY=<64-char-hex-from-above>
# GITHUB_TOKEN=<your-github-token>
# OPENAI_API_KEY=<your-openai-key>
vim .env

# Create volume
docker volume create n8n_data_gabe

# Start everything
docker-compose up -d
```

## Service Access

- **n8n**: https://r2d2.reinventingai.com (production) or check `docker-compose ps` for ports
- **Repository MCP**: http://localhost:3001

## Quick Commands

```bash
# Status
docker-compose ps

# Logs
docker-compose logs -f

# Health check
curl http://localhost:3001/health

# Backup n8n
cd docker/n8n && ./backup.sh

# Stop everything  
docker-compose down
```

## Development

```bash
# Test MCP server locally
cd mcp/servers/repository-server
npm install
npm test

# Validate documentation
./scripts/test-documentation.sh
```

## Troubleshooting

- **MCP server fails**: Check GITHUB_TOKEN and OPENAI_API_KEY in .env
- **n8n won't start**: Verify N8N_ENCRYPTION_KEY is 64 hex chars
- **Volume issues**: Ensure `n8n_data_gabe` volume exists

See full README.md for detailed explanations.