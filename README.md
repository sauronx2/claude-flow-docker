# Claude-Flow Docker

[![Docker Hub](https://img.shields.io/docker/v/sauronx2/claude-flow?label=Docker%20Hub&logo=docker&color=2496ED)](https://hub.docker.com/r/sauronx2/claude-flow)
[![Build](https://github.com/sauronx2/claude-flow-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/sauronx2/claude-flow-docker/actions)
[![Claude-Flow](https://img.shields.io/badge/Claude--Flow-v3-blueviolet)](https://github.com/ruvnet/claude-flow)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**One command to run [Claude-Flow v3](https://github.com/ruvnet/claude-flow) — enterprise AI orchestration platform with 60+ agents, swarm coordination, and self-learning.**

```bash
docker run -d -p 8080:8080 sauronx2/claude-flow
```

---

## What is Claude-Flow?

[Claude-Flow](https://github.com/ruvnet/claude-flow) is a production-ready multi-agent AI orchestration framework for Claude Code.

### Architecture

```
┌─────────────┐     ┌──────────────────────────────────────────┐
│ Claude Code │────▶│           Docker Container               │
└─────────────┘     │  ┌─────────┐   ┌───────────────────────┐ │
                    │  │ SSE     │   │    Claude-Flow MCP    │ │
       HTTP/SSE     │  │ :8080   │──▶│  ┌─────────────────┐  │ │
      ─────────────▶│  └─────────┘   │  │   60+ Agents    │  │ │
                    │       │        │  │   Swarm Coord   │  │ │
                    │       ▼        │  │   HNSW Memory   │  │ │
                    │  ┌─────────┐   │  │   SQLite DB     │  │ │
                    │  │mcp-proxy│──▶│  └─────────────────┘  │ │
                    │  └─────────┘   └───────────────────────┘ │
                    └──────────────────────────────────────────┘
```

### Key Capabilities

| Category | Features |
|----------|----------|
| **Agents** | 60+ specialized: coder, tester, reviewer, architect, security, DevOps |
| **Swarm** | 4 topologies (mesh, hierarchical, ring, star) + 5 consensus protocols |
| **Hive-Mind** | Queen-Worker hierarchy with strategic/tactical/adaptive queens |
| **Memory** | HNSW vector search (150x-12,500x faster), SQLite persistence |
| **Learning** | SONA self-optimization (<0.05ms), EWC++ prevents forgetting |
| **Multi-LLM** | Claude, GPT, Gemini, Ollama with automatic failover |
| **Tools** | 175+ MCP tools for orchestration, memory, GitHub, monitoring |

---

## Why Docker?

Claude-Flow requires Node.js 20+, native dependencies (better-sqlite3), and initialization.

**This project provides:**

| Feature | Description |
|---------|-------------|
| **Zero Setup** | `docker run` and it works |
| **Auto-Update** | Checks npm on every start, updates to latest version |
| **Colored Logs** | Key events only (INFO/OK/WARN/ERROR) for lazydocker |
| **CI/CD** | GitHub Actions auto-publishes to Docker Hub |
| **Persistence** | Docker volumes preserve memory and learned patterns |
| **SSE Bridge** | mcp-proxy converts stdio → SSE for Claude Code |

---

## Supported Platforms

Native multi-architecture support (no emulation, full performance):

| Platform | Architecture | Status |
|----------|--------------|--------|
| macOS Apple Silicon (M1/M2/M3/M4) | linux/arm64 | ✅ Native |
| macOS Intel | linux/amd64 | ✅ Native |
| Linux x86_64 | linux/amd64 | ✅ Native |
| Linux ARM64 | linux/arm64 | ✅ Native |
| Windows (WSL2) | linux/amd64 | ✅ Native |

Docker automatically pulls the correct native image for your platform.

---

## Quick Start

### 1. Run

```bash
# Minimal
docker run -d --name claude-flow -p 8080:8080 sauronx2/claude-flow:latest

# With persistence (recommended)
docker run -d --name claude-flow -p 8080:8080 \
  -v claude-flow-db:/root/.claude-flow \
  sauronx2/claude-flow:latest
```

**Or with Docker Compose:**

```bash
curl -sO https://raw.githubusercontent.com/sauronx2/claude-flow-docker/main/docker-compose.hub.yml
docker compose -f docker-compose.hub.yml up -d
```

### 2. Connect Claude Code

```bash
claude mcp add --transport sse claude-flow http://localhost:8080/sse
```

### 3. Use

```bash
claude
```

175+ tools available:
```
agent_spawn, swarm_init, hive-mind_spawn, memory_store, memory_search,
task_create, hooks_route, hooks_intelligence, neural_train...
```

---

## Claude-Flow v3 Features

### 60+ Specialized Agents

| Category | Agents |
|----------|--------|
| **Core** | coder, reviewer, tester, planner, researcher |
| **V3** | queen-coordinator, security-architect, memory-specialist |
| **Swarm** | hierarchical/mesh/adaptive coordinators |
| **Consensus** | Byzantine, Raft, Gossip managers |
| **GitHub** | PR management, code review, issue tracking |
| **DevOps** | CI/CD, deployment, monitoring |

### Swarm Coordination

```
                    ┌─────────────────┐
                    │      Queen      │
                    │ Strategic/Tactical │
                    └────────┬────────┘
           ┌─────────┬───────┼───────┬─────────┐
           ▼         ▼       ▼       ▼         ▼
       ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
       │ Coder │ │Tester │ │Review │ │Archit │ │  ...  │
       └───────┘ └───────┘ └───────┘ └───────┘ └───────┘
           │         │       │       │         │
           └─────────┴───────┴───────┴─────────┘
                           │
                    ┌──────┴──────┐
                    │  Consensus  │
                    │ Raft/BFT/   │
                    │ Gossip/CRDT │
                    └─────────────┘
```

**Topologies:** Hierarchical • Mesh • Ring • Star • Hybrid

**Consensus:** Raft • Byzantine (f < n/3) • Gossip • CRDT • Majority

### Intelligent Routing

| Tier | Handler | Latency | Use Case |
|------|---------|---------|----------|
| 1 | Agent Booster (WASM) | <1ms | var→const, add-types |
| 2 | Haiku/Sonnet | ~500ms | Bug fixes, refactoring |
| 3 | Opus + Swarm | 2-5s | Architecture design |

### Performance

| Component | Metric |
|-----------|--------|
| **HNSW Search** | ~61µs/query, 16,400 QPS |
| **SONA Adaptation** | <0.05ms |
| **LoRA Compression** | 128x, 383k ops/s |
| **Token Reduction** | 30-50% |

---

## Container Logs

```
2026-02-11T13:13:57Z [INFO] ========== Claude-Flow Container Starting ==========
2026-02-11T13:13:58Z [INFO] Current version: 3.1.0-alpha.28
2026-02-11T13:13:58Z [INFO] Checking for updates...
2026-02-11T13:13:59Z [OK] Already on latest version: 3.1.0-alpha.28
2026-02-11T13:14:01Z [OK] Memory initialized
2026-02-11T13:14:01Z [OK] ========== Starting MCP Server on port 8080 ==========
```

**When update available:**
```
[INFO] New version available: 3.1.0-alpha.29
[INFO] Updating claude-flow...
[OK] Updated to version 3.1.0-alpha.29
```

---

## Local Development

```bash
git clone https://github.com/sauronx2/claude-flow-docker.git
cd claude-flow-docker

make build   # Build image
make start   # Start container
make logs    # View logs
make shell   # Enter container
make stop    # Stop
make clean   # Remove all (including data)
```

---

## Technical Details

| Parameter | Value |
|-----------|-------|
| **Base Image** | `node:22-slim` (multi-arch) |
| **Architectures** | `linux/amd64`, `linux/arm64` |
| **Port** | `8080` (SSE) |
| **Volumes** | `claude-flow-db`, `node-modules-cache` |
| **Restart** | `unless-stopped` |

### Project Structure

```
├── Dockerfile              # Build with native deps
├── entrypoint.sh           # Auto-update + logging
├── docker-compose.yml      # Local build
├── docker-compose.hub.yml  # Docker Hub image
├── Makefile                # Dev commands
└── .github/workflows/      # CI/CD
```

---

## Links

- **Claude-Flow:** https://github.com/ruvnet/claude-flow
- **Docker Hub:** https://hub.docker.com/r/sauronx2/claude-flow
- **This Repo:** https://github.com/sauronx2/claude-flow-docker

## License

MIT
