---
name: goal-bridge
description: Machine-checkable completion contracts for agent goal modes. goal mode, /goal, goal contract, completion contract, evaluator, metric command, exit-zero contract, evidence path, rollback trigger.
---

# Goal-Bridge — Completion Contracts for Goal Modes

## Activate When
- User invokes `/godmode:goal-bridge`
- User sets a goal in a harness goal mode (`/goal` or your harness's equivalent)
- User asks "how do we know this is done"
- An evaluator needs a command that exits 0

## Workflow

### Step 1: Derive the Contract BEFORE Execution
No work starts until the contract exists. Derive all four fields up front:
- **metric** — ONE shell command where exit 0 = goal met. Never prose judgment.
- **threshold** — numeric or boolean bound the metric must satisfy.
- **evidence** — file path where metric output/proof is written every round.
- **rollback** — exact trigger that reverts the work.

### Step 2: Emit the Contract Block
Single source of truth — use EXACTLY this shape everywhere:

```
Goal-Bridge Contract (mandatory final output):
- metric: <single shell command; contract met iff it exits 0>
- threshold: <numeric or boolean bound the metric must satisfy>
- evidence: <file path where metric output/proof is written every round>
- rollback: <exact trigger that reverts the work, e.g. "metric fails on 2 consecutive rounds">
```

### Step 3: Run the Metric Every Round
Each round: run the metric command and append its output to the evidence path.

### Step 4: Rollback on Trigger
```bash
git reset --hard <last-good-commit>
```
Then log the attempt: what failed, which round, evidence excerpt.

### Step 5: Hand Off the Contract
Give the contract block to the harness goal mode / evaluator (`/goal` or your
harness's equivalent). The evaluator consumes "command exits 0".

## Hard Rules
1. The contract exists BEFORE work starts.
2. The metric is a single command, never prose judgment.
3. The evidence file is written every round.
4. Never declare done without exit 0.

## Stop Conditions
```
STOP when FIRST of:
  - metric exits 0 AND evidence written -> DONE
  - rollback trigger fires -> revert + report PARTIAL
  - cannot express goal as exit-0 command -> report NEEDS_CONTEXT (do NOT fake a metric)
```

## Integration
- Works with any harness goal mode: the `/goal` command (or your harness's equivalent).
- pi goal contracts.
- Any harness evaluator that consumes "command exits 0".
- Philosophy source: skills/verify/SKILL.md.
