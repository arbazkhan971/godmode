#!/usr/bin/env bash
# =============================================================================
# validate-prose-count.sh — Prose Skill-Count Consistency Gate
# =============================================================================
# Fails when live (non-frozen) git-tracked files claim a total skill count
# that differs from the on-disk SKILL.md count. This is the gate that would
# have caught the 126->135 drift class.
#
# Frozen point-in-time records are allowlisted below (with justifications).
#
# Usage: bash tests/validate-prose-count.sh [root]
#   root  directory to census for claims (default: repo root). Also settable
#         via GODMODE_PROSE_ROOT; the argument wins.
# Exit codes: 0 = all live claims consistent
#             1 = stale claims found
#             2 = GATE BROKEN (embedded self-test failed to prove detection)
# =============================================================================

set -euo pipefail

top_dir="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$top_dir" ]; then
  echo "FAIL: not inside a git repository — run from the godmode repo"
  echo "GATE BROKEN"
  exit 2
fi
cd "$top_dir"

ROOT="${1:-${GODMODE_PROSE_ROOT:-.}}"

# ─────────────────────────────────────────────────────────────────────────────
# TRUTH — byte-identical to the CI count step (.github/workflows/validate.yml)
# ─────────────────────────────────────────────────────────────────────────────
actual="$(find skills -name SKILL.md -type f | wc -l | tr -d ' ')"

# Claim shapes caught (council amendment: TOTAL-corpus-count drift only,
# not subset references):
#   A. Three-digit counts (1xx) are ALWAYS flagged, in the four shapes
#      `NNN skills`, `NNN-skill`, `Skills (NNN)`, `(NNN skills)` — plus any
#      ONE adjectival word between count and "skills" (`135 specialized
#      skills`, `135 Godmode skills`) so the dominant adjectival claim shape
#      cannot drift un-gated.
#      "NNN skills", "NNN implemented skills", "NNN-skill", "Skills (NNN)",
#      "(NNN skills)". The real drift classes (126/134/135/151) live here.
#   B. Smaller counts are flagged ONLY with a total-context anchor on the
#      same line, within the match window (~4 words / 40 chars, one sentence):
#      - anchor between number and skills: implemented|total|complete|full
#        ("N implemented skills")
#      - anchor before the number: bundles|catalog|corpus, gap free of digits
#        and periods ("bundles N skills", "skill catalog ... N skills")
#      - anchor after the skills: "N skills total|complete|full"
#      Bare un-anchored counts — subset references like "(15 skills)" or
#      "48 skills" — pass. A hypothetical bare two-digit TOTAL ("it is 85
#      skills") is a documented residual blind spot of this design.
# Blind to "N+ skills", "Skills (N+)", "N.x" section numbers, and path forms
# such as `head -20 skills/foo/SKILL.md` (stripped below before extraction).
CLAIM_RE='\<1[0-9][0-9] +([A-Za-z-]+ +)?[Ss]kills\>|\<1[0-9][0-9]-[Ss]kill|[Ss]kills? \(1[0-9][0-9]\)|\(1[0-9][0-9] +[Ss]kills?\)|\<[0-9]+ +([Ii]mplemented|[Tt]otal|[Cc]omplete|[Ff]ull) +[Ss]kills\>|\<([Bb]undles?|[Cc]atalog|[Cc]orpus)[^.0-9]{0,40}\<[0-9]+ +[Ss]kills\>|\<[0-9]+ +[Ss]kills +([Tt]otal|[Cc]omplete|[Ff]ull)\>'

PASS=0
FAIL=0

separator() {
  echo ""
  echo "=== $1 ==="
}

