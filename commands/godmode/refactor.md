# /godmode:refactor

Safely transform codebases using proven refactoring patterns. Performs impact analysis, ensures test coverage, executes transformations in atomic steps, and verifies correctness after every change.

## Usage

```
/godmode:refactor <description>           # Interactive refactoring with full analysis
/godmode:refactor --extract <type>        # Extract function/class/module/interface
/godmode:refactor --inline <target>       # Inline function/variable/class
/godmode:refactor --move <target> <dest>  # Move code to a new location
/godmode:refactor --rename <old> <new>    # Rename symbol across codebase
/godmode:refactor --analyze-only          # Impact analysis without changes
/godmode:refactor --dry-run               # Show planned changes without applying
/godmode:refactor --strangler             # Use strangler pattern for migration
/godmode:refactor --no-verify             # Skip pre-refactoring test check (dangerous)
```

## What It Does

1. Assesses refactoring scope: complexity, test coverage, dependents, risk level
2. Selects from pattern library: Extract, Inline, Move, Rename, Simplify, Compose, Architecture
3. Runs impact analysis: maps all affected files and dependencies
4. Verifies safety net: tests must pass BEFORE refactoring begins
5. Executes one transformation per commit, running full test suite after each
6. If tests fail at any step, reverts immediately and investigates
7. Reports before/after metrics: test count, coverage, dead code

## Output
- Atomic git commits for each transformation step: `"refactor: <pattern> — <description>"`
- Post-refactoring report with before/after metrics
- Zero behavior changes (test count same or higher)

## Next Step
After refactoring: `/godmode:review` to verify code quality, or `/godmode:test` to add missing test coverage.

## Examples

```
/godmode:refactor Extract business logic from UserController into UserService
/godmode:refactor --rename getUser findUserById     # Rename across codebase
/godmode:refactor --move src/utils/auth.ts src/services/auth.service.ts
/godmode:refactor --analyze-only                    # Just show impact, no changes
/godmode:refactor --strangler                       # Incremental migration approach
```
