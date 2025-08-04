#!/bin/bash

# Source test assertions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/assertions.sh"

# Get the log_json function without executing the script
eval "$(sed '/^log_json "\$@" || exit 1$/d' "$SCRIPT_DIR/../bin/log_json")"

# Test cases
test_info_log() {
    local output
    output=$(log_json "INFO" "test message")
    
    # Check log level
    assert_contains "$output" '"level":"INFO"' "Info level should be set"
    
    # Check message
    assert_contains "$output" '"message":"test message"' "Message should be set"
    
    # Check timestamp format
    assert_contains "$output" '"timestamp":"' "Should have timestamp"
}

test_error_log() {
    local output
    output=$(log_json "ERROR" "error occurred")
    
    # Check log level
    assert_contains "$output" '"level":"ERROR"' "Error level should be set"
    
    # Check message
    assert_contains "$output" '"message":"error occurred"' "Message should be set"
    
    # Check timestamp format
    assert_contains "$output" '"timestamp":"' "Should have timestamp"
}

test_debug_log() {
    local output
    output=$(log_json "DEBUG" "debug info")
    
    # Check log level
    assert_contains "$output" '"level":"DEBUG"' "Debug level should be set"
    
    # Check message
    assert_contains "$output" '"message":"debug info"' "Message should be set"
    
    # Check timestamp format
    assert_contains "$output" '"timestamp":"' "Should have timestamp"
}

test_missing_args() {
    local output
    output=$(log_json "INFO" 2>&1)
    assert_contains "$output" "Both level and message are required" "Should error on missing message"
}

test_no_args() {
    local output
    output=$(log_json 2>&1)
    assert_contains "$output" "Both level and message are required" "Should error on no arguments"
}

# Run all tests
echo "Running log_json tests..."
echo "----------------------------------------"

failed_tests=0
for test_func in test_info_log test_error_log test_debug_log test_missing_args test_no_args; do
    echo "Running $test_func..."
    if ! $test_func; then
        ((failed_tests++))
    fi
    echo "----------------------------------------"
done

if [ "$failed_tests" -gt 0 ]; then
    echo "$failed_tests test(s) failed"
    exit 1
fi

echo "All tests passed!"
exit 0
