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
    parsed = parse_invoice_args(args)
    if parsed is None:
        return 2
    customer, month_text = parsed
    month, error = validate_invoice(customer, month_text)
    if error:
        print(error)
        return 1
    rows = select_rows(customer, month)
    totals = compute_totals(rows)
    render_invoice(customer, month, rows, totals)
    return 0


def parse_invoice_args(args):
    if len(args) != 2:
        print(USAGE)
        return None
    return args[0].upper(), args[1]


def validate_invoice(customer, month_text):
    try:
        month = int(month_text)
    except ValueError:
        return 0, "error: month must be an integer"
    if customer not in CUSTOMERS:
        return 0, "error: unknown customer: " + customer
    if month < 1 or month > 12:
        return 0, "error: month must be 1-12"
    return month, None


def select_rows(customer, month):
    rows = []
    for sale in SALES:
        if sale["customer"] == customer and sale["month"] == month:
            rows.append(sale)
    return rows


def compute_totals(rows):
    subtotal = 0
    for sale in rows:
        subtotal = subtotal + sale["qty"] * sale["price"]
    discount = 0
    if subtotal >= DISCOUNT_MIN:
        discount = subtotal * DISCOUNT_RATE // 100
    taxable = subtotal - discount
    tax = taxable * TAX_RATE // 100
    return subtotal, discount, tax, taxable + tax


def sorted_lines(rows):
    decorated = []
    for sale in rows:
        decorated.append((sale["qty"] * sale["price"], sale))
    decorated.sort(key=lambda pair: pair[0], reverse=True)
    return decorated


def render_invoice(customer, month, rows, totals):
    subtotal, discount, tax, total = totals
    print("invoice for " + customer)
    print("month: " + str(month))
    if not rows:
        print("(no charges)")
    for amount, sale in sorted_lines(rows):
        line = "  " + sale["desc"] + " x" + str(sale["qty"])
        print(line + " @" + str(sale["price"]) + " = " + str(amount))
    print("subtotal: " + str(subtotal))
    print("discount: " + str(discount))
    print("tax: " + str(tax))
    print("total: " + str(total))


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
