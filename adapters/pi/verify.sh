#!/usr/bin/env bash
# Godmode — Post-install verification for pi
# Usage: bash adapters/pi/verify.sh [prefix-dir]
# Defaults PREFIX to ~/.pi/agent/skills; the first positional argument
# overrides the environment/default (arg wins).

set -uo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODMODE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# PREFIX resolution (mirrors install.sh): environment PREFIX wins over the
# default, and an optional first positional argument wins over both.
PREFIX="${PREFIX:-$HOME/.pi/agent/skills}"
if [ $# -ge 1 ]; then
    PREFIX="$1"
fi

# Source shared helpers
source "$GODMODE_ROOT/adapters/shared/verify-common.sh"

echo ""
printf "${BOLD}Godmode Verification — pi${RESET}\n"
printf "  Source:  %s\n" "$GODMODE_ROOT"
printf "  Prefix:  %s\n" "$PREFIX"
echo ""

# pi installs skills into <PREFIX>/godmode/
GODMODE_DIR="$PREFIX/godmode"

# ---------------------------------------------------------------------------
# Check 1: godmode directory exists
# ---------------------------------------------------------------------------

verify_dir_exists "$GODMODE_DIR" "godmode directory exists"

# ---------------------------------------------------------------------------
# Check 2: Skill counts match the source tree
# ---------------------------------------------------------------------------

# Count SKILL.md files under the installed prefix and under the repo's
# skills/ directory; they must be equal. No hardcoded count.
SRC_COUNT="$(find "$GODMODE_ROOT/skills" -type f -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
INST_COUNT=0
if [ -d "$GODMODE_DIR" ]; then
    INST_COUNT="$(find "$GODMODE_DIR" -type f -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
fi

if [ "$INST_COUNT" -eq "$SRC_COUNT" ] && [ "$SRC_COUNT" -gt 0 ]; then
    check_pass "Skill counts match" "$INST_COUNT installed == $SRC_COUNT in source"
else
    check_fail "Skill counts match" "installed $INST_COUNT SKILL.md vs source $SRC_COUNT SKILL.md"
fi

# ---------------------------------------------------------------------------
# Check 3: Spot files exist
# ---------------------------------------------------------------------------

verify_file_exists "$GODMODE_DIR/optimize/SKILL.md" "optimize/SKILL.md present"
verify_file_exists "$GODMODE_DIR/godmode/SKILL.md" "godmode/SKILL.md present"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

print_summary "pi"
SUMMARY_EXIT=$?

# Smoke test hint (always printed)
echo ""
printf "%s\n" "Smoke test (optional): pi -p -ne --skill \"$GODMODE_DIR/optimize/SKILL.md\" \"Reply GODMODE_SKILL_OK if the optimize skill description is in your context\""

exit "$SUMMARY_EXIT"
