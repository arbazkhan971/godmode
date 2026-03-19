# /godmode:quality

Code quality analysis — duplication detection, complexity measurement, technical debt identification, dependency analysis, circular dependency detection, and license compliance checking. Every finding includes location, severity, and actionable remediation.

## Usage

```
/godmode:quality                       # Full quality analysis
/godmode:quality --duplication         # Duplication detection only
/godmode:quality --complexity          # Complexity analysis only
/godmode:quality --debt                # Technical debt identification only
/godmode:quality --deps                # Dependency graph analysis only
/godmode:quality --licenses            # License compliance audit only
/godmode:quality --threshold 15        # Custom complexity threshold
/godmode:quality --trend               # Compare against previous report
```

## What It Does

1. Scans for code duplication (Type 1-3 clones) with extraction recommendations
2. Measures cyclomatic complexity and cognitive complexity for every function
3. Identifies and prioritizes technical debt across 5 categories (code smells, architecture, tests, docs, dependencies)
4. Maps the dependency graph — fan-in/fan-out, instability index, coupling
5. Detects circular dependencies with breaking strategies
6. Audits all dependency licenses for compatibility with project license
7. Produces prioritized action plan using Impact x Likelihood / Effort matrix
8. Assigns overall quality grade (A through F)

## Output
- Quality report at `docs/quality/<project>-quality-report.md`
- Commit: `"quality: <project> — grade <grade> (<N> findings)"`
- Overall grade: A (excellent) through F (critical)

## Next Step
If grade D/F: `/godmode:fix` to address priority items.
If grade A/B/C: `/godmode:optimize` to improve hotspots or `/godmode:ship` to proceed.

## Examples

```
/godmode:quality                       # Full quality analysis
/godmode:quality --deps --licenses     # Dependency and license check
/godmode:quality --complexity          # Just complexity metrics
/godmode:quality --trend               # Compare with last report
```
