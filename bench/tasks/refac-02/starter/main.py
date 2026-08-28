#!/usr/bin/env python3
"""invocli - renders a monthly invoice from the fixed in-house ledger."""
import sys

from ledger import CUSTOMERS, SALES

USAGE = "usage: main.py invoice <customer> <month 1-12>"
TAX_RATE = 8
DISCOUNT_RATE = 10
DISCOUNT_MIN = 500


def main(argv):
    if len(argv) >= 1 and argv[0] == "invoice":
        return build_invoice(argv[1:])
    print(USAGE)
    return 2


def build_invoice(args):
    # -- parse arguments --
    if len(args) != 2:
        print(USAGE)
        return 2
    customer = args[0].upper()
    month = None
    try:
        month = int(args[1])
    except ValueError:
        print("error: month must be an integer")
        return 1
    # -- validate --
    if customer not in CUSTOMERS:
        print("error: unknown customer: " + customer)
        return 1
    if month < 1 or month > 12:
        print("error: month must be 1-12")
        return 1
    # -- select ledger rows --
    rows = []
    for sale in SALES:
        if sale["customer"] == customer and sale["month"] == month:
            rows.append(sale)
    # -- compute totals --
    subtotal = 0
    for sale in rows:
        subtotal = subtotal + sale["qty"] * sale["price"]
    discount = 0
    if subtotal >= DISCOUNT_MIN:
        discount = subtotal * DISCOUNT_RATE // 100
    taxable = subtotal - discount
    tax = taxable * TAX_RATE // 100
    total = taxable + tax
    # -- render (largest charge first) --
    print("invoice for " + customer)
    print("month: " + str(month))
    if not rows:
        print("(no charges)")
    decorated = []
    for sale in rows:
        decorated.append((sale["qty"] * sale["price"], sale))
    decorated.sort(key=lambda pair: pair[0], reverse=True)
    for amount, sale in decorated:
        line = "  " + sale["desc"] + " x" + str(sale["qty"])
        line = line + " @" + str(sale["price"]) + " = " + str(amount)
        print(line)
    print("subtotal: " + str(subtotal))
    print("discount: " + str(discount))
    print("tax: " + str(tax))
    print("total: " + str(total))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
