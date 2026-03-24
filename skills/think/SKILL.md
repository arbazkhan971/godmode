---
name: think
description: |
  Design and specification skill. Explores the problem space, scans existing codebase patterns, generates 2-3 concrete approaches with trade-offs, recommends one, and produces .godmode/spec.md. This is the entry point for any new feature or significant change. Triggers on: /godmode:think, "design", "brainstorm", "what's the best approach", or when no spec exists for a requested feature.
---

# Think — Design Session & Spec Generation

## Activate When
- User invokes `/godmode:think`
- User says "design", "brainstorm", "what's the best approach", "how should I build this"
- New feature requested but no `.godmode/spec.md` exists
- `/godmode:predict` returned RETHINK gate — re-enter think with risks as constraints
- User says "I need to figure out", "what are my options", "architecture for"

## Auto-Detection
The godmode orchestrator routes here when:
- Phase detection finds no `.godmode/spec.md` and no `.godmode/plan.yaml`
- User language matches: "design", "approach", "brainstorm", "figure out", "options for", "how to implement"
- `/godmode:predict` output includes `Gate: RETHINK` — re-enter with accumulated risks as constraints
- User describes a feature but does not ask to build or plan it

## Step-by-step Workflow

### Step 1: Understand the Problem
Clarify what the user wants before scanning code:

```
PROBLEM STATEMENT:
- Goal: <one sentence — what the user wants to achieve>
- Constraints: <time, technology, team size, backwards compat, etc.>
- Success criteria: <shell command that exits 0 when done, OR metric + target>
- Out of scope: <what this does NOT include>
```

**Clarification protocol:**
```
If ambiguous: offer 2 interpretations with examples
  "A) You want X — e.g. user clicks button, modal appears"
  "B) You want Y — e.g. data syncs on page load"
User picks one. Proceed immediately.
(Faster than asking open-ended questions)
```

If the user's success criteria is subjective ("works well", "is fast", "looks good"), reject it and propose a concrete alternative (e.g., "response time < 200ms" or "test suite passes").

### Step 2: Scan Codebase

**Greenfield exception:** If no codebase exists (no git repo, empty repo, or user says "new project"), skip this step entirely. Note `greenfield` in the spec and proceed to Step 3.

Read existing code to understand patterns, conventions, and constraints:

```bash
# Project structure
git ls-files | head -150

# Entry points and configs
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null || cat go.mod 2>/dev/null

# Existing types/interfaces relevant to the feature
grep -rn "interface\|type\|class\|def " --include="*.ts" --include="*.py" --include="*.go" | head -40

# Recent changes in related areas
git log --oneline -15 -- <relevant-paths>

# Existing test patterns
ls -la tests/ test/ __tests__/ spec/ 2>/dev/null
```

Document findings:
```
CODEBASE SCAN:
- Framework: <name + version>
- Language: <name + version>
- Patterns to reuse: <list existing patterns — routing, error handling, data access>
- Patterns to avoid: <deprecated or inconsistent patterns found>
- Related code: <files that touch the same domain>
- Test runner: <tool + config location>
```

Never propose an approach that contradicts existing patterns unless the spec explicitly calls for migration.

### Step 3: Generate 2-3 Approaches
For each approach, provide exactly 5 fields:

```
For each approach (A, B, and optionally C if meaningfully different), fill this template:

APPROACH {A|B|C}: {name}
What: {1-2 sentences describing the approach}
Why it wins: {main advantage}
Why it loses: {main disadvantage}
Files: {N} to create/modify
```

Disqualification criteria — immediately reject any approach that:
- Requires a dependency not in the project and not approved by user
- Contradicts an explicit constraint from Step 1
- Touches more than 30 files (too broad — split into sub-features first)
- Has no testable success criteria

### Step 4: Recommend One
Select the best approach and justify:

```
RECOMMENDATION: Approach <A|B|C>
- Chosen because: <1-2 sentences — why this beats the others>
- Approach B rejected: <1 sentence — key weakness>
- Approach C rejected: <1 sentence — key weakness>
- Top risk: <the single biggest risk>
- Mitigation: <concrete action to reduce that risk>
```

If two approaches are genuinely equivalent, prefer the one with fewer files touched and lower complexity.

### Step 5: Write Spec
Write `.godmode/spec.md` with sections: **Problem** (1-3 sentences), **Approach** (chosen approach, 2-5 sentences), **Success Criteria** (shell command that exits 0), **Out of Scope**, **Files to Modify** (path + what changes), **Files to Create** (path + purpose), **Risks** (risk + mitigation pairs). Keep under 100 lines total.

