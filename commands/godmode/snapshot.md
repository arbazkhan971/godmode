# /godmode:snapshot

Snapshot and approval testing for complex outputs. Verifies serialized structures, generated code, UI components, and CLI output against known-good baselines with proper stabilization and update policies.

## Usage

```
/godmode:snapshot                          # Assess suitability and write snapshot tests
/godmode:snapshot --for <file>             # Write snapshot tests for a specific component
/godmode:snapshot --inline                 # Prefer inline snapshots over file-based
/godmode:snapshot --approval               # Use approval testing workflow
/godmode:snapshot --golden                 # Use golden file testing pattern
/godmode:snapshot --update                 # Update existing snapshots after intentional changes
/godmode:snapshot --audit                  # Audit existing snapshots for rot and staleness
/godmode:snapshot --stabilize              # Focus on stabilizing non-deterministic output
```

## What It Does

1. Evaluates whether snapshot testing is appropriate for the target
2. Chooses the right strategy:
   - **File-based snapshots** for large, complex outputs
   - **Inline snapshots** for small, reviewable outputs (<20 lines)
   - **Approval testing** for human-reviewed baselines
   - **Golden file testing** for deterministic artifacts (Go idiom)
3. Stabilizes non-deterministic output (timestamps, UUIDs, tokens)
4. Writes snapshot tests with proper naming and organization
5. Configures CI to prevent obsolete snapshots and uncommitted received files
6. Audits existing snapshots for rot, size, and staleness

## Output
- Snapshot test files alongside existing tests
- Snapshot files (`.snap`, `.approved.txt`, `.golden`)
- Stabilization utilities for non-deterministic values
- Commit: `"test(snapshot): <module> — <N> snapshot tests"`

## Next Step
After snapshots: `/godmode:unittest` for behavioral tests that complement snapshots.
If snapshot rot detected: `/godmode:snapshot --audit` to clean up.

## Examples

```
/godmode:snapshot --for src/components/Invoice.tsx     # Component snapshots
/godmode:snapshot --golden                              # Go golden file pattern
/godmode:snapshot --approval                            # Human-reviewed baselines
/godmode:snapshot --audit                               # Find snapshot rot
/godmode:snapshot --stabilize                           # Fix flaky snapshots
```
