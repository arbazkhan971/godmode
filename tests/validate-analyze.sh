#!/usr/bin/env bash
# validate-analyze.sh — validator for bench/analyze.py (M3-B3 wave 1).
# Runs analyze.py against the frozen real TSV (hash-checked before and after
# every real-TSV invocation) and against synthetic mini-TSVs built in a mktemp
# sandbox. Never writes bench/results.tsv.
# Usage: bash tests/validate-analyze.sh
# Exit code: 0 = all pass, 1 = failures found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ANALYZE="$ROOT/bench/analyze.py"
REAL_TSV="$ROOT/bench/results.tsv"

TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

PASS=0
FAIL=0
OUT=""
ERR=""
RC=0
HASH_OK=1

ok()  { PASS=$((PASS + 1)); printf 'PASS: %s\n' "$1"; }
bad() { FAIL=$((FAIL + 1)); printf 'FAIL: %s\n' "$1" >&2; }

hdr() { printf 'task_id\tarm\trun#\tparent_run\tstart_ts\tend_ts\texit_code\tmetric_pass\tduration_s\tnotes\n'; }
row() { printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}"; }
TS='2026-01-01T00:00:00Z'
M='model:x/y'

# run_py <args...> — capture OUT/ERR/RC without tripping set -e on rc 1.
run_py() {
    if OUT="$(python3 "$ANALYZE" "$@" 2>"$TMP/err")"; then RC=0; else RC=$?; fi
    ERR="$(cat "$TMP/err" 2>/dev/null || true)"
}

# run_real <args...> — like run_py, plus sha256 before/after: the frozen TSV
# must be byte-identical across every invocation that reads it.
REAL_SHA="$(sha256sum "$REAL_TSV" | awk '{print $1}')"
run_real() {
    local before after
    before="$(sha256sum "$REAL_TSV" | awk '{print $1}')"
    run_py "$@"
    after="$(sha256sum "$REAL_TSV" | awk '{print $1}')"
    if [ "$before" != "$after" ] || [ "$after" != "$REAL_SHA" ]; then HASH_OK=0; fi
}

# ── Case a: real TSV — completeness, deterministic bundle strings ───────────
run_real --assert-complete
if [ "$RC" -eq 0 ]; then ok "a1 real TSV --assert-complete exits 0"; else bad "a1 --assert-complete rc=$RC err=[$ERR]"; fi

run_real --markdown --by-task
a2=1
printf '%s\n' "$OUT" | grep -qF 'keep/revert: n/a — not instrumented (no TSV column; logs contain only stray mentions; any count would be fabricated)' || a2=0
printf '%s\n' "$OUT" | grep -qF 'exit-124 durations are right-censored at the 600s cap — recorded value is a lower bound; means including them are biased downward for timeouts' || a2=0
printf '%s\n' "$OUT" | grep -qF 'median of 2 runs = midpoint of the two values' || a2=0
printf '%s\n' "$OUT" | grep -Eq '^\| godmode \| 60 \| 60 \|' || a2=0
if [ "$RC" -eq 0 ] && [ "$a2" -eq 1 ]; then
    ok "a2 real TSV --markdown --by-task: n/a line, both footnotes, godmode 60/60 row"
else
    bad "a2 real TSV --markdown --by-task (rc=$RC hits=$a2)"
fi

# ── Case b: duplicate 4-field key ───────────────────────────────────────────
B="$TMP/dup.tsv"
{ hdr; row bug-01 plain 1 '' "$TS" "$TS" 0 1 40 "$M"
  row bug-01 plain 1 '' "$TS" "$TS" 0 1 40 "$M"; } >"$B"
run_py "$B"
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'dup-key'; then
    ok "b duplicated (task_id,arm,run#,parent_run) exits 1 with dup-key"
else
    bad "b dup-key (rc=$RC err=[$ERR])"
fi

