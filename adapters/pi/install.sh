#!/usr/bin/env bash
# Godmode Installer for pi (and omp-compatible forks)
# Usage: bash install.sh [PREFIX]
# PREFIX = skill root dir. Resolution order:
#   1. first positional argument
#   2. $PREFIX environment variable (exists for omp and other forks whose
#      skill directory differs from pi's default)
#   3. $HOME/.pi/agent/skills
# Copies all godmode skills into $PREFIX/godmode/. pi loads skills only —
# no symlinks, no agents/, no commands/. Idempotent — safe to re-run.

set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GODMODE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_PREFIX="$HOME/.pi/agent/skills"
OMP_SKILLS_DIR="$HOME/.omp/agent/skills"
PREFIX="${1:-${PREFIX:-$DEFAULT_PREFIX}}"

# Refuse prefixes that would install (or delete) directly under the filesystem root.
while [ -n "$PREFIX" ] && [ "${PREFIX%/}" != "$PREFIX" ]; do
    PREFIX="${PREFIX%/}"
done
# Lexical normalization catches root-equivalent forms like "/.", "/..", "//.".
PREFIX="$(realpath -ms -- "$PREFIX" 2>/dev/null || printf '%s' "$PREFIX")"
case "$PREFIX" in
    ""|"/")
        echo "Error: refusing unsafe PREFIX (empty or '/'): would install/delete directly under the filesystem root." >&2
        exit 1
        ;;
esac

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
    exit 1
fi

echo "Godmode installer for pi"
echo "  Source: $GODMODE_ROOT"
echo "  Prefix: $PREFIX"
echo ""

# ---------------------------------------------------------------------------
# Install skills (idempotent overwrite)
# ---------------------------------------------------------------------------

if [ -d "$PREFIX/godmode" ]; then
    echo "[ok]   $PREFIX/godmode exists — refreshing skills (idempotent overwrite)"
else
    echo "[done] Creating $PREFIX/godmode"
fi

# Deterministic re-install: prune the destination first so skills removed
# upstream do not linger (a plain overwrite cannot self-heal a stale dir).
rm -rf -- "$PREFIX/godmode"
mkdir -p -- "$PREFIX/godmode"
cp -R -- "$GODMODE_ROOT/skills/." "$PREFIX/godmode/"

SOURCE_COUNT="$(find "$GODMODE_ROOT/skills" -type f -name SKILL.md | wc -l | tr -d ' ')"
DEST_COUNT="$(find "$PREFIX/godmode" -type f -name SKILL.md | wc -l | tr -d ' ')"
echo "[ok]   SKILL.md files — source: $SOURCE_COUNT, installed: $DEST_COUNT"

if [ "$SOURCE_COUNT" -ne "$DEST_COUNT" ]; then
    echo "Error: skill copy incomplete (source has $SOURCE_COUNT SKILL.md files,"
    echo "$PREFIX/godmode has $DEST_COUNT). Re-run this installer to retry."
    exit 1
fi

# ---------------------------------------------------------------------------
# Activation + smoke test
# ---------------------------------------------------------------------------

echo ""
echo "Godmode installed successfully for pi."
echo ""
echo "  Skills auto-load in the next pi session — no config edits needed."
echo ""
echo "Verify the install:"
echo "  bash $GODMODE_ROOT/adapters/pi/verify.sh"
echo ""
echo "One-line smoke test:"
echo "  pi -p -ne --skill \"$PREFIX/godmode/optimize/SKILL.md\" \"Reply GODMODE_SKILL_OK if the optimize skill description is in your context\""

# ---------------------------------------------------------------------------
# Non-default PREFIX note (omp-compatible forks)
# ---------------------------------------------------------------------------

if [ "$PREFIX" != "$DEFAULT_PREFIX" ]; then
    if [ "$PREFIX" = "$OMP_SKILLS_DIR" ]; then
        # Case A: omp's documented user skills dir.
        echo ""
        echo "Note: $PREFIX is omp's documented user skills dir — skills install under"
        echo "  $PREFIX/godmode/, one level deeper than omp scans (<skills-root>/<skill-name>/SKILL.md)."
        echo "One-time registration is REQUIRED for omp to discover the godmode collection."
        echo "Add this to ~/.omp/agent/config.yml if not already present:"
        echo "  skills:"
        echo "    customDirectories:"
        echo "      - ~/.omp/agent/skills/godmode"
        echo "Profile caveat: with an active omp profile, skills load from"
        echo "  ~/.omp/profiles/<name>/agent/skills instead."
    else
        # Case B: any other non-default PREFIX (forks, custom layouts).
        echo ""
        echo "Note: PREFIX is not pi's default skill dir ($DEFAULT_PREFIX)."
        echo "omp's confirmed user skills dir is $OMP_SKILLS_DIR."
        echo "PREFIX is honored as given for forks and custom layouts."
        echo "For omp, install there and register the collection once in ~/.omp/agent/config.yml:"
        echo "  skills:"
        echo "    customDirectories:"
        echo "      - ~/.omp/agent/skills/godmode"
    fi
fi