### Step 6: Validate and Commit
Run the spec validation checklist before committing:

```
VALIDATE before committing spec:
[ ] All "files_to_modify" exist (git ls-files --error-unmatch)
[ ] All parent dirs in "files_to_create" exist
[ ] Success criteria is valid bash (bash -n -c '<cmd>')
[ ] Spec is <100 lines (wc -l)
[ ] Problem statement is 1 unambiguous sentence
```

```bash
# 1. Verify referenced existing files exist
for f in <files_to_modify>; do git ls-files --error-unmatch "$f"; done

# 2. Verify new file parent dirs exist
for f in <files_to_create>; do test -d "$(dirname "$f")" || echo "MISSING: $(dirname "$f")"; done

# 3. Verify success criteria command is syntactically valid
bash -n -c '<success_criteria_cmd>' 2>&1

# 4. Verify spec length
wc -l .godmode/spec.md  # target <100

# 5. Verify problem statement is 1 sentence
head -5 .godmode/spec.md  # inspect manually

# 6. Commit
git add .godmode/spec.md && git commit -m "spec: {feature}"
```

If any validation fails, fix the spec before committing. Do not commit an invalid spec.

## Output Format
Print at each stage:

```
Think: problem — <one-sentence goal>.
Think: scanned codebase — <framework>, <N> related files found.
Think: generated 3 approaches (A: <name>, B: <name>, C: <name>).
Think: recommending Approach A — <reason>.
Think: wrote .godmode/spec.md (42 lines).
Think: spec committed. Next: /godmode:plan.
```

Final output line:
```
Spec: .godmode/spec.md ({N} lines). Approach: {chosen}. Success: {criteria_cmd}. Files: {modify_count} to modify, {create_count} to create.
```

## TSV Logging
Append to `.godmode/think-log.tsv` (create if missing, never overwrite):

```
timestamp	feature	approaches_considered	chosen_approach	files_to_modify	files_to_create	spec_lines	success_criteria	risks_identified
2025-01-15T14:00:00Z	user-preferences	3	event-driven	5	3	42	npx vitest run --reporter=verbose	2
```

Columns: `timestamp`, `feature`, `approaches_considered`, `chosen_approach`, `files_to_modify`, `files_to_create`, `spec_lines`, `success_criteria`, `risks_identified`.

## Success Criteria
The design session is done when ALL of the following are true:
- [ ] `.godmode/spec.md` exists and is under 100 lines
- [ ] Problem statement is one sentence, unambiguous
- [ ] Success criteria is a shell command (not prose)
- [ ] 2-3 approaches were evaluated with concrete trade-offs
- [ ] One approach is recommended with rejection reasons for others
- [ ] All referenced existing files verified via `git ls-files`
- [ ] All new file parent directories verified to exist
- [ ] Success criteria command passes `bash -n` syntax check
- [ ] Spec is committed to git
- [ ] TSV log row appended

## Error Recovery
- **User's goal is ambiguous:** Offer 2 interpretations with concrete examples. User picks one. Proceed immediately. If still unclear, make your best interpretation, state it explicitly, and proceed.
- **No existing codebase (greenfield):** Skip Step 2 scan. Note `greenfield` in spec. In Step 3, note "greenfield — no existing patterns to match". Recommend the simplest approach that meets success criteria.
- **All approaches disqualified:** Tell the user why. Suggest narrowing scope or relaxing constraints. Do not invent a fourth approach that violates constraints.
- **Success criteria is subjective:** Reject it. Propose a concrete alternative: "Instead of 'works well', use `curl -s localhost:3000/health | jq -e '.status == \"ok\"'`". Do not proceed until criteria is a shell command.
- **Spec exceeds 100 lines:** The feature is too large. Decompose into 2-3 sub-features. Write a top-level spec that references sub-specs: `.godmode/spec-{sub1}.md`, `.godmode/spec-{sub2}.md`.
- **Validation checklist fails:** Fix the failing item before committing. If `files_to_modify` don't exist, confirm paths with user. If parent dirs missing, create them or adjust file paths.

## Anti-Patterns
1. **Analysis paralysis:** Generating 5+ approaches and agonizing over trade-offs. Max 3 approaches. Pick one and move on.
2. **Skipping the scan:** Designing in a vacuum without reading existing code. Always scan first (unless greenfield) — the codebase has patterns to follow.
3. **Subjective success criteria:** "Works well", "is performant", "looks clean". Express every criterion as a shell command or a metric with a threshold.
4. **Gold-plating the spec:** Writing 200 lines of implementation detail. The spec describes WHAT and WHY, not HOW. Implementation details belong in the plan and build phases.
5. **Ignoring existing patterns:** Proposing a new ORM when the project already uses one, or a new state library when one exists. Reuse what is there.
6. **Open-ended clarification:** Asking "what do you want?" instead of offering 2 concrete interpretations. Always constrain the question.

