#!/usr/bin/env bash
# Godmode — Post-install verification for OpenCode
# Usage: bash adapters/opencode/verify.sh [target-dir]
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
printf "${BOLD}Godmode Verification — OpenCode${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Target:  %s\n" "$TARGET_DIR"
echo ""

# OpenCode installs into .opencode/plugins/godmode/
PLUGIN_DIR="$TARGET_DIR/.opencode/plugins/godmode"

# ---------------------------------------------------------------------------
# Check 1: Symlinks and copies are valid
# ---------------------------------------------------------------------------

# AGENTS.md should exist at target root
verify_file_exists "$TARGET_DIR/AGENTS.md" "AGENTS.md present"

# Plugin directory structure
verify_dir_exists "$PLUGIN_DIR" "Plugin directory exists"

# skills/, agents/, commands/ symlinked inside plugin dir
verify_symlink "$PLUGIN_DIR/skills" "skills/ directory linked (plugin)"
verify_symlink "$PLUGIN_DIR/agents" "agents/ directory linked (plugin)"
verify_symlink "$PLUGIN_DIR/commands" "commands/ directory linked (plugin)"

# .godmode/ directory
verify_dir_exists "$TARGET_DIR/.godmode" ".godmode/ directory exists"

# ---------------------------------------------------------------------------
# Check 2: Count skills (expect 126)
# ---------------------------------------------------------------------------

count_skills "$PLUGIN_DIR/skills" 126

# ---------------------------------------------------------------------------
# Check 3: Check agent definitions (expect >= 7)
# ---------------------------------------------------------------------------

count_agents "$PLUGIN_DIR/agents" "*.md" 7 "Agents count"

# ---------------------------------------------------------------------------
# Check 4: Validate platform configs
# ---------------------------------------------------------------------------

validate_yaml_basic "$TARGET_DIR/.godmode/config.yaml" "Godmode config.yaml valid"
validate_json_basic "$PLUGIN_DIR/plugin.json" "OpenCode plugin.json valid"

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

print_summary "OpenCode"
exit $?
