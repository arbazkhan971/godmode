#!/usr/bin/env bash
# =============================================================================
# token-bench.sh — Token cost benchmark for godmode skill routing.
# =============================================================================
# Measures the approximate token cost of Tier 1 routing across all 135 skills,
# using the chars/4 heuristic documented in skills/tokens/SKILL.md.
#
# Two numbers are produced:
#   tier1_tokens  — sum of tokens read by Tier 1 routing (frontmatter +
#                   `## Activate When` block) across all routable skills.
#   full_tokens   — sum of tokens that would be read by full-file routing.
#                   Used to verify the README claim of "~90% routing-time
#                   context reduction."
#
# Output (stdout):
#   tier1_tokens: N
#   full_tokens:  N
#   reduction:    N    (integer percent, e.g. 89 for 89%)
#
# Lower tier1_tokens is better (cheaper routing). Higher reduction is better
# (closer to the claimed 90%). Both numbers feed phase B optimize loop.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"

# Tier 1 extractor — same algorithm as tests/route-eval.sh tier1_block().
# Extracts frontmatter + `## Activate When` block.
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

# chars / 4 heuristic from skills/tokens/SKILL.md.
chars_to_tokens() {
  awk -v c="$1" 'BEGIN { print int((c + 3) / 4) }'
}

tier1_chars=0
full_chars=0
n=0

for f in "$SKILLS_DIR"/*/SKILL.md; do
  [ -f "$f" ] || continue
  n=$((n + 1))

  fc=$(wc -c < "$f" | tr -d ' ')
  full_chars=$((full_chars + fc))

  tc=$(tier1_block "$f" | wc -c | tr -d ' ')
  tier1_chars=$((tier1_chars + tc))
done

tier1_tokens=$(chars_to_tokens "$tier1_chars")
full_tokens=$(chars_to_tokens "$full_chars")

if [ "$full_tokens" -eq 0 ]; then
  reduction=0
else
  reduction=$(( (full_tokens - tier1_tokens) * 100 / full_tokens ))
fi

echo "skills:       $n"
echo "tier1_tokens: $tier1_tokens"
echo "full_tokens:  $full_tokens"
echo "reduction:    $reduction"
