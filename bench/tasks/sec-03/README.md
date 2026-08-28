# Fix regex denial of service (security-hardening)

## Context
`skucheck` validates warehouse SKU codes before they reach the inventory API.
A SKU is one or more alphanumeric segments joined by single dashes, e.g.
`widget-3000-pro`. The API logs every rejected value, and anything that
submits values to `skucheck` must get a fast verdict either way.

## Task
Make `skucheck` return its verdict quickly for every input, including
adversarial ones, while keeping verdicts correct: valid SKUs report VALID,
anything else reports INVALID. The crafted value used by the metric currently
hangs the process; it is an invalid SKU and must be rejected promptly.
Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Node.js standard library only; CommonJS `require`; no `package.json`, no new dependencies, no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
