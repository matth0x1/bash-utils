#!/bin/bash

# Arrays to store test results
declare -a _TEST_RESULTS=()
declare -a _TEST_NAMES=()
declare -a _TEST_OUTPUTS=()
declare -a _TEST_TIMES=()
declare -a _TEST_DESCRIPTIONS=()

# Initialize test counters
_TEST_COUNT=0
_TEST_FAILURES=0
_TEST_SUITE=""

# Function to set test suite name
set_test_suite() {
    _TEST_SUITE="$1"
}
export -f set_test_suite

# Function to run a test case
test_case() {
    local name="$1"
    local test_function="$2"
    local description="${3:-$name}"
    
    ((_TEST_COUNT++))
    _TEST_NAMES+=("$name")
    _TEST_DESCRIPTIONS+=("$description")
    
    # Capture start time in nanoseconds
    local start_time
    start_time=$(date +%s.%N)
    
    # Capture output and run test
    local output
    output=$($test_function 2>&1)
    local status=$?
    
    # Calculate execution time
    local end_time
    end_time=$(date +%s.%N)
    local execution_time
    execution_time=$(echo "$end_time - $start_time" | bc)
    _TEST_TIMES+=("$execution_time")
    
    _TEST_OUTPUTS+=("$output")
    if [ $status -eq 0 ]; then
        _TEST_RESULTS+=(0)  # 0 means pass
    else
        _TEST_RESULTS+=(1)  # 1 means fail
        ((_TEST_FAILURES++))
    fi
}
export -f test_case

# Function to get test results
get_test_results() {
    # Print results to stdout in a format that can be parsed:
    # test_count failures suite_name test_names test_results test_outputs test_times test_descriptions
    local IFS=$'\n'
    cat << EOT
$_TEST_COUNT
$_TEST_FAILURES
$_TEST_SUITE
${_TEST_NAMES[*]}
${_TEST_RESULTS[*]}
${_TEST_OUTPUTS[*]}
${_TEST_TIMES[*]}
${_TEST_DESCRIPTIONS[*]}
EOT
}
export -f get_test_results

# Export variables
export _TEST_RESULTS _TEST_NAMES _TEST_OUTPUTS _TEST_TIMES _TEST_DESCRIPTIONS _TEST_COUNT _TEST_FAILURES _TEST_SUITE
