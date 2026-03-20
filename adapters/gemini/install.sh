#!/usr/bin/env bash
# Godmode Installer for Gemini CLI
# Usage: bash install.sh [target-dir]
# Defaults to current directory if no target is specified.
# Idempotent — safe to re-run.

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODMODE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo "Error: target directory '${1:-.}' does not exist."
    exit 1
}

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

if [ ! -f "$GODMODE_ROOT/GEMINI.md" ]; then
    echo "Error: cannot find GEMINI.md in $GODMODE_ROOT"
    echo "Make sure you are running this script from the godmode repository."
    exit 1
fi

if [ ! -d "$GODMODE_ROOT/skills" ]; then
    echo "Error: cannot find skills/ directory in $GODMODE_ROOT"
    exit 1
fi

echo "Godmode installer for Gemini CLI"
echo "  Source:  $GODMODE_ROOT"
echo "  Target:  $TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Symlink GEMINI.md
# ---------------------------------------------------------------------------

if [ -L "$TARGET_DIR/GEMINI.md" ]; then
    EXISTING_LINK="$(readlink "$TARGET_DIR/GEMINI.md")"
    if [ "$EXISTING_LINK" = "$GODMODE_ROOT/GEMINI.md" ]; then
        echo "[skip] GEMINI.md already symlinked to godmode"
    else
        echo "[skip] GEMINI.md exists as symlink to $EXISTING_LINK — remove and re-run to update"
    fi
elif [ -f "$TARGET_DIR/GEMINI.md" ]; then
    echo "[skip] GEMINI.md already exists (not a symlink — remove manually to re-link)"
else
    ln -s "$GODMODE_ROOT/GEMINI.md" "$TARGET_DIR/GEMINI.md"
    echo "[done] Symlinked GEMINI.md -> $GODMODE_ROOT/GEMINI.md"
fi

# ---------------------------------------------------------------------------
# 2. Create .godmode/ with config.yaml (stack auto-detection)
# ---------------------------------------------------------------------------

GODMODE_DIR="$TARGET_DIR/.godmode"
CONFIG_FILE="$GODMODE_DIR/config.yaml"

mkdir -p "$GODMODE_DIR"

if [ -f "$CONFIG_FILE" ]; then
    echo "[skip] .godmode/config.yaml already exists"
else
    PROJECT_NAME="$(basename "$TARGET_DIR")"
    LANGUAGE="unknown"
    TEST_CMD=""
    LINT_CMD=""

    # Detect language and tooling
    if [ -f "$TARGET_DIR/package.json" ]; then
        LANGUAGE="javascript"
        if grep -q '"typescript"' "$TARGET_DIR/package.json" 2>/dev/null || [ -f "$TARGET_DIR/tsconfig.json" ]; then
            LANGUAGE="typescript"
        fi
        if grep -q '"test"' "$TARGET_DIR/package.json" 2>/dev/null; then
            TEST_CMD="npm test"
        fi
        if grep -q '"lint"' "$TARGET_DIR/package.json" 2>/dev/null; then
            LINT_CMD="npm run lint"
        fi
    elif [ -f "$TARGET_DIR/pyproject.toml" ] || [ -f "$TARGET_DIR/setup.py" ] || [ -f "$TARGET_DIR/requirements.txt" ]; then
        LANGUAGE="python"
        if command -v pytest &>/dev/null; then
            TEST_CMD="pytest"
        fi
        if command -v ruff &>/dev/null; then
            LINT_CMD="ruff check ."
        elif command -v flake8 &>/dev/null; then
            LINT_CMD="flake8"
        fi
    elif [ -f "$TARGET_DIR/Cargo.toml" ]; then
        LANGUAGE="rust"
        TEST_CMD="cargo test"
        LINT_CMD="cargo clippy"
    elif [ -f "$TARGET_DIR/go.mod" ]; then
        LANGUAGE="go"
        TEST_CMD="go test ./..."
        LINT_CMD="golangci-lint run"
    elif [ -f "$TARGET_DIR/Gemfile" ]; then
        LANGUAGE="ruby"
        TEST_CMD="bundle exec rspec"
        LINT_CMD="bundle exec rubocop"
    elif [ -f "$TARGET_DIR/pom.xml" ] || [ -f "$TARGET_DIR/build.gradle" ] || [ -f "$TARGET_DIR/build.gradle.kts" ]; then
        LANGUAGE="java"
        if [ -f "$TARGET_DIR/pom.xml" ]; then
            TEST_CMD="mvn test"
        else
            TEST_CMD="./gradlew test"
        fi
    fi

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

    echo "[done] Created .godmode/config.yaml (detected: ${LANGUAGE})"
fi

# Ensure tracking files exist
touch "$GODMODE_DIR/optimize-results.tsv" 2>/dev/null || true
touch "$GODMODE_DIR/fix-log.tsv" 2>/dev/null || true
touch "$GODMODE_DIR/ship-log.tsv" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 3. Symlink skills, agents, and commands (if not already present)
# ---------------------------------------------------------------------------

for dir in skills agents commands; do
    LINK_PATH="$TARGET_DIR/$dir"
    SOURCE_PATH="$GODMODE_ROOT/$dir"
    if [ ! -d "$SOURCE_PATH" ]; then
        continue
    fi
    if [ -L "$LINK_PATH" ]; then
        echo "[skip] $dir/ symlink already exists"
    elif [ -d "$LINK_PATH" ]; then
        echo "[skip] $dir/ directory already exists (not a symlink — remove manually to re-link)"
    else
        ln -s "$SOURCE_PATH" "$LINK_PATH"
        echo "[done] Symlinked $dir/ -> $SOURCE_PATH"
    fi
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Godmode installed successfully for Gemini CLI."
echo ""
echo "  126 skills available via /godmode:skillname"
echo "  7 subagents available via agents/"
echo ""
echo "  Config:  $CONFIG_FILE"
echo "  Gemini:  $TARGET_DIR/GEMINI.md"
echo ""
echo "Get started:"
echo "  /godmode              # auto-detect phase and route"
echo "  /godmode:setup        # configure project settings"
echo "  /godmode:optimize     # autonomous performance iteration"
echo "  /godmode:build        # TDD build workflow"
