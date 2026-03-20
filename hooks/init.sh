#!/usr/bin/env bash
# Godmode Platform-Agnostic Initialization Script
# Can be called from ANY AI coding platform's session start mechanism.
# Performs stack detection, .godmode/ creation, config.yaml generation,
# and detects the calling platform to print tailored guidance.

set -euo pipefail

GODMODE_DIR=".godmode"
CONFIG_FILE="${GODMODE_DIR}/config.yaml"

# ---------------------------------------------------------------------------
# 1. Platform detection
# ---------------------------------------------------------------------------
PLATFORM=""
PLATFORM_MODE=""

if [ -f "GEMINI.md" ]; then
    PLATFORM="Gemini CLI"
    PLATFORM_MODE="sequential mode"
elif [ -f ".cursorrules" ]; then
    PLATFORM="Cursor"
    PLATFORM_MODE=""
elif [ -d ".codex" ]; then
    PLATFORM="Codex"
    PLATFORM_MODE="batch mode"
elif [ -d ".opencode" ]; then
    PLATFORM="OpenCode"
    PLATFORM_MODE="sequential mode"
else
    PLATFORM="Claude Code"
    PLATFORM_MODE="full parallel support"
fi

if [ -n "$PLATFORM_MODE" ]; then
    PLATFORM_LABEL="${PLATFORM} (${PLATFORM_MODE})"
else
    PLATFORM_LABEL="${PLATFORM}"
fi

echo "Platform: ${PLATFORM_LABEL}"

# ---------------------------------------------------------------------------
# 2. Create .godmode directory if it doesn't exist
# ---------------------------------------------------------------------------
if [ ! -d "$GODMODE_DIR" ]; then
    mkdir -p "$GODMODE_DIR"
fi

# ---------------------------------------------------------------------------
# 3. Detect project type and generate config if none exists
# ---------------------------------------------------------------------------
if [ ! -f "$CONFIG_FILE" ]; then
    PROJECT_NAME=$(basename "$(pwd)")
    LANGUAGE="unknown"
    TEST_CMD=""
    LINT_CMD=""

    # Detect language and tools
    if [ -f "package.json" ]; then
        LANGUAGE="javascript"
        if grep -q '"typescript"' package.json 2>/dev/null || [ -f "tsconfig.json" ]; then
            LANGUAGE="typescript"
        fi
        if grep -q '"test"' package.json 2>/dev/null; then
            TEST_CMD="npm test"
        fi
        if grep -q '"lint"' package.json 2>/dev/null; then
            LINT_CMD="npm run lint"
        fi
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        LANGUAGE="python"
        if command -v pytest &>/dev/null; then
            TEST_CMD="pytest"
        fi
        if command -v ruff &>/dev/null; then
            LINT_CMD="ruff check ."
        elif command -v flake8 &>/dev/null; then
            LINT_CMD="flake8"
        fi
    elif [ -f "Cargo.toml" ]; then
        LANGUAGE="rust"
        TEST_CMD="cargo test"
        LINT_CMD="cargo clippy"
    elif [ -f "go.mod" ]; then
        LANGUAGE="go"
        TEST_CMD="go test ./..."
        LINT_CMD="golangci-lint run"
    elif [ -f "Gemfile" ]; then
        LANGUAGE="ruby"
        TEST_CMD="bundle exec rspec"
        LINT_CMD="bundle exec rubocop"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
        LANGUAGE="java"
        if [ -f "pom.xml" ]; then
            TEST_CMD="mvn test"
        else
            TEST_CMD="./gradlew test"
        fi
    fi

    # Write initial config
    cat > "$CONFIG_FILE" << YAML
# Godmode Configuration
# Generated automatically. Edit as needed.
# Run /godmode:setup for interactive configuration.

project:
  name: "${PROJECT_NAME}"
  language: "${LANGUAGE}"

commands:
  test: "${TEST_CMD}"
  lint: "${LINT_CMD}"

# Optimization config (set via /godmode:setup --optimize)
# optimization:
#   goal: ""
#   metric: ""
#   verify: ""
#   target: ""
#   max_iterations: 25

scope:
  include:
    - "src/"
    - "lib/"
    - "tests/"
  exclude:
    - "node_modules/"
    - "dist/"
    - "build/"
    - ".git/"
    - "vendor/"
    - "__pycache__/"
    - "target/"
YAML

    echo "Godmode initialized for ${PROJECT_NAME} (${LANGUAGE})"
    echo "Config: ${CONFIG_FILE}"
else
    echo "Godmode ready. Config: ${CONFIG_FILE}"
fi

# ---------------------------------------------------------------------------
# 4. Ensure results/log files exist
# ---------------------------------------------------------------------------
touch "${GODMODE_DIR}/optimize-results.tsv" 2>/dev/null || true
touch "${GODMODE_DIR}/fix-log.tsv" 2>/dev/null || true
touch "${GODMODE_DIR}/ship-log.tsv" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 5. Platform-specific next-step suggestion
# ---------------------------------------------------------------------------
case "$PLATFORM" in
    "Gemini CLI")
        echo "Next step: run skills sequentially -- start with /godmode:setup to configure your project."
        ;;
    "Cursor")
        echo "Next step: open .godmode/config.yaml in the editor and run /godmode:setup from the chat panel."
        ;;
    "Codex")
        echo "Next step: queue a batch run -- e.g. /godmode:optimize to kick off an optimization loop."
        ;;
    "OpenCode")
        echo "Next step: run /godmode:setup to walk through configuration one step at a time."
        ;;
    "Claude Code")
        echo "Next step: run /godmode:setup for interactive configuration, or jump straight to /godmode:optimize."
        ;;
esac
