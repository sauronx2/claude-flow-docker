# Claude Flow Docker

Docker setup for Claude Flow MCP server - multi-agent orchestration system accessible via Model Context Protocol (MCP).

## What is This?

This project provides a containerized Claude Flow MCP server that enables Claude Code to spawn and orchestrate multiple AI agents in parallel. The server runs in Docker and communicates with Claude Code through SSE (Server-Sent Events) transport.

## Architecture

```
Claude Code (Mac) → SSE → mcp-proxy (Docker) → stdio → Claude Flow MCP
                                                           ↓
                                                    Swarm Agents
                                                           ↓
                                                  SQLite Database
```

### Components

- **Claude Flow MCP Server**: Multi-agent orchestration engine
- **mcp-proxy**: Bridges SSE transport to stdio for MCP communication
- **SQLite Database**: Persistent storage for agent decisions, performance metrics, and learned patterns
- **Node.js 22**: Runtime environment

## Features

- **Multi-Agent Orchestration**: Spawn and coordinate multiple AI agents in parallel
- **Hive-Mind System**: Queen-Worker architecture for task distribution
- **Persistent Memory**: SQLite database stores agent sessions, decisions, and patterns
- **SSE Transport**: Claude Code connects via Server-Sent Events on port 8080
- **Docker Volumes**: Data persists between container restarts

## Quick Start

### 1. Start the Container

```bash
make start
```

This builds the Docker image and starts the Claude Flow MCP server on port 8080.

### 2. Connect Claude Code

Add the MCP server to Claude Code:

```bash
claude mcp add --transport sse claude-flow --scope user http://localhost:8080/sse
```

### 3. Verify Connection

```bash
make status
```

### 4. Use in Claude Code

Start Claude Code and the MCP tools will be available:

```bash
claude
```

Now you can use Claude Flow tools like:
- `swarm_orchestrate` - Launch parallel agent swarms
- `spawn_agent` - Create specialized agents
- `hive_mind_init` - Initialize Queen-Worker hierarchy
- `memory_store` - Save to persistent database

## Available Commands

```bash
make start         # Start the container
make stop          # Stop the container
make restart       # Restart the container
make logs          # View container logs
make status        # Check container status
make shell         # Enter container shell
make clean         # Remove container and volumes (deletes data!)
make build         # Rebuild Docker image
```

## MCP Tools Available

### Swarm Orchestration
- `swarm_orchestrate` - Launch parallel agent swarms
- `spawn_agent` - Create individual agents
- `swarm_status` - Check swarm status

### Hive-Mind System
- `hive_mind_init` - Initialize Queen-Worker hierarchy
- `queen_coordinate` - Queen coordinates Workers
- `worker_assign` - Assign tasks to Workers
- `consensus_vote` - Agent voting mechanism

### Memory System
- `memory_store` - Save to SQLite database
- `memory_query` - Query stored data
- `memory_search` - Semantic search in AgentDB

### Performance
- `performance_metrics` - Agent performance stats
- `neural_sync` - Synchronize learned patterns

## Data Persistence

All data is stored in Docker volumes:

- `claude-flow-db`: SQLite database with agent sessions, decisions, patterns
- `node-modules-cache`: npm package cache

Data persists between container restarts. Use `make clean` to completely remove all data.

## Database Schema

The SQLite database (`/.claude-flow/memory.db`) contains:

- `decisions` - Agent decision history
- `performance_metrics` - Performance stats
- `learned_patterns` - ML patterns
- `agent_sessions` - Session history
- `task_history` - Completed tasks
- `reasoning_chains` - Reasoning steps
- `vector_embeddings` - Semantic embeddings (AgentDB)

## Port Configuration

- **8080**: SSE endpoint for MCP communication (`http://localhost:8080/sse`)

## Requirements

- Docker
- Docker Compose
- Claude Code

## Troubleshooting

### Container won't start
```bash
make logs
```

### Reset everything
```bash
make clean
make start
```

### Check if server is running
```bash
curl http://localhost:8080/sse
```

## Technical Details

- **Base Image**: node:22-slim
- **Node Modules**: claude-flow@alpha, mcp-proxy
- **Runtime**: Node.js 22
- **Database**: SQLite (better-sqlite3)
- **Transport**: SSE (Server-Sent Events)
- **Protocol**: MCP (Model Context Protocol)

## Documentation

For detailed architecture explanation, see [guide.md](./guide.md).

## License

MIT
