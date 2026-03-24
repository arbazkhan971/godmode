#!/bin/bash
# Godmode quality metric v3 — SOTA measurement. Lower is better.
# Dimensions: language quality, structural completeness, autoresearch alignment, conciseness
cd /Users/arbaz/randomproject/godmode
total=0; count=0

for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  count=$((count + 1))
  score=0
  lines=$(wc -l < "$f")
  words=$(wc -w < "$f")
  
  # === LANGUAGE QUALITY (max ~30 per file) ===
  # Vague words (1pt each)
  v=$(grep -ciE '\b(consider|maybe|might|perhaps|possibly|you may|optionally|if desired|as needed|it depends|generally|typically|usually|probably|basically|simply|just|some|various|appropriate|relevant|suitable|certain|ensure|leverage|utilize)\b' "$f" || true)
  score=$((score + ${v:-0}))
  
  # Passive voice (1pt per 2)
  p=$(grep -ciE '\b(is being|was being|has been|have been|will be|should be|must be|can be|are being|were being|could be|would be)\b' "$f" || true)
  score=$((score + ${p:-0} / 2))
  
  # Weak imperatives (2pt each)
  w=$(grep -ciE '^\s*(note:|tip:|hint:|fyi:|remember:|keep in mind|be aware|be careful|be sure to|make sure to|try to|aim to|feel free)' "$f" || true)
  score=$((score + ${w:-0} * 2))
  
  # Filler phrases (1pt each)
  filler=$(grep -ciE '\b(in order to|at the end of the day|for the purpose of|with respect to|in terms of|on the other hand|as a matter of fact|it is important to|it should be noted|the fact that|in the event that|prior to|subsequent to)\b' "$f" || true)
  score=$((score + ${filler:-0}))
  
  # === STRUCTURAL COMPLETENESS (max 45 per file) ===
  grep -qiE "Keep.*Discard" "$f" || score=$((score + 5))
  grep -qiE "Stop.*Condition" "$f" || score=$((score + 5))
  grep -qiE "Success Criteria" "$f" || score=$((score + 5))
  grep -qiE "Error Recovery" "$f" || score=$((score + 5))
  grep -qiE "Output Format" "$f" || score=$((score + 5))
  grep -qiE "TSV Logging" "$f" || score=$((score + 5))
  grep -qiE "Hard Rules|HARD RULES|Key Behaviors" "$f" || score=$((score + 5))
  grep -qiE "Workflow|## Step" "$f" || score=$((score + 5))
  grep -qiE "Activate.*When|When to Activate" "$f" || score=$((score + 5))
  
  # === CONCISENESS (scaled) ===
  # Bloat: >350 lines
  if [ "$lines" -gt 350 ]; then score=$(( score + (lines - 350) / 5 )); fi
  # Too thin: <60 lines
  if [ "$lines" -lt 60 ]; then score=$((score + 15)); fi
  
  # Duplicates
  dupes=$(sort "$f" | uniq -c | sort -rn | awk '$1 >= 3 && length($0) > 20 {count++} END {print count+0}')
  score=$((score + dupes * 2))
  
  # No code blocks
  cb=$(grep -c '```' "$f" || true)
  if [ "${cb:-0}" -lt 2 ]; then score=$((score + 3)); fi
  
  # No frontmatter
  head -1 "$f" | grep -q '^---' || score=$((score + 5))
  
  # === AUTORESEARCH ALIGNMENT (max 20 per file) ===
  # Missing loop/iteration language (5pt)
  grep -qiE "loop|iterate|round|WHILE|repeat" "$f" || score=$((score + 5))
  # Missing metric/measurement language (5pt)  
  grep -qiE "metric|measure|baseline|guard|verify" "$f" || score=$((score + 5))
  # Missing revert/rollback language (3pt)
  grep -qiE "revert|rollback|reset|discard" "$f" || score=$((score + 3))
  # Missing autonomous language (3pt)
  grep -qiE "autonomous|never ask|do not pause|never stop|loop until" "$f" || score=$((score + 3))
  
  total=$((total + score))
done

echo "scale=2; $total / $count" | bc
