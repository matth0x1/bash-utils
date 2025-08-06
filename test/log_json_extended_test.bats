#!/usr/bin/env bats

# Set up test environment
setup() {
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
    export TEST_LOG_JSON="$BATS_TEST_DIRNAME/../bin/log_json"
}

@test "log_json supports help flag" {
    run "$TEST_LOG_JSON" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage: log_json [OPTIONS] LEVEL MESSAGE" ]]
    [[ "$output" =~ "Generate structured JSON log entries" ]]
    [[ "$output" =~ "Examples:" ]]
}

@test "log_json supports short help flag" {
    run "$TEST_LOG_JSON" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage: log_json [OPTIONS] LEVEL MESSAGE" ]]
}

@test "log_json supports additional key=value fields" {
    run "$TEST_LOG_JSON" "INFO" "Test message" service=api version=1.2.3
    [ "$status" -eq 0 ]
    
    # Validate JSON structure and values
    echo "$output" | jq -e '.service' >/dev/null
    echo "$output" | jq -e '.version' >/dev/null
    [ "$(echo "$output" | jq -r '.service')" = "api" ]
    [ "$(echo "$output" | jq -r '.version')" = "1.2.3" ]
}

@test "log_json handles numeric values correctly" {
    run "$TEST_LOG_JSON" "ERROR" "Connection timeout" timeout=30.5 retry_count=3
    [ "$status" -eq 0 ]
    
    # Check that numeric values are parsed as numbers, not strings
    [ "$(echo "$output" | jq -r '.timeout')" = "30.5" ]
    [ "$(echo "$output" | jq -r '.retry_count')" = "3" ]
    [ "$(echo "$output" | jq -r 'type')" = "object" ]
    [ "$(echo "$output" | jq -r '.timeout | type')" = "number" ]
    [ "$(echo "$output" | jq -r '.retry_count | type')" = "number" ]
}

@test "log_json handles boolean values correctly" {
    run "$TEST_LOG_JSON" "INFO" "Feature enabled" feature_enabled=true debug_mode=false
    [ "$status" -eq 0 ]
    
    # Check that boolean values are parsed correctly
    [ "$(echo "$output" | jq -r '.feature_enabled')" = "true" ]
    [ "$(echo "$output" | jq -r '.debug_mode')" = "false" ]
    [ "$(echo "$output" | jq -r '.feature_enabled | type')" = "boolean" ]
    [ "$(echo "$output" | jq -r '.debug_mode | type')" = "boolean" ]
}

@test "log_json includes PID when --pid flag is used" {
    run "$TEST_LOG_JSON" --pid "INFO" "Test with PID"
    [ "$status" -eq 0 ]
    
    echo "$output" | jq -e '.pid' >/dev/null
    [ "$(echo "$output" | jq -r '.pid | type')" = "number" ]
    # PID should be a positive integer
    pid=$(echo "$output" | jq -r '.pid')
    [[ "$pid" =~ ^[0-9]+$ ]]
    [ "$pid" -gt 0 ]
}

@test "log_json includes hostname when --hostname flag is used" {
    run "$TEST_LOG_JSON" --hostname "INFO" "Test with hostname"
    [ "$status" -eq 0 ]
    
    echo "$output" | jq -e '.hostname' >/dev/null
    hostname=$(echo "$output" | jq -r '.hostname')
    [ -n "$hostname" ]
    [ "$hostname" != "null" ]
}

@test "log_json includes user when --user flag is used" {
    run "$TEST_LOG_JSON" --user "INFO" "Test with user"
    [ "$status" -eq 0 ]
    
    echo "$output" | jq -e '.user' >/dev/null
    user=$(echo "$output" | jq -r '.user')
    [ -n "$user" ]
    [ "$user" != "null" ]
}

@test "log_json includes context when --context flag is used" {
    run "$TEST_LOG_JSON" --context "auth-service" "INFO" "User logged in"
    [ "$status" -eq 0 ]
    
    echo "$output" | jq -e '.context' >/dev/null
    [ "$(echo "$output" | jq -r '.context')" = "auth-service" ]
}

@test "log_json combines system flags with additional fields" {
    run "$TEST_LOG_JSON" --pid --hostname "ERROR" "Database error" database=postgres error_code=500
    [ "$status" -eq 0 ]
    
    # Check all fields are present
    echo "$output" | jq -e '.pid' >/dev/null
    echo "$output" | jq -e '.hostname' >/dev/null
    echo "$output" | jq -e '.database' >/dev/null
    echo "$output" | jq -e '.error_code' >/dev/null
    
    [ "$(echo "$output" | jq -r '.database')" = "postgres" ]
    [ "$(echo "$output" | jq -r '.error_code')" = "500" ]
    [ "$(echo "$output" | jq -r '.error_code | type')" = "number" ]
}

@test "log_json converts log level to uppercase" {
    run "$TEST_LOG_JSON" "info" "Test lowercase level"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r '.level')" = "INFO" ]
    
    run "$TEST_LOG_JSON" "error" "Test lowercase error"
    [ "$status" -eq 0 ]
    [ "$(echo "$output" | jq -r '.level')" = "ERROR" ]
}

@test "log_json warns about non-standard log levels" {
    run "$TEST_LOG_JSON" "CUSTOM" "Test custom level"
    [ "$status" -eq 0 ]
    [[ "${lines[0]}" =~ "Warning: 'CUSTOM' is not a standard log level" ]]
    
    # The JSON output should be on the last line
    json_output="${lines[-1]}"
    [ "$(echo "$json_output" | jq -r '.level')" = "CUSTOM" ]
}

@test "log_json ignores invalid field formats with warning" {
    run "$TEST_LOG_JSON" "INFO" "Test message" valid=field invalid-format another=valid
    [ "$status" -eq 0 ]
    
    # Check for warning in output lines
    warning_found=false
    json_line=""
    for line in "${lines[@]}"; do
        if [[ "$line" =~ "Warning: Ignoring invalid field format" ]]; then
            warning_found=true
        elif [[ "$line" =~ ^\{.*\}$ ]]; then
            json_line="$line"
        fi
    done
    
    [ "$warning_found" = true ]
    
    # Check valid fields are included, invalid ones are not
    echo "$json_line" | jq -e '.valid' >/dev/null
    echo "$json_line" | jq -e '.another' >/dev/null
    # invalid-format should not exist as a field
    ! echo "$json_line" | jq -e '.["invalid-format"]' >/dev/null
}

@test "log_json rejects unknown options" {
    run "$TEST_LOG_JSON" --unknown-option "INFO" "Test message"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Error: Unknown option --unknown-option" ]]
    [[ "$output" =~ "Use --help for usage information" ]]
}

@test "log_json maintains backward compatibility" {
    # Test that old format still works exactly as before
    run "$TEST_LOG_JSON" "INFO" "Simple test"
    [ "$status" -eq 0 ]
    
    # Should have exactly the same fields as the old version
    fields=$(echo "$output" | jq -r 'keys | sort | join(",")')
    [ "$fields" = "level,message,timestamp" ]
}
