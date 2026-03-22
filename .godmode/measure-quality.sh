#!/bin/bash
cd /Users/arbaz/randomproject/godmode
total_score=0
file_count=0

for f in skills/*/SKILL.md; do
  [ -f "$f" ] || continue
  file_count=$((file_count + 1))
  lines=$(wc -l < "$f")
  
  # Penalty: bloat (>500 lines)
  if [ "$lines" -gt 500 ]; then
    bloat_penalty=$(( (lines - 500) / 10 ))
    total_score=$((total_score + bloat_penalty))
  fi
  
  # Penalty: vague words
  vague=$(grep -ciE '\b(consider|maybe|might|perhaps|possibly|should consider|you may|optionally|if desired|as needed)\b' "$f" || true)
  vague=${vague:-0}
  total_score=$((total_score + vague))
  
  # Penalty: missing key sections
  for section in "Keep.*Discard" "Stop.*Condition" "Success Criteria" "Error Recovery" "Output Format" "TSV Logging"; do
    if ! grep -qiE "$section" "$f" 2>/dev/null; then
      total_score=$((total_score + 5))
    fi
  done
  
  # Penalty: no code blocks
  codeblocks=$(grep -c '```' "$f" || true)
  codeblocks=${codeblocks:-0}
  if [ "$codeblocks" -lt 2 ]; then
    total_score=$((total_score + 3))
  fi
  
  # Penalty: passive voice
  passive=$(grep -ciE '\b(is being|was being|has been|have been|will be|should be|must be|can be)\b' "$f" || true)
  passive=${passive:-0}
  total_score=$((total_score + passive / 2))
done

if [ "$file_count" -gt 0 ]; then
  echo "scale=2; $total_score / $file_count" | bc
else
  echo "999"
fi
