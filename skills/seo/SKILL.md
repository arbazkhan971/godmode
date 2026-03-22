---
name: seo
description: |
  SEO optimization and auditing skill. Activates when user needs technical SEO audits, meta tag analysis, structured data implementation, Core Web Vitals optimization, schema.org markup, Open Graph tags, sitemap/robots.txt validation, or keyword tracking. Integrates with Lighthouse, Google Search Console, and Schema.org validators. Triggers on: /godmode:seo, "SEO audit", "meta tags", "structured data", "schema markup", "Core Web Vitals", "sitemap", "robots.txt", "Open Graph".
---

# SEO — SEO Optimization & Technical Auditing

## When to Activate
- User invokes `/godmode:seo`
- User says "SEO audit", "check meta tags", "add structured data", "schema markup"
- User mentions "Core Web Vitals", "LCP", "INP", "CLS"
- User asks about "sitemap", "robots.txt", "Open Graph", "social sharing"
- Pre-ship quality gate or after content/URL changes
- When search ranking drops or Google Search Console reports issues

## Workflow

### Step 1: Technical SEO Discovery
```
SEO DISCOVERY:
Target: <URL / entire site / specific pages>
Framework: <Next.js | Nuxt | Gatsby | SvelteKit | Astro | static HTML>
Rendering: <SSR | SSG | CSR | ISR | hybrid>
Infrastructure: Sitemap, Robots.txt, Canonical tags, Meta tags, Structured data, OG, Hreflang, HTTPS, Mobile
```

### Step 2: Meta Tag Audit
```
TITLE: 50-60 chars, unique per page, primary keyword near beginning, brand at end
DESCRIPTION: 150-160 chars, unique, includes keyword, has call to action
CANONICAL: Every page must have self-referencing canonical. Trailing slash consistent. No canonical to 404/redirect.

MINIMUM META TAGS PER PAGE:
  <title>, <meta description>, <link canonical>, <meta robots>
  OG: og:type, og:title, og:description, og:image (1200x630), og:url, og:site_name
  Twitter: twitter:card, twitter:title, twitter:description, twitter:image
  JSON-LD structured data (see Step 3)
```

### Step 3: Structured Data (Schema.org JSON-LD)

Common types to implement per page type:
- **Homepage**: Organization (name, url, logo, sameAs, contactPoint)
- **Blog posts**: Article (headline, author, datePublished, dateModified, image, publisher)
- **Products**: Product (name, image, description, brand, offers with price/availability, aggregateRating)
- **FAQ**: FAQPage (mainEntity with Question/Answer pairs)
- **Breadcrumbs**: BreadcrumbList (itemListElement with position, name, item)
- **Search**: WebSite + SearchAction for sitelinks search box

Validate with Google Rich Results Test and Schema.org validator. Structured data MUST match visible page content.

### Step 4: Sitemap & Robots.txt

```
SITEMAP AUDIT:
  Location: /sitemap.xml. Format: XML. Check: missing pages, dead URLs, non-canonical URLs,
  missing lastmod, size limits (50MB / 50K URLs → split). Must be in robots.txt.

ROBOTS.TXT:
  Allow important pages. Block admin/login/API/internal and duplicate params (?sort=, ?filter=).
  Reference sitemap. NEVER block CSS/JS (search engines need to render).
```

### Step 5: Core Web Vitals

```
TARGETS: LCP < 2.5s, INP < 200ms, CLS < 0.1

LCP FIXES: Preload LCP image, responsive srcset/sizes, modern formats (WebP/AVIF),
  inline critical CSS, reduce TTFB, defer non-critical JS/CSS, CDN, fetchpriority="high"

CLS FIXES: Explicit width/height on images/videos, aspect-ratio CSS, reserve space for ads/embeds,
  preload fonts, font-display:optional/swap, avoid inserting above existing content, transform animations

INP FIXES: Break long tasks (>50ms) with yield, requestIdleCallback, web workers,
  debounce/throttle inputs, minimize DOM (<1500 elements), content-visibility:auto
```

### Step 6: Open Graph & Social Sharing
```
OG Image: min 1200x630 (Facebook/LinkedIn), JPG/PNG < 8MB, absolute URL, publicly accessible.
Test: Facebook Debugger, Twitter Card Validator, LinkedIn Post Inspector.
```

### Step 7: SEO Monitoring
```
Track: Organic traffic (GA weekly), Search impressions/clicks (Search Console weekly),
  Keyword rankings (Ahrefs/Semrush weekly), CWV field data (CrUX monthly),
  CWV lab data (Lighthouse CI every deploy), Crawl errors, Structured data errors.

Lighthouse CI: Configure assertions for performance >= 0.9, seo >= 0.9, LCP < 2500, CLS < 0.1.
```

### Step 8: SEO Findings Report
For each issue: severity (CRITICAL/HIGH/MEDIUM/LOW), category, affected pages, evidence, impact, remediation code, verification method.

- **CRITICAL**: Site not indexable (robots.txt blocks, noindex, no sitemap, canonical loops)
- **HIGH**: Missing meta descriptions, no structured data on products, CWV failing, broken OG
- **MEDIUM**: Duplicate descriptions, missing alt text, suboptimal CWV, incomplete schema
- **LOW**: Missing hreflang (single-language), suboptimal title length

