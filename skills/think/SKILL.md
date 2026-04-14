---
name: think
description: >
  Design session. Explore problem, scan codebase,
  generate 2-3 approaches, recommend one,
  produce .godmode/spec.md.
---

# Think -- Design Session & Spec Generation

## Activate When
- `/godmode:think`, "design", "brainstorm"
- "what's the best approach", "how should I build"
- No .godmode/spec.md exists for requested feature
- /godmode:predict returned RETHINK gate

## Workflow

### Step 1: Understand the Problem
```
PROBLEM STATEMENT:
- Goal: <one sentence>
- Constraints: <time, tech, backwards compat>
- Success criteria: <shell command that exits 0>
- Out of scope: <what this does NOT include>
```
```
IF ambiguous: offer 2 interpretations with examples
  "A) You want X -- e.g. user clicks, modal appears"
  "B) You want Y -- e.g. data syncs on page load"
  User picks one. Proceed immediately.

IF success criteria is subjective ("works well"):
  reject and propose concrete alternative
  e.g., "response time < 200ms" or "tests pass"
```

### Step 2: Scan Codebase
IF greenfield (no repo): skip to Step 3.
```bash
# Project structure
git ls-files | head -150

# Entry points and configs
cat package.json 2>/dev/null \
  || cat pyproject.toml 2>/dev/null

# Existing types related to feature
grep -rn "interface\|type\|class\|def " \
  --include="*.ts" --include="*.py" | head -40

# Recent changes in related areas
git log --oneline -15 -- <affected-paths>

# Test patterns
ls -la tests/ test/ __tests__/ spec/ 2>/dev/null
```
```
CODEBASE SCAN:
- Framework: <name + version>
- Patterns to reuse: <routing, error handling>
- Patterns to avoid: <deprecated patterns>
- Related code: <files in same domain>
```

### Step 3: Generate 2-3 Approaches
```
APPROACH {A|B|C}: {name}
What: {1-2 sentences}
Why it wins: {main advantage}
Why it loses: {main disadvantage}
Files: {N} to create/modify
```
Disqualify any approach that:
- Requires unapproved dependency
- Contradicts explicit constraint
- Touches >30 files (split into sub-features)
- Has no testable success criteria

### Step 4: Recommend One
```
RECOMMENDATION: Approach {A|B|C}
- Chosen because: <1-2 sentences>
- Approach B rejected: <key weakness>
- Top risk: <biggest risk>
- Mitigation: <concrete action>
```
IF two approaches are equal: prefer fewer files.

### Step 5: Write Spec
Write `.godmode/spec.md` with sections:
**Problem** (1-3 sentences), **Approach** (2-5),
**Success Criteria** (shell command exits 0),
**Out of Scope**, **Files to Modify** (path + what),
**Files to Create** (path + purpose),
**Risks** (risk + mitigation pairs).
Keep under 100 lines total.

### Step 6: Validate and Commit
```bash
# Verify referenced files exist
for f in <files_to_modify>; do
  git ls-files --error-unmatch "$f"
done

# Verify new file parent dirs exist
for f in <files_to_create>; do
  test -d "$(dirname "$f")" \
    || echo "MISSING: $(dirname "$f")"
done

# Verify success criteria syntax
bash -n -c '<success_criteria_cmd>' 2>&1

# Verify spec length (target <100)
wc -l .godmode/spec.md

# Commit
git add .godmode/spec.md \
  && git commit -m "spec: {feature}"
```
IF any validation fails: fix before committing.

## Output Format
```
Think: problem -- <goal>.
Think: scanned codebase -- <framework>, {N} files.
Think: generated {N} approaches.
Think: recommending Approach {X} -- <reason>.
Think: wrote .godmode/spec.md ({N} lines).
Spec: {path}. Approach: {chosen}. Files: {N}+{N}.
```

## TSV Logging
Append to `.godmode/think-log.tsv`:
`timestamp\tfeature\tapproaches\tchosen\tfiles_modify\tfiles_create\tspec_lines\trisks`

## Hard Rules
0. **Inherits Default Activations per `SKILL.md §14`.** Principles prelude (Think/Simplicity/Surgical/Goal-driven), pre-commit audit, terse/stdio/tokens, DispatchContext validation, Progressive Disclosure routing, discard cost hierarchy, and coordination patterns all fire by default. Do NOT require explicit flags; do NOT skip any of them.
1. Max 3 approaches. Pick one, move on.
2. Always scan existing code first (unless greenfield). Read `.godmode/research.md` if it exists — research auto-dispatched before think per `SKILL.md §14`.
3. Success criteria = shell command, never prose.
4. Spec under 100 lines. Longer = decompose.
5. Never commit spec with invalid file paths.
6. Guard: test_cmd && lint_cmd.
7. On failure: git reset --hard HEAD~1.
8. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: approach passes disqualification criteria
  AND has testable success criteria
DISCARD if: violates constraints OR >30 files
  OR no testable criteria
```

## Stop Conditions
```
STOP when FIRST of:
  - spec.md written, validated, and committed
  - 3 approaches evaluated (max)
  - >5 validation failures on spec
```

<!-- tier-3 -->

## Error Recovery
- **Ambiguous goal:** Offer 2 interpretations.
- **All approaches disqualified:** Narrow scope.
- **Spec >100 lines:** Decompose into sub-features.
- **Greenfield:** Skip scan, note in spec.
