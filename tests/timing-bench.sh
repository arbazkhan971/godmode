#!/usr/bin/env bash
# =============================================================================
# timing-bench.sh — Measure orchestrator routing-time and stack-detection
# claims from skills/godmode/SKILL.md § Quality Targets.
# =============================================================================
# Claims under test:
#   - "Skill routing: <2s to match and dispatch"  (line 206)
#   - "Stack detection: <5s for full project analysis"  (line 207)
#
# Methodology: time the actual shell operations the orchestrator performs
# at each step. Bash-side cost only; agent-roundtrip cost (model latency)
# is not measured here — it dominates wall time but is not what the claim
# says ("to match and dispatch" = the shell-level routing operation).
#
# Output: timed numbers in milliseconds plus pass/fail per claim.
# =============================================================================

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

ms_now() {
  python3 -c 'import time; print(int(time.time() * 1000))'
}

# Stack-detection: same commands as skills/godmode/SKILL.md § Step 1.
t0=$(ms_now)
ls package.json pyproject.toml Cargo.toml go.mod Gemfile pom.xml 2>/dev/null > /dev/null || true
ls yarn.lock pnpm-lock.yaml uv.lock package-lock.json 2>/dev/null > /dev/null || true
t1=$(ms_now)
stack_ms=$((t1 - t0))

# Tier 1 routing scan: read Tier 1 of every skill (mirrors orchestrator Step 2).
t0=$(ms_now)
for f in skills/*/SKILL.md; do
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; print; next }
    in_fm && $0 == "---" { in_fm = 0; print; next }
    in_fm { print; next }
    /^## Activate When/ { in_aw = 1; print; next }
    in_aw && /^## / { exit }
    in_aw { print }
  ' "$f" > /dev/null
done
t1=$(ms_now)
tier1_ms=$((t1 - t0))

# Full eval (all 100 prompts routed): a real end-to-end stress test.
t0=$(ms_now)
bash tests/route-eval.sh > /dev/null
t1=$(ms_now)
eval_ms=$((t1 - t0))

echo "stack_detection_ms: $stack_ms"
echo "tier1_routing_ms:   $tier1_ms"
echo "full_eval_100_ms:   $eval_ms"

stack_target=5000
tier1_target=2000

stack_status=PASS
tier1_status=PASS
[ "$stack_ms" -le "$stack_target" ] || stack_status=FAIL
[ "$tier1_ms" -le "$tier1_target" ] || tier1_status=FAIL

echo "claim_stack_<5s:    $stack_status"
echo "claim_tier1_<2s:    $tier1_status"
