---
name: think
description: Design session. Explore approaches, produce .godmode/spec.md.
---

## Activate When
- `/godmode:think`, "design", "brainstorm", "what's the best approach"
- New feature with no spec

## Workflow
### 1. Understand the Problem
- What does the user want? (one sentence, confirmed with user if ambiguous)
- What are the constraints? (time, tech, team)
- Success criteria: a shell command that exits 0 when done, or a metric with target value
### 2. Scan Codebase
Run `git ls-files` + read key files → identify patterns, naming conventions, abstractions to reuse. Note: framework version.
### 3. Generate 2-3 Approaches
Per approach: trade-offs, complexity (S/M/L), files touched, task count. Disqualify any approach requiring unavailable deps.
### 4. Recommend One
Recommend one. State: chosen approach, why others rejected (1 sentence each), top risk + mitigation.
### 5. Write Spec
Output `.godmode/spec.md`: Problem, Approach, Success Criteria (measurable), Out of Scope, Files to Create/Modify. Commit: `"spec: {feature name}"`

## Rules
1. Always produce `.godmode/spec.md`. Next step: `/godmode:plan` reads it.
2. 2-3 approaches, then pick one. Not 7 options.
3. Measurable success criteria. "Works well" is not a criterion.
4. Scan existing code first. Reuse existing patterns, don't introduce new ones.
5. Spec under 100 lines. If longer, decompose into sub-features. Never design what you haven't scanned.
