#!/usr/bin/env bash
# Godmode — Post-install verification for Amp (Sourcegraph)
# Usage: bash adapters/amp/verify.sh [target-dir]
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
printf "${BOLD}Godmode Verification — Amp${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Target:  %s\n" "$TARGET_DIR"
echo ""

# ---------------------------------------------------------------------------
# Check 1: AGENTS.md present and carries godmode instructions
# ---------------------------------------------------------------------------

# AGENTS.md should exist at target root
verify_file_exists "$TARGET_DIR/AGENTS.md" "AGENTS.md present"

# Amp-only: guard against a user-authored AGENTS.md that predates the install
# (installer copies godmode's AGENTS.md wholesale or writes an AGENTS.godmode.md full-file sidecar)
if [ -f "$TARGET_DIR/AGENTS.md" ] && grep -q "Godmode for AI Coding Agents" "$TARGET_DIR/AGENTS.md"; then
    check_pass "AGENTS.md carries godmode instructions"
else
    check_fail "AGENTS.md carries godmode instructions" "AGENTS.md present but lacks godmode section (user-authored?) — merge AGENTS.godmode.md or re-install without a pre-existing AGENTS.md"
fi

# ---------------------------------------------------------------------------
# Check 2: Wiring — symlinks at target root and in .agents/
# ---------------------------------------------------------------------------

verify_symlink "$TARGET_DIR/skills" "skills/ wired at target root"
verify_symlink "$TARGET_DIR/agents" "agents/ wired at target root"
verify_dir_exists "$TARGET_DIR/.agents" ".agents/ directory exists"
verify_symlink "$TARGET_DIR/.agents/skills" ".agents/skills wired (Amp project skills)"

# ---------------------------------------------------------------------------
# Check 3: Count skills (dynamic — derived from the source repo, drift-proof)
# ---------------------------------------------------------------------------

expected="$(find "$GODMODE_ROOT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
if [ "$expected" -gt 0 ] 2>/dev/null; then
    count_skills "$TARGET_DIR/.agents/skills" "$expected"
else
    check_fail "Skills count — source skills dir empty or missing: $GODMODE_ROOT/skills (cannot verify from this clone)"
fi

# Provenance spot-check: the godmode router skill must be present
verify_file_exists "$TARGET_DIR/.agents/skills/godmode/SKILL.md" "godmode router skill present"

# ---------------------------------------------------------------------------
# Check 4: frontmatter name must equal directory name (Amp drops mismatches)
# ---------------------------------------------------------------------------

mismatches=0
checked=0
for dir in "$TARGET_DIR/.agents/skills"/*/; do
    [ -d "$dir" ] || continue
    checked=$((checked + 1))
    name="$(sed -n 's/^name:[[:space:]]*//p' "$dir/SKILL.md" 2>/dev/null | head -1)"
    if [ "$name" != "$(basename "$dir")" ]; then
        mismatches=$((mismatches + 1))
        check_fail "skill dir name mismatch" "$(basename "$dir") vs frontmatter '$name' (Amp will not load it)"
    fi
done
if [ "$mismatches" -eq 0 ] && [ "$checked" -gt 0 ]; then
    check_pass "all skill frontmatter names match directory names (Amp loadable)"
fi

# ---------------------------------------------------------------------------
# Check 5: State directory and config
# ---------------------------------------------------------------------------

verify_dir_exists "$TARGET_DIR/.godmode" ".godmode/ directory exists"
validate_yaml_basic "$TARGET_DIR/.godmode/config.yaml" "Godmode config.yaml valid"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print_summary "Amp"
exit $?
