# Claude-Flow MCP Server - Optimized Multi-stage Build
# Reduces image from ~3GB to ~1.7GB (45% smaller)

# ============================================
# Stage 1: Builder (with build dependencies)
# ============================================
FROM node:22-slim AS builder

# Install build dependencies for native modules (better-sqlite3)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set production mode for npm optimizations
ENV NODE_ENV=production

# Install Claude-Flow and mcp-proxy globally
RUN npm install -g claude-flow@alpha mcp-proxy \
    && npm cache clean --force

# Initialize Claude-Flow (creates .claude-flow directory)
RUN npx claude-flow init --force

# ============================================
# Stage 2: Runtime (minimal, no build tools)
# ============================================
FROM node:22-slim AS runtime

# Install only runtime dependencies (curl for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set production environment
ENV NODE_ENV=production

# Copy entire /usr/local from builder (includes node, npm, node_modules, binaries)
# This ensures all symlinks and dependencies are preserved
COPY --from=builder /usr/local /usr/local

# Copy initialized claude-flow data
COPY --from=builder /root/.claude-flow /root/.claude-flow

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Declare volumes for runtime data persistence
# /.claude/ — agents, memory.db, settings, skills
# /.swarm/ — swarm memory.db, HNSW vector index
VOLUME ["/.claude", "/.swarm", "/root/.claude-flow"]

# Expose SSE port for MCP
EXPOSE 8080

# Health check - use max-time since SSE keeps connection open
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -s --max-time 2 -o /dev/null -w '%{http_code}' http://localhost:8080/sse | grep -q 200 || exit 1

# Use entrypoint for auto-update and logging
ENTRYPOINT ["/entrypoint.sh"]
