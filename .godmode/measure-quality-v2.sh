#!/bin/bash
cd /Users/arbaz/randomproject/godmode
total=0; count=0

for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  count=$((count + 1))
  score=0
  lines=$(wc -l < "$f")
  
  if [ "$lines" -gt 400 ]; then score=$(( score + (lines - 400) / 5 )); fi
  if [ "$lines" -lt 80 ]; then score=$((score + 10)); fi
  
  grep -qiE "Keep.*Discard" "$f" || score=$((score + 5))
  grep -qiE "Stop.*Condition" "$f" || score=$((score + 5))
  grep -qiE "Success Criteria" "$f" || score=$((score + 5))
  grep -qiE "Error Recovery" "$f" || score=$((score + 5))
  grep -qiE "Output Format" "$f" || score=$((score + 5))
  grep -qiE "TSV Logging" "$f" || score=$((score + 5))
  grep -qiE "Hard Rules|HARD RULES|Key Behaviors" "$f" || score=$((score + 5))
  grep -qiE "Workflow|## Step" "$f" || score=$((score + 5))
  grep -qiE "Activate.*When|When to Activate" "$f" || score=$((score + 5))
  
  v=$(grep -ciE '\b(consider|maybe|might|perhaps|possibly|should consider|you may|optionally|if desired|as needed|it depends|generally|typically|usually|probably|basically|simply|just)\b' "$f" || true)
  score=$((score + ${v:-0}))
  
  p=$(grep -ciE '\b(is being|was being|has been|have been|will be|should be|must be|can be|are being|were being)\b' "$f" || true)
  score=$((score + ${p:-0} / 2))
  
  dupes=$(sort "$f" | uniq -c | sort -rn | awk '$1 >= 3 && length($0) > 20 {count++} END {print count+0}')
  score=$((score + dupes * 2))
  
  cb=$(grep -c '```' "$f" || true)
  if [ "${cb:-0}" -lt 2 ]; then score=$((score + 3)); fi
  
  w=$(grep -ciE '^\s*(note:|tip:|hint:|fyi:|remember:|keep in mind|be aware|be careful|be sure to|make sure to|try to|aim to)' "$f" || true)
  score=$((score + ${w:-0} * 2))
  
  if ! head -1 "$f" | grep -q '^---'; then score=$((score + 5)); fi
  
  total=$((total + score))
done

echo "scale=2; $total / $count" | bc
