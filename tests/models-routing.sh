#!/usr/bin/env bash
# models-routing.sh — integration tests for adapters/pi/models.sh routing.
# Every models.sh invocation runs inside a sandbox: HOME is redirected,
# the cwd is a throwaway git repo (so "project root" resolves to the
# sandbox), and env -i isolates GODMODE_MODEL_* from the host.
# Cases C14/C15 copy the real repo into the sandbox to exercise the
# validate-structure.sh Check 7 negative path without touching the tree.
# Usage: bash tests/models-routing.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
MODELS="$REAL_REPO/adapters/pi/models.sh"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

export HOME="$TMP/home"
mkdir -p "$HOME/.config/godmode"

REPO="$TMP/repo"
git init -q "$REPO"

PASS=0
SKIP=0
FAIL=0
OUT=""
ERR=""
RC=0

ok()   { printf 'PASS: %s\n' "$1"; PASS=$((PASS + 1)); }
skip() { printf 'SKIP: %s\n' "$1"; SKIP=$((SKIP + 1)); }
bad()  { printf 'FAIL: %s\n' "$1" >&2; FAIL=$((FAIL + 1)); }

# envrun <dir> [VAR=v ...] -- <models.sh args...>
# Runs models.sh from <dir> (sandbox project root) with a scrubbed env.
# Sets OUT / RC / ERR.
envrun() {
    local dir="$1"
    shift
    local pairs=()
    while [ "$#" -gt 0 ]; do
        case "$1" in
            *=*) pairs+=("$1"); shift ;;
            *) break ;;
        esac
    done
    if OUT="$(cd "$dir" && env -i PATH="$PATH" HOME="$HOME" \
        ${pairs[@]+"${pairs[@]}"} bash "$MODELS" "$@" 2>"$TMP/err")"; then
        RC=0
    else
        RC=$?
    fi
    ERR="$(cat "$TMP/err" 2>/dev/null || true)"
}

tab() { printf '\t'; }

# ── C1: zero-config — every canonical role inherits the session model ──────
c1=1
for role in plan build review optimize explore security test docs; do
    envrun "$REPO" resolve "$role"
    if [ "$RC" -ne 0 ] || [ "$OUT" != "session$(tab)session" ]; then
        c1=0
        printf '  (zero-config %s -> rc=%s out=[%s])\n' "$role" "$RC" "$OUT" >&2
    fi
done
if [ "$c1" -eq 1 ]; then ok "C1 zero-config: all 8 roles -> session/session"; else bad "C1 zero-config"; fi

# ── C2: env layer wins over the file layer ─────────────────────────────────
printf '{"roles":{"build":"vendor/filebuild"}}' >"$REPO/godmode.models.json"
envrun "$REPO" GODMODE_MODEL_BUILD=vendor/strong resolve build
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/strong$(tab)env" ]; then
    ok "C2 env wins over file"
else
    bad "C2 env wins over file (rc=$RC out=[$OUT])"
fi

# ── C3: file layer — repo-root godmode.models.json ─────────────────────────
printf '{"roles":{"review":"vendor/fast"}}' >"$REPO/godmode.models.json"
envrun "$REPO" resolve review
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/fast$(tab)file" ]; then
    ok "C3 file layer at project root"
else
    bad "C3 file layer at project root (rc=$RC out=[$OUT])"
fi

# ── C4: per-role merge, disjoint keys — each file serves its own roles ─────
printf '{"roles":{"review":"vendor/fast"}}' >"$REPO/godmode.models.json"
printf '{"roles":{"plan":"vendor/homeplan"}}' >"$HOME/.config/godmode/models.json"
envrun "$REPO" resolve review
c4a=$([ "$RC" -eq 0 ] && [ "$OUT" = "vendor/fast$(tab)file" ] && echo 1 || echo 0)
envrun "$REPO" resolve plan
c4b=$([ "$RC" -eq 0 ] && [ "$OUT" = "vendor/homeplan$(tab)file" ] && echo 1 || echo 0)
if [ "$c4a" = 1 ] && [ "$c4b" = 1 ]; then
    ok "C4 per-role merge (disjoint): review from repo, plan from home"
else
    bad "C4 per-role merge (review=[$c4a] plan=[$c4b])"
fi

