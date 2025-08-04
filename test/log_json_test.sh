#!/bin/bash

# Source test framework and assertions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/test_framework.sh"
source "$SCRIPT_DIR/lib/assertions.sh"

# Set test suite name
set_test_suite "JSON Logger Tests"

# Get the log_json function without executing the script
eval "$(sed '/^log_json "\$@" || exit 1$/d' "$SCRIPT_DIR/../bin/log_json")"

# Test functions
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

# Register test cases
test_case "info_logging" "test_info_log" "Verifies INFO level logs are correctly formatted with message and timestamp"
test_case "error_logging" "test_error_log" "Verifies ERROR level logs are correctly formatted with message and timestamp"
test_case "debug_logging" "test_debug_log" "Verifies DEBUG level logs are correctly formatted with message and timestamp"
test_case "missing_message" "test_missing_args" "Validates error handling when message argument is missing"
test_case "no_arguments" "test_no_args" "Validates error handling when no arguments are provided"

# Return test results
get_test_results
