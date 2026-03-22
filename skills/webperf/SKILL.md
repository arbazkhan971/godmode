---
name: webperf
description: |
  Web performance optimization skill. Activates when user needs Lighthouse auditing, bundle analysis, code splitting, image optimization, critical CSS extraction, font optimization, service worker caching, or CDN configuration. Covers the full web performance stack from server response to paint completion. Triggers on: /godmode:webperf, "Lighthouse audit", "bundle size", "code splitting", "image optimization", "lazy loading", "critical CSS", "font loading", "service worker cache", "CDN", "page speed", "web performance".
---

# Webperf — Web Performance Optimization

## When to Activate
- User invokes `/godmode:webperf`
- User says "page is slow", "improve performance", "Lighthouse score", "bundle too large"
- User mentions "code splitting", "lazy loading", "image optimization", "critical CSS"
- User asks about "font loading", "service worker", "caching strategy", "CDN"
- Pre-ship quality gate during `/godmode:ship` workflow
- After build size increases, new dependency additions, or layout changes
- When Core Web Vitals regress or Lighthouse score drops

## Workflow

### Step 1: Performance Baseline
Establish current performance metrics before optimizing:

```
PERFORMANCE BASELINE:
Target: <URL(s) to optimize>
Framework: <Next.js | React | Vue | Svelte | Angular | Astro | static>
Build tool: <Webpack | Vite | esbuild | Rollup | Turbopack>
Server: <Node.js | edge | static hosting | CDN>

Lighthouse scores (median of 3 runs):
  Performance: <N>/100
  Accessibility: <N>/100
  Best Practices: <N>/100
  SEO: <N>/100

Core Web Vitals:
  LCP: <value> (target: < 2.5s)
  INP: <value> (target: < 200ms)
```

```bash
# Run Lighthouse performance audit
npx lighthouse https://example.com --only-categories=performance --output=json --output-path=./perf-baseline.json

# Analyze bundle size
npx webpack-bundle-analyzer stats.json    # Webpack
npx vite-bundle-visualizer                # Vite
```

### Step 2: Lighthouse Performance Audit
Deep dive into Lighthouse diagnostics:

```
LIGHTHOUSE DIAGNOSTICS:
| Opportunity | Savings | Priority | Effort |
|---|---|---|---|
| Reduce unused JavaScript | 450 KiB | HIGH | Code splitting |
| Serve images in WebP | 320 KiB | HIGH | Build pipeline |
| Eliminate render-block | 1.2s | HIGH | Critical CSS |
| Preload LCP image | 0.8s | HIGH | One-line fix |
| Reduce unused CSS | 180 KiB | MEDIUM | PurgeCSS/tree |
| Text compression (gzip) | 120 KiB | MEDIUM | Server config |
| Efficient cache policy | N/A | MEDIUM | Cache headers |
| Avoid enormous payloads | N/A | LOW | Incremental |

Diagnostics:
```

### Step 3: Bundle Analysis & Code Splitting
Reduce JavaScript payload through splitting and tree shaking:

```
BUNDLE ANALYSIS:
| Chunk | Size (gz) | Loaded | Route |
|---|---|---|---|
| vendor.js | 245 KiB | Always | All pages |
| main.js | 89 KiB | Always | All pages |
| chart-library.js | 180 KiB | Always | Only /dashboard |
| date-picker.js | 45 KiB | Always | Only /settings |
| markdown-editor.js | 120 KiB | Always | Only /editor |

Issues:
- chart-library.js loaded on all pages but only used on /dashboard
- date-picker.js loaded on all pages but only used on /settings
- vendor.js contains moment.js (67 KiB) — replace with date-fns or dayjs
```

#### Code Splitting Strategies
```javascript
// Route-based code splitting (React)
const Dashboard = React.lazy(() => import('./pages/Dashboard'));
const Settings = React.lazy(() => import('./pages/Settings'));

// Component-based code splitting
const ChartWidget = React.lazy(() => import('./components/ChartWidget'));
```

```javascript
// Next.js dynamic imports
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('../components/HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false, // Skip SSR for client-only components
```

#### Tree Shaking Verification
```bash
# Verify tree shaking is working
npx webpack --stats-modules-space 999 | grep "unused"

# Check for side effects preventing tree shaking
# package.json should declare: "sideEffects": false
# or list specific files: "sideEffects": ["*.css", "./src/polyfills.js"]
```

### Step 4: Image Optimization
Optimize images for modern web delivery:

