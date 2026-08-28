#!/usr/bin/env bash
# =============================================================================
# adapter-smoke.sh — Adapter Install/Verify Smoke Test for Godmode Plugin
# =============================================================================
# Installs godmode via each adapter's REAL installer into a throwaway temp
# dir, then runs that adapter's REAL verify.sh against the same dir, so
# installer regressions (hard-coded skill counts, broken symlinks, missing
# copies) fail the build instead of the user.
#
# Safety contract:
#   - The temp dir is passed POSITIONALLY to every installer and verifier.
#     Never via `PREFIX=x cmd1 && cmd2` scoping (assignment dies with cmd1,
#     so verify.sh would fall back to $HOME) and never left to a default —
#     pi's installer runs `rm -rf "$PREFIX/godmode"` and pi's default PREFIX
#     is $HOME/.pi/agent/skills.
#   - Each adapter gets its own subdirectory under one mktemp -d base,
#     removed by a single EXIT trap. No network, no $HOME writes, no
#     pi/omp/amp binaries needed — filesystem-only assertions.
#
# Audited installer temp-dir contracts (read from each install.sh):
#   amp      install.sh "$target" — positional TARGET_DIR (default: cwd)
#   codex    install.sh "$target" — positional TARGET_DIR (default: cwd)
#   cursor   install.sh "$target" — positional TARGET_DIR (default: cwd)
#   gemini   install.sh "$target" — positional TARGET_DIR (default: cwd)
#   opencode install.sh "$target" — positional TARGET_DIR (default: cwd)
#   pi       install.sh "$target" — positional PREFIX (PREFIX env also
#                                     honored; default: $HOME/.pi/agent/skills)
# Each adapter's verify.sh takes the same positional dir (pi: prefix).
# Adapters whose install.sh has no audited positional/PREFIX contract are
# SKIPped, not guessed at — audit the installer, then add it below.
#
# Usage: bash tests/adapter-smoke.sh   (from anywhere inside the repo)
# Exit code: 0 = all smoke-able adapters pass, 1 = any failure
# =============================================================================

set -euo pipefail

# Guard: resolve and enter the repo root so adapter paths are stable.
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Error: tests/adapter-smoke.sh must run inside the godmode git repository."
    echo "Run: bash tests/adapter-smoke.sh  (from the repo root)"
    exit 1
}
cd "$ROOT_DIR"

ADAPTERS_DIR="$ROOT_DIR/adapters"

# An inherited PREFIX env var could redirect an installer to a wrong prefix;
# positional args win everywhere below, but clear it so it can never leak.
unset PREFIX

# Adapters with an audited positional temp-dir contract (see header).
SMOKE_ADAPTERS="amp codex cursor gemini opencode pi"

TAIL_LINES=25

PASS=0
FAIL=0
SKIPS=0

pass() {
    PASS=$((PASS + 1))
    echo "  PASS: $1"
}

fail() {
    FAIL=$((FAIL + 1))
    echo "  FAIL: $1"
}

skip() {
    SKIPS=$((SKIPS + 1))
    echo "  SKIP: $1"
}

separator() {
    echo ""
    echo "=== $1 ==="
}

# One temp base, one trap, one subdirectory per adapter (see header).
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT

# ─────────────────────────────────────────────────────────────────────────────
# Adapter selection: audited adapters with a complete install.sh + verify.sh
# pair; SKIP lines name any gap found during discovery.
# ─────────────────────────────────────────────────────────────────────────────
separator "Adapter Discovery"

SMOKE_LIST=""

for adapter in $SMOKE_ADAPTERS; do
    if [ -f "$ADAPTERS_DIR/$adapter/install.sh" ] && [ -f "$ADAPTERS_DIR/$adapter/verify.sh" ]; then
        SMOKE_LIST="$SMOKE_LIST $adapter"
    else
        skip "$adapter — audited but missing install.sh/verify.sh pair under adapters/$adapter/"
    fi