# ── Case c: completeness over a synthetic 30x2x2 matrix ─────────────────────
gen_matrix() { # $1=file $2=skip-one-sec-03-godmode-r1 (0|1)
    local skip="$2"
    { hdr
      for cat in perf bug test feat sec refac; do
        for i in 1 2 3 4 5; do
          for arm in plain godmode; do
            for r in 1 2; do
              if [ "$skip" = 1 ] && [ "$cat" = sec ] && [ "$i" = 3 ] \
                 && [ "$arm" = godmode ] && [ "$r" = 1 ]; then continue; fi
              row "$cat-0$i" "$arm" "$r" '' "$TS" "$TS" 0 1 40 "$M"
            done
          done
        done
      done; } >"$1"
}
C1="$TMP/full.tsv"; gen_matrix "$C1" 0
run_py "$C1" --assert-complete
if [ "$RC" -eq 0 ]; then ok "c1 full 30x2x2 synthetic matrix passes --assert-complete"; else bad "c1 full matrix (rc=$RC err=[$ERR])"; fi

C2="$TMP/minus.tsv"; gen_matrix "$C2" 1
run_py "$C2" --assert-complete
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'sec-03'; then
    ok "c2 matrix minus one sec-03 godmode run exits 1 naming sec-03"
else
    bad "c2 missing combo (rc=$RC err=[$ERR])"
fi

# ── Case d: censoring — C-124 count, dagger on the max, split means ─────────
D="$TMP/censor.tsv"
{ hdr; row bug-01 plain 1 '' "$TS" "$TS" 0 1 30 "$M"
  row bug-01 plain 2 '' "$TS" "$TS" 124 1 600 'model:x/y;timeout'; } >"$D"
run_py "$D" --markdown
d_row="$(printf '%s\n' "$OUT" | grep -E '^\| plain \|' | head -1 || true)"
if [ -n "$d_row" ]; then
    d_mean="$(printf '%s' "$d_row" | awk -F'|' '{print $7}' | tr -d ' ')"
    d_excl="$(printf '%s' "$d_row" | awk -F'|' '{print $8}' | tr -d ' ')"
    d_max="$(printf '%s'  "$d_row" | awk -F'|' '{print $9}' | tr -d ' ')"
    d_n="$(printf '%s'   "$d_row" | awk -F'|' '{print $10}' | tr -d ' ')"
    if [ "$RC" -eq 0 ] && [ "$d_n" = 1 ] && [ "$d_max" = '600.0†' ] \
       && [ "$d_mean" != "$d_excl" ] && [ "$d_mean" = '315.0' ] && [ "$d_excl" = '30.0' ]; then
        ok "d exit-124 row: C-124=1, max 600.0†, mean incl 315.0 != mean excl 30.0"
    else
        bad "d censoring (rc=$RC row=[$d_row] n=$d_n max=[$d_max] mean=$d_mean excl=$d_excl)"
    fi
else
    bad "d censoring (no '| plain |' row; rc=$RC err=[$ERR])"
fi

# ── Case e: verify separation and verify-parent rejections ──────────────────
E="$TMP/verify.tsv"
{ hdr; row bug-01 plain 1 '' "$TS" "$TS" 0 1 40 "$M"
  row bug-01 plain 2 '' "$TS" "$TS" 0 1 40 "$M"
  row bug-01 godmode 1 '' "$TS" "$TS" 0 1 40 "$M"
  row bug-01 godmode 2 '' "$TS" "$TS" 0 1 40 "$M"
  row bug-01 godmode 3 bug-01:godmode:1 "$TS" "$TS" 0 1 999 "$M"; } >"$E"
run_py "$E" --markdown
e_ok=1
printf '%s\n' "$OUT" | grep -qF '| plain | 2 | 2 | 100.0% | 40.0 | 40.0 | 40.0 | 40.0 | 0 |' || e_ok=0
printf '%s\n' "$OUT" | grep -qF '| 1 | 1 | 1 | 1 | 100.0% | 999.0 | 999.0 | 999.0 |' || e_ok=0
if [ "$RC" -eq 0 ] && [ "$e_ok" -eq 1 ]; then
    ok "e1 verify row (999 s) excluded from scored stats, present in verify stats"
else
    bad "e1 verify separation (rc=$RC hits=$e_ok)"
fi