# ── C5: per-role merge, overlapping key — repo file wins per key ───────────
printf '{"roles":{"plan":"vendor/repoplan"}}' >"$REPO/godmode.models.json"
printf '{"roles":{"plan":"vendor/homeplan"}}' >"$HOME/.config/godmode/models.json"
envrun "$REPO" resolve plan
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/repoplan$(tab)file" ]; then
    ok "C5 overlap: repo value wins over home"
else
    bad "C5 overlap: repo value wins (rc=$RC out=[$OUT])"
fi

# ── C6: malformed repo file is ignored entirely -> session, exit 0 ─────────
printf '{"roles": {"oops"' >"$REPO/godmode.models.json"
rm -f "$HOME/.config/godmode/models.json"
envrun "$REPO" resolve plan
if [ "$RC" -eq 0 ] && [ "$OUT" = "session$(tab)session" ] \
    && printf '%s' "$ERR" | grep -qF 'is invalid JSON — ignoring'; then
    ok "C6 malformed repo file -> session/session, warning on stderr"
else
    bad "C6 malformed repo file (rc=$RC out=[$OUT] err=[$ERR])"
fi

# ── C7: set-but-empty env is not an override ───────────────────────────────
printf '{"roles":{"build":"vendor/filebuild"}}' >"$REPO/godmode.models.json"
envrun "$REPO" GODMODE_MODEL_BUILD= resolve build
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/filebuild$(tab)file" ]; then
    ok "C7 empty env ignored, file layer applies"
else
    bad "C7 empty env ignored (rc=$RC out=[$OUT])"
fi

# ── C8: hyphenated role <-> GODMODE_MODEL_CODE_REVIEW ──────────────────────
rm -f "$REPO/godmode.models.json"
envrun "$REPO" GODMODE_MODEL_CODE_REVIEW=vendor/hyphen resolve code-review
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/hyphen$(tab)env" ]; then
    ok "C8 hyphenated role env name"
else
    bad "C8 hyphenated role env name (rc=$RC out=[$OUT])"
fi

# ── C9: dotted role <-> GODMODE_MODEL_V2_REVIEW (tr fix) ───────────────────
envrun "$REPO" GODMODE_MODEL_V2_REVIEW=vendor/dot resolve v2.review
if [ "$RC" -eq 0 ] && [ "$OUT" = "vendor/dot$(tab)env" ]; then
    ok "C9 dotted role env name"
else
    bad "C9 dotted role env name (rc=$RC out=[$OUT])"
fi

# ── C10: malicious env value — rejected, never evaluated ───────────────────
envrun "$REPO" 'GODMODE_MODEL_BUILD=x; rm -rf /' resolve build
if [ "$RC" -eq 0 ] && [ "$OUT" = "session$(tab)session" ] \
    && printf '%s' "$ERR" | grep -qF 'ignoring invalid model value for role build'; then
    ok "C10 malicious env value -> warning + session fallback"
else
    bad "C10 malicious env value (rc=$RC out=[$OUT] err=[$ERR])"
fi

# ── C11: doctor, zero GODMODE_MODEL_* env — header, rows, trailer, no ANSI ─
envrun "$REPO" doctor
c11_lines="$(printf '%s\n' "$OUT" | wc -l | tr -d ' ')"
c11_ansi="$(printf '%s' "$OUT" | grep -oP '\033' | wc -l || true)"
c11_ansi="$(printf '%s' "$c11_ansi" | tr -d ' ')"
if [ "$RC" -eq 0 ] \
    && [ "$(printf '%s\n' "$OUT" | head -n1)" = "role$(tab)model$(tab)source$(tab)origin" ] \
    && [ "$c11_lines" -ge 10 ] \
    && printf '%s\n' "$OUT" | tail -n1 | grep -qE "^config$(printf '\t')repo=.+$(printf '\t')home=.+" \
    && [ "$c11_ansi" = "0" ]; then
    ok "C11 doctor zero-env: header + >=8 rows + trailer, exit 0, no ANSI"
else
    bad "C11 doctor zero-env (rc=$RC lines=$c11_lines ansi=$c11_ansi)"
fi

# ── C12: doctor/resolve parity for an env-set (non-canonical) role ─────────
envrun "$REPO" GODMODE_MODEL_CODE_REVIEW=vendor/hyphen resolve code-review
c12_res="$OUT"
envrun "$REPO" GODMODE_MODEL_CODE_REVIEW=vendor/hyphen doctor
c12_row="$(printf '%s\n' "$OUT" | awk -F'\t' '$1=="code-review"{print $2"\t"$3"\t"$4}')"
if [ "$c12_res" = "vendor/hyphen$(tab)env" ] \
    && [ "$c12_row" = "vendor/hyphen$(tab)env$(tab)GODMODE_MODEL_CODE_REVIEW" ]; then
    ok "C12 doctor/resolve parity (env-discovered role)"
