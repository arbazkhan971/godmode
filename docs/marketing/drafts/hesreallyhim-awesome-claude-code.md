# Draft: hesreallyhim/awesome-claude-code — NEEDS_HUMAN (no PR possible)

Verdict: **No PR may be opened.** This repo's CONTRIBUTING.md bans PRs for new
resource recommendations entirely. Submission is possible only via the web UI
issue form, filled in by a human. Hand this draft to the repo author to submit
manually.

## Why no PR (rules quoted verbatim from CONTRIBUTING.md)

> NOTE: ALL RECOMMENDATIONS MUST BE MADE USING THE WEB UI ISSUE FORM TEMPLATE,
> OR YOU RISK BEING RESTRICTED FROM INTERACTING WITH THIS REPOSITORY TEMPORARILY.
>
> Do not open a PR. Just fill out the form.
>
> Warning: it is **not** possible to submit a resource recommendation using the
> `gh` CLI.
>
> Although resources themselves may be partially or entirely written by a coding
> agent, resource recommendations must be created by human beings.

Submission form (web UI only): <https://github.com/hesreallyhim/awesome-claude-code/issues/new?template=recommend-resource.yml>

## Eligibility (CONTRIBUTING.md ground rules)

Ground rule: resource must be (i) >= 14 days old AND show signs of active
development (commits after the first day), OR (ii) >= 100 stars. Also:
"You may not recommend more than one resource at a time."

godmode meets rule (i): repo created 2026-03-19, last pushed 2026-08-27
(evidence: `gh api repos/arbazkhan971/godmode --jq '{created_at,pushed_at}'`).

## Section placement (premise correction)

There is **no "Plugins" section** in this README. Plugins are listed across
thematic sections. Verified section list: Ticker, Recently Added, Start Here,
From Anthropic, Documentation, Knowledge & Learning, Research & Scientific
Inquiry, Providers, Runtime & Integration Infrastructure, Remote Control,
Notifications & Voice I/O, Alternative Clients, Status Lines, Design & UI/UX,
Writing & Prose Quality, Creative Media, Infrastructure & DevOps, Security,
Agent Orchestration, Skills, Memory & Context Persistence, Observability &
Monitoring, Linting.

Recommended primary fit: **Agent Orchestration** (godmode's core is a dispatch
loop over 7 subagents with planner/builder/reviewer roles). Alternative:
**Skills** (godmode ships 135 skills). Note the maintainer guideline: "we
especially welcome and invite recommendations of resources that focus on the
unique features and functionality of Claude Code" — godmode's primary artifact
is a Claude Code plugin (`.claude-plugin/marketplace.json`, `agents/`,
`.codex/agents/`, skills, hooks), though it also adapts to other agents.

## Entry format (verbatim sibling template, Agent Orchestration)

```text
- [fable-mode](https://github.com/mrtooher/fable-mode) by [mrtooher](https://github.com/mrtooher) - A Claude skill that activates Fable-style agentic behavior: explicit multi-stage planning, sub-agent delegation, and self-verification.  
<img src="https://img.shields.io/github/created-at/mrtooher/fable-mode?style=flat-square&labelColor=2b2b2b&color=6b6b6b" alt="created">&nbsp;&nbsp;<img src="https://img.shields.io/github/last-commit/mrtooher/fable-mode?style=flat-square&labelColor=2b2b2b&color=6b6b6b" alt="last-commit">&nbsp;&nbsp;<img src="https://img.shields.io/github/license/mrtooher/fable-mode?style=flat-square&labelColor=2b2b2b&color=6b6b6b" alt="license">&nbsp;&nbsp;<img src="https://img.shields.io/github/stars/mrtooher/fable-mode?style=flat-square&labelColor=2b2b2b&color=6b6b6b" alt="stars">
```

Format: dash + name in square brackets + repo URL in parentheses + " by " +
author in square brackets + profile URL in parentheses + " - Description."
(line ends with two trailing spaces), followed by a badge line with four shields.io badges
(created / last-commit / license / stars).

## Proposed entry (sibling bullet format; badges are godmode's own static factual set from README.md — the sibling stars badge would render a live godmode star count, banned in our copy; description 91 chars)

```text
- [godmode](https://github.com/arbazkhan971/godmode) by [arbazkhan971](https://github.com/arbazkhan971) - 135 skills and 7 subagents that wrap Claude Code in a measure, verify, keep-or-revert loop.  
<img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="license">&nbsp;&nbsp;<img src="https://img.shields.io/badge/skills-135-ff6b6b.svg" alt="skills">&nbsp;&nbsp;<img src="https://img.shields.io/badge/subagents-7-ff9f43.svg" alt="subagents">&nbsp;&nbsp;<img src="https://img.shields.io/badge/Claude_Code-supported-4A90D9.svg" alt="claude-code">
```

Style rules from CONTRIBUTING.md: descriptions, not sales pitches; one line;
no emojis; no addressing the reader.

## Dedup evidence (protocol step 0c, run 2026-08-27/28)

- `gh search prs "godmode" --repo hesreallyhim/awesome-claude-code --state open` -> no results
- same with `--state closed` -> no results
- `gh pr list -R hesreallyhim/awesome-claude-code --author arbazkhan971 --state all` -> no results
- `grep -in godmode README.md` -> no listing
- `gh search issues "godmode" --repo hesreallyhim/awesome-claude-code` -> one hit:

  issue #1085 "Add Godmode Lite — free 4-layer execution protocol skill" by
  Lotron-Electrical (<https://github.com/hesreallyhim/awesome-claude-code/issues/1085>),
  CLOSED. This is a **different project** (Lotron-Electrical/godmode-lite), not
  arbazkhan971/godmode. Do not touch that issue; mention nothing about it in the
  form unless asked.

## Facts usable in the form (canonical, nothing else)

- Repo: <https://github.com/arbazkhan971/godmode>
- Release: <https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0>
- License: MIT
- 135 skills, 7 subagents (planner, builder, reviewer, optimizer, explorer, security, tester)
- Works across Claude Code, Codex, Cursor, Gemini CLI, OpenCode, pi, omp, and Amp (Amp is skills-level: subagents and model routing are Amp's own)
- Loop: measure -> modify -> verify -> keep/revert; every change mechanically verified; failed changes automatically reverted

- Banned in any copy: illustrative demo numbers, star/download/user counts, hype adjectives, engagement-bait asks, run-environment details, URL shorteners.

## Human checklist

1. Open the web UI form link above in a browser (gh CLI cannot do this).
2. Recommend at most this ONE resource (one-at-a-time rule).
3. Paste the proposed entry line from this draft; pick Agent Orchestration (or

   Skills) as the suggested category if the form asks.

4. Disclose authorship (the form is a recommendation; the maintainer values

   honesty — "I am the author" is fine).
