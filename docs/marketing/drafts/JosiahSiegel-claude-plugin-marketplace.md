# NEEDS_HUMAN: JosiahSiegel/claude-plugin-marketplace — JSON-index intake exists, but requires vendoring the full plugin source

## Target

- Repo: <https://github.com/JosiahSiegel/claude-plugin-marketplace>
- `gh api repos/JosiahSiegel/claude-plugin-marketplace` → `{"archived": false, "pushed_at": "2026-06-18T20:57:10Z", "default_branch": "main", "allow_forking": true}` — active within 12 months, forkable, not archived.
- JSON index: `.claude-plugin/marketplace.json` with a `plugins` array. README § Contributing links CONTRIBUTING.md: "Want to add a plugin to this marketplace? See CONTRIBUTING.md (repo root)".

## Step 0 evidence (GET-only, 2026-08-27)

- DEDUP: `gh search prs "godmode" --repo JosiahSiegel/claude-plugin-marketplace` (open + closed) → empty. `gh search issues "godmode" --repo JosiahSiegel/claude-plugin-marketplace` → empty. `gh pr list -R JosiahSiegel/claude-plugin-marketplace --author arbazkhan971 --state all` → empty. Clean slate; the one-PR etiquette budget is unspent.
- CONTRIBUTING.md fetched (HTTP 200) and read in full. Intake **is a PR to a JSON index** — but with mandatory extra steps (see below).
- Our manifest gate: `python3 -m json.tool .claude-plugin/marketplace.json` (godmode repo root) → parses clean (exit 0). godmode's plugin manifest is valid JSON with name/version/description/license/skills.

## Why no PR was opened (their checklist conflicts with the minimal-entry rule)

Their documented entry flow requires, quoting CONTRIBUTING.md:

> "Create plugin directory: `mkdir -p plugins/your-plugin-name/.claude-plugin`" — with `plugin.json`, README.md, and LICENSE **vendored into their repo**, plus:
> "Update marketplace.json — Add a marketplace entry for the plugin... Use `scripts/version_ops.py` to validate and synchronize metadata" (`--validate --metadata all`, keyword `--sync`).
> PR checklist: "Plugin follows the required structure", "`.claude-plugin/marketplace.json` includes the plugin entry", "Versions were bumped only with `scripts/version_ops.py`", "`python3 scripts/version_ops.py --validate --metadata all` passes".

A marketplace.json-entry-only PR (the protocol's single-line/minimal-diff shape) **fails their checklist** — the plugin directory and script validation are mandatory, and a `./plugins/godmode` source with no directory behind it would break their validation. Vendoring godmode (135 skills, 7 subagents, hooks) means a ~170-file PR (153
files under skills/, 9 under agents/, 3 under hooks/, plus .claude-plugin/plugin.json,
README.md, LICENSE — 168 total). That is a scope decision for the lead, not an agent call → NEEDS_HUMAN.

## Their documented marketplace.json entry schema (verbatim from CONTRIBUTING.md)

```json
{
  "name": "your-plugin-name",
  "source": "./plugins/your-plugin-name",
  "description": "Brief description for marketplace listing",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "keywords": ["relevant", "keywords"]
}
```

## Verbatim sibling entry (from their live marketplace.json, for schema shape)

```json
{
  "name": "bash-master",
  "source": "./plugins/bash-master",
  "version": "2.0.7",
  ...
}
```

(Full sibling field order as serialized upstream: `name`, `source`, `description`, `version`, `author.name`, `keywords[]`.)

## Ready-to-paste godmode entry (description = 144 chars, byte-identical to our `.claude-plugin/marketplace.json`; no banned phrases)

```json
{
  "name": "godmode",
  "source": "./plugins/godmode",
  "description": "Godmode: Autonomous AI coding skills inspired by Karpathy's autoresearch. 135 skills, 7 subagents, 7 platforms. Zero configuration. One command.",
  "version": "2.0.0",
  "author": {
    "name": "godmode-team"
  },
  "keywords": ["skills", "subagents", "workflow", "verification", "discipline", "agents"]
}
```

