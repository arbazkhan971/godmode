# godmode demo

Three [vhs](https://github.com/charmbracelet/vhs) tapes that capture real `pi`
sessions running godmode workflows, plus the fixture code they operate on.

## What's here

- `demo/tapes/skill-routing.tape` — the godmode orchestrator routing a
  natural-language request to the `ratelimit` skill.
- `demo/tapes/optimize-loop.tape` — the keep/revert loop with a real metric,
  a real KEEP, and a real `git reset --hard` revert.
- `demo/tapes/goal-bridge.tape` — a 4-field machine-checkable completion
  contract, red test to green with evidence file.
- `demo/targets/optimize/` (`slow_fib.py`, `test_slow_fib.py`, `metric.sh`)
  and `demo/targets/goal-bridge/` (`counter.py`, `test_counter.py`) — fixture
  source the tapes copy into scratch repos.
- `demo/transcripts/<stem>.txt` — text transcripts of each captured
  session; the accessible fallback text in the README embeds is drawn
  from these.
- `demo/<stem>.gif` — the rendered captures, one per tape.

## Re-render

```bash
bash demo/render.sh              # render all three tapes
bash demo/render.sh <stem>       # render one tape, e.g. optimize-loop
bash demo/render.sh --check      # verify deps/tapes/targets, no rendering
```

Requirements:

- `pi` with godmode installed via `adapters/pi/install.sh`
- `vhs`, `ttyd`, and `ffmpeg` on PATH
- a Chromium/Chrome browser (vhs drives it to capture the terminal)
- provider access configured for `pi` (tapes pin `--model zai/glm-5.3`)

Each tape bootstraps its own scratch git repo under `/tmp/godmode-demo-*`;
those directories are disposable. Every render is a real LLM session and
costs provider quota.

## Honesty

The GIFs in this repo are real captures of real `pi` sessions recorded with
vhs; the tapes are capture recipes, not scripts with canned output. LLM
sessions are nondeterministic, so a re-render WILL differ from the committed
GIF — that is expected, not a bug. Every typed line in a tape is a real
command, and on-screen artifacts like `.godmode/optimize-results.tsv` are
written by the live session itself.

## Sizes

Per-file size budget, enforced by `demo/render.sh`: hard fail above 5 MB,
warn above 2.5 MB.

| gif | bytes |
| --- | ----- |
| `demo/skill-routing.gif` | 256,880 |
| `demo/optimize-loop.gif` | 1,155,608 |
| `demo/goal-bridge.gif` | 1,993,066 |
