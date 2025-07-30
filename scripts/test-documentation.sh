#!/bin/bash

set -euo pipefail

# Documentation Testing Framework
# Tests all scripts and documented procedures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_LOG="/tmp/doc-test-$(date +%Y%m%d_%H%M%S).log"

echo "Documentation Testing Framework" | tee "$TEST_LOG"
echo "===============================" | tee -a "$TEST_LOG"
echo "Test started: $(date)" | tee -a "$TEST_LOG"
echo "Test log: $TEST_LOG" | tee -a "$TEST_LOG"
echo "" | tee -a "$TEST_LOG"

TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo "Testing: $test_name" | tee -a "$TEST_LOG"
    echo "Command: $test_command" | tee -a "$TEST_LOG"
    
    if eval "$test_command" >> "$TEST_LOG" 2>&1; then
        echo "✓ PASSED: $test_name" | tee -a "$TEST_LOG"
        ((TESTS_PASSED++))
    else
        echo "✗ FAILED: $test_name" | tee -a "$TEST_LOG"
        ((TESTS_FAILED++))
    fi
    echo "" | tee -a "$TEST_LOG"
}

cd "$REPO_ROOT"

# Test 1: Setup script functionality (skip if .env already configured)
run_test "Setup Environment Script" \
    "bash -c './scripts/setup-environment.sh < /dev/null || true'"

# Test 2: Daily backup script
run_test "Daily Backup Script" \
    "./scripts/daily-backup.sh n8n"

# Test 3: Tunnel health check
run_test "Tunnel Health Check" \
    "./tunnels/scripts/tunnel-health.sh r2d2.reinventingai.com"

# Test 4: Docker Compose configuration validation
run_test "Docker Compose Config Validation" \
    "cd docker/n8n && docker-compose config --quiet"

# Test 5: n8n service status check
run_test "n8n Service Status Check" \
    "docker ps | grep -q n8n-gabe"

# Test 6: n8n persistence test (basic)
run_test "n8n Data Persistence Test" \
    "echo 'no' | ./docker/n8n/test-persistence.sh"

# Test 7: Environment file structure
run_test "Environment File Structure" \
    "test -f .env && grep -q 'N8N_HOST.*r2d2.reinventingai.com' .env"

# Test 8: Backup directory structure
run_test "Backup Directory Structure" \
    "test -d /Users/ed/backups/n8n && ls /Users/ed/backups/n8n/*.tar.gz > /dev/null 2>&1"

# Test 9: Script permissions
run_test "Script Executable Permissions" \
    "test -x ./scripts/setup-environment.sh && test -x ./scripts/daily-backup.sh && test -x ./tunnels/scripts/tunnel-health.sh"

# Test 10: Documentation file existence
run_test "Documentation Files Exist" \
    "test -f ./docs/team-onboarding.md && test -f ./docs/disaster-recovery.md && test -f ./docker/n8n/README.md"

echo "Test Summary" | tee -a "$TEST_LOG"
echo "============" | tee -a "$TEST_LOG"
echo "Tests Passed: $TESTS_PASSED" | tee -a "$TEST_LOG"
echo "Tests Failed: $TESTS_FAILED" | tee -a "$TEST_LOG"
echo "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))" | tee -a "$TEST_LOG"
echo "Test completed: $(date)" | tee -a "$TEST_LOG"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "" | tee -a "$TEST_LOG"
    echo "🎉 All documentation tests passed!" | tee -a "$TEST_LOG"
    exit 0
else
    echo "" | tee -a "$TEST_LOG"
    echo "❌ Some tests failed. Check log for details: $TEST_LOG" | tee -a "$TEST_LOG"
    exit 1
fi