#!/bin/bash

# Terminal colors
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export NC='\033[0m' # No Color

generate_junit_xml() {
    local total_tests=$1
    local failed_tests=$2
    local -n test_outputs_ref=$3
    local -n failures_ref=$4
    local output_file=$5
    local total_time=0

    local timestamp=$(date -u "+%Y-%m-%dT%H:%M:%S")
    local hostname=$(hostname)
    local system_info=$(uname -a)
    
    cat > "$output_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
    <properties>
        <property name="hostname" value="$hostname"/>
        <property name="system" value="$system_info"/>
        <property name="timestamp" value="$timestamp"/>
    </properties>
EOF

    # Group tests by suite
    declare -A suites
    # Extract unique suite names from test outputs
    declare -a suite_names
    for test_name in "${!test_outputs_ref[@]}"; do
        if [[ $test_name == *_test.sh::* ]]; then
            local suite=${test_name%%::*}
            if [[ ! " ${suite_names[@]} " =~ " ${suite} " ]]; then
                suite_names+=("$suite")
            fi
        fi
    done

    # Generate output for each test suite
    for suite in "${suite_names[@]}"; do
        local suite_tests=0
        local suite_failures=0
        local suite_time=0
        local suite_description
        case "$suite" in
            "version_test.sh") suite_description="Version Management Tests" ;;
            "log_json_test.sh") suite_description="JSON Logger Tests" ;;
            "example_test.sh") suite_description="Example Tests" ;;
            *) suite_description="$suite" ;;
        esac
        
        echo "    <testsuite name=\"$suite_description\" timestamp=\"$timestamp\">" >> "$output_file"
        
        # Find all tests for this suite
        for test_name in "${!test_outputs_ref[@]}"; do
            if [[ $test_name == $suite::* ]]; then
                ((suite_tests++))
                
                echo -n "        <testcase name=\"$test_case_name\" classname=\"$suite\" time=\"$time\"" >> "$output_file"
                
                if [ -n "$is_failure" ]; then
                    ((suite_failures++))
                    echo ">" >> "$output_file"
                    echo "            <failure message=\"Test failed\" type=\"AssertionError\"><![CDATA[$output]]></failure>" >> "$output_file"
                    echo "            <system-out><![CDATA[$output]]></system-out>" >> "$output_file"
                    echo "        </testcase>" >> "$output_file"
                else
                    echo "/>" >> "$output_file"
                fi
            fi
        done

        # Add suite-level system-out for debugging info
        echo "        <system-out><![CDATA[Test suite $suite completed with $suite_failures failures]]></system-out>" >> "$output_file"
        echo "    </testsuite>" >> "$output_file"
        total_time=$(echo "$total_time + $suite_time" | bc)
    done
    
    echo "</testsuites>" >> "$output_file"
}

print_test_summary() {
    local total_tests=$1
    local failed_tests=$2
    local -n failures_ref=$3

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
        for test_name in "${!failures_ref[@]}"; do
            echo -e "${RED}$test_name failed:${NC}"
            echo "${failures_ref[$test_name]}"
            echo "---------------"
        done
    fi
}
