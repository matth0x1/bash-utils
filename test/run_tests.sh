#!/bin/bash

# Run all tests
SCRIPT_DIR="$(dirname "$0")"
declare -A failures
total_tests=0
failed_tests=0

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Make scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

echo "Starting test suite..."
echo "===================="

for test in "$SCRIPT_DIR"/*_test.sh; do
    test_name=$(basename "$test")
    ((total_tests++))
    
    echo -n "Running $test_name... "
    
    # Capture both stdout and stderr
    output=$("$test" 2>&1)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        failures["$test_name"]="$output"
        ((failed_tests++))
    fi
done

echo "===================="
echo "Test Summary:"
echo "Total tests: $total_tests"
if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
else
    echo -e "${RED}Failed tests: $failed_tests${NC}"
    echo ""
    echo "Failure Details:"
    echo "---------------"
    for test_name in "${!failures[@]}"; do
        echo -e "${RED}$test_name failed:${NC}"
        echo "${failures[$test_name]}"
        echo "---------------"
    done
fi

exit $failed_tests
