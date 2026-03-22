---
name: seo
description: |
  SEO optimization and auditing skill. Activates when user needs technical SEO audits, meta tag analysis, structured data implementation, Core Web Vitals optimization, schema.org markup, Open Graph tags, sitemap/robots.txt validation, or keyword tracking. Integrates with Lighthouse, Google Search Console, and Schema.org validators. Triggers on: /godmode:seo, "SEO audit", "meta tags", "structured data", "schema markup", "Core Web Vitals", "sitemap", "robots.txt", "Open Graph".
---

# SEO — SEO Optimization & Technical Auditing

## When to Activate
- User invokes `/godmode:seo`
- User says "SEO audit", "check meta tags", "add structured data", "schema markup"
- User mentions "Core Web Vitals", "LCP", "FID", "CLS", "INP"
- User asks about "sitemap", "robots.txt", "Open Graph", "social sharing"
- Pre-ship quality gate during `/godmode:ship` workflow
- After content changes, new page creation, or URL restructuring
- When search ranking drops or Google Search Console reports issues

## Workflow

### Step 1: Technical SEO Discovery
Assess the current SEO posture of the site:

```
SEO DISCOVERY:
Target: <URL / entire site / specific pages>
Framework: <Next.js | Nuxt | Gatsby | SvelteKit | Astro | static HTML>
Rendering: <SSR | SSG | CSR | ISR | hybrid>
Current tools: <Google Search Console | Ahrefs | Semrush | none>

SEO infrastructure:
  Sitemap: <present at /sitemap.xml | missing>
  Robots.txt: <present at /robots.txt | missing>
  Canonical tags: <present | missing | inconsistent>
  Meta tags: <complete | partial | missing>
  Structured data: <present | missing>
  Open Graph: <present | missing>
  Hreflang: <present | missing | N/A (single language)>
  HTTPS: <yes | no>
  Mobile-friendly: <yes | no>
```

### Step 2: Meta Tag Audit
Verify every page has correct, complete meta tags:

```
META TAG AUDIT:
┌─────────────────────────────────────────────────────────────────┐
│ Page               │ Title       │ Description │ Canonical │ OG │
├─────────────────────────────────────────────────────────────────┤
│ /                  │ OK (55 ch)  │ OK (152 ch) │ OK        │ OK │
│ /about             │ MISSING     │ TOO SHORT   │ OK        │ MISSING │
│ /blog/:slug        │ OK (48 ch)  │ DUPLICATE   │ MISSING   │ PARTIAL │
│ /products/:id      │ TOO LONG    │ OK (145 ch) │ OK        │ OK │
└─────────────────────────────────────────────────────────────────┘

Title tag rules:
  - Length: 50-60 characters (Google truncates at ~60)
  - Unique per page
  - Primary keyword near the beginning
  - Brand name at the end (separated by | or —)

Meta description rules:
  - Length: 150-160 characters (Google truncates at ~160)
  - Unique per page
  - Contains primary keyword naturally
  - Includes call to action
  - No duplicate descriptions across pages

Canonical tag rules:
  - Every page must have a self-referencing canonical
  - Paginated pages point to canonical (or use rel=prev/next)
  - HTTP pages canonical to HTTPS version
  - Trailing slash consistency (pick one, enforce everywhere)
  - No canonical pointing to 404 or redirect
```

#### Meta Tag Implementation
```html
<!-- Minimum required meta tags per page -->
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Primary Keyword — Secondary Keyword | Brand</title>
  <meta name="description" content="Compelling 150-160 char description with keyword.">
  <link rel="canonical" href="https://example.com/current-page">
  <meta name="robots" content="index, follow">

  <!-- Open Graph -->
  <meta property="og:type" content="website">
  <meta property="og:title" content="Page Title">
  <meta property="og:description" content="Description for social sharing.">
  <meta property="og:image" content="https://example.com/og-image-1200x630.jpg">
  <meta property="og:url" content="https://example.com/current-page">
  <meta property="og:site_name" content="Brand Name">

  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Page Title">
  <meta name="twitter:description" content="Description for Twitter.">
  <meta name="twitter:image" content="https://example.com/twitter-card-1200x628.jpg">

  <!-- Structured Data (JSON-LD) -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "Page Title",
    "description": "Page description"
  }
  </script>
</head>
```

### Step 3: Structured Data & Schema.org Implementation
Add and validate schema.org markup for rich search results:

```
STRUCTURED DATA AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│ Page Type        │ Schema Type        │ Status    │ Rich Result  │
├──────────────────────────────────────────────────────────────────┤
│ Homepage         │ Organization       │ VALID     │ Knowledge    │
│ Product pages    │ Product            │ MISSING   │ Product card │
│ Blog posts       │ Article            │ PARTIAL   │ Article      │
│ FAQ page         │ FAQPage            │ MISSING   │ FAQ          │
│ Contact page     │ LocalBusiness      │ MISSING   │ Map pack     │
│ Breadcrumbs      │ BreadcrumbList     │ MISSING   │ Breadcrumbs  │
│ Search           │ WebSite+SearchAction│ MISSING  │ Sitelinks    │
└──────────────────────────────────────────────────────────────────┘
```

#### Common Schema.org Templates

