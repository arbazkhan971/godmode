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
  CLS: <value> (target: < 0.1)
  FCP: <value> (target: < 1.8s)
  TTFB: <value> (target: < 200ms)

Bundle analysis:
  Total JS: <size> (gzipped: <size>)
  Total CSS: <size> (gzipped: <size>)
  Largest chunks: <list with sizes>
  Third-party JS: <size> (<percentage> of total)
```

```bash
# Run Lighthouse performance audit
npx lighthouse https://example.com --only-categories=performance --output=json --output-path=./perf-baseline.json

# Analyze bundle size
npx webpack-bundle-analyzer stats.json    # Webpack
npx vite-bundle-visualizer                # Vite
npx source-map-explorer dist/**/*.js      # Any bundler with source maps

# Measure real bundle sizes
npx bundlesize --files "dist/**/*.js" --max-size 100kB
```

### Step 2: Lighthouse Performance Audit
Deep dive into Lighthouse diagnostics:

```
LIGHTHOUSE DIAGNOSTICS:
┌──────────────────────────────────────────────────────────────────┐
│ Opportunity              │ Savings  │ Priority │ Effort          │
├──────────────────────────────────────────────────────────────────┤
│ Reduce unused JavaScript │ 450 KiB  │ HIGH     │ Code splitting  │
│ Serve images in WebP     │ 320 KiB  │ HIGH     │ Build pipeline  │
│ Eliminate render-block   │ 1.2s     │ HIGH     │ Critical CSS    │
│ Preload LCP image        │ 0.8s     │ HIGH     │ One-line fix    │
│ Reduce unused CSS        │ 180 KiB  │ MEDIUM   │ PurgeCSS/tree   │
│ Text compression (gzip)  │ 120 KiB  │ MEDIUM   │ Server config   │
│ Efficient cache policy   │ N/A      │ MEDIUM   │ Cache headers   │
│ Avoid enormous payloads  │ N/A      │ LOW      │ Incremental     │
└──────────────────────────────────────────────────────────────────┘

Diagnostics:
  DOM size: <N> elements (target: < 1,500)
  Main thread work: <N>ms (target: < 2,000ms)
  JavaScript execution: <N>ms
  Style & Layout: <N>ms
  Render-blocking resources: <N> files, <N>ms blocking time
  Third-party code impact: <N>ms main thread, <size> transfer
```

### Step 3: Bundle Analysis & Code Splitting
Reduce JavaScript payload through splitting and tree shaking:

```
BUNDLE ANALYSIS:
┌──────────────────────────────────────────────────────────────────┐
│ Chunk              │ Size (gz) │ Loaded │ Route              │
├──────────────────────────────────────────────────────────────────┤
│ vendor.js          │ 245 KiB   │ Always │ All pages          │
│ main.js            │ 89 KiB    │ Always │ All pages          │
│ chart-library.js   │ 180 KiB   │ Always │ Only /dashboard    │
│ date-picker.js     │ 45 KiB    │ Always │ Only /settings     │
│ markdown-editor.js │ 120 KiB   │ Always │ Only /editor       │
└──────────────────────────────────────────────────────────────────┘

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
const MarkdownEditor = React.lazy(() => import('./components/MarkdownEditor'));

// Dynamic import with loading states
function DashboardPage() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <ChartWidget />
    </Suspense>
  );
}
```

```javascript
// Next.js dynamic imports
import dynamic from 'next/dynamic';

const HeavyComponent = dynamic(() => import('../components/HeavyComponent'), {
  loading: () => <Skeleton />,
  ssr: false, // Skip SSR for client-only components
});
```

#### Tree Shaking Verification
```bash
# Verify tree shaking is working
npx webpack --stats-modules-space 999 | grep "unused"

# Check for side effects preventing tree shaking
# package.json should declare: "sideEffects": false
# or list specific files: "sideEffects": ["*.css", "./src/polyfills.js"]

