#!/usr/bin/env bash
# Godmode — Post-install verification for Codex (OpenAI)
# Usage: bash adapters/codex/verify.sh [target-dir]
# Defaults to current directory if no target is specified.

set -uo pipefail

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

# Source shared helpers
source "$GODMODE_ROOT/adapters/shared/verify-common.sh"

echo ""
printf "${BOLD}Godmode Verification — Codex${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Target:  %s\n" "$TARGET_DIR"
echo ""

CODEX_DIR="$TARGET_DIR/.codex"

# ---------------------------------------------------------------------------
# Check 1: Symlinks and copies are valid
# ---------------------------------------------------------------------------

# AGENTS.md should exist at target root
verify_file_exists "$TARGET_DIR/AGENTS.md" "AGENTS.md present"

# .codex/ directory with config
verify_dir_exists "$CODEX_DIR" ".codex/ directory exists"
verify_file_exists "$CODEX_DIR/config.toml" ".codex/config.toml present"
verify_dir_exists "$CODEX_DIR/agents" ".codex/agents/ directory exists"

# skills/, agents/, commands/ should be accessible
verify_symlink "$TARGET_DIR/skills" "skills/ directory linked"
verify_symlink "$TARGET_DIR/agents" "agents/ directory linked"
verify_symlink "$TARGET_DIR/commands" "commands/ directory linked"

# .godmode/ directory
verify_dir_exists "$TARGET_DIR/.godmode" ".godmode/ directory exists"

# ---------------------------------------------------------------------------
# Check 2: Count skills (expect 126)
# ---------------------------------------------------------------------------

count_skills "$TARGET_DIR/skills" 126

# ---------------------------------------------------------------------------
# Check 3: Check agent definitions (expect >= 7 in both locations)
# ---------------------------------------------------------------------------

count_agents "$TARGET_DIR/agents" "*.md" 7 "Agents count (agents/*.md)"
count_agents "$CODEX_DIR/agents" "*.toml" 7 "Codex agents count (.codex/agents/*.toml)"

# ---------------------------------------------------------------------------
# Check 4: Validate platform configs
# ---------------------------------------------------------------------------

validate_yaml_basic "$TARGET_DIR/.godmode/config.yaml" "Godmode config.yaml valid"
validate_toml_basic "$CODEX_DIR/config.toml" "Codex config.toml valid"

# ---------------------------------------------------------------------------
# Check 5: Validate AGENTS.md is readable and non-empty
# ---------------------------------------------------------------------------

if [ -f "$TARGET_DIR/AGENTS.md" ] && [ -s "$TARGET_DIR/AGENTS.md" ]; then
    check_pass "AGENTS.md content" "file is non-empty and readable"
else
    check_fail "AGENTS.md content" "file is missing or empty"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print_summary "Codex"
exit $?
