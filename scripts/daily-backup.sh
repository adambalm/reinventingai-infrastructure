#!/bin/bash

set -euo pipefail

# Daily backup script for ReinventingAI infrastructure
# Usage: ./scripts/daily-backup.sh [service]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
DATE=$(date +%Y%m%d_%H%M%S)

# Load environment variables
if [[ -f "$REPO_ROOT/.env" ]]; then
    source "$REPO_ROOT/.env"
fi

# Default backup directory
BACKUP_BASE_DIR="${BACKUP_DIR:-$HOME/backups}"
mkdir -p "$BACKUP_BASE_DIR"

backup_n8n() {
    echo "Starting n8n backup..."
    
    local n8n_dir="$REPO_ROOT/docker/n8n"
    local backup_dir="$BACKUP_BASE_DIR/n8n"
    
    if [[ ! -d "$n8n_dir" ]]; then
        echo "Error: n8n directory not found at $n8n_dir"
        exit 1
    fi
    
    cd "$n8n_dir"
    
    if [[ -x "./backup.sh" ]]; then
        ./backup.sh
        echo "n8n backup completed"
    else
        echo "Error: n8n backup script not found or not executable"
        exit 1
    fi
}

backup_all() {
    echo "Starting full infrastructure backup..."
    backup_n8n
    echo "Full backup completed at $(date)"
}

main() {
    local service="${1:-all}"
    
    echo "ReinventingAI Infrastructure Backup - $(date)"
    echo "Service: $service"
    echo "Backup directory: $BACKUP_BASE_DIR"
    echo "----------------------------------------"
    
    case "$service" in
        "n8n")
            backup_n8n
            ;;
        "all"|"")
            backup_all
            ;;
        *)
            echo "Error: Unknown service '$service'"
            echo "Available services: n8n, all"
            exit 1
            ;;
    esac
    
    echo "Backup operation completed successfully"
}

main "$@"