E2="$TMP/bad-parent-colon.tsv"
{ hdr; row bug-01 godmode 3 'bug-01:godmode:1:' "$TS" "$TS" 0 1 40 "$M"; } >"$E2"
run_py "$E2"
e2a=0
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'verify-parent'; then e2a=1; fi
E3="$TMP/bad-parent-task.tsv"
{ hdr; row bug-02 godmode 3 bug-01:godmode:1 "$TS" "$TS" 0 1 40 "$M"; } >"$E3"
run_py "$E3"
e2b=0
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'verify-parent'; then e2b=1; fi
E4="$TMP/bad-parent-arm.tsv"
{ hdr; row bug-01 plain 3 bug-01:godmode:1 "$TS" "$TS" 0 1 40 "$M"; } >"$E4"
run_py "$E4"
e2c=0
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'verify-parent'; then e2c=1; fi
if [ "$e2a" = 1 ] && [ "$e2b" = 1 ] && [ "$e2c" = 1 ]; then
    ok "e2 malformed parents (trailing colon / task mismatch / arm=plain) each exit 1 verify-parent"
else
    bad "e2 bad verify parents (colon=$e2a mismatch=$e2b plainarm=$e2c)"
fi

# ── Case f: empty cells parse as None -> n/a, excluded from time stats ──────
F2="$TMP/na.tsv"
{ hdr; row bug-01 plain 1 '' "$TS" "$TS" 0 1 30 "$M"
  row bug-01 plain 2 '' "$TS" "$TS" '' '' '' "$M"; } >"$F2"
run_py "$F2" --markdown --by-task
f_ok=1
printf '%s\n' "$OUT" | grep -qF '| plain | 2 | 1 | 50.0% | 30.0 | 30.0 | 30.0 | 30.0 | 0 |' || f_ok=0
printf '%s\n' "$OUT" | grep -qF '| bug-01 | plain | 30.0 | n/a | 1/2 | n/a | - |' || f_ok=0
if [ "$RC" -eq 0 ] && [ "$f_ok" -eq 1 ]; then
    ok "f empty duration/metric_pass/exit_code render n/a; row counted, times exclude it"
else
    bad "f n/a cells (rc=$RC hits=$f_ok)"
fi

# ── Case g: malformed field count and bad arm ───────────────────────────────
G1="$TMP/nine.tsv"
{ hdr; printf 'bug-01\tplain\t1\t\t%s\t%s\t0\t1\t40\n' "$TS" "$TS"; } >"$G1"
run_py "$G1"
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'malformed'; then
    ok "g1 9-field row exits 1 with malformed"
else
    bad "g1 malformed (rc=$RC err=[$ERR])"
fi

G2="$TMP/bad-arm.tsv"
{ hdr; row bug-01 flaky 1 '' "$TS" "$TS" 0 1 40 "$M"; } >"$G2"
run_py "$G2"
if [ "$RC" -eq 1 ] && printf '%s' "$ERR" | grep -q 'domain'; then
    ok "g2 bad arm value exits 1 with domain"
else
    bad "g2 domain (rc=$RC err=[$ERR])"
fi

# ── Case h: median of 2 runs = midpoint (appendix Mid s) ────────────────────
H="$TMP/mid2.tsv"
{ hdr; row bug-01 plain 1 '' "$TS" "$TS" 0 1 20 "$M"
  row bug-01 plain 2 '' "$TS" "$TS" 0 1 41 "$M"; } >"$H"
run_py "$H" --markdown --by-task
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF '| bug-01 | plain | 20.0 | 41.0 | 2/2 | 30.5 | - |'; then
    ok "h runs 20 s + 41 s -> appendix Mid s shows 30.5"
else
    bad "h mid-of-2 (rc=$RC)"
fi

# ── Case j: model note survives the ';timeout' suffix (lenient parse) ───────
run_real --markdown
if [ "$RC" -eq 0 ] && printf '%s\n' "$OUT" | grep -qF 'model:zai/glm-5.3'; then
    ok "j --markdown contains model:zai/glm-5.3"
else
    bad "j model note (rc=$RC)"
fi

# ── Case i: real TSV byte-identical across every invocation above ───────────
final_sha="$(sha256sum "$REAL_TSV" | awk '{print $1}')"
if [ "$HASH_OK" -eq 1 ] && [ "$final_sha" = "$REAL_SHA" ]; then
    ok "i real TSV sha256 unchanged before/after every invocation"
else
    bad "i real TSV changed (hash_ok=$HASH_OK)"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
printf 'validate-analyze: %d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