# Replace heavy libraries with lighter alternatives
# moment.js (67KB) → date-fns (tree-shakeable) or dayjs (2KB)
# lodash (72KB) → lodash-es (tree-shakeable) or native methods
# axios (14KB) → fetch API (built-in) or ky (3KB)
```

### Step 4: Image Optimization
Optimize images for modern web delivery:

```
IMAGE AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│ Image            │ Format │ Size    │ Dimensions │ Issues         │
├──────────────────────────────────────────────────────────────────┤
│ hero.jpg         │ JPEG   │ 1.2 MB  │ 4000x2000  │ No srcset, oversized │
│ logo.png         │ PNG    │ 45 KB   │ 400x100    │ Could be SVG   │
│ team-photo.jpg   │ JPEG   │ 800 KB  │ 3000x2000  │ No lazy load   │
│ icon-set.png     │ PNG    │ 120 KB  │ 500x500    │ Should be SVG  │
│ product-1.jpg    │ JPEG   │ 650 KB  │ 2400x1600  │ No WebP        │
└──────────────────────────────────────────────────────────────────┘

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
</picture>

<!-- LCP image: eager loading with high priority -->
<img src="hero.webp" alt="Hero" width="1200" height="600"
     loading="eager" fetchpriority="high" decoding="async">
```

#### Responsive Images
```html
<!-- Responsive images with srcset and sizes -->
<img
  srcset="
    hero-400.webp 400w,
    hero-800.webp 800w,
    hero-1200.webp 1200w,
    hero-1600.webp 1600w"
  sizes="(max-width: 640px) 100vw,
         (max-width: 1024px) 80vw,
         1200px"
  src="hero-1200.webp"
  alt="Hero image"
  width="1200"
  height="600"
  loading="lazy"
  decoding="async"
>
```

#### Build Pipeline Image Optimization
```bash
# Sharp for Node.js image processing
npm install sharp

# Next.js: built-in image optimization (next/image)
# Astro: built-in image optimization (astro:assets)
# Vite: vite-imagetools plugin

# CLI optimization
npx sharp-cli --input "src/images/*.{jpg,png}" --output dist/images/ --webp --avif --resize 1200

# Squoosh CLI for batch optimization
npx @squoosh/cli --webp auto --avif auto -d dist/images/ src/images/*.jpg
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
npm install critters                  # Vite/generic

# Remove unused CSS with PurgeCSS
npx purgecss --css dist/styles.css --content "dist/**/*.html" --output dist/styles.purged.css
```

```html
<!-- Inline critical CSS, async-load the rest -->
<head>
  <style>
    /* Critical (above-the-fold) CSS inlined here */
    .header { ... }
    .hero { ... }
    .nav { ... }
  </style>
  <!-- Async load full stylesheet -->
  <link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="/styles.css"></noscript>
</head>
```

### Step 6: Font Optimization
Optimize web font loading for fast, shift-free text rendering:

```
FONT AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│ Font            │ Weight  │ Format │ Size   │ font-display │ Used │
├──────────────────────────────────────────────────────────────────┤
│ Inter           │ 400     │ woff2  │ 24 KB  │ swap         │ Yes  │
│ Inter           │ 500     │ woff2  │ 25 KB  │ swap         │ Yes  │
│ Inter           │ 600     │ woff2  │ 25 KB  │ swap         │ Yes  │
│ Inter           │ 700     │ woff2  │ 26 KB  │ swap         │ Yes  │
│ Inter           │ 300     │ woff2  │ 24 KB  │ swap         │ No   │
│ Inter           │ 800     │ woff2  │ 26 KB  │ swap         │ No   │
│ FancyDisplay    │ 400     │ ttf    │ 180 KB │ (none)       │ Yes  │
└──────────────────────────────────────────────────────────────────┘

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
  unicode-range: U+0000-00FF, U+0131, U+0152-0153; /* Latin subset only */
}

/* Size-adjust to reduce layout shift during font swap */
@font-face {
  font-family: 'Inter Fallback';
  src: local('Arial');
  ascent-override: 90.20%;
  descent-override: 22.48%;
  line-gap-override: 0.00%;
  size-adjust: 107.40%;
}

body {
  font-family: 'Inter', 'Inter Fallback', system-ui, sans-serif;
}
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

