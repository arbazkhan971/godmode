#!/usr/bin/env python3
"""Checkout reconciliation: print the total of every order in a sheet.

Usage:
  main.py ORDERS    read the order sheet from ORDERS
  main.py -         read the order sheet from stdin

An order sheet contains one or more blocks like:

    ORDER alpha
    mug 2 4.50
    pen 3 1.25
"""
import sys

from orderkit import add_items, cart_total


def read_source(arg):
    """Return the raw sheet text for a path, or stdin when arg is '-'."""
    if arg == "-":
        return sys.stdin.read()
    with open(arg, "r", encoding="utf-8") as fh:
        return fh.read()


def split_orders(text):
    """Split a sheet into (name, item-line list) pairs, in sheet order."""
    orders = []
    name, items = None, []
    for line in text.splitlines():
        if line.startswith("ORDER "):
            if name is not None:
                orders.append((name, items))
            name, items = line.split(None, 1)[1].strip(), []
        elif line.strip():
            items.append(line.strip())
    if name is not None:
        orders.append((name, items))
    return orders


def main(argv):
    if len(argv) != 2:
        print("usage: main.py ORDERS|-", file=sys.stderr)
        return 2
    try:
        text = read_source(argv[1])
    except OSError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    for name, items in split_orders(text):
        cart = add_items(items)
        print(f"ORDER {name}: ${cart_total(cart):.2f}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
