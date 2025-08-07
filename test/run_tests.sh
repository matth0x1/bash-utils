#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$TEST_DIR/.." && pwd)"

# Function to display test results summary
# Usage: display_test_results <total_tests> <passed_tests> <failed_tests> <duration> <commit_hash> <is_success>
display_test_results() {
    local total_tests="$1"
    local passed_tests="$2"
    local failed_tests="$3"
    local duration="$4"
    local commit_hash="$5"
    local is_success="$6"
    
    local total_suites=$(ls -1 "$TEST_DIR"/*.bats 2>/dev/null | wc -l)
    local total_files=$(ls -1 "$TEST_DIR"/*.bats 2>/dev/null | wc -l)
    
    echo ""
    echo "Test Results"
    printf "%4d tests        %2d ✓ %ds\n" "$total_tests" "$passed_tests" "$duration"
    printf "%4d suites       %2d 💤\n" "$total_suites" "0"
    printf "%4d files        %2d ❌\n" "$total_files" "$failed_tests"
    echo ""
    echo "  Results for commit ${commit_hash}."
    echo ""
    
    if [ "$is_success" = "true" ]; then
        echo -e "${GREEN}Test results saved to test-results.xml${NC}"
    else
        echo -e "${RED}Test results saved to test-results.xml${NC}"
    fi
}

# Function to parse test failures from XML
parse_test_failures() {
    local xml_file="$1"
    local failed_tests=0
    
    if [ -f "$xml_file" ]; then
        # Count failures and errors from XML attributes
        local failure_count=$(grep -oE 'failures="[0-9]+"' "$xml_file" 2>/dev/null | grep -oE '[0-9]+' | awk '{sum += $1} END {print sum+0}')
        local error_count=$(grep -oE 'errors="[0-9]+"' "$xml_file" 2>/dev/null | grep -oE '[0-9]+' | awk '{sum += $1} END {print sum+0}')
        failed_tests=$((failure_count + error_count))
    fi
    
    echo "$failed_tests"
}

# Function to copy test results to test directory
copy_test_results() {
    local source_file="$1"
    local dest_file="$2"
    
    cp "$source_file" "$dest_file" 2>/dev/null || true
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    local cmd_name="$2"
    local install_instructions="$3"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}Error: $cmd_name is required but not installed${NC}" >&2
        echo "$install_instructions" >&2
        exit 1
    fi
}

echo -e "${YELLOW}Running bash-utils tests with bats${NC}"

# Check if bats is available
check_command "bats" "bats" "Install bats using one of these methods:
  - Ubuntu/Debian: sudo apt-get install bats
  - macOS with Homebrew: brew install bats-core
  - From source: https://github.com/bats-core/bats-core"

# Check if jq is available (required for log_json tests)
check_command "jq" "jq" "Install jq using one of these methods:
  - Ubuntu/Debian: sudo apt-get install jq
  - macOS with Homebrew: brew install jq"

echo "Using bats version: $(bats --version)"
echo "Project root: $PROJECT_ROOT"
echo "Test directory: $TEST_DIR"

# Create output directory for test results
mkdir -p "$PROJECT_ROOT/test-output"

# Run bats tests with JUnit XML output
echo -e "${YELLOW}Running tests...${NC}"

# Count total tests first
total_tests=$(bats --count "$TEST_DIR"/*.bats 2>/dev/null || echo "0")
total_suites=$(ls -1 "$TEST_DIR"/*.bats 2>/dev/null | wc -l)
total_files=1

# Get current commit hash
commit_hash=$(cd "$PROJECT_ROOT" && git rev-parse HEAD 2>/dev/null | cut -c1-8 || echo "unknown")

# Use bats with TAP formatter and convert to JUnit XML
if command -v bats >/dev/null 2>&1; then
    # Run bats tests and capture timing
    start_time=$(date +%s)
    
    # Run bats tests and capture both stdout and the exit code
    if bats --formatter junit "$TEST_DIR"/*.bats > "$PROJECT_ROOT/test-results.xml" 2>&1; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        # Also create a copy in the test directory for compatibility
        copy_test_results "$PROJECT_ROOT/test-results.xml" "$TEST_DIR/test-results.xml"
        
        # Display success results
        display_test_results "$total_tests" "$total_tests" "0" "$duration" "$commit_hash" "true"
        exit 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        # Parse failures from XML if possible
        failed_tests=$(parse_test_failures "$PROJECT_ROOT/test-results.xml")
        passed_tests=$((total_tests - failed_tests))
        
        # Still copy the results even if tests failed
        copy_test_results "$PROJECT_ROOT/test-results.xml" "$TEST_DIR/test-results.xml"
        
        # Display failure results
        display_test_results "$total_tests" "$passed_tests" "$failed_tests" "$duration" "$commit_hash" "false"
        exit 1
    fi
else
    echo -e "${RED}Error: Could not run bats${NC}" >&2
    exit 1
fi