done

# Any install.sh + verify.sh pair we have NOT audited stays skipped until its
# positional/PREFIX temp-dir contract is verified by reading the installer.
for install_sh in "$ADAPTERS_DIR"/*/install.sh; do
    adapter="$(basename "$(dirname "$install_sh")")"
    case " $SMOKE_ADAPTERS " in
        *" $adapter "*) continue ;;
    esac
    if [ -f "$ADAPTERS_DIR/$adapter/verify.sh" ]; then
        skip "$adapter — no audited positional/PREFIX temp-dir contract (audit install.sh, then add to SMOKE_ADAPTERS)"
    else
        skip "$adapter — install.sh present but verify.sh missing (incomplete pair)"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# Smoke one adapter: real install into temp dir, real verify against it
# ─────────────────────────────────────────────────────────────────────────────

smoke_adapter() {
    local adapter="$1"
    local target="$TMP/$adapter"
    local install_log="$TMP/$adapter.install.log"
    local verify_log="$TMP/$adapter.verify.log"

    # Target dirs must exist before install (codex/amp/cursor/gemini/opencode
    # `cd` into them; harmless for pi, which mkdirs its own prefix).
    mkdir -p "$target"

    # CRITICAL: temp dir passed POSITIONALLY — never via env scoping or
    # installer defaults (pi's installer rm -rf's "$PREFIX/godmode" and its
    # default prefix lives under $HOME).
    if ! bash "$ADAPTERS_DIR/$adapter/install.sh" "$target" >"$install_log" 2>&1; then
        fail "$adapter — install.sh exited non-zero (target: $target)"
        echo "  --- adapters/$adapter/install.sh output (last $TAIL_LINES lines) ---"
        tail -n "$TAIL_LINES" "$install_log" | sed 's/^/    /'
        return 1
    fi

    if ! bash "$ADAPTERS_DIR/$adapter/verify.sh" "$target" >"$verify_log" 2>&1; then
        fail "$adapter — verify.sh exited non-zero (target: $target)"
        echo "  --- adapters/$adapter/verify.sh output (last $TAIL_LINES lines) ---"
        tail -n "$TAIL_LINES" "$verify_log" | sed 's/^/    /'
        return 1
    fi

    # False-green guard: verify.sh must have checked the temp target, not a
    # $HOME default that happens to hold an older dogfood install. Every
    # verify.sh prints its resolved target/prefix dir in its banner.
    if ! grep -qF "$target" "$verify_log"; then
        fail "$adapter — verify.sh output never mentions the temp target $target (ran against a default prefix?)"
        echo "  --- adapters/$adapter/verify.sh output (last $TAIL_LINES lines) ---"
        tail -n "$TAIL_LINES" "$verify_log" | sed 's/^/    /'
        return 1
    fi

    pass "$adapter — install.sh + verify.sh green against temp target"
    return 0
}

separator "Smoke: install + verify per adapter"

for adapter in $SMOKE_LIST; do
    smoke_adapter "$adapter" || {
        echo ""
        echo "============================================"
        echo "  STATUS: FAIL"
        echo "============================================"
        exit 1
    }
done

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  SMOKE RESULTS"
echo "============================================"
echo "  PASS: $PASS"
echo "  SKIP: $SKIPS"
echo "  FAIL: $FAIL"
echo "============================================"

if [ "$FAIL" -gt 0 ]; then
    echo "  STATUS: FAIL"
    echo "============================================"
    exit 1
elif [ "$PASS" -eq 0 ]; then
    # No adapter was smoke-tested at all — SMOKE_ADAPTERS is stale or every
    # audited pair vanished. Refuse to report a false green.
    echo "  STATUS: FAIL — no adapters were smoke-tested (stale SMOKE_ADAPTERS?)"
    echo "============================================"
    exit 1
else
    echo "  STATUS: PASS"
    echo "============================================"
    exit 0
fi
