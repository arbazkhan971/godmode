#!/usr/bin/env bash
# Godmode Installer for Amp (Sourcegraph)
# Usage: bash install.sh [target-dir]
# Defaults to current directory if no target is specified.
# Idempotent — safe to re-run.
# Amp reads root AGENTS.md and .agents/skills/ natively; this installer wires
# both and never clobbers user-authored files.

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

if [ ! -f "$GODMODE_ROOT/AGENTS.md" ]; then
    echo "Error: cannot find AGENTS.md in $GODMODE_ROOT"
    echo "Make sure you are running this script from the godmode repository."
    exit 1
fi

if [ ! -d "$GODMODE_ROOT/skills" ]; then
    echo "Error: cannot find skills/ directory in $GODMODE_ROOT"
    echo "Make sure you are running this script from the godmode repository."
    exit 1
fi

if [ ! -d "$GODMODE_ROOT/agents" ]; then
    echo "Error: cannot find agents/ directory in $GODMODE_ROOT"
    echo "Make sure you are running this script from the godmode repository."
    exit 1
fi

echo "Godmode installer for Amp"
echo "  Source:  $GODMODE_ROOT"
echo "  Target:  $TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. AGENTS.md (never clobber a user-authored file)
# ---------------------------------------------------------------------------

if [ -f "$TARGET_DIR/AGENTS.md" ]; then
    if cmp -s "$GODMODE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md"; then
        echo "[skip] AGENTS.md already up to date"
    else
        cp "$GODMODE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.godmode.md"
        echo "[skip] AGENTS.md exists (user-authored) — godmode copy written to AGENTS.godmode.md; merge it into your AGENTS.md to activate godmode instructions"
    fi
else
    cp "$GODMODE_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md"
    echo "[done] Copied AGENTS.md"
fi

# ---------------------------------------------------------------------------
# 2. Symlink skills and agents into target root (if not present)
# ---------------------------------------------------------------------------

for dir in skills agents; do
    LINK_PATH="$TARGET_DIR/$dir"
    SOURCE_PATH="$GODMODE_ROOT/$dir"
    if [ -L "$LINK_PATH" ]; then
        CURRENT_TARGET="$(readlink "$LINK_PATH")"
        if [ "$CURRENT_TARGET" = "$SOURCE_PATH" ]; then
            echo "[skip] $dir/ symlink already exists"
        else
            echo "[skip] $dir/ symlink already exists (points to $CURRENT_TARGET — remove manually to re-link)"
        fi
    elif [ -d "$LINK_PATH" ]; then
        echo "[skip] $dir/ directory already exists (not a symlink — remove manually to re-link)"
    else
        ln -s "$SOURCE_PATH" "$LINK_PATH"
        echo "[done] Symlinked $dir/ -> $SOURCE_PATH"
    fi
done

# ---------------------------------------------------------------------------
# 3. Wire .agents/skills (Amp project skills dir)
# ---------------------------------------------------------------------------

AMP_AGENTS_DIR="$TARGET_DIR/.agents"
AMP_SKILLS_LINK="$AMP_AGENTS_DIR/skills"

mkdir -p "$AMP_AGENTS_DIR"

if [ -L "$AMP_SKILLS_LINK" ]; then
    CURRENT_TARGET="$(readlink "$AMP_SKILLS_LINK")"
    if [ "$CURRENT_TARGET" = "$GODMODE_ROOT/skills" ]; then
        echo "[skip] .agents/skills symlink already exists"
    else
        echo "[skip] .agents/skills symlink already exists (points to $CURRENT_TARGET — remove manually to re-link)"
    fi
elif [ -d "$AMP_SKILLS_LINK" ]; then
    echo "[skip] .agents/skills directory already exists (user-owned — merge manually or remove to re-link)"
else
    ln -s "$GODMODE_ROOT/skills" "$AMP_SKILLS_LINK"
    echo "[done] Wired .agents/skills -> godmode skills (Amp project skills dir)"
fi

# ---------------------------------------------------------------------------
# 4. Create .godmode/ with config.yaml (stack auto-detection)
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
# Summary
# ---------------------------------------------------------------------------

echo ""
echo "Godmode installed successfully for Amp."
echo ""
echo "  135 skills wired via .agents/skills/ (Amp project skills dir)"
echo "  Godmode instructions in AGENTS.md (or AGENTS.godmode.md if you kept your own)"
echo "  skills/ and agents/ symlinks at the root keep the target in sync with this clone"
echo ""
echo "  Config:  $CONFIG_FILE"
echo "  Skills:  $AMP_SKILLS_LINK"
echo ""
echo "Verify (run from the godmode repo):"
echo "  bash adapters/amp/verify.sh \"$TARGET_DIR\""
echo ""
echo "Note: Amp reads .agents/skills/ and root AGENTS.md natively; symlinks keep"
echo "skills in sync with this clone. For a committable install, replace the"
echo ".agents/skills symlink with a copy:"
echo '  cp -rL "$(readlink -f .agents/skills)" .agents/skills.real && rm .agents/skills && mv .agents/skills.real .agents/skills'
