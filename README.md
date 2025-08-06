# bash-utils

Reusable Bash utilities, installable via GitHub releases.

## 🔧 Install

```bash
LATEST=$(curl -s https://api.github.com/repos/matth0x1/bash-utils/releases/latest | jq -r .tag_name)
curl -L -o /usr/local/bin/log_json https://github.com/matth0x1/bash-utils/releases/download/$LATEST/log_json
chmod +x /usr/local/bin/log_json
```

## 🚀 Usage

```bash
log_json info "Starting process"
log_json error "Something went wrong"
log_json --version
```

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
