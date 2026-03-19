# /godmode:visual

Visual regression testing using component screenshots, pixel-level diffs, cross-browser comparison, responsive breakpoint testing, and design compliance validation. Detects unintended visual changes before they reach production.

## Usage

```
/godmode:visual                            # Full visual regression test
/godmode:visual --changed-only             # Test only components affected by changes
/godmode:visual --component Button         # Test a specific component
/godmode:visual --browser firefox          # Test in a specific browser
/godmode:visual --breakpoint 768           # Test at a specific viewport width
/godmode:visual --update-baselines         # Accept current state as new baselines
/godmode:visual --design-check             # Design compliance validation only
/godmode:visual --threshold 0.02           # Override diff threshold (default: 0.01)
/godmode:visual --ci                       # CI-friendly output (exit code 1 on fail)
```

## What It Does

1. Assesses visual testing infrastructure (Playwright, BackstopJS, Chromatic, Percy)
2. Identifies components under test with variant/state/breakpoint matrix
3. Captures baseline screenshots or loads existing baselines
4. Runs pixel-level visual comparison against baselines
5. Tests cross-browser rendering (Chromium, Firefox, WebKit)
6. Verifies responsive layout at all breakpoints
7. Validates design token compliance (colors, spacing, typography)
8. Produces diff reports with before/after/highlighted screenshots

## Output
- Visual regression report at `docs/visual/<target>-visual-report.md`
- Baseline update commit: `"visual: update baselines — <N> components updated"`
- Fix commit: `"fix: visual regression — <component> <description>"`
- Verdict: PASS / REVIEW NEEDED / FAIL

## Next Step
If FAIL: Fix regressions, then re-run `/godmode:visual`.
If REVIEW NEEDED: Inspect diffs and either fix or update baselines.
If PASS: `/godmode:a11y` for accessibility, or `/godmode:ship` to deploy.

## Examples

```
/godmode:visual                            # Full visual regression suite
/godmode:visual --changed-only             # Quick check after CSS changes
/godmode:visual --update-baselines         # Accept intentional changes
/godmode:visual --design-check             # Verify design token compliance
```
