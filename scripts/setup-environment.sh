#!/bin/bash

set -euo pipefail

# Environment setup script for ReinventingAI infrastructure
# Usage: ./scripts/setup-environment.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "ReinventingAI Infrastructure Setup"
echo "=================================="

# Check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        echo "Error: Docker Compose is not installed"
        exit 1
    fi
    
    echo "Prerequisites check passed"
}

# Setup environment file
setup_env_file() {
    echo "Setting up environment configuration..."
    
    if [[ ! -f "$REPO_ROOT/.env" ]]; then
        if [[ -f "$REPO_ROOT/.env.example" ]]; then
            cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
            echo "Created .env file from .env.example"
            echo "IMPORTANT: Edit .env file with your actual values before starting services"
        else
            echo "Error: .env.example file not found"
            exit 1
        fi
    else
        echo ".env file already exists"
    fi
}

# Create backup directories
setup_backup_dirs() {
    echo "Creating backup directories..."
    
    local backup_dir="${BACKUP_DIR:-$HOME/backups}"
    mkdir -p "$backup_dir/n8n"
    
    echo "Backup directories created at $backup_dir"
}

# Display next steps
show_next_steps() {
    echo ""
    echo "Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env file with your actual values:"
    echo "   vim $REPO_ROOT/.env"
    echo ""
    echo "2. Start n8n service:"
    echo "   cd $REPO_ROOT/docker/n8n"
    echo "   docker-compose up -d"
    echo ""
    echo "3. View service logs:"
    echo "   docker logs n8n-gabe -f"
    echo ""
    echo "4. Create initial backup:"
    echo "   $REPO_ROOT/scripts/daily-backup.sh"
}

main() {
    cd "$REPO_ROOT"
    
    check_prerequisites
    setup_env_file
    setup_backup_dirs
    show_next_steps
}

main "$@"