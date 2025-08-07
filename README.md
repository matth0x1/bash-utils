# bash-utils

Reusable Bash utilities, installable via GitHub releases.

## 🔧 Install

```bash
curl -L -o /usr/local/bin/log_json https://github.com/matth0x1/bash-utils/releases/download/latest/log_json
chmod +x /usr/local/bin/log_json
```

## 🚀 Usage

### Basic Usage

```bash
log_json INFO "Starting process"
log_json ERROR "Something went wrong"
log_json --version
```

### Advanced Features

**Add custom fields:**
```bash
log_json ERROR "Database connection failed" service=api database=postgres timeout=30.5
# Output: {"timestamp":"2025-08-06T12:00:00.000+00:00","level":"ERROR","message":"Database connection failed","service":"api","database":"postgres","timeout":30.5}
```

**Include system information:**
```bash
log_json --pid --hostname --user INFO "System event occurred"
# Output: {"timestamp":"2025-08-06T12:00:00.000+00:00","level":"INFO","message":"System event occurred","pid":12345,"hostname":"myserver","user":"admin"}
```

**Add context information:**
```bash
log_json --context "user-authentication" INFO "Login successful" user_id=12345 ip_address=127.0.0.1
# Output: {"timestamp":"2025-08-06T12:00:00.000+00:00","level":"INFO","message":"Login successful","context":"user-authentication","user_id":12345,"ip_address":"127.0.0.1"}
```

**Data type handling:**
- Numbers (integers and floats) are automatically detected: `count=42`, `rate=3.14`
- Booleans are automatically detected: `enabled=true`, `debug=false`
- All other values are treated as strings

**Get help:**
```bash
log_json --help  # or -h
```

### Supported Log Levels
- `DEBUG` - Detailed information for debugging
- `INFO` - General information messages
- `WARN` or `WARNING` - Warning messages
- `ERROR` - Error messages
- `FATAL` - Fatal error messages

Custom log levels are supported but will generate a warning.

## 🧰 Requirements

- `jq` installed

## 🧪 Testing

This project uses [bats](https://github.com/bats-core/bats-core) for testing the shell scripts.

### Prerequisites

Install bats and jq:
```bash
# Ubuntu/Debian
sudo apt-get install bats jq

# macOS with Homebrew
brew install bats-core jq
```

### Running Tests

Run all tests:
```bash
./test/run_tests.sh
# or using make
make test
```

Run individual test files:
```bash
bats test/log_json_test.bats
bats test/version_test.bats
```

### Development Setup

Install dependencies and set up permissions:
```bash
make install-deps
make setup
```

Check if dependencies are installed:
```bash
make check-deps
```

Test results are output in JUnit XML format to `test-results.xml` for CI/CD integration.

### Test Coverage

The test suite covers:
- **log_json**: JSON output validation, error handling, special characters, timestamp format, version flag
- **version.sh**: Function existence, execution, output format validation
