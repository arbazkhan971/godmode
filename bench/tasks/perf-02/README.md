# Record join takes quadratic time (performance-optimization)

## Context

`starter/` holds a reporting utility from an e-commerce back office. Every night
it joins an orders export (`ORDER_ID,CUSTOMER_ID,AMOUNT`) against a customers
export (`CUSTOMER_ID,NAME`) and prints `ORDER_ID,NAME,AMOUNT` per order, keeping
the orders' file order. The two exports are produced by other systems and the
join's output feeds a reconciliation job that expects the exact current format.

## Task

Bring the tool's runtime for the benchmark workload within the time budget
enforced by `metric.sh`, while producing byte-identical output to the current
behavior. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Standard library only; no third-party packages.
- Everything must run offline.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