```
IMAGE AUDIT:
| Image | Format | Size | Dimensions | Issues |
|---|---|---|---|---|
| hero.jpg | JPEG | 1.2 MB | 4000x2000 | No srcset, oversized |
| logo.png | PNG | 45 KB | 400x100 | Could be SVG |
| team-photo.jpg | JPEG | 800 KB | 3000x2000 | No lazy load |
| icon-set.png | PNG | 120 KB | 500x500 | Convert to SVG |
| product-1.jpg | JPEG | 650 KB | 2400x1600 | No WebP |

Total image weight: <N> MB
Potential savings: <N> MB (<N>% reduction)
```

#### Modern Image Formats
```html
<!-- Serve modern formats with fallback -->
<picture>
  <source srcset="hero.avif" type="image/avif">
  <source srcset="hero.webp" type="image/webp">
  <img src="hero.jpg" alt="Hero image" width="1200" height="600"
       loading="lazy" decoding="async">
```

#### Responsive Images
```html
<!-- Responsive images with srcset and sizes -->
<img
  srcset="
    hero-400.webp 400w,
    hero-800.webp 800w,
    hero-1200.webp 1200w,
```

#### Build Pipeline Image Optimization
```bash
# Sharp for Node.js image processing
npm install sharp

# Next.js: built-in image optimization (next/image)
# Astro: built-in image optimization (astro:assets)
# Vite: vite-imagetools plugin
```

### Step 5: Critical CSS Extraction
Inline above-the-fold CSS to eliminate render blocking:

```
CRITICAL CSS ANALYSIS:
Total CSS: <size> (gzipped: <size>)
Above-the-fold CSS: <size> (estimated)
Render-blocking stylesheets: <N> files
Blocking time: <N>ms

Strategy:
  1. Extract critical CSS for each route
  2. Inline in <style> tag in <head>
  3. Async-load remaining CSS
  4. Remove unused CSS rules
```

```bash
# Extract critical CSS with critical
npm install critical
npx critical https://example.com --inline --minify --base dist/

# Extract with critters (Webpack/Vite plugin)
npm install critters-webpack-plugin  # Webpack
```

```html
<!-- Inline critical CSS, async-load the rest -->
<head>
  <style>
    /* Critical (above-the-fold) CSS inlined here */
    .header { ... }
    .hero { ... }
```

### Step 6: Font Optimization
Optimize web font loading for fast, shift-free text rendering:

```
FONT AUDIT:
| Font | Weight | Format | Size | font-display | Used |
|---|---|---|---|---|---|
| Inter | 400 | woff2 | 24 KB | swap | Yes |
| Inter | 500 | woff2 | 25 KB | swap | Yes |
| Inter | 600 | woff2 | 25 KB | swap | Yes |
| Inter | 700 | woff2 | 26 KB | swap | Yes |
| Inter | 300 | woff2 | 24 KB | swap | No |
| Inter | 800 | woff2 | 26 KB | swap | No |
| FancyDisplay | 400 | ttf | 180 KB | (none) | Yes |

Issues:
- Inter 300 and 800 loaded but never used in CSS — remove
- FancyDisplay served as TTF (180 KB) — convert to woff2 (~50 KB)
- FancyDisplay missing font-display — causes FOIT (invisible text)
```

#### Font Loading Strategy
```css
/* Optimal font-face declaration */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;  /* Variable font — one file for all weights */
  font-display: swap;     /* Show fallback immediately, swap when loaded */
```

```html
<!-- Preload critical fonts -->
<link rel="preload" href="/fonts/inter-var.woff2" as="font" type="font/woff2" crossorigin>
```

```bash
# Subset fonts to include only needed characters
npx glyphhanger https://example.com --subset=fonts/inter.woff2 --formats=woff2

# Convert TTF/OTF to WOFF2
npx woff2-cli compress fonts/fancy.ttf

```

### Step 7: Service Worker Caching Strategies
Configure service workers for optimal caching:

```
CACHING STRATEGY MATRIX:
| Resource Type | Strategy | Max Age | Rationale |
|---|---|---|---|
| HTML pages | Network First | 0 | Fresh content |
| CSS/JS (hashed) | Cache First | 1 year | Immutable |
| CSS/JS (unhashed) | Stale While Revalidate | 1 hour | Fast + fresh |
| Images | Cache First | 30 days | Rarely change |
| Fonts | Cache First | 1 year | Never change |
| API (dynamic) | Network First | 0 | Real-time |
| API (semi-static) | Stale While Revalidate | 5 min | Fast + fresh |
| Third-party | Stale While Revalidate | 1 day | Not controlled |
```

#### Workbox Configuration
```javascript
// workbox-config.js
module.exports = {
  globDirectory: 'dist/',
  globPatterns: ['**/*.{html,js,css,png,jpg,webp,avif,woff2,svg}'],
  swDest: 'dist/sw.js',
  runtimeCaching: [
```

```bash
# Generate service worker with Workbox
npx workbox generateSW workbox-config.js

# Or inject into existing service worker
npx workbox injectManifest workbox-config.js
```

