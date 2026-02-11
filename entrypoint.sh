#!/bin/bash
set -e

# Colors for logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Logging function - only important events
log_event() {
    local level=$1
    local message=$2
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    case $level in
        "INFO")  echo -e "${timestamp} ${BLUE}[INFO]${NC} $message" ;;
        "OK")    echo -e "${timestamp} ${GREEN}[OK]${NC} $message" ;;
        "WARN")  echo -e "${timestamp} ${YELLOW}[WARN]${NC} $message" ;;
        "ERROR") echo -e "${timestamp} ${RED}[ERROR]${NC} $message" ;;
    esac
}

log_event "INFO" "========== Claude-Flow Container Starting =========="

# Get current installed version
CURRENT_VERSION=$(npm list -g claude-flow --depth=0 2>/dev/null | grep claude-flow | sed 's/.*@//' || echo "none")
log_event "INFO" "Current version: $CURRENT_VERSION"

# Check for updates
log_event "INFO" "Checking for updates..."
LATEST_VERSION=$(npm view claude-flow@alpha version 2>/dev/null || echo "unknown")

if [ "$LATEST_VERSION" = "unknown" ]; then
    log_event "WARN" "Could not check latest version (network issue?)"
elif [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    log_event "INFO" "New version available: $LATEST_VERSION"
    log_event "INFO" "Updating claude-flow..."

    if npm install -g claude-flow@alpha --silent 2>/dev/null; then
        log_event "OK" "Updated to version $LATEST_VERSION"

        # Re-init if major version changed
        log_event "INFO" "Re-initializing claude-flow..."
        npx claude-flow init --force --silent 2>/dev/null || true
        log_event "OK" "Re-initialization complete"
    else
        log_event "ERROR" "Update failed, continuing with current version"
    fi
else
    log_event "OK" "Already on latest version: $CURRENT_VERSION"
fi

# Initialize memory if needed
log_event "INFO" "Initializing memory database..."
npx claude-flow memory init --silent 2>/dev/null || true
log_event "OK" "Memory initialized"

# Start the MCP server
log_event "OK" "========== Starting MCP Server on port 8080 =========="

# Execute mcp-proxy
exec mcp-proxy --port 8080 npx claude-flow mcp start
