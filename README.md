# Claude-Flow Docker

[![Docker Hub](https://img.shields.io/docker/v/sauronx2/claude-flow?label=Docker%20Hub&logo=docker)](https://hub.docker.com/r/sauronx2/claude-flow)
[![Build](https://github.com/sauronx2/claude-flow-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sauronx2/claude-flow-docker/actions)

Ready-to-use Docker image for [Claude-Flow](https://github.com/ruvnet/claude-flow) — AI agent orchestration platform for Claude Code.

## Why this project?

[Claude-Flow](https://github.com/ruvnet/claude-flow) is a powerful multi-agent orchestration system. But installation requires Node.js, native dependencies, and configuration.

**This project solves it:** one command — Claude-Flow works.

```bash
docker run -d -p 8080:8080 sauronx2/claude-flow
```

## What this project adds

| Feature | Description |
|---------|-------------|
| **Auto-update** | Container checks npm and updates to latest version on every start |
| **Logging** | Colored logs for key events (start, update, errors) for lazydocker/docker logs |
| **CI/CD** | GitHub Actions auto-builds and pushes image to Docker Hub on every commit |
| **Persistence** | Docker volumes preserve data between restarts |
| **SSE Transport** | mcp-proxy converts stdio to SSE for Claude Code connection |

## Quick Start

### 1. Run container

```bash
# Single command
docker run -d --name claude-flow -p 8080:8080 sauronx2/claude-flow:latest

# Or with docker-compose (with persistence)
curl -sO https://raw.githubusercontent.com/sauronx2/claude-flow-docker/main/docker-compose.hub.yml
docker compose -f docker-compose.hub.yml up -d
```

### 2. Connect to Claude Code

```bash
claude mcp add --transport sse claude-flow http://localhost:8080/sse
```

### 3. Done

Run `claude` and use 200+ Claude-Flow tools.

## What is Claude-Flow

[Claude-Flow](https://github.com/ruvnet/claude-flow) v3 — enterprise AI agent orchestration platform:

### Key Features

| Feature | Description |
|---------|-------------|
| **60+ agents** | coder, tester, reviewer, architect, security, etc. |
| **Swarm coordination** | Parallel agent work with consensus (Raft, Byzantine, Gossip) |
| **Hive-Mind** | Queen-Worker hierarchy for complex tasks |
| **HNSW Memory** | Vector search 150x-12,500x faster than standard |
| **Self-Learning** | SONA — agents learn from results (<0.05ms adaptation) |
| **Multi-LLM** | Claude, GPT, Gemini, Ollama with automatic failover |

### Main MCP Tools

```
agent_spawn          — create an agent
swarm_init           — start a swarm
hive-mind_spawn      — create hive with workers
memory_store/search  — vector memory
task_create          — create a task
hooks_route          — intelligent routing
```

## Architecture

```
Claude Code → SSE:8080 → mcp-proxy → stdio → claude-flow mcp
                                                    ↓
                                              ┌─────────────┐
                                              │ 60+ Agents  │
                                              │ HNSW Memory │
                                              │ SQLite DB   │
                                              └─────────────┘
```

## Commands (local build)

```bash
make start    # Start container
make stop     # Stop container
make logs     # View logs
make shell    # Enter container
make clean    # Remove everything (including data)
```

## Log Example

```
2026-02-11T13:13:57Z [INFO] ========== Claude-Flow Container Starting ==========
2026-02-11T13:13:58Z [INFO] Current version: 3.1.0-alpha.28
2026-02-11T13:13:58Z [INFO] Checking for updates...
2026-02-11T13:13:59Z [OK] Already on latest version: 3.1.0-alpha.28
2026-02-11T13:14:01Z [OK] Memory initialized
2026-02-11T13:14:01Z [OK] ========== Starting MCP Server on port 8080 ==========
```

## Technical Details

| Parameter | Value |
|-----------|-------|
| Base Image | `node:22-slim` |
| Port | `8080` (SSE) |
| Volumes | `claude-flow-db`, `node-modules-cache` |
| Restart | `unless-stopped` |

## Links

- **Original project:** https://github.com/ruvnet/claude-flow
- **Docker Hub:** https://hub.docker.com/r/sauronx2/claude-flow
- **Claude-Flow docs:** https://github.com/ruvnet/claude-flow#readme

## License

MIT