else
    bad "C12 doctor/resolve parity (resolve=[$c12_res] row=[$c12_row])"
fi

# ── C13: python3-absent guard (best-effort) ────────────────────────────────
# The file layer must be skipped with one warning when python3 is missing.
if printf '%s' "$(cat "$MODELS" 2>/dev/null || true)" | grep -q 'command -v python3'; then
    guard_ok=1
else
    guard_ok=0
fi
NOBIN="$TMP/nobin"
mkdir -p "$NOBIN"
tools_ok=1
for tool in bash tr printenv grep dirname basename; do
    tool_path="$(command -v "$tool" 2>/dev/null || true)"
    if [ -n "$tool_path" ]; then
        ln -sf "$tool_path" "$NOBIN/$tool"
    else
        tools_ok=0
    fi
done
if [ "$tools_ok" -eq 1 ] && [ "$guard_ok" -eq 1 ]; then
    printf '{"roles":{"plan":"vendor/nopy"}}' >"$REPO/godmode.models.json"
    if OUT="$(cd "$REPO" && env -i PATH="$NOBIN" HOME="$HOME" \
        bash "$MODELS" resolve plan 2>"$TMP/err")"; then
        RC=0
    else
        RC=$?
    fi
    ERR="$(cat "$TMP/err" 2>/dev/null || true)"
    if [ "$RC" -eq 0 ] && [ "$OUT" = "session$(tab)session" ] \
        && printf '%s' "$ERR" | grep -qF 'python3 not found'; then
        ok "C13 python3-absent guard skips file layer"
    else
        bad "C13 python3-absent guard (rc=$RC out=[$OUT] err=[$ERR])"
    fi
else
    skip "C13 (cannot build a python3-free PATH in this sandbox: tools_ok=$tools_ok guard_ok=$guard_ok)"
fi

# ── C14: validator Check 7 negative path, fully sandboxed ──────────────────
cp -R "$REAL_REPO"/. "$TMP/copy"
if grep -q 'Check 7' "$TMP/copy/tests/validate-structure.sh"; then
    printf '{"roles":{"plan":"nocolon"}}' >"$TMP/copy/godmode.models.json"
    if OUT="$(cd "$TMP/copy" && bash tests/validate-structure.sh 2>&1)"; then
        RC=0
    else
        RC=$?
    fi
    if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q 'Check 7'; then
        ok "C14 Check 7 rejects invalid model id (exit 1)"
    else
        bad "C14 Check 7 rejects invalid model id (rc=$RC)"
    fi
else
    skip "C14 (Check 7 not present yet)"
fi

# ── C15: cleanup restores green ────────────────────────────────────────────
if [ -d "$TMP/copy" ]; then
    if grep -q 'Check 7' "$TMP/copy/tests/validate-structure.sh"; then
        rm -f "$TMP/copy/godmode.models.json"
        if OUT="$(cd "$TMP/copy" && bash tests/validate-structure.sh 2>&1)"; then
            RC=0
        else
            RC=$?
        fi
        if [ "$RC" -eq 0 ]; then
            ok "C15 cleanup restores validator green"
        else
            bad "C15 cleanup restores validator green (rc=$RC)"
            printf '%s\n' "$OUT" | grep -E 'FAIL' >&2 || true
        fi
    fi
else
    skip "C15 (no sandbox copy — C14 skipped)"
fi

# ── C16: no real-tree pollution ────────────────────────────────────────────
if [ ! -e "$REAL_REPO/godmode.models.json" ]; then
    ok "C16 real repo root has no godmode.models.json"
else
    bad "C16 real repo root has a godmode.models.json — pollution detected"
fi

# ── C17: skills hygiene guard mirrors validator Check 6 ────────────────────
c17="$(cd "$REAL_REPO" && grep -ril claude skills || true)"
if [ "$c17" = "skills/research/SKILL.md" ]; then
    ok "C17 skills claude-wording allowlist intact"
else
    bad "C17 skills claude-wording allowlist (got: [$c17])"
fi

# ── Summary ────────────────────────────────────────────────────────────────
printf 'models-routing: %d passed, %d skipped, %d failed\n' "$PASS" "$SKIP" "$FAIL"
[ "$FAIL" -eq 0 ]
