#!/bin/bash

# Basic equality assertion
assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" != "$actual" ]; then
        echo "FAIL: $message"
        echo "Expected: $expected"
        echo "Actual  : $actual"
        return 1
    fi
    echo "PASS: $message"
    return 0
}

# JSON equality assertion with normalization
assert_json_eq() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    # Normalize both JSONs using jq
    local normalized_expected
    local normalized_actual
    normalized_expected=$(echo "$expected" | jq -c '.')
    normalized_actual=$(echo "$actual" | jq -c '.')
    
    assert_eq "$normalized_expected" "$normalized_actual" "$message"
    return $?
}

# String contains assertion
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        echo "FAIL: $message"
        echo "Expected to find: $needle"
        echo "In: $haystack"
        return 1
    fi
    echo "PASS: $message"
    return 0
}
