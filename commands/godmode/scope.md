# /godmode:scope

Manage project scope with feature decomposition, MVP definition, scope creep detection, requirements validation, and user story writing.

## Usage

```
/godmode:scope                                # Full scoping workflow for a feature
/godmode:scope --mvp                          # Define MVP only
/godmode:scope --creep                        # Detect scope creep against original scope
/godmode:scope --validate                     # Validate requirements completeness and consistency
/godmode:scope --stories                      # Generate user stories from requirements
/godmode:scope --refine "Story 3"             # Refine a specific user story
/godmode:scope --feature notifications        # Scope a specific feature
/godmode:scope --budget 30                    # Scope to fit within a point budget
/godmode:scope --compare v1 v2                # Compare scope between versions
```

## What It Does

1. **Decompose** — Breaks features into capabilities with complexity estimates (S/M/L/XL)
2. **MVP** — Identifies the minimum viable set that delivers core user value
3. **Boundaries** — Explicitly defines in-scope, out-of-scope, assumptions, and open questions
4. **Creep Detection** — Compares current state to original scope with quantified drift percentage
5. **Validate** — Checks requirements for completeness, consistency, testability, and ambiguity
6. **Stories** — Generates INVEST-quality user stories with Gherkin acceptance criteria

## Output
- Scope document saved to `docs/scopes/<feature-name>-scope.md`
- User stories with acceptance criteria
- Scope creep analysis with severity rating (GREEN/YELLOW/ORANGE/RED)
- Requirements validation report
- Git commit with scope summary

## Next Step
After scope: `/godmode:think` to design the solution, or `/godmode:plan` to plan implementation.

## Examples

```
/godmode:scope --feature "user notifications"  # Full scope for notifications
/godmode:scope --mvp --budget 20               # MVP that fits in 20 points
/godmode:scope --creep                         # Check for scope drift
/godmode:scope --stories --feature auth        # User stories for auth feature
```
