#!/usr/bin/env bash
# metric perf-02: ledger-join finishes the 45k-orders x 10k-customers workload within the 2s cap with the exact expected join output. Immutable during benchmark runs (runner SHA256-checksums this file).
# Margins measured on authoring host (python3.12, 4-core): pristine starter ~8.4s, reference solution ~0.13s, cap 2s.
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

cat > "$tmp/gen_expect.py" <<'PYEOF'
import sys

N_ORDERS = 45000
N_CUSTOMERS = 10000

state = 42


def rnd(mod):
    global state
    state = (state * 6364136223846793005 + 1442695040888963407) % (1 << 64)
    return (state >> 33) % mod


def main(orders_path, customers_path, expected_path):
    customers = [("c%05d" % i, "cust_%05d" % rnd(99999)) for i in range(N_CUSTOMERS)]
    for i in range(N_CUSTOMERS - 1, 0, -1):
        j = rnd(i + 1)
        customers[i], customers[j] = customers[j], customers[i]
    names = dict(customers)
    with open(customers_path, "w", encoding="utf-8") as fh:
        fh.writelines("%s,%s\n" % row for row in customers)
    with open(orders_path, "w", encoding="utf-8") as fh:
        for i in range(N_ORDERS):
            order_id = "o%06d" % i
            cust_id = "c%05d" % rnd(N_CUSTOMERS)
            amount = str(rnd(50000) + 100)
            fh.write("%s,%s,%s\n" % (order_id, cust_id, amount))
    with open(expected_path, "w", encoding="utf-8") as fh:
        fh.writelines("%s,%s,%s\n" % (oid, names[cid], amt)
                      for oid, cid, amt in read_orders(orders_path))


def read_orders(path):
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            yield tuple(line.rstrip("\n").split(","))


main(sys.argv[1], sys.argv[2], sys.argv[3])
PYEOF
"$PY" "$tmp/gen_expect.py" "$tmp/orders.csv" "$tmp/customers.csv" "$tmp/expected.txt" || die "input generator failed"

"$TO" 2 "$PY" starter/main.py "$tmp/orders.csv" "$tmp/customers.csv" > "$tmp/out.txt" 2> "$tmp/err.txt"
rc=$?
[ "$rc" -eq 124 ] && die "too slow: killed by 2s cap"
[ "$rc" -eq 0 ] || die "starter/main.py exited rc=$rc"

cmp -s "$tmp/out.txt" "$tmp/expected.txt" || die "output does not match expected join result"
echo "METRIC: PASS perf-02"
exit 0
