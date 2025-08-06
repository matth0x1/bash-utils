#!/bin/bash

# Example script showing how to use the enhanced log_json utility
# This demonstrates common logging patterns for bash applications

# Source: log_json should be in PATH or provide the full path
LOG_JSON="$(dirname "$0")/../bin/log_json"

# Application configuration
APP_NAME="example-app"
APP_VERSION="1.0.0"

# Logging helper functions
log_info() {
    $LOG_JSON --context "$APP_NAME" INFO "$1" "${@:2}"
}

log_warn() {
    $LOG_JSON --pid --context "$APP_NAME" WARN "$1" "${@:2}"
}

log_error() {
    $LOG_JSON --pid --hostname --context "$APP_NAME" ERROR "$1" "${@:2}"
}

log_debug() {
    if [ "${DEBUG:-}" = "true" ]; then
        $LOG_JSON --pid --user --context "$APP_NAME" DEBUG "$1" "${@:2}"
    fi
}

# Example application workflow
main() {
    log_info "Application starting" version=$APP_VERSION
    
    # Simulate some work
    log_debug "Loading configuration" config_file="/etc/app.conf"
    
    # Simulate a warning
    log_warn "Configuration file not found, using defaults" config_file="/etc/app.conf" using_defaults=true
    
    # Simulate processing
    for i in {1..3}; do
        log_info "Processing batch" batch_number=$i total_batches=3 progress_percent=$((i * 33))
        sleep 1
    done
    
    # Simulate an error condition (uncomment to test)
    # log_error "Failed to connect to database" database="postgres" host="localhost" port=5432 timeout=30
    
    log_info "Application completed successfully" duration_seconds=5 exit_code=0
}

# Run the example
echo "=== Example Application Logging ==="
main "$@"
