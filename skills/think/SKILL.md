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
Run `git ls-files` → identify relevant modules, naming conventions, existing abstractions to reuse.
### 3. Generate 2-3 Approaches
Per approach: description (2-3 sentences), trade-offs, complexity (Low/Med/High), files to create/modify.
### 4. Recommend One
Lead with recommendation. One sentence justification.
### 5. Write Spec
Output `.godmode/spec.md`: Problem, Approach, Success Criteria (measurable), Out of Scope, Edge Cases, Files Affected. Commit: `"spec: {feature name}"`

## Rules
1. Always produce a spec file. Think without output is wasted.
2. 2-3 approaches, then pick one. Not 7 options.
3. Measurable success criteria. "Works well" is not a criterion.
4. Scan existing code first. Don't propose conflicting patterns.
5. Spec under 100 lines. If longer, decompose the feature.
