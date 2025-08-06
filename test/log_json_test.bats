#!/usr/bin/env bats

# Set up test environment
setup() {
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
    export TEST_LOG_JSON="$BATS_TEST_DIRNAME/../bin/log_json"
}

@test "log_json command exists and is executable" {
    [ -x "$TEST_LOG_JSON" ]
}

@test "log_json requires jq dependency" {
    # Test that jq is available
    command -v jq >/dev/null 2>&1
}

@test "log_json shows usage when no arguments provided" {
    run "$TEST_LOG_JSON"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Both level and message are required" ]]
    [[ "$output" =~ "Usage: log_json LEVEL MESSAGE" ]]
}

@test "log_json shows usage when only one argument provided" {
    run "$TEST_LOG_JSON" "INFO"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Both level and message are required" ]]
    [[ "$output" =~ "Usage: log_json LEVEL MESSAGE" ]]
}

@test "log_json produces valid JSON output with INFO level" {
    run "$TEST_LOG_JSON" "INFO" "Test message"
    [ "$status" -eq 0 ]
    
    # Validate JSON structure
    echo "$output" | jq -e '.timestamp' >/dev/null
    echo "$output" | jq -e '.level' >/dev/null
    echo "$output" | jq -e '.message' >/dev/null
    
    # Check specific values
    [ "$(echo "$output" | jq -r '.level')" = "INFO" ]
    [ "$(echo "$output" | jq -r '.message')" = "Test message" ]
}

@test "log_json produces valid JSON output with ERROR level" {
    run "$TEST_LOG_JSON" "ERROR" "Error occurred"
    [ "$status" -eq 0 ]
    
    # Check specific values
    [ "$(echo "$output" | jq -r '.level')" = "ERROR" ]
    [ "$(echo "$output" | jq -r '.message')" = "Error occurred" ]
}

@test "log_json produces valid JSON output with WARNING level" {
    run "$TEST_LOG_JSON" "WARNING" "Warning message"
    [ "$status" -eq 0 ]
    
    [ "$(echo "$output" | jq -r '.level')" = "WARNING" ]
    [ "$(echo "$output" | jq -r '.message')" = "Warning message" ]
}

@test "log_json handles special characters in message" {
    run "$TEST_LOG_JSON" "INFO" "Message with \"quotes\" and $special chars!"
    [ "$status" -eq 0 ]
    
    # Ensure output is valid JSON
    echo "$output" | jq . >/dev/null
    [ "$(echo "$output" | jq -r '.message')" = "Message with \"quotes\" and $special chars!" ]
}

@test "log_json timestamp format is ISO 8601" {
    run "$TEST_LOG_JSON" "INFO" "Test timestamp"
    [ "$status" -eq 0 ]
    
    timestamp=$(echo "$output" | jq -r '.timestamp')
    # Check that timestamp matches ISO 8601 format (basic validation)
    [[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}[+-][0-9]{2}:[0-9]{2}$ ]]
}

@test "log_json --version flag works" {
    run "$TEST_LOG_JSON" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "log_json version v" ]]
}

@test "log_json handles empty message" {
    run "$TEST_LOG_JSON" "INFO" ""
    [ "$status" -eq 0 ]
    
    [ "$(echo "$output" | jq -r '.message')" = "" ]
}

@test "log_json handles multiline message" {
    multiline_msg="Line 1
Line 2
Line 3"
    run "$TEST_LOG_JSON" "INFO" "$multiline_msg"
    [ "$status" -eq 0 ]
    
    # Ensure output is valid JSON
    echo "$output" | jq . >/dev/null
    [ "$(echo "$output" | jq -r '.message')" = "$multiline_msg" ]
}

@test "log_json output contains all required fields" {
    run "$TEST_LOG_JSON" "DEBUG" "Debug message"
    [ "$status" -eq 0 ]
    
    # Check that all required fields exist
    timestamp=$(echo "$output" | jq -r '.timestamp')
    level=$(echo "$output" | jq -r '.level')
    message=$(echo "$output" | jq -r '.message')
    
    [ "$timestamp" != "null" ]
    [ "$level" = "DEBUG" ]
    [ "$message" = "Debug message" ]
}
