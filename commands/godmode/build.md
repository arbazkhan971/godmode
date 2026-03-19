# /godmode:build

Execute an implementation plan using TDD (RED-GREEN-REFACTOR), parallel agent dispatch for independent tasks, and 2-stage code review gates.

## Usage

```
/godmode:build                      # Execute all remaining tasks
/godmode:build --task 5             # Execute only task 5
/godmode:build --phase 2            # Execute only phase 2
/godmode:build --continue           # Resume from last stopping point
/godmode:build --no-parallel        # Disable parallel agents
/godmode:build --no-review          # Skip code review gates
/godmode:build --dry-run            # Show execution plan without making changes
```

## What It Does

1. Loads the plan from `docs/plans/`
2. Verifies pre-build health (tests pass, lint clean)
3. For each task, follows TDD:
   - **RED**: Write failing test, commit
   - **GREEN**: Implement minimum code to pass, commit
   - **REFACTOR**: Clean up without changing behavior, commit
4. Dispatches parallel agents for independent tasks
5. Runs code review at phase boundaries

## Output
- Implementation code with tests
- Small, atomic git commits for each RED/GREEN/REFACTOR step
- Code review report at each phase boundary
- Final build summary: `"build: <feature> — all <N> tasks complete"`

## Next Step
After build completes: `/godmode:optimize` to improve quality, or `/godmode:ship` if satisfied.

## Examples

```
/godmode:build                      # Build everything
/godmode:build --phase 1            # Just build the foundation
/godmode:build --continue           # Resume after a break
```