**Organization:**
```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Company Name",
  "url": "https://example.com",
  "logo": "https://example.com/logo.png",
  "sameAs": [
    "https://twitter.com/company",
    "https://linkedin.com/company/company"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "telephone": "+1-800-555-0199",
    "contactType": "customer service"
  }
}
```

**Article (Blog Post):**
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Article Title",
  "author": {
    "@type": "Person",
    "name": "Author Name"
  },
  "datePublished": "2026-01-15",
  "dateModified": "2026-03-01",
  "image": "https://example.com/article-image.jpg",
  "publisher": {
    "@type": "Organization",
    "name": "Publisher Name",
    "logo": { "@type": "ImageObject", "url": "https://example.com/logo.png" }
  }
}
```

**Product:**
```json
{
  "@context": "https://schema.org",
  "@type": "Product",
  "name": "Product Name",
  "image": "https://example.com/product.jpg",
  "description": "Product description",
  "brand": { "@type": "Brand", "name": "Brand" },
  "offers": {
    "@type": "Offer",
    "price": "29.99",
    "priceCurrency": "USD",
    "availability": "https://schema.org/InStock"
  },
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.5",
    "reviewCount": "89"
  }
}
```

**FAQ Page:**
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [
    {
      "@type": "Question",
      "name": "Question text here?",
      "acceptedAnswer": {
        "@type": "Answer",
        "text": "Answer text here."
      }
    }
  ]
}
```

**BreadcrumbList:**
```json
{
  "@context": "https://schema.org",
  "@type": "BreadcrumbList",
  "itemListElement": [
    { "@type": "ListItem", "position": 1, "name": "Home", "item": "https://example.com" },
    { "@type": "ListItem", "position": 2, "name": "Category", "item": "https://example.com/category" },
    { "@type": "ListItem", "position": 3, "name": "Current Page" }
  ]
}
```

#### Validation
```bash
# Validate structured data with Google's Rich Results Test
npx structured-data-testing-tool --url https://example.com

# Validate JSON-LD syntax
npx jsonld-lint schema.json

# Test with Schema.org validator
# https://validator.schema.org (manual browser test)
# https://search.google.com/test/rich-results (manual browser test)
```

### Step 4: Sitemap & Robots.txt
Validate and generate sitemap and robots.txt:

#### Sitemap Validation
```
SITEMAP AUDIT:
Location: /sitemap.xml
Format: XML (standard) / XML index (multi-sitemap)
Pages listed: <N>
Pages on site: <N>

Issues:
- [ ] Missing pages: <list of pages not in sitemap>
- [ ] Dead pages: <sitemap URLs returning 404>
- [ ] Non-canonical URLs in sitemap
- [ ] Missing lastmod dates
- [ ] Sitemap size > 50MB or > 50,000 URLs (needs splitting)
- [ ] Sitemap not referenced in robots.txt
```

```xml
<!-- sitemap.xml template -->
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2026-03-19</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://example.com/about</loc>
    <lastmod>2026-02-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

#### Robots.txt Validation
```
ROBOTS.TXT AUDIT:
Location: /robots.txt

