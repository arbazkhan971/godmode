---
name: think
description: |
  Design and brainstorming. Explore approaches, evaluate trade-offs, produce a spec. Output: .godmode/spec.md
---

# Think — Design Session

## Activate When
- `/godmode:think`, "design", "brainstorm", "what's the best approach"
- New feature with no spec

## Workflow

### 1. Understand the Problem
- What does the user want? (one sentence)
- What are the constraints? (time, tech, team)
- What does success look like? (measurable criteria)

### 2. Scan Codebase
```bash
git ls-files | head -50  # project structure
# Look for: existing patterns, conventions, related code
```

### 3. Generate 2-3 Approaches
For each approach:
- Description (2-3 sentences)
- Pros / Cons
- Complexity (Low/Medium/High)
- Files affected

### 4. Recommend One
Lead with your recommendation. Explain why in one sentence.

### 5. Write Spec
Output to `.godmode/spec.md`:
```markdown
# Spec: {feature name}
## Problem: {one sentence}
## Approach: {chosen approach}
## Success Criteria: {measurable}
## Out of Scope: {what we're NOT building}
## Edge Cases: {known gotchas}
```

Commit: `"spec: {feature name}"`

## Rules

1. **Always produce a spec file.** Think without output is wasted.
2. **2-3 approaches, then pick one.** Don't present 7 options.
3. **Measurable success criteria.** "Works well" is not a criterion.
4. **Scan existing code first.** Don't propose patterns that conflict with the codebase.
5. **Keep it short.** Spec should be under 100 lines. If longer, the feature needs decomposition.
