#!/usr/bin/env bash
# Godmode — Post-install verification for Gemini CLI
# Usage: bash adapters/gemini/verify.sh [target-dir]
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
printf "${BOLD}Godmode Verification — Gemini CLI${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Target:  %s\n" "$TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# Check 1: Symlinks and copies are valid
# ---------------------------------------------------------------------------

# GEMINI.md should exist (symlink or copy)
verify_symlink "$TARGET_DIR/GEMINI.md" "GEMINI.md present"

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
# Check 3: Check agent definitions (expect >= 7)
# ---------------------------------------------------------------------------

count_agents "$TARGET_DIR/agents" "*.md" 7 "Agents count"

# ---------------------------------------------------------------------------
# Check 4: Validate platform config
# ---------------------------------------------------------------------------

validate_yaml_basic "$TARGET_DIR/.godmode/config.yaml" "Godmode config.yaml valid"

# ---------------------------------------------------------------------------
# Check 5: Validate GEMINI.md is readable and non-empty
# ---------------------------------------------------------------------------

if [ -f "$TARGET_DIR/GEMINI.md" ] && [ -s "$TARGET_DIR/GEMINI.md" ]; then
    check_pass "GEMINI.md content" "file is non-empty and readable"
else
    check_fail "GEMINI.md content" "file is missing or empty"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print_summary "Gemini CLI"
exit $?
