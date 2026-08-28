#!/usr/bin/env bash
# metric perf-01: wfreq finishes the 30k-token workload within the 2s cap with the exact expected frequency table. Immutable during benchmark runs (runner SHA256-checksums this file).
# Margins measured on authoring host (python3.12, 4-core): pristine starter ~8.0s, reference solution ~0.07s, cap 2s.
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

cat > "$tmp/gen_expect.py" <<'PYEOF'
import sys

N_TOKENS = 30000
VOCAB = 18000

state = 987654321


def rnd(mod):
    global state
    state = (state * 6364136223846793005 + 1442695040888963407) % (1 << 64)
    return (state >> 33) % mod


def main(words_path, expected_path):
    counts = {}
    with open(words_path, "w", encoding="utf-8") as fh:
        for _ in range(N_TOKENS):
            tok = "w%d" % rnd(VOCAB)
            fh.write(tok + "\n")
            counts[tok] = counts.get(tok, 0) + 1
    ranked = sorted(counts.items(), key=lambda e: (-e[1], e[0]))
    with open(expected_path, "w", encoding="utf-8") as fh:
        fh.writelines("%s %d\n" % (word, count) for word, count in ranked)


main(sys.argv[1], sys.argv[2])
PYEOF
"$PY" "$tmp/gen_expect.py" "$tmp/words.txt" "$tmp/expected.txt" || die "input generator failed"

"$TO" 2 "$PY" starter/main.py "$tmp/words.txt" > "$tmp/out.txt" 2> "$tmp/err.txt"
rc=$?
[ "$rc" -eq 124 ] && die "too slow: killed by 2s cap"
[ "$rc" -eq 0 ] || die "starter/main.py exited rc=$rc"

cmp -s "$tmp/out.txt" "$tmp/expected.txt" || die "output does not match expected frequency table"
echo "METRIC: PASS"
exit 0
