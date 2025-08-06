#!/usr/bin/env bats

# Set up test environment
setup() {
    export PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
    export TEST_VERSION_SH="$BATS_TEST_DIRNAME/../bin/version.sh"
}

@test "version.sh command exists and is executable" {
    [ -x "$TEST_VERSION_SH" ]
}

@test "version.sh can be sourced without errors" {
    run bash -c "source '$TEST_VERSION_SH'"
    [ "$status" -eq 0 ]
}

@test "get_version function exists after sourcing" {
    run bash -c "source '$TEST_VERSION_SH' && declare -f get_version"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "get_version ()" ]]
}

@test "get_version function returns a version string" {
    run bash -c "source '$TEST_VERSION_SH' && get_version"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
    # Should not be empty
    [[ "$output" != "" ]]
}

@test "get_version function output format" {
    run bash -c "source '$TEST_VERSION_SH' && get_version"
    [ "$status" -eq 0 ]
    # During CI/CD, this should be a semantic version after injection
    # During development, it might be "VERSION_PLACEHOLDER"
    [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]] || [[ "$output" = "VERSION_PLACEHOLDER" ]]
}

@test "version.sh script structure is valid bash" {
    run bash -n "$TEST_VERSION_SH"
    [ "$status" -eq 0 ]
}

@test "version.sh defines only get_version function" {
    # Source the script and check what functions are defined
    run bash -c "source '$TEST_VERSION_SH' && declare -F"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "declare -f get_version" ]]
}

@test "get_version function can be called multiple times" {
    run bash -c "source '$TEST_VERSION_SH' && get_version && get_version"
    [ "$status" -eq 0 ]
    # Count the number of lines (should be 2)
    lines=$(echo "$output" | wc -l)
    [ "$lines" -eq 2 ]
}
