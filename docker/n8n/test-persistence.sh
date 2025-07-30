#!/bin/bash
# n8n Persistence Test Script
# Tests that data persists through container restarts and recreation

set -e

# Load environment variables
if [ -f "../../.env" ]; then
    export $(grep -v '^#' ../../.env | xargs)
fi

# Configuration
VOLUME_NAME="${N8N_VOLUME_NAME:-n8n_data_gabe}"
CONTAINER_NAME="${N8N_CONTAINER_NAME:-n8n-gabe}"
TEST_FILE="PERSISTENCE_TEST.txt"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "n8n Data Persistence Test"
echo "============================"

# Phase 1: Verify Volume Mount
echo -e "\nPhase 1: Verifying volume mount..."
MOUNT_INFO=$(docker inspect "${CONTAINER_NAME}" | grep -A 10 "Mounts" | grep -A 5 "${VOLUME_NAME}" || true)
if echo "$MOUNT_INFO" | grep -q "${VOLUME_NAME}"; then
    echo -e "${GREEN}Volume ${VOLUME_NAME} is properly mounted${NC}"
    docker exec "${CONTAINER_NAME}" ls -la /home/node/.n8n
else
    echo -e "${RED}Volume ${VOLUME_NAME} is NOT mounted${NC}"
    exit 1
fi

# Phase 2: Test Write/Read
echo -e "\nPhase 2: Testing write/read operations..."
TIMESTAMP=$(date)
docker exec "${CONTAINER_NAME}" sh -c "echo '${TIMESTAMP} - Persistence test' > /home/node/.n8n/${TEST_FILE}"
CONTENT=$(docker exec "${CONTAINER_NAME}" cat "/home/node/.n8n/${TEST_FILE}")
if [ "$CONTENT" = "${TIMESTAMP} - Persistence test" ]; then
    echo -e "${GREEN}Write/read test passed${NC}"
    echo "   Content: ${CONTENT}"
else
    echo -e "${RED}Write/read test failed${NC}"
    exit 1
fi

# Phase 3: Container Restart Test
echo -e "\nPhase 3: Testing persistence through restart..."
docker restart "${CONTAINER_NAME}"
echo "⏳ Waiting for container to start..."
sleep 10

CONTENT_AFTER_RESTART=$(docker exec "${CONTAINER_NAME}" cat "/home/node/.n8n/${TEST_FILE}" 2>/dev/null || echo "FILE_NOT_FOUND")
if [ "$CONTENT_AFTER_RESTART" = "${TIMESTAMP} - Persistence test" ]; then
    echo -e "${GREEN}Data persisted through restart${NC}"
else
    echo -e "${RED}Data lost after restart${NC}"
    exit 1
fi

# Phase 4: Container Recreation Test (with warning)
echo -e "\nPhase 4: Testing persistence through container recreation..."
echo -e "${YELLOW}This will stop and recreate the container${NC}"
echo -n "Continue? (yes/no): "
read -r response
if [[ ! "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Skipping recreation test"
    echo -e "\nCleaning up test file..."
    docker exec "${CONTAINER_NAME}" rm "/home/node/.n8n/${TEST_FILE}"
    echo -e "${GREEN}Basic persistence tests passed${NC}"
    exit 0
fi

# Get container configuration
CONFIG=$(docker inspect "${CONTAINER_NAME}" --format='docker run -d --name {{.Name}} {{range .Config.Env}}-e {{.}} {{end}}{{range $p, $conf := .HostConfig.PortBindings}}{{range $conf}}-p {{.HostPort}}:{{$p}} {{end}}{{end}}-v {{(index .Mounts 0).Name}}:{{(index .Mounts 0).Destination}} {{.Config.Image}}')

# Stop and remove container
docker stop "${CONTAINER_NAME}"
docker rm "${CONTAINER_NAME}"

# Recreate container
echo "Recreating container..."
eval ${CONFIG//\/\//}
sleep 15

# Final verification
CONTENT_AFTER_RECREATION=$(docker exec "${CONTAINER_NAME}" cat "/home/node/.n8n/${TEST_FILE}" 2>/dev/null || echo "FILE_NOT_FOUND")
if [ "$CONTENT_AFTER_RECREATION" = "${TIMESTAMP} - Persistence test" ]; then
    echo -e "${GREEN}Data persisted through complete container recreation${NC}"
else
    echo -e "${RED}Data lost after container recreation${NC}"
    echo "This indicates a serious problem with volume persistence."
    exit 1
fi

# Cleanup
echo -e "\nCleaning up test file..."
docker exec "${CONTAINER_NAME}" rm "/home/node/.n8n/${TEST_FILE}"

# Summary
echo -e "\n${GREEN}All persistence tests passed${NC}"
echo "===================================="
echo "Volume mount verified"
echo "Write/read operations working"
echo "Data persists through restart"
echo "Data persists through container recreation"
echo -e "\n🎉 It's safe to use this container for persistent data!"
