Seeded flaw: CLI prints a text report only; the --json capability is absent.
Fix: main.py declares --json (store_true) and dispatches to a new shelf.render_json();
render_json builds {"items":<ordered dict>,"total":N} with json.dumps(ensure_ascii=False, separators=(",",":")).
Insertion-ordered dict gives first-occurrence order; duplicate assignment keeps position and last count.
Verification: starter fails at json-basic (argparse exit 2); solution passes all 9 checks, exit 0.
