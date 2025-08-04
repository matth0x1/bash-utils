#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/test_framework.sh"

# Define test functions first
test_addition() {
    result=$((2 + 2))
    if [ "$result" -eq 4 ]; then
        return 0
    else
        echo "Expected 4, got $result"
        return 1
    fi
}

test_multiplication() {
    result=$((3 * 3))
    if [ "$result" -eq 9 ]; then
        return 0
    else
        echo "Expected 9, got $result"
        return 1
    fi
}

# Then define test cases
test_case "should add two numbers" "test_addition" "Tests basic addition operation (2 + 2 = 4)"
test_case "should multiply two numbers" "test_multiplication" "Tests basic multiplication operation (3 * 3 = 9)"

# Return test results
get_test_results
