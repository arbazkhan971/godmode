#!/usr/bin/env bash
# Prints one integer: milliseconds for slow_fib.work(). Lower is better.
python3 -c 'import time, slow_fib; t = time.perf_counter(); slow_fib.work(); print(int((time.perf_counter() - t) * 1000))'
