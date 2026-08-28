#!/usr/bin/env python3
"""ledger-join -- enrich orders with customer names.

Usage: python3 main.py ORDERS.csv CUSTOMERS.csv
Prints one line per order: ORDER_ID,CUSTOMER_NAME,AMOUNT
Orders keep their input-file order. Every customer id in the orders
export is guaranteed to exist in the customers export.
"""
import sys

import recordfile


def join_orders(orders, customers):
    """Attach each order's customer name, matched on customer id."""
    rows = []
    for order in orders:
        order_id, cust_id, amount = order[0], order[1], order[2]
        name = None
        for cust in customers:
            if cust[0] == cust_id:
                name = cust[1]
                break
        rows.append((order_id, name, amount))
    return rows


def render(rows):
    return "".join("%s,%s,%s\n" % row for row in rows)


def main(argv):
    if len(argv) != 3:
        sys.stderr.write("usage: main.py ORDERS.csv CUSTOMERS.csv\n")
        return 2
    orders = recordfile.read_rows(argv[1])
    customers = recordfile.read_rows(argv[2])
    sys.stdout.write(render(join_orders(orders, customers)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
