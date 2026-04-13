---
name: research
description: >
  Research phase. Runs before think on non-trivial features. Dispatches the
  explorer subagent plus a docs/ecosystem scan to gather prior art, existing
  patterns, and relevant dependencies. Writes .godmode/research.md as input
  for the think skill. Fills the gap where think only scans the local
  codebase, not external references.
---

# Research — Prior Art & Context Gathering

## Activate When

- `/godmode:research`, "research", "prior art", "existing patterns"
- Before `/godmode:think` for features touching >5 files or mentioning
  an external library, framework, or standard by name
- Spec rework: `.godmode/spec.md` exists but think was stuck

Skip for trivial tasks (one-line fixes, typos, renames) — go straight
to the relevant skill.

## Workflow

### Step 1: Define the Research Question

```
RESEARCH QUESTION:
- Feature: <one sentence>
- What we want to know:
  - What existing patterns in the codebase could we reuse?
  - What dependencies already handle part of this?
  - What docs/ADRs/RFCs describe constraints?
  - What prior attempts exist in git history?
```

If the question is unanswerable in ≤10 minutes of scanning, narrow it
before continuing. Emit `NEEDS_CONTEXT` if ambiguous.

### Step 2: Codebase Scan via Explorer

Dispatch the `explorer` subagent (read-only) with the research question.

```
Agent(
  role: explorer,
  task: "Find existing patterns, utilities, and prior code related to
         {feature}. Map files, key symbols, and existing abstractions.
         Return a codebase report under 80 lines.",
  scope: read-only,
  output: .godmode/explorer-report.md
)
```

Do NOT scan the codebase yourself — the explorer is optimized for this
and keeps the research skill focused on synthesis, not search.

### Step 3: Ecosystem Scan

```bash
# Dependencies that might already solve part of the problem
grep -l "{keyword}" package.json pyproject.toml Cargo.toml go.mod \
  Gemfile pom.xml 2>/dev/null

# Docs, ADRs, RFCs
ls docs/ 2>/dev/null
find . -maxdepth 3 -type f \
  \( -name "CLAUDE.md" -o -name "AGENTS.md" \
     -o -name "ARCHITECTURE.md" -o -name "RFC*.md" \
     -o -iname "*adr*" \) 2>/dev/null

# Prior attempts in git history
git log --all --oneline --grep="{keyword}" 2>/dev/null | head -20
```

Record relevance for each hit. Skip hits with no relevance.

### Step 4: Synthesize

For each source, write one line:

```
- <path|package|commit> | <relevance: HIGH|MED|LOW> | <1-sentence takeaway>
```

If all sources are LOW relevance, record "no prior art" and note the
gap.

### Step 5: Write .godmode/research.md

Format (under 60 lines total):

```
# Research: {feature}

## Existing patterns
- {path}:{lines} — {what's there, why it matters for this feature}

## Relevant dependencies
- {package} — {which capability we could reuse}

## Related docs
- {path} — {what constraint or decision it records}

## Prior attempts
- {commit_sha} {subject} — {what was tried, why it was reverted/abandoned}

## Gaps
- {what we DON'T have that think must design from scratch}

## Recommended starting point for think
- {one-line pointer: "extend existing X" / "new module under Y" / "greenfield"}
```

### Step 6: Commit

```bash
git add .godmode/research.md
git commit -m "research: {feature} — {N} patterns, {N} deps, {N} gaps"
```

Research output is append-only per feature. Previous research files for
other features are never rewritten.

## Hard Rules

1. Always dispatch explorer first — never scan the codebase yourself.
2. Under 60 lines total. Longer = scope too broad, narrow the question.
3. Never duplicate findings in the subsequent `think` spec — research.md
   is the source of truth for prior art; think references it by filename.
4. If research finds an existing pattern that solves the feature, emit
   `DONE_WITH_CONCERNS` and recommend skipping `think` for that path.
5. Commit research.md before dispatching `think`.
6. Never modify source files from this skill — research is read-only
   except for `.godmode/research.md` and `.godmode/explorer-report.md`.

## Keep / Discard Discipline

```
KEEP if: research.md has at least 1 HIGH-relevance hit OR 1 gap identified
DISCARD if: research.md is empty or every hit is LOW relevance
On empty: skip research phase, emit "no prior art — proceed to think"
  (this is a valid outcome, not a failure)
```

## Stop Conditions

```
STOP when FIRST of:
  - research.md written, committed, under 60 lines
  - explorer returns empty twice (scope too narrow)
  - >10 dependencies examined with 0 HIGH-relevance hits
  - explorer emits NEEDS_CONTEXT (re-dispatch with narrower query max 2x,
    then stop)
```

## Output Format

```
Research: question={feature}, patterns={N}, deps={N}, docs={N}, gaps={N}.
Research: wrote .godmode/research.md ({N} lines).
Research: recommended starting point — {greenfield|extend|reuse-existing}.
```

## TSV Logging

Append to `.godmode/research-log.tsv`:

```
timestamp	feature	patterns	deps	docs	gaps	starting_point	lines
```

## Error Recovery

| Failure | Action |
|---|---|
| explorer returns nothing | Narrow question, retry once. Second empty = no prior art, proceed. |
| research.md >60 lines | Drop LOW-relevance hits. If still >60, the question is too broad. |
| All hits LOW relevance | Record "no prior art" and commit. This is a valid outcome. |
| git history scan very slow | Cap to last 500 commits. Note the cap in research.md. |

## Integration with Think

The `think` skill should read `.godmode/research.md` at the start of its
Step 2 (Scan Codebase) if the file exists. Think uses the research output
to avoid re-scanning and to anchor its 2-3 approaches in existing
patterns rather than proposing greenfield abstractions.
