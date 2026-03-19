# /godmode:debug

Scientific bug investigation using 7 systematic techniques. Reproduces the bug, gathers evidence, isolates the root cause, and produces a root cause analysis document.

## Usage

```
/godmode:debug                              # Investigate current failures
/godmode:debug --error "TypeError: ..."     # Investigate specific error
/godmode:debug --test "test name"           # Investigate specific failing test
/godmode:debug --bisect                     # Jump straight to git bisect
/godmode:debug --trace                      # Add trace logging and re-run
/godmode:debug --quick                      # Skip full investigation, hypothesis from error
```

## What It Does

1. Reproduces the bug (runs the failing command/test)
2. Gathers initial evidence (recent commits, logs, related code)
3. Applies investigation techniques:
   - **Binary search** (git bisect) — find the breaking commit
   - **Minimal reproduction** — simplify until you find the cause
   - **Trace analysis** — follow the execution path
   - **State inspection** — dump state at checkpoints
   - **Dependency isolation** — mock externals one at a time
   - **Diff analysis** — review recent changes
   - **Rubber duck** — explain every line until something doesn't add up
4. Forms and tests a hypothesis
5. Produces a root cause analysis document

## Output
- Root cause analysis with exact file:line, mechanism, and suggested fix
- Does NOT apply the fix (that's `/godmode:fix`)

## Next Step
After debug: `/godmode:fix` to apply the fix and add regression tests.

## Examples

```
/godmode:debug                                    # Investigate all current failures
/godmode:debug --error "Cannot read property 'id' of undefined"
/godmode:debug --test "creates user with valid email"
/godmode:debug --bisect                          # Use git bisect to find the breaking commit
```