# Generate font-display fallback metrics
npx @next/font/local  # Next.js automatic optimization
npx fontaine          # Generate fallback font metrics
```

### Step 7: Service Worker Caching Strategies
Configure service workers for optimal caching:

```
CACHING STRATEGY MATRIX:
┌──────────────────────────────────────────────────────────────────┐
│ Resource Type      │ Strategy              │ Max Age  │ Rationale │
├──────────────────────────────────────────────────────────────────┤
│ HTML pages         │ Network First         │ 0        │ Fresh content │
│ CSS/JS (hashed)    │ Cache First           │ 1 year   │ Immutable  │
│ CSS/JS (unhashed)  │ Stale While Revalidate│ 1 hour   │ Fast + fresh │
│ Images             │ Cache First           │ 30 days  │ Rarely change │
│ Fonts              │ Cache First           │ 1 year   │ Never change │
│ API (dynamic)      │ Network First         │ 0        │ Real-time  │
│ API (semi-static)  │ Stale While Revalidate│ 5 min    │ Fast + fresh │
│ Third-party        │ Stale While Revalidate│ 1 day    │ Not controlled │
└──────────────────────────────────────────────────────────────────┘
```

#### Workbox Configuration
```javascript
// workbox-config.js
module.exports = {
  globDirectory: 'dist/',
  globPatterns: ['**/*.{html,js,css,png,jpg,webp,avif,woff2,svg}'],
  swDest: 'dist/sw.js',
  runtimeCaching: [
    {
      urlPattern: /\.(?:js|css)$/,
      handler: 'CacheFirst',
      options: {
        cacheName: 'static-resources',
        expiration: { maxEntries: 60, maxAgeSeconds: 365 * 24 * 60 * 60 },
      },
    },
    {
      urlPattern: /\.(?:png|jpg|jpeg|webp|avif|svg|gif)$/,
      handler: 'CacheFirst',
      options: {
        cacheName: 'images',
        expiration: { maxEntries: 100, maxAgeSeconds: 30 * 24 * 60 * 60 },
      },
    },
    {
      urlPattern: /\/api\//,
      handler: 'NetworkFirst',
      options: {
        cacheName: 'api-responses',
        networkTimeoutSeconds: 3,
        expiration: { maxEntries: 50, maxAgeSeconds: 5 * 60 },
      },
    },
  ],
};
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
┌──────────────────────────────────────────────────────────────────┐
│ Resource           │ Cache-Control           │ CDN │ Edge Cache   │
├──────────────────────────────────────────────────────────────────┤
│ HTML               │ no-cache                │ Yes │ 0 (origin)   │
│ JS (hashed)        │ public, max-age=31536000│ Yes │ 1 year       │
│ CSS (hashed)       │ public, max-age=31536000│ Yes │ 1 year       │
│ Images             │ public, max-age=2592000 │ Yes │ 30 days      │
│ Fonts              │ public, max-age=31536000│ Yes │ 1 year       │
│ API responses      │ private, no-store       │ No  │ 0            │
│ Static data API    │ public, s-maxage=300    │ Yes │ 5 min (edge) │
└──────────────────────────────────────────────────────────────────┘
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
+------------------------------------------------------------+
|  WEB PERFORMANCE AUDIT — <target>                           |
+------------------------------------------------------------+
|  Lighthouse Scores:                                         |
|  Performance: <before> → <after> (+<delta>)                 |
|  Best Practices: <N>/100                                    |
|                                                             |
|  Core Web Vitals:                                           |
|  LCP: <before> → <after> (target: < 2.5s)                  |
|  INP: <before> → <after> (target: < 200ms)                 |
|  CLS: <before> → <after> (target: < 0.1)                   |
|  FCP: <before> → <after> (target: < 1.8s)                  |
|  TTFB: <before> → <after> (target: < 200ms)                |
|                                                             |
|  Bundle Size:                                               |
|  JS: <before> → <after> (-<savings>)                        |
|  CSS: <before> → <after> (-<savings>)                       |
|  Images: <before> → <after> (-<savings>)                    |
|  Fonts: <before> → <after> (-<savings>)                     |
|  Total transfer: <before> → <after>                         |
|                                                             |
|  Optimizations Applied:                                     |
|  1. <optimization> — saved <amount>                         |
|  2. <optimization> — saved <amount>                         |
|  3. <optimization> — saved <amount>                         |
|                                                             |
|  Caching:                                                   |
|  Service worker: <installed/not installed>                   |
|  Cache headers: <optimal/needs work/missing>                |
|  CDN: <configured/not configured>                           |
|                                                             |
|  Remaining opportunities:                                   |
|  1. <opportunity> — estimated savings <amount>              |
|  2. <opportunity> — estimated savings <amount>              |
|                                                             |
|  Verdict: <FAST | ACCEPTABLE | SLOW>                       |
+------------------------------------------------------------+
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
2. **JavaScript is the most expensive resource.** A 200KB image and 200KB of JavaScript are not equivalent. JavaScript must be parsed, compiled, and executed. Reduce JS first.
3. **Images are the lowest-hanging fruit.** Converting to WebP/AVIF, adding responsive srcset, and enabling lazy loading often saves more bytes than any code change.
4. **Critical CSS eliminates render blocking.** Inlining above-the-fold CSS and async-loading the rest removes the single biggest cause of slow First Contentful Paint.
5. **Fonts cause invisible text.** Without font-display: swap and proper preloading, custom fonts cause Flash of Invisible Text (FOIT). Users see a blank page while fonts download.
6. **Cache everything possible.** Hashed assets should be cached for a year. Service workers provide offline caching. CDN edge caches reduce latency. Every cache miss is wasted time.
7. **Third-party scripts are performance debt.** Every analytics tag, chat widget, and ad script runs on the main thread. Audit third-party impact and defer or remove what is not essential.

