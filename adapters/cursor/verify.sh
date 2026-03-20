#!/usr/bin/env bash
# Godmode — Post-install verification for Cursor
# Usage: bash adapters/cursor/verify.sh [target-dir]
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
printf "${BOLD}Godmode Verification — Cursor${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Target:  %s\n" "$TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# Check 1: Symlinks and copies are valid
# ---------------------------------------------------------------------------

# .cursorrules should exist
verify_file_exists "$TARGET_DIR/.cursorrules" ".cursorrules present"

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
# Check 5: Validate .cursorrules is readable and non-empty
# ---------------------------------------------------------------------------

if [ -f "$TARGET_DIR/.cursorrules" ] && [ -s "$TARGET_DIR/.cursorrules" ]; then
    # Check that it contains godmode-related content
    if grep -qi "godmode\|skill\|agent" "$TARGET_DIR/.cursorrules" 2>/dev/null; then
        check_pass ".cursorrules content" "file is non-empty and contains godmode configuration"
    else
        check_fail ".cursorrules content" "file exists but does not appear to contain godmode configuration"
    fi
else
    check_fail ".cursorrules content" "file is missing or empty"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print_summary "Cursor"
exit $?
