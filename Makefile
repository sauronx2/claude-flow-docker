.PHONY: help build start stop restart shell logs clean status

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Claude-Flow Docker Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Quick start:$(NC)"
	@echo "  1. make build    - Build the Docker image"
	@echo "  2. make start    - Start the container"
	@echo "  3. make shell    - Enter interactive shell"
	@echo "  4. make logs     - View container logs"

build: ## Build Claude-Flow Docker image
	@echo "$(BLUE)Building Claude-Flow Docker image...$(NC)"
	docker-compose build

start: ## Start Claude-Flow container
	@echo "$(BLUE)Starting Claude-Flow container...$(NC)"
	docker-compose up -d
	@echo "$(GREEN)✓ Container started. Use 'make shell' to enter.$(NC)"

stop: ## Stop Claude-Flow container
	@echo "$(YELLOW)Stopping Claude-Flow container...$(NC)"
	docker-compose down

restart: stop start ## Restart Claude-Flow container

shell: ## Enter interactive shell in the container
	@echo "$(BLUE)Entering Claude-Flow container shell...$(NC)"
	docker-compose exec claude-flow /bin/bash

logs: ## View container logs
	docker-compose logs -f

status: ## Show container status
	@echo "$(BLUE)Claude-Flow Container Status:$(NC)"
	@docker-compose ps

clean: ## Stop container and remove volumes (WARNING: deletes all data!)
	@echo "$(YELLOW)⚠️  This will remove all data including databases!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "$(GREEN)✓ Cleaned up.$(NC)"; \
	else \
		echo "Cancelled."; \
	fi

# LazyDocker shortcut
lazy: ## Open LazyDocker TUI for this project
	@echo "$(BLUE)Opening LazyDocker...$(NC)"
	@cd $(PWD) && lazydocker
