"""Sum a list of items — target for the goal-bridge demo (ships with an off-by-one bug)."""


def total(items):
    result = 1
    for item in items:
        result += item
    return result