## Example Usage

### Full performance audit
```
User: /godmode:webperf

Webperf: Establishing performance baseline...

PERFORMANCE BASELINE:
Target: https://example.com
Framework: Next.js (SSR)
Lighthouse Performance: 62/100

Bundle analysis:
  Total JS: 487 KiB (gzipped)
  Largest: vendor.js (245 KiB) — includes moment.js, lodash
  Third-party: 180 KiB (37% of total)

Optimizations applied:
  1. Replace moment.js with dayjs — saved 65 KiB
  2. Route-based code splitting — saved 120 KiB initial load
  3. Convert images to WebP with srcset — saved 1.2 MB
  4. Inline critical CSS — eliminated 1.1s render blocking
  5. Preload LCP image — improved LCP by 800ms
  6. Add font-display: swap — eliminated FOIT

Results:
  Lighthouse: 62 → 91 (+29)
  LCP: 4.2s → 2.1s
  Total JS: 487 KiB → 302 KiB (-38%)
  Total transfer: 3.8 MB → 1.9 MB (-50%)

Verdict: FAST
```

### Bundle analysis only
```
User: /godmode:webperf --bundle

Webperf: Analyzing bundles...

vendor.js (245 KiB):
  moment.js: 67 KiB → Replace with dayjs (2 KiB)
  lodash: 72 KiB → Import individual functions or use lodash-es
  axios: 14 KiB → Use native fetch

Recommended code splits:
  ChartWidget (180 KiB) — lazy load, only used on /dashboard
  MarkdownEditor (120 KiB) — lazy load, only used on /editor
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full performance audit and optimization |
| `--lighthouse` | Lighthouse audit only (no optimization) |
| `--bundle` | Bundle analysis and code splitting recommendations |
| `--images` | Image optimization only (WebP/AVIF, srcset, lazy) |
| `--css` | Critical CSS extraction and unused CSS removal |
| `--fonts` | Font optimization (subsetting, font-display, preload) |
| `--cache` | Service worker and HTTP caching audit |
| `--cdn` | CDN and edge caching configuration |
| `--page <url>` | Audit a specific page |
| `--budget <file>` | Check against a performance budget file |
| `--fix` | Auto-apply optimizations after audit |
| `--ci` | CI-friendly output (exit code 1 if below thresholds) |

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

# Detect image optimization
grep -r "next/image\|sharp\|imagemin\|@sveltejs/enhanced-img" package.json src/ 2>/dev/null | head -5

# Detect service worker
find . -name "sw.*" -o -name "service-worker.*" -o -name "workbox-config.*" 2>/dev/null

# Detect performance budget
ls .lighthouserc.* budget.json performance-budget.* 2>/dev/null
```

## Iteration Protocol

For iterative performance optimization:

```
current_iteration = 0
max_iterations = 10

WHILE current_iteration < max_iterations AND performance_budget_not_met:
  1. Measure: Run Lighthouse audit, capture Core Web Vitals (LCP, FID, CLS)
  2. Identify: Find the single largest bottleneck (bundle, images, fonts, 3rd party)
  3. Optimize: Apply the targeted fix for that bottleneck
  4. Verify: Re-measure to confirm improvement and no regressions
  current_iteration += 1
  Report: "Perf iteration {current_iteration}: {optimization_applied} -- LCP: {lcp}ms, CLS: {cls}, bundle: {size}KB"

STOP when:
  - All Core Web Vitals are in "Good" range (LCP < 2.5s, FID < 100ms, CLS < 0.1)
  - OR performance budget thresholds are met
  - OR no further optimizations yield meaningful improvement
```