Rules:
- [ ] Allows search engine crawling of important pages
- [ ] Blocks admin/login/API/internal pages
- [ ] Blocks duplicate content paths (?sort=, ?filter=)
- [ ] References sitemap location
- [ ] Does not accidentally block CSS/JS (breaks rendering)
- [ ] Crawl-delay is reasonable (or absent for major engines)
```

```
# robots.txt template
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/
Disallow: /internal/
Disallow: /*?sort=
Disallow: /*?filter=
Disallow: /*?page=

Sitemap: https://example.com/sitemap.xml
```

### Step 5: Core Web Vitals Optimization
Measure and optimize Google's Core Web Vitals:

```
CORE WEB VITALS REPORT:
┌──────────────────────────────────────────────────────────────────┐
│ Metric   │ Value    │ Target   │ Status │ Impact               │
├──────────────────────────────────────────────────────────────────┤
│ LCP      │ 3.8s     │ < 2.5s   │ POOR   │ Largest content slow │
│ INP      │ 150ms    │ < 200ms  │ GOOD   │ Interactions fast    │
│ CLS      │ 0.18     │ < 0.1    │ POOR   │ Layout shifts        │
│ FCP      │ 2.1s     │ < 1.8s   │ NEEDS  │ First paint slow     │
│ TTFB     │ 450ms    │ < 200ms  │ POOR   │ Server response slow │
└──────────────────────────────────────────────────────────────────┘
```

```bash
# Measure Core Web Vitals with Lighthouse
npx lighthouse https://example.com --only-categories=performance --output=json --output-path=./cwv-report.json

# Web Vitals JavaScript library for real user monitoring
npm install web-vitals
```

#### LCP Optimization (Largest Contentful Paint)
```
LCP DIAGNOSIS:
LCP element: <img src="hero.jpg" /> (or <h1>, <video>, <div with background-image>)
Current LCP: <value>

Optimization checklist:
- [ ] Preload LCP image: <link rel="preload" as="image" href="hero.jpg">
- [ ] Use responsive images with srcset and sizes
- [ ] Serve modern formats (WebP, AVIF) with <picture> fallback
- [ ] Inline critical CSS (above-the-fold styles)
- [ ] Reduce server response time (TTFB < 200ms)
- [ ] Remove render-blocking resources (defer non-critical JS/CSS)
- [ ] Use CDN for static assets
- [ ] Set fetchpriority="high" on LCP image
```

#### CLS Optimization (Cumulative Layout Shift)
```
CLS DIAGNOSIS:
Layout shift sources:
  1. <element> shifts by <value> at <timestamp>
  2. <element> shifts by <value> at <timestamp>

Optimization checklist:
- [ ] Set explicit width/height on all images and videos
- [ ] Use aspect-ratio CSS property for responsive containers
- [ ] Reserve space for ads/embeds with min-height
- [ ] Preload web fonts to prevent FOIT/FOUT shifts
- [ ] Use font-display: optional or swap with size-adjust
- [ ] Avoid inserting content above existing content dynamically
- [ ] Use transform animations instead of top/left/width/height
- [ ] Set contain: layout on dynamic containers
```

#### INP Optimization (Interaction to Next Paint)
```
INP DIAGNOSIS:
Slowest interactions:
  1. <element> click: <value>ms (processing: <value>ms)
  2. <element> input: <value>ms (processing: <value>ms)

Optimization checklist:
- [ ] Break long tasks (> 50ms) with yield to main thread
- [ ] Defer non-critical event handlers with requestIdleCallback
- [ ] Use web workers for heavy computation
- [ ] Debounce/throttle rapid input handlers
- [ ] Minimize DOM size (target < 1,500 elements)
- [ ] Avoid forced synchronous layouts in event handlers
- [ ] Use content-visibility: auto for off-screen content
```

### Step 6: Open Graph & Social Media Meta
Optimize how pages appear when shared on social platforms:

```
SOCIAL SHARING AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│ Page         │ OG Title │ OG Desc │ OG Image │ Twitter │ Result │
├──────────────────────────────────────────────────────────────────┤
│ /            │ OK       │ OK      │ OK (1200x630) │ OK  │ PASS   │
│ /blog/:slug  │ OK       │ MISSING │ MISSING       │ MISSING │ FAIL │
│ /product/:id │ OK       │ OK      │ WRONG SIZE    │ OK  │ WARN   │
└──────────────────────────────────────────────────────────────────┘

OG Image requirements:
  - Minimum: 1200x630 pixels (Facebook/LinkedIn optimal)
  - Twitter large card: 1200x628 pixels
  - Format: JPG or PNG (< 8MB)
  - Must be absolute URL (not relative path)
  - Must be publicly accessible (no auth required)
```

```bash
# Test Open Graph tags
npx open-graph-scraper --url https://example.com

# Preview social cards
# https://developers.facebook.com/tools/debug/ (Facebook)
# https://cards-dev.twitter.com/validator (Twitter)
# https://www.linkedin.com/post-inspector/ (LinkedIn)
```

### Step 7: SEO Monitoring & Keyword Tracking
Set up ongoing SEO monitoring:

```
SEO MONITORING SETUP:
┌──────────────────────────────────────────────────────────────────┐
│ Metric                    │ Tool              │ Frequency        │
├──────────────────────────────────────────────────────────────────┤
│ Organic traffic           │ Google Analytics   │ Weekly           │
│ Search impressions/clicks │ Search Console     │ Weekly           │
│ Keyword rankings          │ Ahrefs/Semrush     │ Weekly           │
│ Core Web Vitals (field)   │ CrUX / Search Console │ Monthly      │
│ Core Web Vitals (lab)     │ Lighthouse CI      │ Every deploy     │
│ Crawl errors              │ Search Console     │ Weekly           │
│ Backlink profile          │ Ahrefs/Semrush     │ Monthly          │
│ Structured data errors    │ Search Console     │ Weekly           │
│ Mobile usability          │ Search Console     │ Monthly          │
└──────────────────────────────────────────────────────────────────┘
```

#### Lighthouse CI Integration
```bash
# Install Lighthouse CI
npm install -g @lhci/cli

# Configure .lighthouserc.js
cat > .lighthouserc.js << 'LHRC'
module.exports = {
  ci: {
    collect: {
      url: ['http://localhost:3000/', 'http://localhost:3000/blog', 'http://localhost:3000/product/1'],
      numberOfRuns: 3,
    },
    assert: {
      assertions: {
        'categories:performance': ['error', { minScore: 0.9 }],
        'categories:seo': ['error', { minScore: 0.9 }],
        'first-contentful-paint': ['warn', { maxNumericValue: 1800 }],
        'largest-contentful-paint': ['error', { maxNumericValue: 2500 }],
        'cumulative-layout-shift': ['error', { maxNumericValue: 0.1 }],
        'interactive': ['warn', { maxNumericValue: 3800 }],
      },
    },
    upload: {
      target: 'temporary-public-storage',
    },
  },
};
LHRC

# Run Lighthouse CI
lhci autorun
```

### Step 8: SEO Findings Report

For each issue found:
```
### SEO FINDING <N>: <Title>
**Severity:** CRITICAL | HIGH | MEDIUM | LOW
**Category:** Meta Tags | Structured Data | Core Web Vitals | Crawlability | Social | Content
**Page(s):** <affected URLs or file paths>
**Evidence:**
  <current state — missing tag, wrong value, poor metric>

**Impact:**
  <how this affects search ranking, click-through rate, or indexing>

**Remediation:**
```html
<!-- The fix -->
<fixed code>
```

**Verification:**
  <how to confirm the fix — tool command, validator URL, or metric check>
```

Severity definitions:
- **CRITICAL**: Site not indexable. Blocked by robots.txt, noindex on important pages, no sitemap, broken canonical loops. Immediate revenue impact.
- **HIGH**: Significant ranking/CTR loss. Missing meta descriptions, no structured data on product pages, Core Web Vitals failing, broken Open Graph images.
- **MEDIUM**: Suboptimal performance. Duplicate meta descriptions, missing alt text, slow LCP but within thresholds, incomplete schema markup.
- **LOW**: Minor improvements. Missing hreflang for single-language sites, suboptimal title length, missing secondary structured data types.

### Step 9: Auto-Fix Common SEO Issues
Apply automated fixes for straightforward issues:

```
AUTO-FIXABLE SEO ISSUES:
1. Add missing meta description tags
2. Add canonical tags (self-referencing)
3. Generate sitemap.xml from page routes
4. Generate robots.txt with sensible defaults
5. Add Open Graph meta tags (derive from existing meta)
6. Add JSON-LD structured data (Organization, BreadcrumbList)
7. Add width/height attributes to images (CLS fix)
8. Add fetchpriority="high" to LCP image
9. Add preload link for LCP resource
10. Fix image alt text (flag empty alt on non-decorative images)
```

For each auto-fix:
```
FIX <N>: <description>
File: <path>
Before: <original code>
After: <fixed code>
SEO impact: <what this improves — indexing, ranking, CTR, CWV>
```

### Step 10: SEO Report

```
+------------------------------------------------------------+
|  SEO AUDIT — <target>                                       |
+------------------------------------------------------------+
|  Technical SEO:                                             |
|  Meta tags: <complete/partial/missing> (<N> pages checked)  |
|  Canonical tags: <OK/issues found>                          |
|  Sitemap: <valid/invalid/missing>                           |
|  Robots.txt: <valid/invalid/missing>                        |
|  HTTPS: <yes/no>                                            |
|  Mobile-friendly: <yes/no>                                  |
|                                                             |
|  Core Web Vitals:                                           |
|  LCP: <value> (target: < 2.5s) — <GOOD/NEEDS IMPROVEMENT/POOR>  |
|  INP: <value> (target: < 200ms) — <GOOD/NEEDS IMPROVEMENT/POOR> |
|  CLS: <value> (target: < 0.1) — <GOOD/NEEDS IMPROVEMENT/POOR>   |
|                                                             |
|  Structured Data:                                           |
|  Schema types: <N> implemented, <N> recommended             |
|  Validation: <all valid/N errors>                           |
|  Rich result eligible: <list of types>                      |
|                                                             |
|  Social Sharing:                                            |
|  Open Graph: <complete/partial/missing>                     |
|  Twitter Cards: <complete/partial/missing>                  |
|                                                             |
|  Findings: <total>                                          |
|    CRITICAL: <N>  HIGH: <N>  MEDIUM: <N>  LOW: <N>         |
|                                                             |
|  Lighthouse SEO Score: <N>/100                              |
|  Lighthouse Performance Score: <N>/100                      |
|                                                             |
|  Auto-fixed: <N> issues                                     |
|  Manual fix required: <N> issues                            |
|                                                             |
|  Verdict: <PASS | NEEDS WORK | FAIL>                       |
+------------------------------------------------------------+
|  Priority fixes:                                            |
|  1. <highest impact finding>                                |
|  2. <second highest impact finding>                         |
|  3. <third highest impact finding>                          |
+------------------------------------------------------------+
```

Verdicts:
- **PASS**: Lighthouse SEO >= 90, all CWV in "Good" range, no CRITICAL/HIGH findings.
- **NEEDS WORK**: Lighthouse SEO >= 70, CWV mostly acceptable, HIGH findings with remediation path.
- **FAIL**: Lighthouse SEO < 70, or any CRITICAL finding, or CWV in "Poor" range.

### Step 11: Commit and Transition
1. Save report as `docs/seo/<target>-seo-audit.md`
2. If auto-fixes were applied, commit: `"seo: <target> — fix <N> SEO issues"`
3. Commit report: `"seo: <target> — <verdict> (Lighthouse: <N>/100, CWV: <status>)"`
4. If FAIL: "Critical SEO issues found. Fix the priority items, then re-audit with `/godmode:seo`."
5. If PASS: "SEO audit passed. Ready for `/godmode:ship`."

## Key Behaviors

1. **Crawlability is the foundation.** If search engines cannot crawl and index the site, nothing else matters. Fix robots.txt, sitemap, and canonical tags first.
2. **Core Web Vitals affect ranking.** Google uses CWV as a ranking signal. LCP, INP, and CLS are not optional performance metrics — they directly impact search visibility.
3. **Structured data earns rich results.** JSON-LD markup does not directly improve ranking, but rich results dramatically improve click-through rates. Implement schema.org for every eligible page type.
4. **Meta tags are the sales pitch.** Title and description are what users see in search results. Write them for humans (compelling, actionable) while including target keywords naturally.
5. **Open Graph is not optional.** Every page shared on social media needs proper OG tags. A missing OG image means an ugly, text-only card that nobody clicks.
6. **Measure with field data, not just lab data.** Lighthouse scores are lab measurements. Real user data from CrUX or web-vitals library reflects actual user experience. Both matter.
7. **SEO is ongoing, not a one-time fix.** Set up monitoring, run audits on every deploy, and track rankings over time. A site that was optimized six months ago may have regressed.

## Example Usage

### Full SEO audit
```
User: /godmode:seo

SEO: Discovering site structure...

SEO DISCOVERY:
Target: https://example.com (Next.js SSR)
Pages: 47 routes detected
Sitemap: Present (43 URLs — missing 4 pages)
Robots.txt: Present (2 issues)

Running meta tag audit...
  Complete: 38/47 pages
  Missing descriptions: 6 pages
  Duplicate titles: 3 pages

Running structured data audit...
  Organization: present, valid
  BreadcrumbList: missing (recommended)
  Article: present on 12/20 blog posts
  Product: missing on all product pages (HIGH impact)

Core Web Vitals (Lighthouse):
  LCP: 3.2s (NEEDS IMPROVEMENT — hero image not preloaded)
  INP: 120ms (GOOD)
  CLS: 0.15 (POOR — images without dimensions)

Auto-fixing 8 issues...
Manual fix required for 5 issues.

Verdict: NEEDS WORK — Lighthouse SEO: 82/100, 2 HIGH findings.
```

### Structured data only
```
User: /godmode:seo --schema-only

SEO: Auditing structured data...

Found 3 schema types. Recommending 5 additional:
  1. Product (all /product/* pages) — enables product rich results
  2. FAQPage (/faq) — enables FAQ rich results
  3. BreadcrumbList (all pages) — enables breadcrumb display
  4. SearchAction (homepage) — enables sitelinks search box
  5. Review (product pages) — enables star ratings in search

Generating JSON-LD for each page type...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SEO audit (meta, schema, CWV, social, crawlability) |
| `--meta-only` | Audit meta tags only (title, description, canonical) |
| `--schema-only` | Structured data audit and implementation only |
| `--cwv` | Core Web Vitals analysis only |
| `--social` | Open Graph and Twitter Card audit only |
| `--sitemap` | Sitemap and robots.txt audit only |
| `--page <url>` | Audit a specific page |
| `--fix` | Auto-fix issues after audit |
| `--monitor` | Set up ongoing SEO monitoring (Lighthouse CI) |
| `--ci` | CI-friendly output (exit code 1 on failure) |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Detect framework: Next.js (app/ or pages/), Nuxt, Gatsby, Remix, SvelteKit, Astro
2. Check for SSR/SSG: next.config.js (output: export?), generateStaticParams, getStaticPaths
3. Detect meta tag management: next/head, @next/metadata, react-helmet, vue-meta
4. Check for structured data: grep for application/ld+json, schema.org in templates
5. Check for sitemap: public/sitemap.xml, sitemap generation in build scripts
6. Check for robots.txt: public/robots.txt, middleware-generated robots
7. Detect analytics: Google Analytics, Search Console, Lighthouse CI configs
8. Check for canonical URLs: grep for rel="canonical", alternate hreflang tags
9. Detect image optimization: next/image, sharp, imagemin, WebP/AVIF usage
```

## Iterative SEO Audit Loop

```
current_iteration = 0
max_iterations = 10
pages_to_audit = [list of page types/routes to audit]

WHILE pages_to_audit is not empty AND current_iteration < max_iterations:
    page = pages_to_audit.pop(0)
    1. Check meta tags: title (50-60 chars), description (150-160 chars), canonical URL
    2. Check structured data: validate JSON-LD against schema.org, test with Rich Results Test
    3. Check Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1
    4. Check images: alt text, dimensions, srcset, lazy loading, modern formats
    5. Check heading hierarchy: single H1, logical H2-H6 nesting
    6. Check internal linking: orphan pages, broken links, anchor text quality
    7. Auto-fix what's possible (missing dimensions, missing alt text placeholders)
    8. Flag manual fixes required with priority (HIGH/MEDIUM/LOW)
    9. IF Lighthouse SEO < 90 → identify and fix blocking issues
    10. IF passing → commit: "seo: audit + fix <page> (Lighthouse SEO: <score>)"
    11. current_iteration += 1

POST-LOOP: Generate sitemap, verify robots.txt, submit to Search Console
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "seo-meta": meta tags, canonical URLs, Open Graph, Twitter Cards per page type
  Agent 2 — "seo-schema": JSON-LD structured data for all page types
  Agent 3 — "seo-performance": Core Web Vitals fixes, image optimization, Lighthouse CI setup

MERGE ORDER: meta → schema → performance (meta and schema are content, performance is optimization)
CONFLICT ZONES: head/metadata components, layout files (coordinate on head structure first)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. EVERY page must have a unique title (50-60 chars) and meta description (150-160 chars).
2. EVERY page must have a canonical URL. No duplicate content without canonicalization.
3. EVERY image must have alt text. Decorative images get alt="" (empty, not missing).
4. NEVER use client-side rendering for SEO-critical content. SSR/SSG for indexable pages.
5. Structured data MUST match visible page content. Fake markup = manual penalty.
6. Sitemap MUST be auto-generated and updated on deploy. Stale sitemaps waste crawl budget.
7. EVERY page must have a single H1 tag. Multiple H1s confuse document structure.
8. Core Web Vitals targets: LCP < 2.5s, INP < 200ms, CLS < 0.1. Non-negotiable.
9. NEVER block CSS/JS in robots.txt. Search engines need to render pages.
10. EVERY route change in SPA must update the document title and push to analytics.
```

## Output Format

After each SEO skill invocation, emit a structured report:

```
SEO AUDIT REPORT:
┌──────────────────────────────────────────────────────┐
│  Pages audited      │  <N>                            │
│  Meta tags fixed    │  <N>                            │
│  Structured data    │  <N> schemas added/updated      │
│  Canonical URLs     │  <N> set / <N> missing          │
│  Core Web Vitals    │  LCP: <N>s  INP: <N>ms  CLS: <N>│
│  Lighthouse SEO     │  <N>/100                        │
│  Sitemap            │  <N> URLs, auto-generated: YES/NO│
│  Robots.txt         │  Valid: YES/NO                  │
│  Verdict            │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every SEO action for tracking:

```
timestamp	skill	page	action	metric	before	after	status
2026-03-20T14:00:00Z	seo	/home	meta_title	length	0	58	fixed
2026-03-20T14:01:00Z	seo	/product	structured_data	Product	missing	added	fixed
2026-03-20T14:02:00Z	seo	/blog	core_web_vitals	LCP	3.8s	2.1s	improved
```

## Success Criteria

The SEO skill is complete when ALL of the following are true:
1. Every page has a unique meta title (50-60 chars) and meta description (150-160 chars)
2. Every page has a canonical URL set
3. Structured data (JSON-LD) validates with zero errors in Google Rich Results Test
4. Core Web Vitals meet targets: LCP < 2.5s, INP < 200ms, CLS < 0.1
5. Lighthouse SEO score >= 90
6. Sitemap is auto-generated and referenced in robots.txt
7. Every page has a single H1 tag and logical heading hierarchy
8. Open Graph and Twitter Card meta tags are present on all shareable pages

## Error Recovery

```
IF Lighthouse SEO score is below 90:
  1. Review the specific failing audits in the Lighthouse report
  2. Fix in priority order: missing titles > missing descriptions > missing alt text > crawl issues
  3. Re-run Lighthouse after each batch of fixes
  4. If score remains low, check for blocked resources in robots.txt

IF structured data validation fails:
  1. Paste the JSON-LD into Google Rich Results Test (https://search.google.com/test/rich-results)
  2. Fix required fields first (name, description for Article; name, image for Product)
  3. Ensure JSON-LD values match visible page content (no fabricated data)
  4. Re-validate after each fix

IF Core Web Vitals fail:
  1. LCP > 2.5s: optimize largest image (compress, add srcset, preload), reduce server response time
  2. INP > 200ms: profile long tasks, break up heavy JavaScript, defer non-critical scripts
  3. CLS > 0.1: add explicit width/height to images/video, avoid injecting content above the fold
  4. Re-measure with PageSpeed Insights after each optimization

IF sitemap generation fails:
  1. Verify the sitemap plugin/script is installed and configured
  2. Check build output for sitemap.xml in the correct public directory
  3. Validate sitemap XML syntax at https://www.xml-sitemaps.com/validate-xml-sitemap.html
  4. Ensure robots.txt contains: Sitemap: https://<domain>/sitemap.xml
```

## Anti-Patterns

- **Do NOT stuff keywords into meta tags.** "Buy cheap shoes online best shoes cheap shoes sale" is spam. Write naturally for humans with one primary keyword per page.
- **Do NOT use client-side rendering for SEO-critical pages.** Search engines can render JavaScript, but SSR/SSG is more reliable and faster. Critical content should be in the initial HTML.
- **Do NOT block CSS/JS in robots.txt.** Search engines need to render the page to evaluate it. Blocking stylesheets or scripts breaks rendering and hurts ranking.
- **Do NOT create a sitemap and forget it.** Sitemaps must be regenerated when pages are added or removed. Stale sitemaps with 404 URLs waste crawl budget.
- **Do NOT use the same meta description on every page.** Google will ignore duplicate descriptions and generate its own snippet. Unique descriptions earn better click-through rates.
- **Do NOT add structured data that does not match page content.** Marking up fake reviews, wrong prices, or misleading content violates Google's guidelines and risks a manual penalty.
- **Do NOT ignore Core Web Vitals because "the content is good enough."** Google uses CWV as a tiebreaker between similar-quality pages. When content is equal, performance wins.
- **Do NOT treat SEO as separate from performance.** Fast sites rank better, have lower bounce rates, and earn more conversions. SEO and web performance are inseparable.


## SEO Audit Loop

Autoresearch-grade iterative SEO optimization loop. Combines Core Web Vitals measurement, structured data validation, and crawlability verification into a repeatable, metrics-driven cycle.

```
SEO AUDIT PROTOCOL:

Phase 1 — Core Web Vitals Optimization Loop
  targets:
    LCP < 2.5s (Good)
    INP < 200ms (Good)
    CLS < 0.1 (Good)
    TTFB < 200ms
    FCP < 1.8s
  current_iteration = 0
  max_iterations = 10

  WHILE any_cwv_metric in "Poor" or "Needs Improvement" AND current_iteration < max_iterations:
    1. MEASURE with Lighthouse (lab data):
       npx lighthouse <url> --only-categories=performance --output=json --output-path=./cwv.json
       Parse: LCP, INP (TBT as proxy), CLS, FCP, TTFB
    2. MEASURE with web-vitals (field data, if available):
       import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';
       Report to analytics endpoint
    3. COMPARE lab vs field:
       - If field is significantly worse than lab → investigate device/network conditions
       - If lab is worse → investigate rendering pipeline
    4. IDENTIFY the worst metric and its root cause:
       a. LCP > 2.5s:
          - What is the LCP element? (image, text block, video)
          - Is the LCP resource preloaded? (<link rel="preload">)
          - Is there render-blocking CSS/JS?
          - Is the server response slow (TTFB > 200ms)?
       b. INP > 200ms:
          - Which interaction is slowest? (click, keypress, tap)
          - Is there a long task blocking the main thread?
          - Are event handlers doing too much synchronous work?
       c. CLS > 0.1:
          - Which elements shift? (use Layout Shift Regions in DevTools)
          - Are images/videos missing dimensions?
          - Is content injected above the fold dynamically?
          - Are fonts causing layout shift (FOIT/FOUT)?
       d. TTFB > 200ms:
          - Is the server slow? (database queries, cold starts)
          - Is there a CDN? (cache hit ratio)
          - Is the page dynamically rendered when it could be static/ISR?
    5. APPLY targeted fix (one fix per iteration for measurable impact)
    6. RE-MEASURE same URL with same tool
    7. RECORD:
       url | metric | before | after | fix_applied | lab_or_field
    8. IF metric worsens → REVERT
    9. current_iteration += 1

  CWV OPTIMIZATION RESULTS:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Metric  │  Start (lab) │  Final (lab) │  Field p75  │  Target      │
  ├──────────┼──────────────┼──────────────┼─────────────┼──────────────┤
  │  LCP     │  <N>s        │  <N>s        │  <N>s       │  < 2.5s      │
  │  INP     │  <N>ms       │  <N>ms       │  <N>ms      │  < 200ms     │
  │  CLS     │  <N>         │  <N>         │  <N>        │  < 0.1       │
  │  FCP     │  <N>s        │  <N>s        │  <N>s       │  < 1.8s      │
  │  TTFB    │  <N>ms       │  <N>ms       │  <N>ms      │  < 200ms     │
  └──────────┴──────────────┴──────────────┴─────────────┴──────────────┘

Phase 2 — Structured Data Validation Loop
  target: zero validation errors, all eligible page types have schema markup

  PAGE TYPE → SCHEMA MAPPING:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Page Type          │  Required Schema    │  Rich Result Eligible   │
  ├─────────────────────┼─────────────────────┼─────────────────────────┤
  │  Homepage           │  Organization       │  Knowledge panel        │
  │  Product pages      │  Product + Offer    │  Product cards, pricing │
  │  Blog/article pages │  Article            │  Article cards          │
  │  FAQ pages          │  FAQPage            │  FAQ accordion          │
  │  How-to content     │  HowTo              │  How-to steps           │
  │  Review pages       │  Review             │  Star ratings           │
  │  Recipe pages       │  Recipe             │  Recipe cards           │
  │  Event pages        │  Event              │  Event listings         │
  │  All pages          │  BreadcrumbList     │  Breadcrumb trail       │
  │  All pages          │  WebSite+SearchAction│  Sitelinks search box  │
  └─────────────────────┴─────────────────────┴─────────────────────────┘

  FOR EACH page type:
    1. CHECK if JSON-LD script tag exists in page source
    2. IF missing → generate schema from page content
    3. IF present → validate:
       a. Parse JSON-LD for syntax errors
       b. Validate against schema.org vocabulary
       c. Check required fields per type:
          - Product: name, image, description, offers.price, offers.priceCurrency
          - Article: headline, author, datePublished, image, publisher
          - FAQPage: mainEntity with Question+Answer pairs
          - BreadcrumbList: itemListElement with position, name, item
       d. Verify values match visible page content (no fabricated data)
    4. TEST with Google Rich Results Test:
       npx structured-data-testing-tool --url <url>
    5. RECORD:
       page | schema_type | validation_status | errors | rich_result_eligible
    6. IF errors → fix JSON-LD, re-validate
    7. REPEAT until all page types have valid, complete schema markup

  STRUCTURED DATA SCORECARD:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Page Type     │  Schema     │  Valid  │  Complete  │  Rich Result  │
  ├────────────────┼─────────────┼─────────┼────────────┼───────────────┤
  │  Homepage      │  Org        │  YES    │  YES       │  Eligible     │
  │  Products      │  Product    │  YES    │  PARTIAL   │  Needs price  │
  │  Blog posts    │  Article    │  YES    │  YES       │  Eligible     │
  │  FAQ           │  FAQPage    │  YES    │  YES       │  Eligible     │
  │  Breadcrumbs   │  Breadcrumb │  YES    │  YES       │  Eligible     │
  │  Search        │  SearchAction│ MISSING│  —         │  Not eligible │
  └────────────────┴─────────────┴─────────┴────────────┴───────────────┘

Phase 3 — Crawlability & Indexing Loop
  target: all important pages indexable, zero crawl waste, zero orphan pages

  CRAWLABILITY AUDIT:
  1. ROBOTS.TXT validation:
     - Fetch /robots.txt
     - Verify: important pages are NOT blocked
     - Verify: admin/api/internal paths ARE blocked
     - Verify: CSS/JS resources are NOT blocked (needed for rendering)
     - Verify: Sitemap directive is present and points to valid sitemap

  2. SITEMAP validation:
     - Fetch /sitemap.xml (or sitemap index)
     - Count URLs in sitemap vs actual pages
     - Check: every indexable page is IN the sitemap
     - Check: NO 404 or redirect URLs in the sitemap
     - Check: lastmod dates are accurate (not fabricated)
     - Check: sitemap size < 50MB, < 50,000 URLs per file

  3. CANONICAL TAG audit:
     FOR EACH page:
       - Verify: canonical tag is present and self-referencing
       - Verify: no canonical pointing to 404 or redirect
       - Verify: trailing slash consistency
       - Verify: HTTP pages canonical to HTTPS

  4. INTERNAL LINKING audit:
     - Identify orphan pages (not linked from any other page)
     - Identify pages with > 3 clicks from homepage (crawl depth)
     - Verify: no broken internal links (404 responses)
     - Check: anchor text is descriptive (not "click here")

  5. INDEX COVERAGE:
     - Check Google Search Console Index Coverage report
     - Investigate: pages with "Excluded" status
     - Fix: noindex tags on pages that should be indexed
     - Fix: canonicalization issues causing deduplication

  CRAWLABILITY SCORECARD:
  ┌──────────────────────────────────────────────────────────────────────┐
  │  Check                         │  Status    │  Issues  │  Action    │
  ├────────────────────────────────┼────────────┼──────────┼────────────┤
  │  robots.txt valid              │  PASS/FAIL │  <N>     │  <fix>     │
  │  Sitemap complete              │  PASS/FAIL │  <N>     │  <fix>     │
  │  Sitemap URLs all 200          │  PASS/FAIL │  <N>     │  <fix>     │
  │  Canonical tags present        │  PASS/FAIL │  <N>     │  <fix>     │
  │  No orphan pages               │  PASS/FAIL │  <N>     │  <fix>     │
  │  Max crawl depth <= 3          │  PASS/FAIL │  <N>     │  <fix>     │
  │  No broken internal links      │  PASS/FAIL │  <N>     │  <fix>     │
  │  CSS/JS not blocked by robots  │  PASS/FAIL │  <N>     │  <fix>     │
  └────────────────────────────────┴────────────┴──────────┴────────────┘

FINAL SEO AUDIT REPORT:
┌──────────────────────────────────────────────────────────────────────┐
│  Category                       │  Before   │  After    │  Target    │
├─────────────────────────────────┼───────────┼───────────┼────────────┤
│  Lighthouse SEO score           │  <N>      │  <N>      │  >= 95     │
│  Lighthouse Performance score   │  <N>      │  <N>      │  >= 90     │
│  LCP (p75)                      │  <N>s     │  <N>s     │  < 2.5s    │
│  INP (p75)                      │  <N>ms    │  <N>ms    │  < 200ms   │
│  CLS (p75)                      │  <N>      │  <N>      │  < 0.1     │
│  Structured data types valid    │  <N>/<M>  │  <N>/<M>  │  100%      │
│  Rich result eligible pages     │  <N>      │  <N>      │  Maximize  │
│  Sitemap coverage               │  <N>%     │  <N>%     │  100%      │
│  Crawl errors                   │  <N>      │  0        │  0         │
│  Orphan pages                   │  <N>      │  0        │  0         │
│  Canonical tag coverage         │  <N>%     │  100%     │  100%      │
└─────────────────────────────────┴───────────┴───────────┴────────────┘
```

### SEO Audit Loop TSV Logging

Append one row per optimization action to `.godmode/seo-optimization.tsv`:

```
timestamp	project	phase	url	metric	before	after	technique	status
2024-01-15T10:30:00Z	my-site	cwv	/home	lcp_s	3.8	2.1	preload-lcp-image	improved
2024-01-15T10:45:00Z	my-site	schema	/products/1	product_schema	missing	valid	added-jsonld	fixed
2024-01-15T11:00:00Z	my-site	crawl	/sitemap.xml	missing_urls	12	0	regenerated-sitemap	fixed
```

### SEO Audit Hard Rules

```
1. NEVER fabricate structured data. Schema markup MUST match visible page content. Fake reviews, wrong prices, or misleading content risks Google manual penalty.
2. NEVER measure CWV only in lab. Field data (CrUX, web-vitals) reflects real user experience. Lab data is for debugging.
3. ALWAYS re-validate structured data after every change with Google Rich Results Test.
4. NEVER block CSS/JS in robots.txt. Search engines need to render pages to evaluate them.
5. ALWAYS regenerate sitemap on deploy. Stale sitemaps with 404 URLs waste crawl budget.
6. NEVER exceed 10 iterations per CWV metric. If targets are not met, recommend infrastructure changes (CDN, edge rendering, database optimization).
7. Log every SEO action in TSV format for tracking improvements across releases.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run SEO tasks sequentially: meta tags/canonicals, then JSON-LD structured data, then Core Web Vitals/performance.
- Use branch isolation per task: `git checkout -b godmode-seo-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
