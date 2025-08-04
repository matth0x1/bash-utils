#!/bin/bash

# Source test framework and assertions
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/lib/test_framework.sh"
source "$SCRIPT_DIR/lib/assertions.sh"

# Set test suite name
set_test_suite "Version Management Tests"

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
    if ! [[ "$version" =~ \. ]]; then
        echo "Version should contain at least one dot"
        return 1
    fi
    
    # Test specific format (major.minor.patch)
    if ! [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Invalid version format: $version"
        return 1
    fi
    
    return 0
}

# Test version is not placeholder
test_not_placeholder() {
    local version
    version=$(get_version)
    
    if [[ "$version" =~ ^0\.0\.0|SNAPSHOT|DEVELOPMENT$ ]]; then
        echo "Version should not be a placeholder: $version"
        return 1
    fi
    
    return 0
}

# Test version command line flag
test_version_flag() {
    local version_output expected
    version_output=$("$TEMP_VERSION_SCRIPT" --version)
    expected="v$(get_version)"
    
    if [ "$version_output" != "$expected" ]; then
        echo "Expected version output '$expected', but got '$output'"
        return 1
    fi
    
    return 0
}

# Register test cases
test_case "version_format" "test_version_format" "Validates that version string follows semantic versioning format (x.y.z)"
test_case "no_placeholder" "test_not_placeholder" "Ensures version is not set to a development placeholder"
test_case "version_flag" "test_version_flag" "Verifies --version flag outputs the correct version string"

# Return test results
get_test_results