### Step 8: CDN & Edge Caching
Configure CDN and HTTP cache headers for optimal delivery:

```
CDN & CACHING AUDIT:
| Resource | Cache-Control | CDN | Edge Cache |
|---|---|---|---|
| HTML | no-cache | Yes | 0 (origin) |
| JS (hashed) | public, max-age=31536000 | Yes | 1 year |
| CSS (hashed) | public, max-age=31536000 | Yes | 1 year |
| Images | public, max-age=2592000 | Yes | 30 days |
| Fonts | public, max-age=31536000 | Yes | 1 year |
| API responses | private, no-store | No | 0 |
| Static data API | public, s-maxage=300 | Yes | 5 min (edge) |
```

```
# Optimal Cache-Control headers
# Hashed static assets (immutable)
Cache-Control: public, max-age=31536000, immutable

# HTML pages (always revalidate)
Cache-Control: no-cache
# or: public, max-age=0, must-revalidate

# API responses (private, no caching)
Cache-Control: private, no-store

# Semi-static API (edge-cacheable)
Cache-Control: public, s-maxage=300, stale-while-revalidate=600

# Images (long but not immutable)
Cache-Control: public, max-age=2592000
```

### Step 9: Performance Optimization Report

```
|  WEB PERFORMANCE AUDIT — <target>                           |
|  Lighthouse Scores:                                         |
|  Performance: <before> → <after> (+<delta>)                 |
|  Best Practices: <N>/100                                    |
|  Core Web Vitals:                                           |
|  LCP: <before> → <after> (target: < 2.5s)                  |
|  INP: <before> → <after> (target: < 200ms)                 |
```

Verdicts:
- **FAST**: Lighthouse Performance >= 90, all CWV "Good", total JS < 200KB gzipped.
- **ACCEPTABLE**: Lighthouse Performance >= 70, CWV mostly "Good" or "Needs Improvement", total JS < 400KB gzipped.
- **SLOW**: Lighthouse Performance < 70, or any CWV "Poor", or total JS > 400KB gzipped.

### Step 10: Commit and Transition
1. Save report as `docs/webperf/<target>-perf-report.md`
2. If optimizations were applied, commit: `"webperf: <target> — <N> optimizations (<savings> saved)"`
3. Commit report: `"webperf: <target> — <verdict> (Lighthouse: <before> → <after>)"`
4. If SLOW: "Performance issues found. Apply the remaining opportunities, then re-audit with `/godmode:webperf`."
5. If FAST: "Performance audit passed. Ready for `/godmode:seo` or `/godmode:ship`."

## Key Behaviors

1. **Measure before optimizing.** Run Lighthouse and bundle analysis to establish a baseline. Without numbers, you are guessing. Optimization without measurement is superstition.
2. **JavaScript is the most expensive resource.** A 200KB image and 200KB of JavaScript are not equivalent. The browser parses, compiles, and executes JavaScript. Reduce JS first.
3. **Images are the lowest-hanging fruit.** Converting to WebP/AVIF, adding responsive srcset, and enabling lazy loading often saves more bytes than any code change.
4. **Critical CSS eliminates render blocking.** Inlining above-the-fold CSS and async-loading the rest removes the single biggest cause of slow First Contentful Paint.
5. **Fonts cause invisible text.** Without font-display: swap and proper preloading, custom fonts cause Flash of Invisible Text (FOIT). Users see a blank page while fonts download.
6. **Cache everything possible.** Cache hashed assets for a year. Service workers provide offline caching. CDN edge caches reduce latency. Every cache miss is wasted time.
7. **Third-party scripts are performance debt.** Every analytics tag, chat widget, and ad script runs on the main thread. Audit third-party impact and defer or remove what is not essential.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full performance audit and optimization |
| `--lighthouse` | Lighthouse audit only (no optimization) |
| `--bundle` | Bundle analysis and code splitting recommendations |

## HARD RULES

1. **NEVER optimize without measuring first.** Run Lighthouse, analyze the bundle, measure Core Web Vitals. Data drives optimization, not intuition.
2. **NEVER lazy-load the LCP element.** The Largest Contentful Paint image must load eagerly with `fetchpriority="high"`.
3. **NEVER serve uncompressed assets.** Enable gzip or Brotli compression. Uncompressed text assets are 60-80% larger.
4. **NEVER set `Cache-Control: no-store` on static assets with hashed filenames.** Hash-versioned assets are immutable -- cache them for a year.
5. **ALWAYS code-split by route** and lazy load components not visible on initial render.
6. **ALWAYS use responsive images with srcset.** A 4000px image on a 375px screen wastes 90% of bytes.
7. **ALWAYS measure third-party script impact.** A single chat widget can add 200KB+ and block the main thread for seconds.
8. **ALWAYS set a performance budget** and enforce it in CI. Without a budget, performance degrades one commit at a time.

