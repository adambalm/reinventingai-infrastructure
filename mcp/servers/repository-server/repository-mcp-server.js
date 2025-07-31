#!/usr/bin/env node

const { McpServer } = require('@modelcontextprotocol/sdk/server/mcp.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const { exec } = require('child_process');
const { promisify } = require('util');
const winston = require('winston');
const { z } = require('zod');
require('dotenv').config();

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'repository-mcp' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Create MCP server instance
const server = new McpServer({
  name: 'repository-analysis-server',
  version: '1.0.0',
});

// Register repository analysis tool
server.registerTool(
  'analyze_repository',
  {
    title: 'Repository Analysis',
    description: 'Analyze remote repository using Codex CLI',
    inputSchema: {
      repository_url: z.string().url().describe('GitHub repository URL'),
      task_description: z.string().describe('Analysis task description'),
      options: z.object({
        timeout: z.number().optional().describe('Timeout in seconds (default: 300)'),
        retry_count: z.number().optional().describe('Number of retries on failure (default: 3)')
      }).optional()
    }
  },
  async ({ repository_url, task_description, options = {} }) => {
    const startTime = Date.now();
    const timeout = options.timeout || 300;
    const retryCount = options.retry_count || 3;

    logger.info('Repository analysis started', {
      repository: repository_url,
      task: task_description,
      timeout,
      retryCount
    });

    // Validate environment
    if (!process.env.GITHUB_TOKEN) {
      throw new Error('GITHUB_TOKEN environment variable not configured');
    }

    if (!process.env.OPENAI_API_KEY) {
      throw new Error('OPENAI_API_KEY environment variable not configured');
    }

    let lastError;
    for (let attempt = 1; attempt <= retryCount; attempt++) {
      try {
        logger.info('Analysis attempt', { attempt, repository: repository_url });
        
        const result = await executeCodexWithRetry(
          repository_url, 
          task_description, 
          timeout
        );
        
        const duration = Date.now() - startTime;
        logger.info('Repository analysis completed', {
          repository: repository_url,
          duration,
          attempt
        });

        return {
          content: [{
            type: 'text',
            text: JSON.stringify({
              success: true,
              result: result,
              repository: repository_url,
              task: task_description,
              duration,
              attempt
            }, null, 2)
          }]
        };

      } catch (error) {
        lastError = error;
        logger.warn('Analysis attempt failed', {
          attempt,
          repository: repository_url,
          error: error.message
        });

        if (attempt < retryCount) {
          const delay = Math.pow(2, attempt - 1) * 1000; // Exponential backoff
          logger.info('Retrying after delay', { delay, nextAttempt: attempt + 1 });
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }

    // All attempts failed
    const duration = Date.now() - startTime;
    logger.error('Repository analysis failed after all retries', {
      repository: repository_url,
      error: lastError.message,
      duration,
      attempts: retryCount
    });

    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          success: false,
          error: lastError.message,
          repository: repository_url,
          task: task_description,
          duration,
          attempts: retryCount
        }, null, 2)
      }]
    };
  }
);

// Register health check tool
server.registerTool(
  'health_check',
  {
    title: 'Health Check',
    description: 'Check MCP server health and dependencies',
    inputSchema: {}
  },
  async () => {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      checks: {}
    };

    // Check environment variables
    health.checks.environment = {
      github_auth: !!process.env.GITHUB_TOKEN,
      openai_auth: !!process.env.OPENAI_API_KEY
    };

    // Check Codex CLI availability
    try {
      const execAsync = promisify(exec);
      await execAsync('which codex', { timeout: 5000 });
      health.checks.codex_cli = { available: true };
    } catch (error) {
      health.checks.codex_cli = { 
        available: false, 
        error: 'Codex CLI not found in PATH' 
      };
      health.status = 'degraded';
    }

    // Check write permissions for logs
    try {
      const fs = require('fs').promises;
      await fs.access('logs', fs.constants.W_OK);
      health.checks.logging = { writable: true };
    } catch (error) {
      health.checks.logging = { 
        writable: false, 
        error: 'Log directory not writable' 
      };
    }

    logger.info('Health check completed', health);
    
    return {
      content: [{
        type: 'text',
        text: JSON.stringify(health, null, 2)
      }]
    };
  }
);

async function executeCodexWithRetry(repository_url, task_description, timeout) {
  // Set environment variables for authentication
  const env = {
    ...process.env,
    GITHUB_TOKEN: process.env.GITHUB_TOKEN,
    OPENAI_API_KEY: process.env.OPENAI_API_KEY
  };

  // Build Codex CLI command
  const command = `codex create --repo "${repository_url}" --prompt "${task_description.replace(/"/g, '\\"')}"`;
  
  logger.info('Executing Codex CLI command', { 
    command: command.replace(/--prompt ".*"/, '--prompt "[REDACTED]"'),
    timeout 
  });

  const execAsync = promisify(exec);
  
  try {
    const { stdout, stderr } = await execAsync(command, { 
      env,
      timeout: timeout * 1000,
      maxBuffer: 1024 * 1024 * 10 // 10MB buffer
    });
    
    if (stderr && stderr.trim()) {
      logger.warn('Codex CLI stderr output', { stderr: stderr.trim() });
    }
    
    if (!stdout || stdout.trim() === '') {
      throw new Error('Codex CLI returned empty output');
    }
    
    return stdout.trim();
    
  } catch (error) {
    if (error.code === 'ENOENT') {
      throw new Error('Codex CLI not found. Please ensure it is installed and in PATH.');
    } else if (error.signal === 'SIGTERM') {
      throw new Error(`Codex CLI timed out after ${timeout} seconds`);
    } else {
      throw new Error(`Codex CLI error: ${error.message}`);
    }
  }
}

// Start server
if (require.main === module) {
  async function runServer() {
    const transport = new StdioServerTransport();
    
    logger.info('Repository MCP Server starting', { 
      pid: process.pid,
      node_version: process.version
    });

    await server.connect(transport);
    
    logger.info('Repository MCP Server started successfully');
  }

  runServer().catch((error) => {
    logger.error('Failed to start server', { error: error.message, stack: error.stack });
    process.exit(1);
  });

  // Graceful shutdown
  process.on('SIGTERM', () => {
    logger.info('SIGTERM received, shutting down gracefully');
    process.exit(0);
  });

  process.on('SIGINT', () => {
    logger.info('SIGINT received, shutting down gracefully');
    process.exit(0);
  });
}

module.exports = { server };