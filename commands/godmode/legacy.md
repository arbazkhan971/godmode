# /godmode:legacy

Modernize legacy codebases safely. Characterizes legacy code, adds tests to untested code (characterization tests, golden master, approval testing), plans incremental modernization, audits dependency health, assesses technology obsolescence, and removes dead code.

## Usage

```
/godmode:legacy                               # Interactive legacy assessment
/godmode:legacy --assess                      # Full codebase health assessment
/godmode:legacy --characterize <path>         # Add characterization tests to a module
/godmode:legacy --golden-master <path>        # Create golden master tests
/godmode:legacy --deps                        # Dependency health check and upgrade plan
/godmode:legacy --obsolescence                # Technology obsolescence assessment
/godmode:legacy --dead-code                   # Detect and report dead code
/godmode:legacy --roadmap                     # Generate modernization roadmap
/godmode:legacy --coverage                    # Analyze test coverage gaps
/godmode:legacy --understand <path>           # Deep analysis of a specific module
/godmode:legacy --dry-run                     # Show plan without making changes
```

## What It Does

1. Characterizes legacy code: age, contributors, test coverage, complexity, dependencies
2. Builds understanding through code archaeology (git blame, dependency graphs, runtime observation)
3. Adds characterization tests that capture current behavior as a safety net
4. Creates golden master tests for complex outputs (HTML, PDFs, reports)
5. Audits dependencies for vulnerabilities, deprecations, and EOL status
6. Assesses technology obsolescence (language versions, framework status)
7. Detects dead code through static analysis, coverage, and git history
8. Generates prioritized modernization roadmaps (security > stability > maintainability)

## Output
- Legacy assessment at `docs/legacy/<project>-assessment.md`
- Modernization roadmap at `docs/legacy/<project>-roadmap.md`
- Characterization tests in `tests/` directory
- Golden master files in `tests/golden-masters/`
- Commit: `"legacy: <action> -- <target> (<impact>)"`

## Testing Strategies for Legacy Code

| Strategy | When to Use | Output |
|----------|-------------|--------|
| **Characterization Tests** | Function with known inputs/outputs | Unit tests capturing current behavior |
| **Golden Master** | Complex outputs (HTML, reports) | Saved output files compared on each run |
| **Approval Testing** | Snapshot-based verification | Jest/pytest snapshots of outputs |
| **Integration Tests** | Module boundaries | Tests at service/API boundaries |

## Next Step
After assessment: `/godmode:plan` to decompose modernization into tasks, then `/godmode:build` with TDD.

## Examples

```
/godmode:legacy Assess our codebase for tech debt
/godmode:legacy --characterize src/payments/processor.js
/godmode:legacy --golden-master src/reports/generator.js
/godmode:legacy --deps Show outdated and vulnerable dependencies
/godmode:legacy --dead-code Find unused code in src/
/godmode:legacy --understand src/legacy/order-engine.js
/godmode:legacy --roadmap Create modernization plan for this project
```
