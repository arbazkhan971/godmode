---
name: think
description: Design session. Explore approaches, produce .godmode/spec.md.
---

## Activate When
- `/godmode:think`, "design", "brainstorm", "what's the best approach"
- New feature with no spec

## Workflow
### 1. Understand the Problem
- What does the user want? (one sentence)
- What are the constraints? (time, tech, team)
- What does success look like? (measurable criteria)
### 2. Scan Codebase
Run `git ls-files` + read key files → identify patterns, naming conventions, abstractions to reuse. Note: framework version.
### 3. Generate 2-3 Approaches
Per approach: description (2-3 sentences), trade-offs, complexity (Low/Med/High), files to create/modify.
### 4. Recommend One
Lead with recommendation + justification. State: chosen approach, why others rejected, key risk.
### 5. Write Spec
Output `.godmode/spec.md`: Problem, Approach, Success Criteria (measurable), Out of Scope, Edge Cases, Files Affected. Commit: `"spec: {feature name}"`

## Rules
1. Always produce `.godmode/spec.md`. Next step: `/godmode:plan` reads it.
2. 2-3 approaches, then pick one. Not 7 options.
3. Measurable success criteria. "Works well" is not a criterion.
4. Scan existing code first. Reuse existing patterns, don't introduce new ones.
5. Spec under 100 lines. If longer, decompose into sub-features. Never design what you haven't scanned.
