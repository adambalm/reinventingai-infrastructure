#!/bin/bash
# n8n Backup Script
# Creates timestamped backups of n8n data volumes

set -e

# Load environment variables
if [ -f "../../.env" ]; then
    export $(grep -v '^#' ../../.env | xargs)
fi

# Configuration
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups/n8n}"
VOLUME_NAME="${N8N_VOLUME_NAME:-n8n_data_gabe}"
CONTAINER_NAME="${N8N_CONTAINER_NAME:-n8n-gabe}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="n8n-gabe-backup-${TIMESTAMP}.tar.gz"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting n8n backup process..."

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${RED}Error: Container ${CONTAINER_NAME} not found${NC}"
    exit 1
fi

# Check if volume exists
if ! docker volume ls --format '{{.Name}}' | grep -q "^${VOLUME_NAME}$"; then
    echo -e "${RED}Error: Volume ${VOLUME_NAME} not found${NC}"
    exit 1
fi

# Create backup
echo "Creating backup: ${BACKUP_FILE}"
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "${BACKUP_DIR}:/backup" \
    alpine tar -czf "/backup/${BACKUP_FILE}" -C /data .

# Verify backup was created
if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
    SIZE=$(ls -lh "${BACKUP_DIR}/${BACKUP_FILE}" | awk '{print $5}')
    echo -e "${GREEN}Backup completed successfully${NC}"
    echo "Location: ${BACKUP_DIR}/${BACKUP_FILE}"
    echo "Size: ${SIZE}"
    
    # List recent backups
    echo -e "\nRecent backups:"
    ls -lht "${BACKUP_DIR}" | head -6
    
    # Cleanup old backups (keep last 7 days)
    echo -e "\nCleaning up old backups..."
    find "${BACKUP_DIR}" -name "n8n-gabe-backup-*.tar.gz" -mtime +7 -delete
    echo "Old backups cleaned up (kept last 7 days)"
else
    echo -e "${RED}Error: Backup file was not created${NC}"
    exit 1
fi

echo -e "\nBackup process completed"
