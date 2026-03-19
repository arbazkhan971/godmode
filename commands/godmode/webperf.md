# /godmode:webperf

Web performance optimization covering Lighthouse auditing, bundle analysis, code splitting, image optimization (WebP/AVIF, lazy loading, responsive images), critical CSS extraction, font optimization, service worker caching, and CDN configuration. Measures before/after with Core Web Vitals and bundle size metrics.

## Usage

```
/godmode:webperf                          # Full performance audit and optimization
/godmode:webperf --lighthouse             # Lighthouse audit only (no optimization)
/godmode:webperf --bundle                 # Bundle analysis and code splitting
/godmode:webperf --images                 # Image optimization (WebP/AVIF, srcset, lazy)
/godmode:webperf --css                    # Critical CSS extraction and unused CSS removal
/godmode:webperf --fonts                  # Font optimization (subsetting, font-display)
/godmode:webperf --cache                  # Service worker and HTTP caching audit
/godmode:webperf --cdn                    # CDN and edge caching configuration
/godmode:webperf --page /dashboard        # Audit a specific page
/godmode:webperf --budget perf-budget.json # Check against performance budget
/godmode:webperf --fix                    # Auto-apply optimizations after audit
/godmode:webperf --ci                     # CI-friendly output (exit code 1 if below thresholds)
```

## What It Does

1. Establishes performance baseline (Lighthouse scores, Core Web Vitals, bundle sizes)
2. Runs Lighthouse diagnostics with opportunity/savings analysis
3. Analyzes JavaScript bundles:
   - Identifies oversized chunks and dead code
   - Recommends route-based and component-based code splitting
   - Suggests lighter library alternatives
4. Optimizes images:
   - Converts to WebP/AVIF with `<picture>` fallbacks
   - Adds responsive `srcset` and `sizes`
   - Enables lazy loading for below-the-fold images
5. Extracts critical CSS and removes unused styles
6. Optimizes font loading (subsetting, `font-display`, preloading, fallback metrics)
7. Configures service worker caching strategies (Cache First, Network First, Stale While Revalidate)
8. Sets up CDN and HTTP cache headers for optimal delivery

## Output
- Performance report at `docs/webperf/<target>-perf-report.md`
- Optimization commit: `"webperf: <target> — <N> optimizations (<savings> saved)"`
- Report commit: `"webperf: <target> — <verdict> (Lighthouse: <before> → <after>)"`
- Verdict: FAST / ACCEPTABLE / SLOW

## Next Step
If SLOW: Apply remaining opportunities, then re-audit with `/godmode:webperf`.
If FAST: `/godmode:seo` for SEO optimization, or `/godmode:ship` to deploy.

## Examples

```
/godmode:webperf                          # Full audit and optimization
/godmode:webperf --bundle                 # Analyze and split bundles
/godmode:webperf --images                 # Optimize all images
/godmode:webperf --fonts --css            # Font and CSS optimization
```
