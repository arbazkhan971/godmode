# /godmode:plan

Decompose a specification into small, implementable tasks. Each task is 2-5 minutes, has exact file paths, code sketches, tests, and dependencies.

## Usage

```
/godmode:plan                              # Plan from most recent spec
/godmode:plan --from-spec <path>           # Plan from a specific spec file
/godmode:plan --max-tasks 20               # Override 15-task maximum
/godmode:plan --parallel                   # Mark tasks that can run in parallel
/godmode:plan --estimate                   # Add time estimates
```

## What It Does

1. Reads the specification from `docs/specs/`
2. Researches the codebase for implementation patterns and file locations
3. Decomposes into ordered tasks grouped by phase (Foundation → Core → Integration → Polish)
4. Each task includes: file path, code sketch, test, and "done when" condition
5. Creates a feature branch if one doesn't exist

## Output
- A plan file saved to `docs/plans/<feature-name>-plan.md`
- A feature branch: `feat/<feature-name>`
- A git commit: `"plan: <feature-name> — <N> tasks in <M> phases"`

## Next Step
After plan completes: `/godmode:build` to start executing tasks with TDD.

## Examples

```
/godmode:plan                          # Plans the most recent spec
/godmode:plan --from-spec docs/specs/rate-limiter.md
/godmode:plan --parallel --estimate    # Show parallel opportunities and time estimates
```
