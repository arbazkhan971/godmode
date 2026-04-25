#!/usr/bin/env bash
# accuracy-guard.sh — pass if routing accuracy >= threshold (default 100).
# Use as a guard in phase-B trim agents: editing must not regress accuracy.
# Usage: bash tests/accuracy-guard.sh [threshold]
set -euo pipefail
threshold="${1:-100}"
acc=$(bash "$(dirname "$0")/route-eval.sh" | tail -1 | awk '{print $2}')
if [ "$acc" -ge "$threshold" ]; then
  echo "guard pass: accuracy=$acc% (threshold=$threshold%)"
  exit 0
fi
echo "guard fail: accuracy=$acc% (threshold=$threshold%)"
exit 1
