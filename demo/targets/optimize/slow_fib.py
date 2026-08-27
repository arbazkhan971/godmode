"""Deliberately slow recursive Fibonacci — optimize-loop demo target."""

def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

def work():
    return fib(30)
