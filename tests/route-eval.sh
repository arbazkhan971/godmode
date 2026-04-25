#!/usr/bin/env bash
# =============================================================================
# route-eval.sh — Routing accuracy benchmark for godmode skill matching.
# =============================================================================
# Mirrors the algorithm in skills/godmode/SKILL.md § Step 2:
#   1. Canonical trigger table (exact substring match)
#   2. Tier 1 keyword scan (frontmatter description + Activate When bullets)
#   3. Tie-break: shorter Activate When list wins
#
# Reads tests/route-eval-prompts.tsv (prompt<TAB>expected_skill).
# Prints per-prompt result + final accuracy line. Exit 0 always; CI/optimize
# loop reads the accuracy number, never the exit code.
#
# Output (stdout):
#   PASS|FAIL  prompt  -> matched_skill (expected: expected_skill)
#   accuracy: N    (N is integer 0-100)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROMPTS="$SCRIPT_DIR/route-eval-prompts.tsv"
SKILLS_DIR="$ROOT_DIR/skills"

if [ ! -f "$PROMPTS" ]; then
  echo "missing prompts file: $PROMPTS" >&2
  exit 2
fi

# Canonical trigger shortcuts (skills/godmode/SKILL.md § Step 2).
# Keyed by lowercase substring; first match wins. ORDER MATTERS:
# narrower domain triggers come before generic "build"/"test"/"implement"
# so the latter don't intercept domain-specific prompts.
canonical_match() {
  local p; p="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$p" in
    *"prior art"*|*"research"*)                                                   echo research ;;
    *"integration test"*|*"integration testing"*)        echo integration ;;
    *"end to end"*|*"end-to-end"*|*"e2e test"*)          echo e2e ;;
    *"load test"*|*"stress test"*)                       echo loadtest ;;
    *"docker image"*|*"dockerfile"*|*"container image"*) echo docker ;;
    *"rate limiting"*|*"rate limit"*|*"throttling"*)     echo ratelimit ;;
    *"react component"*|*"react hook"*|*"jsx"*)          echo react ;;
    *"vue page"*|*"vue component"*|*"composition api"*)  echo vue ;;
    *"nextjs"*|*"next.js"*|*"app router"*)               echo nextjs ;;
    *"django view"*|*"django model"*|*"django orm"*)     echo django ;;
    *"fastapi route"*|*"fastapi endpoint"*)              echo fastapi ;;
    *"rails controller"*|*"rails model"*|*"active record"*)  echo rails ;;
    *"openapi spec"*|*"openapi schema"*|*"rest api spec"*)   echo api ;;
    *"design the architecture"*|*"system architecture"*)     echo architect ;;
    *"event sourcing"*|*"event-driven architecture"*)        echo event ;;
    *"make faster"*|*"optimize"*|*"slow"*|*"response time"*|*"p99"*|*"latency"*)  echo optimize ;;
    *"why is this"*|*"debug"*|*"leaking"*|*"segfault"*|*"trace this"*)            echo debug ;;
    *"is red"*|*" red "*|*"failing"*|*"errored"*|*"broken"*|*"error"*|*"fix"*)    echo fix ;;
    *"vulnerabilities"*|*"secure"*)                                               echo secure ;;
    *"check my code"*|*"look over this pr"*|*"pull request"*|*"review"*)          echo review ;;
    *"break down"*|*"plan"*)                                                      echo plan ;;
    *"deploy"*|*"ship"*)                                                          echo ship ;;
    *"wrap up"*|*"clean up"*|*"finish"*|*"done"*)                                 echo finish ;;
    *"compress output"*|*"terse"*)                                                echo terse ;;
    *"token budget"*|*"tokens"*)                                                  echo tokens ;;
    *"command patterns"*|*"stdio"*)                                               echo stdio ;;
    *"bundle"*|*"team"*)                                                          echo team ;;
    *"get started"*|*"first run"*|*"onboarding"*|*"tutorial"*)                    echo tutorial ;;
    *"benchmark"*|*"bench"*)                                                      echo bench ;;
    *"coverage"*|*"test"*)                                                        echo test ;;
    *"implement"*|*"create"*|*"build"*)                                           echo build ;;
    *) return 1 ;;
  esac
}

# Tier 1 extractor — extracts the `## Activate When` block.
# The awk in skills/godmode/SKILL.md § Step 2 has a fallthrough `{print}` bug
# that emits the entire file when a skill has no `## Activate When` (e.g.
# principles, which is intentionally routing-invisible). This runner
# implements the algorithm as documented in prose (Tier 1 = frontmatter +
# Activate When block, ending at the next `##`), not the buggy awk.
tier1_block() {
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; print; next }
    in_fm && $0 == "---" { in_fm = 0; print; next }
    in_fm { print; next }
    /^## Activate When/ { in_aw = 1; print; next }
    in_aw && /^## / { exit }
    in_aw { print }
  ' "$1"
}

# Tier 1 keyword scan: count overlap between prompt words and tier-1 block.
# Tie-break: shorter Activate When list wins (proxy: tier-1 byte count).
tier1_match() {
  local prompt; prompt="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]' ' ')"
  local best_skill="" best_score=0 best_size=999999
  for f in "$SKILLS_DIR"/*/SKILL.md; do
    [ -f "$f" ] || continue
    local skill; skill="$(basename "$(dirname "$f")")"
    local block; block="$(tier1_block "$f" 2>/dev/null | tr '[:upper:]' '[:lower:]')"
    [ -n "$block" ] || continue
    local score=0
    for word in $prompt; do
      [ "${#word}" -ge 3 ] || continue
      case "$block" in *"$word"*) score=$((score + 1)) ;; esac
    done
    if [ "$score" -gt 0 ]; then
      local size; size=${#block}
      if [ "$score" -gt "$best_score" ] || { [ "$score" -eq "$best_score" ] && [ "$size" -lt "$best_size" ]; }; then
        best_score=$score
        best_size=$size
        best_skill=$skill
      fi
    fi
  done
  if [ -n "$best_skill" ]; then
    echo "$best_skill"
    return 0
  fi
  return 1
}

# Route a single prompt: canonical first, then tier-1, else "unmatched".
route() {
  local prompt="$1" matched
  if matched="$(canonical_match "$prompt")"; then
    echo "$matched"
  elif matched="$(tier1_match "$prompt")"; then
    echo "$matched"
  else
    echo "unmatched"
  fi
}

# Main loop.
total=0
pass=0
while IFS=$'\t' read -r prompt expected; do
  case "$prompt" in ''|'#'*) continue ;; esac
  total=$((total + 1))
  matched="$(route "$prompt")"
  if [ "$matched" = "$expected" ]; then
    pass=$((pass + 1))
    echo "PASS  $prompt -> $matched"
  else
    echo "FAIL  $prompt -> $matched (expected: $expected)"
  fi
done < "$PROMPTS"

if [ "$total" -eq 0 ]; then
  echo "no prompts found in $PROMPTS" >&2
  exit 2
fi

accuracy=$(( pass * 100 / total ))
echo "accuracy: $accuracy"
