# /godmode:ui

UI component architecture analysis covering component library design, design system consistency, Storybook integration, CSS architecture decisions, and component documentation. Identifies violations and enforces patterns across the UI codebase.

## Usage

```
/godmode:ui                                # Full UI architecture audit
/godmode:ui --component DataTable          # Audit a specific component
/godmode:ui --tokens                       # Design token audit only
/godmode:ui --storybook                    # Storybook coverage audit only
/godmode:ui --css-decision                 # CSS architecture recommendation
/godmode:ui --structure                    # Component directory structure audit
/godmode:ui --patterns                     # Component API pattern consistency
/godmode:ui --fix                          # Auto-fix violations
/godmode:ui --init                         # Initialize component library structure
/godmode:ui --generate Button              # Generate new component with all files
```

## What It Does

1. Analyzes current component architecture (framework, styling, library, Storybook)
2. Audits component composition (Atomic Design hierarchy, quality checklist)
3. Evaluates CSS architecture (CSS Modules vs Tailwind vs CSS-in-JS vs SCSS)
4. Checks design system consistency (tokens used vs hardcoded values)
5. Audits Storybook coverage (stories, docs, controls, a11y addon)
6. Validates component documentation completeness
7. Enforces naming conventions and API consistency patterns
8. Auto-fixes common violations (token replacement, ref forwarding, display names)

## Output
- UI architecture report at `docs/ui/<project>-ui-audit.md`
- Fix commit: `"ui: fix <N> component architecture violations"`
- Story commit: `"ui: add Storybook stories for <N> components"`
- Consistency score: HIGH / MEDIUM / LOW

## Next Step
After UI audit: `/godmode:a11y` for accessibility, `/godmode:visual` for visual regression testing, or `/godmode:build` to implement improvements.

## Examples

```
/godmode:ui                                # Full architecture review
/godmode:ui --tokens                       # Find hardcoded values
/godmode:ui --css-decision                 # Get CSS strategy recommendation
/godmode:ui --generate Card                # Scaffold a new component
```
