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

# Install Claude-Flow (latest alpha) and mcp-proxy globally
RUN npm install -g claude-flow@alpha mcp-proxy

# Initialize Claude-Flow
RUN npx claude-flow init --force

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose SSE port for MCP
EXPOSE 8080

# Use entrypoint for auto-update and logging
ENTRYPOINT ["/entrypoint.sh"]
