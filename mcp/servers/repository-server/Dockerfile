FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install system dependencies for git operations
RUN apk add --no-cache git curl

# Create logs directory
RUN mkdir -p logs

# Install Codex CLI globally
RUN npm install -g @openai/codex

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy source code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S mcp -u 1001 -G nodejs

# Set proper permissions
RUN chown -R mcp:nodejs /app
USER mcp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "const http = require('http'); \
  const options = { hostname: 'localhost', port: process.env.MCP_SERVER_PORT || 3001, path: '/health', timeout: 5000 }; \
  const req = http.request(options, (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }); \
  req.on('error', () => process.exit(1)); \
  req.end();"

# Expose port
EXPOSE 3001

# Start the server
CMD ["npm", "start"]