# NEEDS_HUMAN: agentskills.io — spec/docs site, not a skills directory; only showcase is for agent clients

## Target

- Site: <https://agentskills.io> · Source repo: <https://github.com/agentskills/agentskills> ("Specification and documentation for Agent Skills"; not archived; default branch `main`; pushed 2026-08-09)
- What the site is (GET-only verification, 2026-08-27): the home of the Agent Skills standard — `/specification`, `/skill-creation/{quickstart,best-practices,optimizing-descriptions,evaluating-skills,using-scripts}`, `/client-implementation/adding-skills-support`, and `/clients` (Client Showcase).
- What it is NOT: there is **no skills directory and no submission form**. No `<form>` elements, no "submit" / "add your skill" / "get listed" path anywhere in the homepage or `llms.txt` nav. The only curated listing is the Client Showcase, and it lists **agent products/clients that implement the format** (Codex, OpenCode, Gemini CLI, pi, VS Code, and others), not skills or skill collections.
- Showcase mechanics: rendered from `docs/snippets/clients.jsx` in the repo. The file itself documents the process: "To add a new client: 1. Add logo files to /images/logos/[logo-name]/ 2. Add entry to the clients array below". Entries need `name`, `description`, `url`, `lightSrc`/`darkSrc` logo assets, optional `instructionsUrl`/`sourceCodeUrl`.
- Relevant context: pi (badlogic/pi-mono) implements the Agent Skills standard and links the spec from its own skills docs — the standard is real traction for the agents godmode supports.
- DEDUP (2026-08-27): `gh search prs "godmode" --repo agentskills/agentskills` (open + closed), `gh search issues "godmode" --repo agentskills/agentskills`, and `gh pr list -R agentskills/agentskills --author arbazkhan971 --state all` → all empty. Clean slate.

## Proposed one-paragraph entry (usable as a Client Showcase `description` or a discussion opener, pending human decision)

godmode is a discipline layer for AI coding agents: 135 skills + 7 subagents wrapping Claude Code, Codex, Cursor, Gemini CLI, OpenCode, pi, and omp in a measure -> modify -> verify -> keep/revert loop. Its skills are folders containing SKILL.md files with name and description frontmatter — the same shape the Agent Skills standard specifies — usable across all seven of those harnesses. Every change is mechanically verified and failed changes are automatically reverted.

- Repo: <https://github.com/arbazkhan971/godmode>
- Release: <https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0>
- License: MIT

## Exact open questions for the human

1. **Fit**: The Client Showcase is scoped to agent products/clients that implement the format. godmode is a skills collection + discipline layer that *wraps* clients, not a client itself. Do we (a) propose it anyway, (b) ask the maintainers whether a skills-collection showcase exists or is planned, or (c) drop agentskills.io as a P6 listing target?
2. **Channel**: No submission form exists. If proceeding: open a GitHub Discussion in agentskills/agentskills first, or PR directly into `docs/snippets/clients.jsx`? Etiquette favors asking before a logo-asset PR.
3. **Assets**: The showcase requires light + dark logo files under `/images/logos/<name>/`. No godmode logo assets exist yet. Who produces them, or do we hold until assets are ready?
4. **Claim check**: The entry above claims only the canonical platform list and the SKILL.md folder shape — no certification/compatibility claims beyond that. OK to keep it that narrowly worded?

## Submission URL(s) — no form exists; these are the contact points found (GET-only)

- Docs repo (discussions / docs PRs): <https://github.com/agentskills/agentskills>
- Discord: <https://discord.gg/MKPE9g8aUy> (site header link; "Agent Skills official Discord server" is discussion #273) — human action: re-pull the invite live from the agentskills.io site header at use time and confirm it resolves to the official server before sharing; invite codes expire and a swapped code would be a phishing vector

## Status

- No PR opened. No fork created. No issues filed. Nothing modified upstream. Verification was GET-only.
- This file is the only write from this research pass; it is committed to the godmode repo as part of the P6 marketing set.
