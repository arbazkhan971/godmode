# /godmode:responsive

Responsive and adaptive design covering layout strategies (fluid, adaptive, intrinsic), CSS Grid and Flexbox mastery, container queries, mobile-first and desktop-first breakpoint systems, fluid typography, responsive images with art direction, print stylesheets, and touch vs pointer interactions.

## Usage

```
/godmode:responsive                           # Full responsive design — build or audit
/godmode:responsive --audit                   # Audit existing site for responsive issues
/godmode:responsive --grid                    # CSS Grid layout implementation
/godmode:responsive --container-queries       # Container query setup
/godmode:responsive --images                  # Responsive images optimization
/godmode:responsive --typography              # Fluid typography implementation
/godmode:responsive --print                   # Print stylesheet setup
/godmode:responsive --touch                   # Touch vs pointer interaction setup
/godmode:responsive --breakpoints             # Breakpoint system audit and standardization
/godmode:responsive --table DataTable         # Make a specific table responsive
```

## What It Does

1. Assesses responsive requirements (target devices, strategy, current state)
2. Implements mobile-first or desktop-first breakpoint system
3. Builds CSS Grid layouts with named areas, auto-fit, and subgrid
4. Implements container queries for component-level responsive design
5. Creates fluid typography and spacing with clamp()
6. Optimizes images with srcset, art direction, and modern formats (avif, webp)
7. Adds print stylesheets with page break controls and URL display
8. Handles touch vs pointer interactions with pointer media queries
9. Makes data tables responsive (scroll or stack patterns)
10. Audits all viewports (320px through 1536px+) for issues

## Output
- Responsive layout components and CSS
- Responsive audit report at `docs/responsive/<project>-responsive-audit.md`
- Score: 0-100
- Verdict: RESPONSIVE / PARTIALLY RESPONSIVE / DESKTOP-ONLY

## Next Step
After responsive design: `/godmode:a11y` for accessibility, `/godmode:perf` for performance, `/godmode:visual` for visual regression testing, or `/godmode:e2e` for cross-viewport E2E testing.

## Examples

```
/godmode:responsive                           # Full responsive audit or build
/godmode:responsive --audit                   # Find responsive issues
/godmode:responsive --grid                    # Build Grid-based layout
/godmode:responsive --container-queries       # Add container queries
/godmode:responsive --images                  # Optimize images for all viewports
/godmode:responsive --print                   # Add print stylesheet
```
