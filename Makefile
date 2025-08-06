.PHONY: test install-deps clean

# Run all tests
test:
	./test/run_tests.sh

# Install test dependencies
install-deps:
	@echo "Installing dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y bats jq; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install bats-core jq; \
	else \
		echo "Please install bats and jq manually"; \
		exit 1; \
	fi

# Clean test artifacts
clean:
	rm -f test-results.xml
	rm -rf test-output/

# Check if dependencies are available
check-deps:
	@command -v bats >/dev/null 2>&1 || (echo "bats not found" && exit 1)
	@command -v jq >/dev/null 2>&1 || (echo "jq not found" && exit 1)
	@echo "All dependencies are available"

# Set up file permissions
setup:
	chmod +x bin/log_json bin/version.sh test/run_tests.sh
