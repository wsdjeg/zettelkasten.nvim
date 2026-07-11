.PHONY: test clean install-deps install-luaunit help

# Default target
help:
	@echo "Available targets:"
	@echo "  test            - Run all tests (or specific tests with PATTERN=...)"
	@echo "  clean           - Clean test cache files"
	@echo "  install-deps    - Download all test dependencies"
	@echo "  install-luaunit - Download luaunit test framework"
	@echo ""
	@echo "Examples:"
	@echo "  make test                               # Run all tests"
	@echo "  make test PATTERN=formatter             # Match test/**/*formatter*_spec.lua"
	@echo "  make test PATTERN=test/zettelkasten/config_spec.lua  # Full path"

# Install all test dependencies (cross-platform, uses Lua)
# Use -u NONE to avoid loading user config which may pollute project directory
install-deps:
	@nvim --headless -u NONE -c "lua dofile('test/install_deps.lua')" -c "qa!"

# Alias for individual dependency install
install-luaunit: install-deps

# Run tests with nvim headless
# Supports PATTERN parameter to run specific test file(s)
# Examples:
#   make test PATTERN=test/zettelkasten/config_spec.lua
#   make test PATTERN=config  (shorthand for test/**/*config*_spec.lua)
test: install-deps
	@echo "Running tests with nvim --headless..."
	@nvim --headless -u test/minimal_init.lua \
		-c "lua _G.TEST_PATTERN = '$(PATTERN)'" \
		-c "lua dofile('test/run.lua')" \
		-c "qa!"

# Clean generated files
clean:
	@echo "Cleaning up..."
	@rm -rf test/*.lua~
	@rm -rf test/*.out
	@rm -rf *.swp
	@rm -rf /tmp/zettelkasten_nvim_test_* 2>/dev/null || true

