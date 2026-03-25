---
name: rfc
description: RFC and technical proposal writing.
---

## Activate When
- `/godmode:rfc`, "write a proposal", "RFC for"
- "propose a change", "need team buy-in"
- Design decision too large for single-person ADR

## Workflow

### 1. Determine RFC Type
```
FEATURE:      2 reviewers, 3-day comment period
ARCHITECTURE: 3 reviewers, 5-day comment period
PROCESS:      All team, 5-day comment period
DEPRECATION:  2 reviewers + leads, 5-day period
MIGRATION:    3 reviewers, 7-day comment period
STANDARD:     All team, 7-day comment period
```

### 2. Research & Evidence
```bash
git log --oneline --since="3 months ago" -- <paths>
ls docs/rfcs/ docs/adr/ 2>/dev/null
```
Gather: current state, problem evidence (metrics),
prior art, constraints.

IF no quantitative evidence: gather before writing.
IF past RFC exists on same topic: reference it.

### 3. Write the RFC
Required sections:
- **Metadata**: author, status, type, dates, reviewers
- **Summary**: 2-3 sentences (most important section)
- **Problem Statement**: quantitative evidence required
- **Proposed Solution**: design, API/data/config changes,
  implementation plan with phased milestones
- **Alternatives**: minimum 2 + "Do Nothing" (mandatory)
- **Risks & Mitigations**: every risk needs mitigation
- **Testing Strategy**: unit, integration, load, canary
- **Open Questions**: tracked to resolution

Save to `docs/rfcs/<NNN>-<kebab-title>.md`.

IF RFC > 5 pages: split into parent + child RFCs.
IF "Do Nothing" is acceptable: no RFC needed.

### 4. Manage Review
Track per-reviewer: status (approved/concerns/pending),
comments. When concerns raised: acknowledge, research,
update RFC, re-request review.

### 5. Decision Timeline
Log: created, comments, updates, approvals, decision.
Set deadline and hold to it.

### 6. Finalize
- All approve -> Accepted. Create ADR, plan impl.
- Blocking concerns -> Deferred. Set revisit date.
- Rejected -> Document reasons. Preserve for reference.

### 7. Commit
```bash
git add docs/rfcs/<NNN>-<title>.md
git commit -m "rfc: RFC-<NNN> -- <title> (<status>)"
```

## Hard Rules
1. EVERY RFC must include "Do Nothing" alternative.
2. NEVER write RFC after code is already written.
3. EVERY RFC must have a review deadline.
4. NEVER accept with unresolved open questions.
5. EVERY rejected RFC preserved with rationale.
6. RFC scope < 5 pages. Split if longer.
7. EVERY RFC must include rollback/migration plan.
8. NEVER skip alternatives section.

## TSV Logging
Append `.godmode/rfc-results.tsv`:
```
timestamp	rfc_number	title	type	status	reviewers	alternatives	open_questions
```

## Keep/Discard
```
KEEP if: evidence-based, concise, actionable,
  all sections complete.
DISCARD if: vague, lacks evidence, exceeds 5 pages.
```

## Stop Conditions
```
STOP when FIRST of:
  - All sections complete + committed
  - 8 iterations exhausted
  - Re-edits produce no new information
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| No RFC directory | Create docs/rfcs/, start at 001 |
| Written after code | Convert to ADR, warn user |
| Deadline passes | Extend 3 days or schedule sync |
| Exceeds 5 pages | Split into parent + child RFCs |
| All reviewers reject | Set Rejected, preserve rationale |