## Examples

### Example 1: API Feature
```
User: "Design a user preferences feature"
Think: problem — users need to save and retrieve display preferences (theme, language, timezone).
Think: scanned codebase — Express + TypeScript, 12 related files in src/models/ and src/routes/.
Think: generated 2 approaches:
  APPROACH A: column-per-preference
  What: Add theme, language, timezone columns to users table.
  Why it wins: Type-safe, queryable per field.
  Why it loses: Schema migration for every new preference.
  Files: 4 to create/modify

  APPROACH B: JSON blob column
  What: Single jsonb preferences column with runtime validation.
  Why it wins: Extensible without schema changes.
  Why it loses: No per-field DB queries.
  Files: 3 to create/modify
Think: recommending Approach B — fewer migrations, extensible without schema changes.
Think: wrote .godmode/spec.md (38 lines). Next: /godmode:plan.
```

### Example 2: Re-entry from Predict
```
/godmode:predict returned Gate: RETHINK with risks:
  - "No rate limiting on preferences endpoint" (Security Researcher, confidence 9)
  - "Preferences blob has no schema validation" (Technical Architect, confidence 8)

Think: re-entering with 2 risks as constraints.
Think: generated 2 approaches (A: JSON Schema validation + rate limiter middleware, B: typed preferences with Zod).
Think: recommending Approach B — compile-time safety, lighter than JSON Schema.
Think: updated .godmode/spec.md (51 lines). Risks section now includes mitigations.
```

### Example 3: Greenfield Project
```
User: "Design a CLI tool for managing dotfiles"
Think: problem — user wants a CLI to symlink, backup, and restore dotfiles.
Think: greenfield — no existing codebase. Skipping scan.
Think: generated 3 approaches:
  APPROACH A: Node.js + Commander
  What: CLI built on Commander with Node.js fs APIs.
  Why it wins: Familiar ecosystem, fast to prototype.
  Why it loses: Requires Node.js runtime on target machine.
  Files: 5 to create/modify

  APPROACH B: Python + Click
  What: CLI built on Click with pathlib for file operations.
  Why it wins: Clean API, widely available runtime.
  Why it loses: Dependency management via pip/venv.
  Files: 5 to create/modify

  APPROACH C: Go + Cobra
  What: CLI built on Cobra, compiles to single binary.
  Why it wins: Single binary, no runtime deps.
  Why it loses: Slower iteration during development.
  Files: 6 to create/modify
Think: recommending Approach C — single binary, no runtime deps, user prefers Go.
Think: wrote .godmode/spec.md (45 lines). Next: /godmode:plan.
```

### Example 4: Ambiguous Request (clarification protocol)
```
User: "Design notifications"
Think: ambiguous — offering 2 interpretations:
  A) Push notifications to mobile/desktop — e.g. Firebase Cloud Messaging sends alert when order ships
  B) In-app notification feed — e.g. bell icon shows unread messages in the UI
User: "B"
Think: problem — in-app notification feed with unread count and mark-as-read.
(proceeds immediately)
```

## Hard Rules
1. Max 3 approaches — pick one and move on. No analysis paralysis.
2. Always scan existing code first (unless greenfield) — reuse patterns, do not reinvent.
3. Success criteria must be a shell command or metric with threshold — never subjective prose.
4. Spec must be under 100 lines — if longer, decompose into sub-features.
5. Never commit a spec with invalid file paths — verify with `git ls-files` before commit.
6. Measure before/after. Guard: test_cmd && lint_cmd.
7. On failure: git reset --hard HEAD~1.
8. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
After EACH approach evaluation:
  KEEP if: approach passes disqualification criteria AND has testable success criteria
  DISCARD if: approach violates constraints OR touches >30 files OR has no testable criteria
  On discard: log rejection reason. If all approaches disqualified, tell user to narrow scope.
  Never keep an approach that contradicts explicit constraints.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: spec.md written, validated, and committed
  - budget_exhausted: 3 approaches evaluated (max)
  - diminishing_returns: user accepts recommendation on first pass
  - stuck: >5 validation failures on spec (paths, syntax, length)
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- The think skill requires no parallel agents — it runs identically on all platforms.
- All file scanning, approach generation, and spec writing happen in the current session.
- No worktree or branch isolation needed for design work.
- The output `.godmode/spec.md` is consumed by `/godmode:plan` regardless of platform.