## Auto-Detection

On activation, detect the web performance context:

```bash
# Detect build tool
ls webpack.config.* vite.config.* next.config.* nuxt.config.* 2>/dev/null

# Detect bundle analysis tools
grep -r "webpack-bundle-analyzer\|source-map-explorer\|@next/bundle-analyzer" package.json 2>/dev/null

```

## Output Format
Print on completion: `Webperf: Lighthouse {before_score} → {after_score} (+{delta}). LCP: {lcp}s, INP: {inp}ms, CLS: {cls}. JS: {js_before} → {js_after} (-{js_savings}). Total transfer: {transfer_before} → {transfer_after}. Verdict: {verdict}.`

## TSV Logging
Log every optimization iteration to `.godmode/webperf-results.tsv`:
```
iteration	optimization	lighthouse_before	lighthouse_after	lcp_ms	inp_ms	cls	js_size_kb	status
1	code_splitting	62	71	3800	180	0.12	487	improved
2	image_webp	71	79	3200	180	0.12	487	improved
3	critical_css	79	88	2400	160	0.05	487	improved
4	font_optimize	88	91	2100	140	0.03	487	target_met
```
Columns: iteration, optimization, lighthouse_before, lighthouse_after, lcp_ms, inp_ms, cls, js_size_kb, status(improved/no_change/regressed/target_met).

## Success Criteria
- Lighthouse Performance score >= 90.
- All Core Web Vitals in "Good" range: LCP < 2.5s, INP < 200ms, CLS < 0.1.
- Total JavaScript bundle < 200KB gzipped.
- All images served in modern formats (WebP/AVIF) with responsive srcset.
- Critical CSS inlined, remaining CSS async-loaded.
- Font loading optimized with `font-display: swap` and preload.
- Cache headers set correctly (immutable for hashed assets, revalidate for HTML).
- Performance budget defined and enforced in CI.

## Keep/Discard Discipline
```
After EACH performance optimization:
  1. MEASURE: Re-run Lighthouse audit (median of 3 runs). Check Core Web Vitals.
  2. COMPARE: Did Lighthouse score improve? Did any CWV regress?
  3. DECIDE:
     - KEEP if: Lighthouse score improved AND no CWV regression AND no visual breakage
     - DISCARD if: Lighthouse score unchanged/decreased OR any CWV regressed OR layout broken
  4. COMMIT kept changes. Revert discarded changes before the next optimization.

Never keep a JS bundle optimization that breaks visual rendering or causes CLS regression.
```

## Stuck Recovery
```
IF >3 consecutive optimizations produce no Lighthouse improvement:
  1. Clear all caches and re-run in incognito — cached resources can mask improvements.
  2. Check if the bottleneck has shifted: use Lighthouse Treemap to identify the new largest contributor.
  3. Look for third-party scripts that dominate main-thread time — these require loading strategy changes, not code changes.
  4. If still stuck → log stop_reason=optimization_plateau, report current metrics and remaining opportunities.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Lighthouse Performance >= 90
  - All Core Web Vitals in "Good" range (LCP < 2.5s, INP < 200ms, CLS < 0.1)
  - Performance budget thresholds met
  - User explicitly requests stop
  - No further optimizations yield meaningful improvement (< 2 point Lighthouse improvement)

DO NOT STOP just because:
  - Third-party scripts lower the score (report them but focus on what you can control)
  - One page is slow if the rest are fast (report the slow page separately)
```

## Simplicity Criterion
```
PREFER the simpler performance optimization:
  - next/image or framework-native image optimization before custom Sharp pipelines
  - Route-based code splitting (built into Next.js, Remix, SvelteKit) before manual dynamic imports
  - font-display: swap before complex font subsetting and size-adjust calculations
  - Cache-Control headers before service worker caching strategies
  - Removing unused dependencies before tree-shaking configuration tweaks
  - Fewer large impactful optimizations (images, code splitting, critical CSS) over many micro-optimizations
```


## Error Recovery
| Failure | Action |
|---------|--------|
| LCP regression after code change | Check for render-blocking resources added. Verify critical CSS is inlined. Check image loading strategy (preload hero image). |
| CLS spike on specific pages | Find the shifting element with DevTools Performance panel. Set explicit dimensions on images, ads, and embeds. |
| Bundle size increased unexpectedly | Run bundle analyzer. Check for new dependencies. Verify tree-shaking works. Check for duplicate dependencies in lockfile. |
| Performance gains disappear in production | Check CDN cache hit rate. Verify compression (brotli/gzip) is active. Check for A/B test or feature flag overhead. |
