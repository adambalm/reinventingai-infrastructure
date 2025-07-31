const { server } = require('./repository-mcp-server');

// Mock environment variables for testing
process.env.GITHUB_TOKEN = 'mock-github-testing-value';
process.env.OPENAI_API_KEY = 'mock-openai-testing-value';
process.env.MCP_SERVER_PORT = '3001';

describe('Repository MCP Server', () => {
  describe('Server Instance', () => {
    test('should export server instance', () => {
      expect(server).toBeDefined();
      expect(typeof server).toBe('object');
    });

    test('should have MCP server properties', () => {
      expect(server.server).toBeDefined();
      expect(server._registeredTools).toBeDefined();
      expect(typeof server._registeredTools).toBe('object');
    });
  });

  describe('Environment Configuration', () => {
    test('should have required environment variables for testing', () => {
      expect(process.env.GITHUB_TOKEN).toBeDefined();
      expect(process.env.OPENAI_API_KEY).toBeDefined();
    });

    test('should not expose actual tokens in test environment', () => {
      expect(process.env.GITHUB_TOKEN).toContain('mock');
      expect(process.env.OPENAI_API_KEY).toContain('mock');
    });
  });

  describe('Server Tools', () => {
    test('should have registered tools', () => {
      expect(server._registeredTools).toBeDefined();
      
      const toolNames = Object.keys(server._registeredTools);
      expect(toolNames).toHaveLength(2);
      expect(toolNames).toContain('analyze_repository');
      expect(toolNames).toContain('health_check');
    });

    test('should have correct tool configurations', () => {
      const analyzeRepo = server._registeredTools.analyze_repository;
      expect(analyzeRepo.title).toBe('Repository Analysis');
      expect(analyzeRepo.description).toContain('Codex CLI');
      
      const healthCheck = server._registeredTools.health_check;
      expect(healthCheck.title).toBe('Health Check');
      expect(healthCheck.description).toContain('health and dependencies');
    });
  });
});

// Integration tests would require a full MCP transport setup
describe('Integration Tests', () => {
  test.skip('should successfully connect via stdio transport', async () => {
    // This would require setting up stdio transport and protocol messages
    // Skipped for now as it requires more complex setup
  });

  test.skip('should handle analyze_repository tool calls', async () => {
    // This would test the full MCP protocol interaction
    // Skipped for now as it requires external dependencies (Codex CLI)
  });

  test.skip('should handle health_check tool calls', async () => {
    // This would test the health check via MCP protocol
    // Skipped for now as it requires protocol setup
  });
});