### Step 9: Auto-Fix Common Issues
Auto-fixable: missing meta descriptions, canonical tags, sitemap generation, robots.txt defaults, OG tags, JSON-LD (Organization, BreadcrumbList), image width/height (CLS), fetchpriority on LCP, preload LCP resource, flag empty alt text.

### Step 10: SEO Report
```
SEO AUDIT — <target>:
  Meta tags: <status> (<N> pages), Canonical: <status>, Sitemap: <status>, Robots.txt: <status>
  CWV: LCP <N>s, INP <N>ms, CLS <N>
  Structured data: <N> types, Validation: <status>, Rich result eligible: <types>
  Social: OG <status>, Twitter Cards <status>
  Findings: CRITICAL:<N> HIGH:<N> MEDIUM:<N> LOW:<N>
  Lighthouse: SEO <N>/100, Performance <N>/100
  Verdict: PASS (>=90, all CWV good, no CRITICAL/HIGH) | NEEDS WORK (>=70) | FAIL (<70 or CRITICAL)
```

Commit: `"seo: <target> — fix <N> issues"` or `"seo: <target> — <verdict> (Lighthouse: <N>/100)"`

## Key Behaviors

1. **Crawlability first.** Fix robots.txt, sitemap, canonicals before anything else.
2. **CWV affects ranking.** LCP, INP, CLS are Google ranking signals.
3. **Structured data earns rich results.** JSON-LD dramatically improves CTR.
4. **Meta tags are the sales pitch.** Write for humans with natural keywords.
5. **Open Graph is not optional.** Missing OG = ugly social cards nobody clicks.
6. **Measure with field data, not just lab.** CrUX + web-vitals for real user experience.
7. **SEO is ongoing.** Audit every deploy, track rankings over time.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SEO audit |
| `--meta-only` | Meta tags only |
| `--schema-only` | Structured data only |
| `--cwv` | Core Web Vitals only |
| `--social` | Open Graph / Twitter Cards only |
| `--sitemap` | Sitemap / robots.txt only |
| `--page <url>` | Audit specific page |
| `--fix` | Auto-fix after audit |
| `--monitor` | Set up Lighthouse CI |
| `--ci` | CI-friendly output (exit 1 on failure) |

## Auto-Detection
```
Detect: framework, SSR/SSG config, meta tag library (next/head, react-helmet, vue-meta),
JSON-LD, sitemap, robots.txt, analytics, canonical tags, image optimization.
```

## HARD RULES

1. EVERY page: unique title (50-60 chars) and meta description (150-160 chars).
2. EVERY page: canonical URL. No duplicate content without canonicalization.
3. EVERY image: alt text. Decorative = alt="" (empty, not missing).
4. NEVER client-side render SEO-critical content. SSR/SSG for indexable pages.
5. Structured data MUST match visible content. Fake markup = manual penalty.
6. Sitemap MUST be auto-generated and updated on deploy.
7. EVERY page: single H1 tag with logical heading hierarchy.
8. CWV targets: LCP < 2.5s, INP < 200ms, CLS < 0.1. Non-negotiable.
9. NEVER block CSS/JS in robots.txt.
10. EVERY SPA route change: update document title and push to analytics.

## Iterative Audit Loop
```
FOR EACH page type:
  Check meta tags, structured data, CWV, images, headings, internal links.
  Auto-fix what possible, flag manual fixes with priority.
  If Lighthouse SEO < 90 → fix blocking issues.
POST-LOOP: Generate sitemap, verify robots.txt, submit to Search Console.
```

## Multi-Agent Dispatch
```
Agent 1 — seo-meta: meta tags, canonical URLs, OG, Twitter Cards
Agent 2 — seo-schema: JSON-LD structured data for all page types
Agent 3 — seo-performance: CWV fixes, image optimization, Lighthouse CI
MERGE: meta → schema → performance. Coordinate on head structure.
```

## Output Format
```
SEO AUDIT REPORT:
  Pages: <N>, Meta fixed: <N>, Schemas: <N>, Canonicals: <N>/<N>
  CWV: LCP <N>s, INP <N>ms, CLS <N>
  Lighthouse SEO: <N>/100, Sitemap: <status>, Robots.txt: <status>
  Verdict: PASS | NEEDS REVISION
```

## TSV Logging
Append to `.godmode/seo-results.tsv`: `timestamp	skill	page	action	metric	before	after	status`

## Success Criteria
1. Every page: unique title + description. 2. Every page: canonical URL. 3. JSON-LD validates (0 errors). 4. CWV targets met. 5. Lighthouse SEO >= 90. 6. Sitemap auto-generated in robots.txt. 7. Single H1 per page. 8. OG + Twitter Cards on all shareable pages.

## Error Recovery
```
Lighthouse SEO < 90 → fix: missing titles > descriptions > alt text > crawl issues.
Structured data fails → fix required fields, ensure data matches visible content.
CWV fails → LCP: optimize images/TTFB. INP: break long tasks. CLS: add dimensions.
Sitemap fails → verify plugin, check build output, validate XML syntax.
```

## Keep/Discard Discipline
```
KEEP if Lighthouse SEO >= previous AND CWV held AND structured data validates.
DISCARD if SEO dropped OR CWV regressed OR structured data errors.
Never keep structured data that doesn't match visible content.
```

## Stop Conditions
```
STOP when: Lighthouse SEO >= 95 AND LCP < 2.5s AND INP < 200ms AND CLS < 0.1
  AND all pages have titles/descriptions/canonicals/valid structured data
  OR user requests stop OR max 10 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
