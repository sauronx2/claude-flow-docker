# Claude-Flow MCP Server in Docker
# Base: Node.js 22 Slim
FROM node:22-slim

# Install system dependencies for native Node modules (better-sqlite3)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Claude-Flow and mcp-proxy globally
RUN npm install -g claude-flow@alpha
RUN npm install -g mcp-proxy

# Initialize Claude-Flow
RUN npx claude-flow@alpha init --force

# Expose SSE port for MCP
EXPOSE 8080

# Start mcp-proxy that bridges stdio Claude-Flow to SSE
CMD ["mcp-proxy", "--port", "8080", "npx", "claude-flow@alpha", "mcp", "start"]
