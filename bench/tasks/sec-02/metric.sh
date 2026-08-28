#!/usr/bin/env bash
# metric sec-02: thumbnail digests must survive malicious filenames without executing embedded shell payloads. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.py ] || die "missing starter/main.py"

fx="$tmp/fixture"; mkdir -p "$fx"
printf 'PNGDATA-photo-0001\n' > "$fx/photo.png"
printf 'PNGDATA-icon-0002\n' > "$fx/icon.svg"
printf 'PNGDATA-spaced-0003\n' > "$fx/my photo.png"

# expected digests come from a metric-owned helper, never from the starter
cat > "$tmp/expect.py" <<'EOF'
import hashlib
import sys
for p in sys.argv[1:]:
    with open(p, "rb") as fh:
        print(hashlib.sha256(fh.read()).hexdigest())
EOF
d_photo="$($TO 5 "$PY" "$tmp/expect.py" "$fx/photo.png")" || die "helper: photo digest"
d_icon="$($TO 5 "$PY" "$tmp/expect.py" "$fx/icon.svg")" || die "helper: icon digest"
d_spaced="$($TO 5 "$PY" "$tmp/expect.py" "$fx/my photo.png")" || die "helper: spaced digest"

# 1) benign simple filename -> exact digest
out="$($TO 10 "$PY" starter/main.py thumb "$fx/photo.png" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "thumb photo.png: exit $rc, want 0"
[ "$out" = "$d_photo" ] || die "thumb photo.png: wrong digest"

# 2) benign filename containing a space -> exact digest
out="$($TO 10 "$PY" starter/main.py thumb "$fx/my photo.png" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "thumb spaced: exit $rc, want 0"
[ "$out" = "$d_spaced" ] || die "thumb spaced: wrong digest"

# 3) injection payload: embedded command must not run, no digest printed
m="$tmp/marker"
out="$($TO 10 "$PY" starter/main.py thumb "$fx/photo.png; touch $m" 2>/dev/null)"; rc=$?
[ "$rc" -ne 0 ] || die "injection payload: exit 0, want nonzero"
[ ! -e "$m" ] || die "injection payload: marker file was created"
[ "$out" != "$d_photo" ] || die "injection payload: digest printed for bad name"

# 4) batch over the fixture dir: sorted, exact "name digest" lines
out="$($TO 10 "$PY" starter/main.py batch "$fx" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "batch: exit $rc, want 0"
want="icon.svg $d_icon
my photo.png $d_spaced
photo.png $d_photo"
[ "$out" = "$want" ] || die "batch: wrong output"

echo "METRIC: PASS sec-02"
exit 0
