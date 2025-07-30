#!/bin/bash
# n8n Restore Script
# Restores n8n data from backup files

set -e

# Configuration
BACKUP_DIR="$HOME/backups/n8n"
VOLUME_NAME="n8n_data_gabe"
CONTAINER_NAME="n8n-gabe"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if backup file was provided
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: No backup file specified${NC}"
    echo "Usage: $0 <backup-file>"
    echo -e "\nAvailable backups:"
    ls -lht "${BACKUP_DIR}"/n8n-gabe-backup-*.tar.gz 2>/dev/null || echo "No backups found in ${BACKUP_DIR}"
    exit 1
fi

BACKUP_FILE="$1"

# If only filename provided, prepend backup directory
if [[ ! "$BACKUP_FILE" =~ ^/ ]]; then
    BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

echo "🔄 Starting n8n restore process..."
echo "📦 Backup file: ${BACKUP_FILE}"

# Warning
echo -e "${YELLOW}⚠️  WARNING: This will replace ALL current n8n data!${NC}"
echo -n "Are you sure you want to continue? (yes/no): "
read -r response
if [[ ! "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Restore cancelled"
    exit 0
fi

# Stop container if running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🛑 Stopping container ${CONTAINER_NAME}..."
    docker stop "${CONTAINER_NAME}"
fi

# Backup current data before restore (safety measure)
SAFETY_BACKUP="n8n-gabe-pre-restore-$(date +%Y%m%d_%H%M%S).tar.gz"
echo "🔒 Creating safety backup: ${SAFETY_BACKUP}"
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "${BACKUP_DIR}:/backup" \
    alpine tar -czf "/backup/${SAFETY_BACKUP}" -C /data .

# Clear current volume data
echo "🧹 Clearing current volume data..."
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    alpine sh -c "rm -rf /data/*"

# Restore from backup
echo "📥 Restoring from backup..."
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    -v "$(dirname "$BACKUP_FILE"):/backup" \
    alpine tar -xzf "/backup/$(basename "$BACKUP_FILE")" -C /data

# Verify restore
echo "🔍 Verifying restore..."
docker run --rm \
    -v "${VOLUME_NAME}:/data" \
    alpine ls -la /data/

# Start container if it was running
echo "🚀 Starting container ${CONTAINER_NAME}..."
docker start "${CONTAINER_NAME}"

# Wait for startup
echo "⏳ Waiting for n8n to start..."
sleep 10

# Check if n8n is responding
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5679/ | grep -q "200\|301\|302"; then
    echo -e "${GREEN}✅ Restore completed successfully!${NC}"
    echo "🌐 n8n is accessible at https://r2d2.reinventingai.com"
    echo "🔒 Safety backup saved as: ${BACKUP_DIR}/${SAFETY_BACKUP}"
else
    echo -e "${YELLOW}⚠️  Restore completed but n8n may still be starting up${NC}"
    echo "Check logs: docker logs ${CONTAINER_NAME}"
fi

echo -e "\n✨ Restore process completed!"
