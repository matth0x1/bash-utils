#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running bash-utils tests with bats${NC}"

# Get the directory where this script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Check if bats is available
if ! command -v bats >/dev/null 2>&1; then
    echo -e "${RED}Error: bats is required but not installed${NC}" >&2
    echo "Install bats using one of these methods:" >&2
    echo "  - Ubuntu/Debian: sudo apt-get install bats" >&2
    echo "  - macOS with Homebrew: brew install bats-core" >&2
    echo "  - From source: https://github.com/bats-core/bats-core" >&2
    exit 1
fi

# Check if jq is available (required for log_json tests)
if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}Error: jq is required but not installed${NC}" >&2
    echo "Install jq using one of these methods:" >&2
    echo "  - Ubuntu/Debian: sudo apt-get install jq" >&2
    echo "  - macOS with Homebrew: brew install jq" >&2
    exit 1
fi

echo "Using bats version: $(bats --version)"
echo "Project root: $PROJECT_ROOT"
echo "Test directory: $TEST_DIR"

# Create output directory for test results
mkdir -p "$PROJECT_ROOT/test-output"

# Run bats tests with JUnit XML output
echo -e "${YELLOW}Running tests...${NC}"

# Use bats with TAP formatter and convert to JUnit XML
if command -v bats >/dev/null 2>&1; then
    # Run bats tests and capture both stdout and the exit code
    if bats --formatter junit "$TEST_DIR"/*.bats > "$PROJECT_ROOT/test-results.xml" 2>&1; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        
        # Also create a copy in the test directory for compatibility
        cp "$PROJECT_ROOT/test-results.xml" "$TEST_DIR/test-results.xml" 2>/dev/null || true
        
        # Display summary
        echo -e "${GREEN}Test results saved to test-results.xml${NC}"
        exit 0
    else
        echo -e "${RED}✗ Some tests failed${NC}"
        
        # Still copy the results even if tests failed
        cp "$PROJECT_ROOT/test-results.xml" "$TEST_DIR/test-results.xml" 2>/dev/null || true
        
        # Show the test results
        echo -e "${RED}Test results saved to test-results.xml${NC}"
        exit 1
    fi
else
    echo -e "${RED}Error: Could not run bats${NC}" >&2
    exit 1
fi