# ─────────────────────────────────────────────────────────────────────────────
# scan_root <dir> — census every text file under <dir>, print one line per
# stale claim ("path:line: claimed N, disk M"), and set CONSISTENT to the
# number of claims equal to the disk count. Git roots are censused via
# `git ls-files` so extensionless tracked files (e.g. .cursorrules, hooks/)
# are included; non-git roots (self-test fixtures) fall back to `find`.
# ─────────────────────────────────────────────────────────────────────────────
scan_root() {
  local root="$1" raw line file rest lineno text match n consistent=0

  if git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    raw="$(cd "$root" && git ls-files -z | xargs -0 -r grep -IHnE "$CLAIM_RE" 2>/dev/null || true)"
  else
    raw="$(cd "$root" && find . -type f -print0 | xargs -0 -r grep -IHnE "$CLAIM_RE" 2>/dev/null || true)"
  fi

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    file="${line%%:*}"
    rest="${line#*:}"
    lineno="${rest%%:*}"
    text="${rest#*:}"

    # Frozen point-in-time records — historical counts, not live claims:
    case "$file" in
      docs/promises-audit.md) continue ;;                  # frozen audit snapshot
      docs/overnight-session-report.md) continue ;;        # frozen session report
      docs/blog/godmode-meets-autoresearch.md) continue ;; # frozen published blog post
      CHANGELOG.md) continue ;;                            # release history is point-in-time
      PROGRESS.md) continue ;;                             # iteration ledger is point-in-time
    esac

    # Drop path forms (`head -20 skills/foo/SKILL.md`) before extracting.
    text="$(printf '%s\n' "$text" | sed -E 's/\<[0-9]+ +([A-Za-z]+ +)?[Ss]kills?\//X/g')"

    while IFS= read -r match; do
      [ -n "$match" ] || continue
      n="$(printf '%s' "$match" | grep -oE '[0-9]+' | head -1)"
      if [ "$n" = "$actual" ]; then
        consistent=$((consistent + 1))
      else
        printf '%s:%s: claimed %s, disk %s\n' "$file" "$lineno" "$n" "$actual"
      fi
    done < <(printf '%s\n' "$text" | grep -oE "$CLAIM_RE" || true)
  done < <(printf '%s\n' "$raw")

  # Consistent-claim count rides along on the last line (callers run this in a
  # command substitution, so a global would not survive the subshell).
  printf 'CONSISTENT %s\n' "$consistent"
}

# ─────────────────────────────────────────────────────────────────────────────
# EMBEDDED NEGATIVE SELF-TEST — runs on every invocation, before the census.
# A fixture carrying one stale claim and one current claim must produce
# exactly one flag. Stale strings are assembled from variables so this
# script's own source can never trip the real census (the fixture lives in
# a temp dir outside the repo — that is the point).
# ─────────────────────────────────────────────────────────────────────────────
separator "Self-test: detector must flag stale, pass current"

fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT
# Stale A-set fixture number: always three digits, never equal to disk truth.
stale_num="$(( actual == 126 ? 134 : 126 ))"
# Stale B-set fixture number: two digits anchored by "bundles" (corpus stays
# three-digit for the foreseeable horizon, so this can never equal truth).
anchor_num=97

git ls-files > "$fixture/tracked-files.list"
printf 'Godmode ships %s skills.\n' "$stale_num" > "$fixture/stale-fixture.md"
printf 'Godmode ships %s specialized skills.\n' "$stale_num" >> "$fixture/stale-fixture.md"
printf 'Godmode bundles %s skills today.\n' "$anchor_num" >> "$fixture/stale-fixture.md"
printf 'Godmode ships %s skills.\n' "$actual" > "$fixture/current-fixture.md"

selftest_out="$(scan_root "$fixture")"
adj_count="$(printf '%s\n' "$selftest_out" | grep -c "claimed $stale_num, disk $actual" || true)"
if [ "$adj_count" -ge 2 ] \
   && printf '%s\n' "$selftest_out" | grep -q "stale-fixture.md.*claimed $anchor_num, disk $actual" \
   && ! printf '%s\n' "$selftest_out" | grep -q "current-fixture.md"; then
  PASS=$((PASS + 1))
  echo "  PASS: self-test — stale 1xx $stale_num (bare + adjectival) and anchored $anchor_num flagged, current $actual not flagged"
else
  echo "  FAIL: self-test — detector cannot demonstrate detection"
  echo "GATE BROKEN"
  exit 2
fi

# ─────────────────────────────────────────────────────────────────────────────
# CENSUS — scan the requested root and compare every claim to disk truth
# ─────────────────────────────────────────────────────────────────────────────
separator "Census: prose claims vs disk count ($actual)"

census_out="$(scan_root "$ROOT")"
CONSISTENT="$(printf '%s\n' "$census_out" | sed -n 's/^CONSISTENT //p')"
[ -n "$CONSISTENT" ] || CONSISTENT=0
stale_out="$(printf '%s\n' "$census_out" | grep -v '^CONSISTENT ' || true)"
if [ -n "$stale_out" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    FAIL=$((FAIL + 1))
    echo "  FAIL: $line"
  done < <(printf '%s\n' "$stale_out")
else
  PASS=$((PASS + 1))
  echo "  PASS: no stale prose claims under $ROOT"
fi

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "============================================"
echo "  VALIDATION RESULTS"
echo "============================================"
echo "  Disk skill count: $actual"
echo "  Claims consistent with disk: $CONSISTENT"
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
echo "============================================"

if [ "$FAIL" -gt 0 ]; then
  echo "  STATUS: FAIL — stale skill-count claims in live files"
  echo "============================================"
  exit 1
else
  echo "  STATUS: PASS"
  echo "============================================"
  exit 0
fi