Note: their privacy rule says use `username@users.noreply.github.com` style for any email field; the entry above omits email entirely (allowed — `author.name` only in sibling entries).

## Options for the lead

1. **Option A — authorize a vendoring PR** (agent-executable in a follow-up dispatch): fork, branch `add-godmode`, add `plugins/godmode/` (plugin.json, README.md, LICENSE, skills/agents trees), add the entry above, run `python3 scripts/version_ops.py --validate --metadata all` and the keyword `--sync`, commit `Add godmode plugin`, PR with their template. Tradeoff: full compliance with their checklist, but a heavy diff — explicitly out of the minimal-entry protocol, hence this draft.
2. **Option B — manifest-only entry PR** (the minimal-diff shape): submit just the ready-to-paste entry above into their `.claude-plugin/marketplace.json`, no vendored tree. Tradeoff: tiny diff, but likely rejected — their checklist requires the plugin directory and a passing `python3 scripts/version_ops.py --validate --metadata all`, and a `./plugins/godmode` source with no directory behind it breaks their validation; it also spends the one-PR etiquette budget.
3. **Skip** — defensible; zero etiquette risk.
4. **Official Anthropic plugin directory instead** (found in the same sweep): `anthropics/claude-plugins-official` README § Contributing → "Third-party partners can submit plugins for inclusion in the marketplace... use the [plugin directory submission form](https://clau.de/plugin-directory-submission)" — **web form, human-only**. DEDUP there is clean (no godmode PRs/issues). If chosen, a human fills that form; nothing an agent may do (no PR, no issue).

## Landscape evidence from this sweep (all GET-only, 2026-08-27)

Rejected candidates and why (for the lead's queue notes):

- `anthropics/claude-plugins-official` — intake = web form only (see above). NEEDS_HUMAN-class; never PR/issue.
- `obra/superpowers-marketplace` — remote-source JSON index (right shape) but **no CONTRIBUTING** (404), 100% single-maintainer commit history (all "Jesse Vincent"), entries limited to his ecosystem. Third-party intake undocumented → ambiguity, no PR.
- `davila7/claude-code-templates` — "PRs Welcome", CONTRIBUTING exists, but intake = component markdown/JSON files vendored under `cli-tool/components/...`, not a marketplace JSON entry. Off-spec.
- `mhattingpete/claude-skills-marketplace` (667 stars) — intake = fork + skill directory + README edit + PR; skills-vendoring repo, not a JSON index. Off-spec.
- `devsforge/marketplace` — community marketplace with CONTRIBUTING, but requires full plugin structure with "Minimum 200 lines of documentation" vendored in-repo. Off-spec for a minimal entry.
- `quemsah/awesome-claude-plugins` — auto-generated star-ranking table (bot-maintained), no intake process. Not a target.
- `xiaolai/`, `Vvkmnn/`, `uyu423/`, `mwguerra/`, `Dev-GOM/`, `netresearch/`, `manutej/` marketplaces — all self-described **personal** marketplaces ("plugins by <owner>"), no community intake docs. Not targets.
- Exact-name `kkeril/awesome-claude-code-agents` (name resolution pass) — 5-star stale clone, last pushed 2025-07-25; name-squatting clone, skipped per protocol.

## Facts usable in any submission (canonical, nothing else)

- Repo: <https://github.com/arbazkhan971/godmode>
- Release: <https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0>
- License: MIT
- 135 skills, 7 subagents (planner, builder, reviewer, optimizer, explorer, security, tester)
- Works across Claude Code, Codex, Cursor, Gemini CLI, OpenCode, pi, omp, and Amp (Amp is skills-level: subagents and model routing are Amp's own)
- Loop: measure -> modify -> verify -> keep/revert; every change mechanically verified; failed changes automatically reverted
- Banned in any copy: illustrative demo numbers, star/download/user counts, hype adjectives, engagement-bait asks, run-environment details, URL shorteners.

## Status

- No PR opened. No fork created. No issues filed. Nothing modified upstream. Verification was GET-only.
- This file is the only write from this research pass; it is committed to the godmode repo as part of the P6 marketing set.
