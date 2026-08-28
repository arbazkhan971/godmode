Seeded flaw: build_invoice in starter/main.py is a 52-line god-function covering parse, validate, select, totals, and render.
Fix: split into parse_invoice_args / validate_invoice / select_rows / compute_totals / sorted_lines / render_invoice, with build_invoice as a thin orchestrator.
Measured: solution has 8 named functions, max function span 13 lines (limit 20).
Behavior: 10 fixed CLI cases (stdout + exit code) unchanged from the original starter.
