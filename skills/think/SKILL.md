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

If the goal is ambiguous, ask exactly ONE clarifying question. Do not ask multiple questions or present a menu of options. If the user's success criteria is subjective ("works well", "is fast", "looks good"), reject it and propose a concrete alternative (e.g., "response time < 200ms" or "test suite passes").

### Step 2: Scan Codebase
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
For each approach, provide concrete details:

```
APPROACH A: <name>
- Summary: <1-2 sentences>
- Files to modify: <exact paths>
- Files to create: <exact paths>
- Complexity: S / M / L
- Estimated tasks: <number>
- Trade-offs:
  + <advantage 1>
  + <advantage 2>
  - <disadvantage 1>
  - <disadvantage 2>
- Risk: <top risk + mitigation>
- Disqualified: NO (or YES + reason)

APPROACH B: <name>
...

APPROACH C: <name> (optional — only if meaningfully different)
...
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
Verify the spec is actionable:

```bash
# Verify referenced existing files exist
for f in <files_to_modify>; do git ls-files --error-unmatch "$f"; done

# Verify new file parent dirs exist
for f in <files_to_create>; do test -d "$(dirname "$f")"; done

# Verify success criteria command is syntactically valid
bash -n -c '<success_criteria_cmd>' 2>&1

# Commit
git add .godmode/spec.md && git commit -m "spec: {feature}"
```

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
- [ ] Spec is committed to git
- [ ] TSV log row appended

## Error Recovery
- **User's goal is ambiguous:** Ask exactly ONE clarifying question. Do not list options. If still unclear after one question, make your best interpretation, state it explicitly, and proceed.
- **No existing codebase (greenfield):** Skip Step 2 scan. In Step 3, note "greenfield — no existing patterns to match". Recommend the simplest approach that meets success criteria.
- **All approaches disqualified:** Tell the user why. Suggest narrowing scope or relaxing constraints. Do not invent a fourth approach that violates constraints.
- **Success criteria is subjective:** Reject it. Propose a concrete alternative: "Instead of 'works well', use `curl -s localhost:3000/health | jq -e '.status == \"ok\"'`". Do not proceed until criteria is a shell command.
- **Spec exceeds 100 lines:** The feature is too large. Decompose into 2-3 sub-features. Write a top-level spec that references sub-specs: `.godmode/spec-{sub1}.md`, `.godmode/spec-{sub2}.md`.

## Anti-Patterns
1. **Analysis paralysis:** Generating 5+ approaches and agonizing over trade-offs. Max 3 approaches. Pick one and move on.
2. **Skipping the scan:** Designing in a vacuum without reading existing code. Always scan first — the codebase has patterns to follow.
3. **Subjective success criteria:** "Works well", "is performant", "looks clean". Every criterion must be a shell command or a metric with a threshold.
4. **Gold-plating the spec:** Writing 200 lines of implementation detail. The spec describes WHAT and WHY, not HOW. Implementation details belong in the plan and build phases.
5. **Ignoring existing patterns:** Proposing a new ORM when the project already uses one, or a new state library when one exists. Reuse what is there.

## Examples

### Example 1: API Feature
```
User: "Design a user preferences feature"
Think: problem — users need to save and retrieve display preferences (theme, language, timezone).
Think: scanned codebase — Express + TypeScript, 12 related files in src/models/ and src/routes/.
Think: generated 2 approaches (A: column-per-preference, B: JSON blob column).
Think: recommending Approach B — fewer migrations, extensible without schema changes.
Think: wrote .godmode/spec.md (38 lines). Next: /godmode:plan.
```

### Example 2: Re-entry from Predict
```
/godmode:predict returned Gate: RETHINK with risks:
  - "No rate limiting on preferences endpoint" (SRE, confidence 9)
  - "Preferences blob has no schema validation" (Backend Architect, confidence 8)

Think: re-entering with 2 risks as constraints.
Think: generated 2 approaches (A: JSON Schema validation + rate limiter middleware, B: typed preferences with Zod).
Think: recommending Approach B — compile-time safety, lighter than JSON Schema.
Think: updated .godmode/spec.md (51 lines). Risks section now includes mitigations.
```

### Example 3: Greenfield Project
```
User: "Design a CLI tool for managing dotfiles"
Think: problem — user wants a CLI to symlink, backup, and restore dotfiles.
Think: no existing codebase (greenfield). Framework choice open.
Think: generated 3 approaches (A: Node.js + Commander, B: Python + Click, C: Go + Cobra).
Think: recommending Approach C — single binary, no runtime deps, user prefers Go.
Think: wrote .godmode/spec.md (45 lines). Next: /godmode:plan.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- The think skill requires no parallel agents — it runs identically on all platforms.
- All file scanning, approach generation, and spec writing happen in the current session.
- No worktree or branch isolation needed for design work.
- The output `.godmode/spec.md` is consumed by `/godmode:plan` regardless of platform.
