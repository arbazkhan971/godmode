"""Fixed sales ledger used by the invoicing CLI."""

CUSTOMERS = ("ACME", "GLOBEX", "INITECH")

SALES = [
    {"customer": "ACME", "month": 3, "desc": "anvil", "qty": 2, "price": 100},
    {"customer": "ACME", "month": 3, "desc": "rope", "qty": 5, "price": 4},
    {"customer": "ACME", "month": 3, "desc": "trap", "qty": 1, "price": 300},
    {"customer": "ACME", "month": 4, "desc": "anvil", "qty": 1, "price": 100},
    {"customer": "GLOBEX", "month": 3, "desc": "fin", "qty": 3, "price": 20},
    {"customer": "GLOBEX", "month": 5, "desc": "fin", "qty": 2, "price": 22},
    {"customer": "INITECH", "month": 4, "desc": "tps report", "qty": 10, "price": 1},
]
