#!/bin/bash

# Run all tests
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/test_reporter.sh"
source "$SCRIPT_DIR/lib/test_framework.sh"

run_test_suite() {
    declare -A failures
    declare -A test_outputs
    total_test_files=0
    total_test_cases=0
    failed_test_cases=0
    skip_version_tests=false

    # Parse command line arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --skip-version-tests) skip_version_tests=true ;;
            *) echo "Unknown parameter: $1"; exit 1 ;;
        esac
        shift
    done

    # Make scripts executable
    chmod +x "$SCRIPT_DIR"/*.sh

    echo "Starting test suite..."
    echo "===================="

for test in "$SCRIPT_DIR"/*_test.sh; do
    test_name=$(basename "$test")
    
    # Skip version tests if requested
    if [ "$skip_version_tests" = true ] && [ "$test_name" = "version_test.sh" ]; then
        continue
    fi
    
    ((total_test_files++))
    echo -n "Running $test_name... "
    
    # Run the test file and capture its test results
    test_output=$("$test" 2>&1)
    test_status=$?
    line_num=1
    file_test_count=0
    file_failures=0
    test_names=()
    test_results=()
    test_case_outputs=()

    # Read test results from the output
    # Format: test_count, failures, test_names, test_results, test_outputs
    if [ $test_status -eq 0 ]; then
        # Parse the test results
        while IFS= read -r line; do
            case $((line_num++)) in
                1) local file_test_count=$line
                   ((total_test_cases+=file_test_count)) ;;
                2) local file_failures=$line
                   ((failed_test_cases+=file_failures)) ;;
                3) IFS=',' read -r -a test_names <<< "$line" ;;
                4) IFS=',' read -r -a test_results <<< "$line" ;;
                5) IFS=',' read -r -a test_case_outputs <<< "$line" ;;
            esac
        done <<< "$test_output"

        # Store results for each test case
        for i in "${!test_names[@]}"; do
            local full_test_name="${test_name}::${test_names[i]}"
            if [ "${test_results[i]}" = "1" ]; then
                failures["$full_test_name"]="${test_case_outputs[i]}"
            fi
            test_outputs["$full_test_name"]="${test_case_outputs[i]}"
        done

        if [ "$file_failures" -eq 0 ]; then
            echo -e "${GREEN}PASS${NC} ($file_test_count tests)"
        else
            echo -e "${RED}FAIL${NC} ($file_failures/$file_test_count failed)"
        fi
    else
        echo -e "${RED}FAIL${NC} (test file error)"
        failures["$test_name"]="$test_output"
        test_outputs["$test_name"]="$test_output"
        ((failed_test_cases++))
    fi
done

    # Print test summary
    print_test_summary "$total_test_cases" "$failed_test_cases" failures

    # Generate JUnit XML report with all collected information
    generate_junit_xml "$total_test_cases" "$failed_test_cases" test_outputs failures "test-results.xml" test_times test_descriptions    return $failed_test_cases
}

# Run the test suite and exit with its status
run_test_suite "$@"
exit $?
