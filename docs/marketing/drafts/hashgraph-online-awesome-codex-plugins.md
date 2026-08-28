# hashgraph-online/awesome-codex-plugins - NEEDS_HUMAN submission draft

## What the list is

- Repo: <https://github.com/hashgraph-online/awesome-codex-plugins> — 854-star, actively maintained curated list of Codex plugins (live-verified 2026-08-28 via API: 854 stars, last push 2026-08-28).
- Submission format: a single README line, placed alphabetically within a category section.
- Bundle mechanics: a maintainer-run generator mirrors the plugin bundle from the source repo and regenerates `plugins.json` / `marketplace.json` — submitters never copy plugin files into the list repo. Our PR is the README line; their tooling does the rest.

## Why NEEDS_HUMAN (product decision, not a formatting problem)

Their CONTRIBUTING makes PR acceptance conditional on changes in OUR repository first. This is not a "format the entry correctly" blocker — it is a decision about adopting their repository-prep standard inside godmode. The full verified precondition list, all sourced from their CONTRIBUTING (nothing invented; godmode state verified 2026-08-28 via repo inspection):

1. **HOL AI Plugin Scanner workflow** installed in godmode at `.github/workflows/hol-plugin-scanner.yml`, using their action `hashgraph-online/ai-plugin-scanner-action@v1`, passing on `main` — absent in godmode today.
2. **Local scan** via `plugin-scanner` (pipx; currently version 3.0.11) scoring >= 80/130 with no critical or high findings; scan output saved for the PR description.
3. A valid **`.codex-plugin/plugin.json` manifest** — absent in godmode today.
4. An **`assets/icon.svg`** (~512x512, under 50KB) referenced via the manifest's `interface.composerIcon` — absent in godmode today.
5. **`SECURITY.md`** — present at `docs/SECURITY.md` (a GitHub-honored location); root-level file absent — confirm their scanner accepts the `docs/` location.
6. **`LICENSE`** (MIT qualifies) — present, MIT.
7. **`README`** — present.
8. **No hardcoded secrets, no dangerous MCP commands** — needs an explicit audit pass before anyone claims compliance.
9. **SHA-pinned GitHub Actions** — not met today: godmode's only workflow action reference is `actions/checkout@v4` (tag ref, not commit SHA).
10. **Dependency lockfiles** (`package-lock.json`) — already present.
11. **Dependabot configured** (their Operational Security scoring) — absent in godmode today.
12. **`.codexignore`** (earns their Best Practices points) — absent in godmode today.
13. Their **CI bot validates all of the above on the PR** and auto-comments tagging the PR author when items are missing — noncompliance is surfaced publicly, not rejected quietly.

PR-level requirements (also from their CONTRIBUTING): the PR description must include the public GitHub URL of the plugin repo; one plugin per PR; and every link in the README entry must resolve.

## WARNING — do not open the PR until repo prep lands

Because of precondition 13, opening the PR before the repo prep (Option A) lands means their CI bot publicly auto-comments the missing items on the PR and tags the godmode submitter by handle, in front of the 854-star community watching that list. Prep the repository first, run the local scanner to a clean >= 80/130 with zero critical/high findings, and only then submit the single README line.

## Ready-to-paste entry (for AFTER the decision)

```text
- [godmode](https://github.com/arbazkhan971/godmode) - Discipline layer for coding agents: 135 skills and 7 subagents in a measure → modify → verify → keep/revert loop.
```

Placement: alphabetically within the `### Development & Workflow` category section (under Community Plugins) of their README; their generator mirrors the bundle and regenerates `plugins.json` / `marketplace.json` afterwards.

## Options and decision checklist

**Option A — adopt the requirements.** What changes in godmode: a new workflow (`.github/workflows/hol-plugin-scanner.yml` invoking their action), a `.codex-plugin/plugin.json` manifest, an `assets/icon.svg`, a Dependabot config, and a `.codexignore` (plus the audit items above: SECURITY.md, secrets/MCP check, SHA-pinning). Tradeoff: a third-party CI action (`hashgraph-online/ai-plugin-scanner-action@v1`) scans every push to godmode forever — recurring external dependency on their action, their scanner version, and their scoring curve gating a check on our `main`.

**Option B — skip the target.** No PR, no workflow, no manifest, no icon. The 854-star Codex-plugin audience is left to organic discovery; dedup stays clean, so the SKIP remains revisitable rather than burned.

Decision checklist — five questions a human should answer:

1. **Third-party CI trust:** do we accept `hashgraph-online/ai-plugin-scanner-action@v1` running inside godmode CI on every push — and should we pin it to a commit SHA (their own precondition 9 standard) rather than `@v1`?
2. **Scan posture:** can godmode reach >= 80/130 with zero critical or high findings today, or would wiring the workflow put a red check on `main` before cleanup lands?
3. **Maintenance surface:** does a `.codex-plugin/plugin.json` manifest become a second source of truth next to godmode's existing adapter files, and who owns the drift?
4. **Audience value:** is this 854-star list worth the standing requirements, or do the already-open PRs (show-hn, social) deliver the same reach for less surface?
5. **Re-entry trigger (if Option B):** what would re-open this target later — e.g. the plugin manifest landing for another reason — so the SKIP is recorded as a deferral with a trigger, not a burn?

## Status

- No PR opened. No fork created. Nothing modified upstream. Read-only verification only.
- Dedup clean (2026-08-28): `gh pr list -R hashgraph-online/awesome-codex-plugins --author arbazkhan971 --state all` → empty; `grep -ci godmode` on their README → 0.
- This draft file is the only write from this pass; every Option A item is proposed, not landed.
