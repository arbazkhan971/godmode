---
name: webperf
description: >
  Web performance optimization. Lighthouse, bundle
  analysis, code splitting, image optimization,
  critical CSS, fonts, service workers, CDN.
---

# Webperf -- Web Performance Optimization

## Activate When
- `/godmode:webperf`, "page is slow", "Lighthouse"
- "bundle too large", "code splitting", "lazy loading"
- "image optimization", "critical CSS", "font loading"
- Pre-ship quality gate or Core Web Vitals regression

## Workflow

### Step 1: Performance Baseline
```bash
# Lighthouse audit (median of 3 runs)
npx lighthouse https://example.com \
  --only-categories=performance \
  --output=json --output-path=./perf-baseline.json

# Bundle analysis
npx vite-bundle-visualizer    # Vite
npx webpack-bundle-analyzer stats.json  # Webpack
```
```
BASELINE:
  Lighthouse Performance: <N>/100
  LCP: <N>s (target: <2.5s)
  INP: <N>ms (target: <200ms)
  CLS: <N> (target: <0.1)
  Total JS: <N>KB gzipped
  Total CSS: <N>KB gzipped
  Total transfer: <N>KB
```

### Step 2: Lighthouse Diagnostics
```
| Opportunity        | Savings | Priority |
|-------------------|---------|---------|
| Reduce unused JS  | 450 KiB | HIGH    |
| Serve WebP images | 320 KiB | HIGH    |
| Eliminate render-block| 1.2s | HIGH    |
| Preload LCP image | 0.8s   | HIGH    |
| Reduce unused CSS | 180 KiB | MEDIUM  |

IF Lighthouse < 70: fix HIGH opportunities first
IF Lighthouse 70-89: fix HIGH + MEDIUM
IF Lighthouse >= 90: target remaining MEDIUM/LOW
```

### Step 3: Bundle Analysis & Code Splitting
```bash
# Route-based splitting (React)
# const Dashboard = React.lazy(() =>
#   import('./pages/Dashboard'));

# Verify tree shaking
grep '"sideEffects"' package.json
```
```
BUNDLE ANALYSIS:
| Chunk             | Size(gz) | Loaded  | Route     |
|------------------|---------|---------|----------|
| vendor.js        | 245 KiB | Always  | All      |
| chart-library.js | 180 KiB | Always  | /dashboard|
| main.js          | 89 KiB  | Always  | All      |

IF chunk loaded on all pages but used on one:
  split into route-specific chunk
IF vendor > 200KB gzipped: split heavy deps
IF total JS > 400KB gzipped: SLOW classification
```

### Step 4: Image Optimization
```html
<picture>
  <source srcset="hero.avif" type="image/avif">
  <source srcset="hero.webp" type="image/webp">
  <img src="hero.jpg" alt="Hero" width="1200"
       height="600" loading="lazy" decoding="async">
</picture>
```
```bash
# Install Sharp for processing
npm install sharp

# Subset fonts
npx glyphhanger https://example.com \
  --subset=fonts/inter.woff2 --formats=woff2
```
Rules:
- LCP image: `fetchpriority="high"`, no lazy-load
- All other images: `loading="lazy"`
- Responsive srcset with 400w, 800w, 1200w
- WebP + AVIF with JPEG fallback
- Explicit width/height on every image (CLS)

### Step 5: Critical CSS
```bash
npx critical https://example.com \
  --inline --minify --base dist/
```
```
IF render-blocking stylesheets > 0:
  extract critical CSS, inline in <head>
  async-load remaining CSS
IF using Vite: use critters plugin
IF using Next.js: built-in CSS optimization
```

### Step 6: Font Optimization
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-weight: 100 900;
  font-display: swap;
}
```
```html
<link rel="preload" href="/fonts/inter-var.woff2"
  as="font" type="font/woff2" crossorigin>
```
Rules:
- Variable fonts (one file for all weights)
- font-display: swap (show fallback immediately)
- Preload critical fonts in <head>
- Subset to needed characters (30-50% savings)
- WOFF2 only (smallest format)

### Step 7: Service Worker & CDN
```
CACHING STRATEGY:
  HTML: Network First (always fresh)
  CSS/JS hashed: Cache First (1yr, immutable)
  Images: Cache First (30 days)
  Fonts: Cache First (1yr)
  API: Network First or stale-while-revalidate

CDN HEADERS:
  Hashed assets: max-age=31536000, immutable
  HTML: no-cache (revalidate every request)
  API: private, no-cache
```

### Step 8: Performance Report
```
WEBPERF AUDIT:
  Lighthouse: {before} -> {after} (+{delta})
  LCP: {before}s -> {after}s (target: <2.5s)
  INP: {before}ms -> {after}ms (target: <200ms)
  CLS: {before} -> {after} (target: <0.1)
  JS: {before}KB -> {after}KB (-{savings})

VERDICT:
  FAST: Lighthouse >=90, all CWV good, JS <200KB
  ACCEPTABLE: Lighthouse >=70, CWV mostly good
  SLOW: Lighthouse <70 or any CWV poor
```

## Key Behaviors
1. **Measure before optimizing.** No guessing.
2. **JS is the most expensive resource.** Cut first.
3. **Images are lowest-hanging fruit.**
4. **Critical CSS eliminates render blocking.**
5. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER optimize without measuring first.
2. NEVER lazy-load the LCP element.
3. NEVER serve uncompressed assets. Brotli/gzip.
4. NEVER no-store on hashed static assets.
5. ALWAYS code-split by route.
6. ALWAYS use responsive images with srcset.
7. ALWAYS measure third-party script impact.
8. ALWAYS set and enforce performance budget in CI.

## Auto-Detection
```bash
ls webpack.config.* vite.config.* next.config.* \
  nuxt.config.* 2>/dev/null
grep -r "bundle-analyzer\|source-map-explorer" \
  package.json 2>/dev/null
```

## TSV Logging
Log to `.godmode/webperf-results.tsv`:
`iteration\toptimization\tlighthouse_before\tlighthouse_after\tlcp_ms\tinp_ms\tcls\tjs_kb\tstatus`

## Output Format
Print: `Webperf: Lighthouse {before} -> {after}. LCP: {N}s. INP: {N}ms. CLS: {N}. JS: {N}KB. Verdict: {verdict}.`

## Keep/Discard Discipline
```
KEEP if: Lighthouse improved AND no CWV regression
  AND no visual breakage
DISCARD if: Lighthouse unchanged/decreased
  OR CWV regressed OR layout broken. Revert.
```

## Stop Conditions
```
STOP when:
  - Lighthouse Performance >= 90
  - All CWV good (LCP <2.5s, INP <200ms, CLS <0.1)
  - Performance budget met
  - <2 point improvement per iteration
  - User requests stop
```
