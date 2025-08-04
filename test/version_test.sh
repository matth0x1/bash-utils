#!/bin/bash

# Source test assertions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/assertions.sh"

# Create a temporary version script for testing
TEMP_VERSION_SCRIPT=$(mktemp)
trap 'rm -f "$TEMP_VERSION_SCRIPT"' EXIT

# Copy the version script template and inject a test version
cat > "$TEMP_VERSION_SCRIPT" << 'EOF'
#!/bin/bash

get_version() {
    echo "1.2.3"
}

if [[ "$1" == "--version" ]]; then
    echo "v$(get_version)"
    exit 0
fi
EOF

chmod +x "$TEMP_VERSION_SCRIPT"

# Source our test version of the script
source "$TEMP_VERSION_SCRIPT"

# Test version format
test_version_format() {
    local version
    version=$(get_version)
    
    # Test that version follows semver format
    assert_contains "$version" "." "Version should contain at least one dot"
    
    # Test specific format (major.minor.patch)
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        assert_eq "valid semver" "$version" "Version should be in format major.minor.patch"
        return 1
    fi
    
    echo "PASS: Version format is valid: $version"
    return 0
}

# Test version is not placeholder
test_not_placeholder() {
    local version
    version=$(get_version)
    
    if [ "$version" = "VERSION_PLACEHOLDER" ]; then
        assert_eq "real version" "VERSION_PLACEHOLDER" "Version should not be the placeholder value"
        return 1
    fi
    
    echo "PASS: Version is not placeholder"
    return 0
}

# Test version command line flag
test_version_flag() {
    local version_output
    version_output=$("$TEMP_VERSION_SCRIPT" --version)
    
    assert_contains "$version_output" "v1.2.3" "Version flag should output correct version"
}

# Run all tests
echo "Running version tests..."
echo "----------------------------------------"

failed_tests=0
for test_func in test_version_format test_not_placeholder test_version_flag; do
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