## Anti-Patterns

- **Do NOT optimize without measuring.** "I think this is slow" is not actionable. Run Lighthouse, analyze the bundle, measure Core Web Vitals. Data drives optimization, not intuition.
- **Do NOT lazy-load the LCP element.** The Largest Contentful Paint image must load eagerly with `fetchpriority="high"`. Lazy loading it makes LCP worse.
- **Do NOT serve uncompressed assets.** Enable gzip or Brotli compression on the server. Uncompressed text assets (HTML, CSS, JS) are 60-80% larger than compressed.
- **Do NOT load all JavaScript upfront.** Code split by route and lazy load components that are not visible on initial render. Users should not download code for pages they have not visited.
- **Do NOT use enormous hero images without srcset.** A 4000px wide image on a 375px mobile screen wastes 90% of the bytes. Use responsive images with appropriate breakpoints.
- **Do NOT add font weights you do not use.** Each unused font weight is 20-30KB downloaded for nothing. Audit CSS for actually-used weights and remove the rest.
- **Do NOT set Cache-Control: no-store on static assets.** Hashed filenames (main.a1b2c3.js) are immutable — cache them for a year. Only HTML and API responses need revalidation.
- **Do NOT ignore third-party script impact.** A single chat widget can add 200KB+ of JavaScript and block the main thread for seconds. Measure third-party impact and load non-essential scripts with async/defer.

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

## Error Recovery
- **Lighthouse score does not improve after optimization**: Clear all caches and re-run. Verify the optimization was actually deployed (check network tab). Run Lighthouse in incognito mode to avoid extension interference.
- **Code splitting increases total bundle size**: Check for duplicated modules across chunks. Use `webpack-bundle-analyzer` to identify shared dependencies. Extract common code into a shared chunk.
- **Critical CSS extraction misses above-the-fold styles**: Adjust the viewport dimensions used for critical CSS extraction. Test on multiple viewport sizes (mobile and desktop). Manually verify the above-the-fold rendering.
- **Font loading causes layout shift (CLS increase)**: Add `size-adjust` properties to the fallback font. Use `fontaine` or `@next/font` for automatic fallback metrics. Set explicit `width` and `height` on font-dependent containers.
- **Service worker caches stale content**: Implement a cache-busting strategy for the service worker itself. Use `skipWaiting()` and `clients.claim()` for immediate activation. Version your cache names.
- **Third-party script blocks main thread**: Load with `async` or `defer` attribute. Use a facade pattern (load on interaction, not on page load). Consider removing non-essential third-party scripts entirely.

## Multi-Agent Dispatch
For comprehensive web performance optimization:
```
DISPATCH parallel agents (one per optimization area):

Agent 1 (worktree: webperf-bundle):
  - Bundle analysis and code splitting
  - Tree shaking verification
  - Library replacement (moment → dayjs, lodash → native)
  - Scope: webpack/vite config, dynamic imports
  - Output: Optimized bundle with route-based splitting

Agent 2 (worktree: webperf-assets):
  - Image optimization (WebP/AVIF, srcset, lazy loading)
  - Font optimization (subsetting, font-display, preload)
  - Scope: public/, src/assets/, CSS @font-face
  - Output: Optimized images and fonts

Agent 3 (worktree: webperf-rendering):
  - Critical CSS extraction and inlining
  - Render-blocking resource elimination
  - LCP element optimization (preload, fetchpriority)
  - Scope: HTML templates, CSS files, head tags
  - Output: Optimized rendering pipeline

Agent 4 (worktree: webperf-caching):
  - Service worker configuration (Workbox)
  - HTTP cache headers audit and fix
  - CDN configuration
  - Scope: sw.js, server config, CDN rules
  - Output: Optimal caching strategy

MERGE ORDER: bundle → assets → rendering → caching
CONFLICT RESOLUTION: each agent owns its resource type exclusively
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run webperf tasks sequentially: bundle optimization, then assets, then rendering, then caching.
- Use branch isolation per task: `git checkout -b godmode-webperf-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
