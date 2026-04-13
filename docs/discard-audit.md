# Discard Audit — Design Spec

**Status.** Design spec. Implementation lands in Phase B alongside the
`scope_drift` taxonomy split and the cheapest-discard-first precedence rule.

## The Gap

Godmode today has three discard mechanisms:

1. `SKILL.md §2` — keep/discard pseudo-code rules (metric + guard)
2. `SKILL.md §3` — simplicity criterion linear table (lines vs delta%)
3. `skills/principles/SKILL.md §3` — line-trace rule (aspirational)

The first two are mechanical. The third — "every semantically changed
line must trace to the user's request" — is aspirational. An agent that
ignores it faces no mechanical consequence. Adjacent-code "improvements,"
formatting churn, and renames-for-consistency can slip through and only
get caught at post-commit review, if at all.

This doc specifies the mechanical enforcement layer.

## Three Changes

### Change 1: Pre-commit discard audit

A new gate runs immediately before every `git commit` in `skills/build/`
and any skill that issues commits.

```
Before each commit:
  diff = git diff --cached
  hunks = parse-hunks(diff)

  FOR each hunk in hunks:
    trace = classify(hunk, task.requirements)

    IF trace IN {requirement, test_for_requirement, orphan_cleanup}:
      keep
    ELSE:
      drop hunk via: git restore -p --staged <file>
      append to .godmode/build-failures.tsv with class=line_scope_drift
      log the dropped hunk for the failures.tsv audit trail

  IF any hunk dropped:
    re-run guard: build_cmd && lint_cmd && test_cmd
    IF guard now fails: revert all dropped hunks, classify as noise,
                        proceed with original commit, log warning

  commit surviving hunks
```

The `classify(hunk, task.requirements)` function is mechanical:

- **requirement** — hunk modifies code named in `task.files` AND at least
  one line in the hunk contains a symbol/function/identifier mentioned in
  the task's `done_when` spec
- **test_for_requirement** — hunk is under a test directory AND the file
  name or describe/it string references a requirement symbol
- **orphan_cleanup** — hunk removes an import, variable, or function that
  is unused *only because of other hunks in this same commit*
- **else** — `line_scope_drift`, drop

Whitespace-only hunks, comment-only hunks, and auto-formatter reflows on
untouched semantic lines are always classified as `line_scope_drift` unless
the task explicitly mentions formatting.

### Change 2: Split `scope_drift` into two sub-classes

Current state: `SKILL.md §8` failure classification table has one class
`scope_drift` covering two very different failures:

| Sub-class | Meaning | Recovery |
|---|---|---|
| `file_scope_drift` | Agent touched a file outside `task.files` | Revert whole agent output; re-dispatch with narrower `task.files` |
| `line_scope_drift` | Agent touched right file but added unrelated lines | Surgically drop drift hunks via `git restore -p`; keep in-scope hunks |

Without the split, `git reset --hard HEAD~1` nukes both cases identically
and loses salvageable in-scope work. With the split, recovery is surgical.

Implementation: add the two sub-classes as rows in the `SKILL.md §8` table,
update `skills/build/SKILL.md § Failure Classification`, and update
`agents/builder.md` retry logic to prefer surgical hunk drops over whole-
commit reverts when the class is `line_scope_drift`.

### Change 3: Cheapest-discard-first precedence

Discards have a cost hierarchy:

```
  Cost-0:  Pre-MODIFY strike — item never written
           (from skills/principles/SKILL.md §2 checklist)

  Cost-1:  Pre-commit audit — written, dropped before commit
           (this spec's Change 1)

  Cost-2:  Post-commit revert — written, committed, git reset --hard
           (existing SKILL.md §2 keep/discard rules)
```

When a Cost-2 discard fires on something that Cost-0 or Cost-1 *should*
have caught, log it as an `escaped_discard` lesson in
`.godmode/lessons.md`. This creates a feedback loop:

- If `escaped_discard` fires >3 times in one session, emit a warning:
  "pre-MODIFY checklist is drifting — review `skills/principles/SKILL.md §2`
  against recent failures"
- If the same pattern shows up across sessions, the lesson becomes a
  candidate for a new entry in `skills/principles/SKILL.md` — the prelude
  learns from its own escapes

`escaped_discard` is an orthogonal classification, not a replacement for
the existing 8 failure classes. A Cost-2 discard gets both its primary
class (e.g., `complexity_tax`) AND the `escaped_discard` marker if it
could have been caught earlier.

## Verification Checklist

When Change 1, 2, and 3 are implemented (Phase B), these mechanical checks
must pass:

1. `grep -n 'git restore -p --staged' agents/builder.md` — returns ≥1 hit
2. `grep -cE 'file_scope_drift|line_scope_drift' SKILL.md` — returns 2
3. `grep -n 'escaped_discard' skills/principles/SKILL.md` — returns ≥1 hit
4. `grep -n 'cheapest-discard-first\|Cost-0\|Cost-1\|Cost-2' SKILL.md` —
   returns ≥1 hit in the keep/discard section
5. `skills/build/SKILL.md § Failure Classification` lists both new
   sub-classes

## What This Does NOT Change

- Universal Protocol loop (`SKILL.md §1`) — unchanged
- Keep/discard metric rules (`SKILL.md §2`) — unchanged; this spec adds a
  PRE-commit layer that runs before those rules fire
- Simplicity criterion table (`SKILL.md §3`) — unchanged
- Existing 6 failure classes other than `scope_drift` — unchanged
- Agent dispatch contract (`AGENTS.md § DispatchContext Schema`) — unchanged
- Multi-agent coordination rules — unchanged

This spec is pure enforcement of existing aspirational rules. No new
behavior is introduced; existing rules become mechanically enforceable.

## Open Questions

1. **Whitespace churn from project formatter.** If `prettier --write` runs
   on save and reformats lines the agent didn't semantically touch, those
   lines appear in `git diff --cached` and would be classified as
   `line_scope_drift`. Mitigation: the classifier ignores whitespace-only
   hunks unless the task explicitly mentions formatting. Flag for review.
2. **Test additions in unfamiliar test file layouts.** If a test lives in
   a non-standard location (`src/__tests__/` vs `tests/`), the
   `test_for_requirement` classifier may miss it. Mitigation: `task.files`
   should explicitly list expected test paths when non-standard.
3. **Refactor tasks.** A task whose `done_when` is "extract helper X"
   legitimately touches multiple unrelated-looking lines. The classifier
   must recognize refactor tasks from the task description and relax the
   line-trace rule for those. Flag for review.

These open questions are why this is a design spec, not an implementation
PR. Phase B's Plan agent pass will resolve them before any code lands.
