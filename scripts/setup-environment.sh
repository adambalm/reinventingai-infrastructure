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

# Validate required environment variables
validate_env_vars() {
    echo "Validating environment configuration..."
    
    if [[ ! -f "$REPO_ROOT/.env" ]]; then
        echo "Error: .env file not found"
        return 1
    fi
    
    # Load environment variables
    set -o allexport
    source "$REPO_ROOT/.env"
    set +o allexport
    
    # Check required variables
    local missing_vars=()
    for key in N8N_ENCRYPTION_KEY N8N_HOST WEBHOOK_URL; do
        if [[ -z "${!key}" || "${!key}" == *"your_"*"_here"* ]]; then
            missing_vars+=("$key")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        echo "Error: The following required environment variables are not properly configured:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please edit $REPO_ROOT/.env and set actual values for these variables."
        echo "See docs/team-onboarding.md for detailed setup instructions."
        return 1
    fi
    
    echo "Environment validation passed"
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
    echo "2. Validate your configuration:"
    echo "   $REPO_ROOT/scripts/setup-environment.sh --validate"
    echo ""
    echo "3. Start n8n service:"
    echo "   cd $REPO_ROOT/docker/n8n"
    echo "   docker-compose up -d"
    echo ""
    echo "4. View service logs:"
    echo "   docker logs n8n-gabe -f"
    echo ""
    echo "5. Create initial backup:"
    echo "   $REPO_ROOT/scripts/daily-backup.sh"
}

main() {
    cd "$REPO_ROOT"
    
    # Handle command line arguments
    if [[ "${1:-}" == "--validate" ]]; then
        validate_env_vars
        if [[ $? -eq 0 ]]; then
            echo "✅ Environment is properly configured and ready for use"
        else
            echo "❌ Environment configuration needs attention"
            exit 1
        fi
        return
    fi
    
    check_prerequisites
    setup_env_file
    setup_backup_dirs
    show_next_steps
}

main "$@"