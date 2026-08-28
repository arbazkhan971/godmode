"""Cart helpers for checkout reconciliation.

Item lines are "sku qty unit_price", e.g. "mug 2 4.50".
"""


def add_items(item_lines, cart=None):
    """Append every item line to CART and return the cart."""
    if cart is None:
        cart = []
    for line in item_lines:
        sku, qty, price = line.split()
        cart.append((sku, int(qty), float(price)))
    return cart


def cart_total(cart):
    """Return the cart's total price, rounded to cents."""
    return round(sum(qty * price for _sku, qty, price in cart), 2)
