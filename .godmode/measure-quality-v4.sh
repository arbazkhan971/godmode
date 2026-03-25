#!/bin/bash
cd /Users/arbaz/randomproject/godmode
total=0; count=0

for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  count=$((count + 1))
  score=0
  lines=$(wc -l < "$f")
  
  # CONCISENESS (target: 150-300)
  if [ "$lines" -gt 300 ]; then score=$(( score + (lines - 300) / 10 )); fi
  if [ "$lines" -lt 100 ]; then score=$((score + (100 - lines) / 5)); fi
  
  # COMMAND SPECIFICITY — reward concrete shell commands
  shell_cmds=$(grep -cE '^\s*(npm |npx |yarn |pnpm |pytest |cargo |go |rspec |mvn |git |docker |kubectl |curl |grep |jq |uv |pip )' "$f" || true)
  if [ "${shell_cmds:-0}" -lt 1 ]; then score=$((score + 3)); fi
  
  # DECISION TREES — reward IF/THEN/ELSE patterns
  decisions=$(grep -ciE '^\s*(if |IF |elif |ELIF |else|ELSE|WHEN )' "$f" || true)
  if [ "${decisions:-0}" -lt 2 ]; then score=$((score + 2)); fi
  
  # NUMERICAL THRESHOLDS — reward concrete numbers
  numbers=$(grep -cE '[0-9]+%|[0-9]+ms|[0-9]+MB|<[0-9]|>[0-9]' "$f" || true)
  if [ "${numbers:-0}" -lt 3 ]; then score=$((score + 2)); fi
  
  # PROSE BLOAT — long lines that aren't code/tables
  prose_lines=$(awk 'length > 120 && !/^[|`#>*-]/ && !/^\s{4}/' "$f" | wc -l || true)
  if [ "${prose_lines:-0}" -gt 5 ]; then score=$((score + (prose_lines - 5))); fi
  
  # FRONTMATTER
  head -1 "$f" | grep -q '^---' || score=$((score + 5))
  
  # CARRY FORWARD
  grep -qiE "Keep.*Discard" "$f" || score=$((score + 5))
  grep -qiE "Stop.*Condition" "$f" || score=$((score + 5))
  grep -qiE "autonomous|never ask|do not pause|never stop|loop until" "$f" || score=$((score + 3))
  grep -qiE "revert|rollback|reset|discard" "$f" || score=$((score + 3))
  
  total=$((total + score))
done

echo "scale=2; $total / $count" | bc
