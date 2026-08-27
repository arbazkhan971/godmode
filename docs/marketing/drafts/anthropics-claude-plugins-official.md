# NEEDS_HUMAN: anthropics/claude-plugins-official — official directory; intake is a human-filed form

## Target

- Repo: <https://github.com/anthropics/claude-plugins-official>
- Default branch: `main` · live/active (verified 2026-08-27)

## Step 0 evidence (verified by lead 2026-08-27 via gh api)

- `gh api repos/anthropics/claude-plugins-official` → live, `main`, active.
- README is titled **"Claude Code Plugins Directory"**.
- `/external_plugins` holds third-party plugins as directories containing `.claude-plugin/plugin.json` + README, indexed via `.claude-plugin/marketplace.json`.
- README states external plugins "must meet quality and security standards for approval", and intake is the plugin directory submission form at <https://clau.de/plugin-directory-submission> — **a human must file it**. There is no PR path for external listings.
- DEDUP (2026-08-27): `gh search prs "godmode" --repo anthropics/claude-plugins-official` (open + closed), `gh search issues "godmode" --repo anthropics/claude-plugins-official`, and `gh pr list -R anthropics/claude-plugins-official --author arbazkhan971 --state all` → all empty. Clean slate.

## Paste-ready form entry (plain, factual, no hype)

- Name: godmode
- Repo: <https://github.com/arbazkhan971/godmode>
- One-line: discipline layer for AI coding agents — 135 skills + 7 subagents wrapping a measure -> modify -> verify -> keep/revert loop
- Install: `claude plugin install godmode` (also adapters for Codex/Cursor/Gemini CLI/OpenCode/pi/omp)
- License: MIT
- Release: v2.0.0 — <https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0>
- Author: @arbazkhan971

## Human checklist (what the human must do)

1. **File the form** at <https://clau.de/plugin-directory-submission> using the paste-ready entry above.
2. **Expect a quality and security review** — README says external plugins "must meet quality and security standards for approval"; no timeline guarantee.
3. **If accepted**, the directory slot is `external_plugins/godmode/` (`.claude-plugin/plugin.json` + README, indexed via `.claude-plugin/marketplace.json`) — Anthropic places it, we do not PR it.

## Status

- No PR opened. No fork created. No issues filed. Nothing modified upstream.
- DRAFT — human fires this; no commits are made in the godmode repo as part of drafting (this draft file is the only write).
