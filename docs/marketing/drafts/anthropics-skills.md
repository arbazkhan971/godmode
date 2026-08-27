# SKIP: anthropics/skills — no listing mechanism; contributions require porting skills

## Target

- Repo: <https://github.com/anthropics/skills>
- Default branch: `main` · not archived · allow_forking: true · pushed 2026-08-21 (live)

## Step 0 evidence (GET-only, 2026-08-27)

- `gh api repos/anthropics/skills` → `{"archived": false, "pushed_at": "2026-08-21T17:10:55Z", "default_branch": "main", "allow_forking": true}`
- `CONTRIBUTING.md`: **404 at root and at `.github/CONTRIBUTING.md`** — no contribution guide exists.
- Repo tree: `.claude-plugin/`, `.gitignore`, `README.md`, `THIRD_PARTY_NOTICES.md`, `skills/`, `spec/`, `template/` — **no catalog/awesome-list file**.
- `.claude-plugin/marketplace.json` lists ONLY Anthropic's own plugins (`document-skills`, `example-skills`, `claude-api`, `academy-guide`, `discernment-nudge`). It is their internal marketplace manifest, not a third-party catalog.
- README self-description: "This repository contains skills that demonstrate what's possible with Claude's skills system" — a curated Anthropic demo-skills collection. The only external highlights are "Partner Skills" picked by Anthropic.
- DEDUP: `gh search prs "godmode" --repo anthropics/skills` (open + closed), `gh search issues "godmode" --repo anthropics/skills`, `gh pr list -R anthropics/skills --author arbazkhan971 --state all` → all empty. No prior godmode PRs, no inclusion-request issues, no PRs by us. Clean slate.

## Why SKIP (lead decision 2026-08-27)

The analysis below stands — kept as the record for a future revisit. This target was classified SKIP because, in this queue, the human-completion status means "a human must complete a submission that an agent prepared" (a form, a post, or a vendored PR). Here there is no submission artifact to prepare: the only path is authoring new content (porting a skill into their layout), which is a product decision tracked as a future option (see Options), not a pending submission.

- There is **no listing/catalog entry mechanism** for third-party projects. A PR adding godmode as a line item has nowhere to go.
- The only plausible contribution path is **porting individual skills into their `skills/<name>/SKILL.md` layout** (frontmatter `name` + `description`, self-contained folder). godmode is a 135-skill discipline plugin with 7 subagents, adapters, and its own progressive-disclosure conventions — porting even one representative skill means authoring new content in their format, which is a product decision (which skill, how much to trim, what to call it), not a submission formality.
- Honest fit judgment: a full meta-plugin does not belong in a repo of individual demonstration skills; a single ported skill might, but that choice belongs to the author/lead.

## Options for the lead

1. **Skip** — treat as out of scope for P6 listings (defensible; zero risk).
2. **Port one skill** — the representative candidate is `goal-bridge`: self-contained (a single SKILL.md, no plugin machinery) and it carries godmode's core discipline as an exit-0 completion contract (metric command, threshold, evidence path, rollback trigger). Port into their `skills/<name>/SKILL.md` layout as a standalone folder + SKILL.md, PR'd from a fork, following their `template/` shape exactly. Described here, never executed; go/no-go stays with the lead. Heavy lift; requires adapting content.
3. **Wait/watch** — if Anthropic adds a community catalog or third-party listing mechanism (check `marketplace.json` and README "Partner Skills" section), re-run this analysis then.

## Status

- No PR opened. No fork created. No issues filed. Nothing modified upstream.
- Banned-content rules respected; no commits made in the godmode repo during analysis (this draft file is the only write).
