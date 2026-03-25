---
name: seo
description: >
  SEO optimization. Meta tags, structured data,
  Core Web Vitals, sitemap, robots.txt, Open Graph.
---

# SEO -- SEO Optimization & Technical Auditing

## Activate When
- `/godmode:seo`, "SEO audit", "meta tags"
- "structured data", "schema markup", "Core Web Vitals"
- "sitemap", "robots.txt", "Open Graph"
- Pre-ship quality gate or search ranking drops

## Workflow

### Step 1: Technical Discovery
```bash
# Check for sitemap and robots.txt
curl -sf https://example.com/sitemap.xml | head -5
curl -sf https://example.com/robots.txt

# Lighthouse SEO audit
npx lighthouse https://example.com \
  --only-categories=seo --output=json
```
```
SEO DISCOVERY:
Target: <URL / entire site>
Framework: <Next.js | Nuxt | SvelteKit | static>
Rendering: SSR | SSG | CSR | ISR | hybrid
```

### Step 2: Meta Tag Audit
```
TITLE: 50-60 chars, unique per page,
  primary keyword near beginning, brand at end
DESCRIPTION: 150-160 chars, unique, has CTA
CANONICAL: every page, self-referencing,
  trailing slash consistent, no canonical to 404

MINIMUM META TAGS PER PAGE:
  <title>, <meta description>, <link canonical>
  OG: og:type, og:title, og:description,
    og:image (1200x630), og:url, og:site_name
  Twitter: twitter:card, twitter:title,
    twitter:description, twitter:image
  JSON-LD structured data
```

### Step 3: Structured Data (JSON-LD)
```
Page type -> Schema.org type:
  Homepage: Organization (name, url, logo, sameAs)
  Blog posts: Article (headline, author, date)
  Products: Product (name, price, availability)
  FAQ: FAQPage (Question/Answer pairs)
  Breadcrumbs: BreadcrumbList (position, name)
  Search: WebSite + SearchAction

IF structured data present: validate with
  Google Rich Results Test (0 errors required)
IF structured data missing: add for page type
WHEN data doesn't match visible content: fix
  (mismatch = manual penalty risk)
```

### Step 4: Sitemap & Robots.txt
```
SITEMAP:
  Location: /sitemap.xml, XML format
  Check: missing pages, dead URLs, non-canonical
  Limits: 50MB / 50K URLs -> split
  Reference in robots.txt

ROBOTS.TXT:
  Allow important pages
  Block admin/login/API/internal
  Block duplicate params (?sort=, ?filter=)
  NEVER block CSS/JS (engines need to render)
```

### Step 5: Core Web Vitals
```
TARGETS: LCP <2.5s, INP <200ms, CLS <0.1

LCP FIXES: preload LCP image, responsive srcset,
  WebP/AVIF, inline critical CSS, reduce TTFB,
  defer non-critical JS, fetchpriority="high"

CLS FIXES: explicit width/height on images/videos,
  aspect-ratio CSS, reserve space for ads/embeds,
  preload fonts, font-display:optional/swap

INP FIXES: break long tasks (>50ms) with yield,
  requestIdleCallback, web workers,
  debounce inputs, minimize DOM (<1500 elements)
```

### Step 6: Open Graph & Social
```
OG Image: min 1200x630, JPG/PNG <8MB,
  absolute URL, publicly accessible
Test: Facebook Debugger, Twitter Card Validator
```

### Step 7: Monitoring
```
Track weekly: organic traffic, impressions/clicks,
  keyword rankings, crawl errors
Track per deploy: Lighthouse CI scores
  Assert: performance >=0.9, seo >=0.9,
    LCP <2500, CLS <0.1
Track monthly: CWV field data (CrUX)
```

### Step 8: Report
```
SEO AUDIT -- {target}:
  Meta: {status} ({N} pages)
  Canonical: {status}, Sitemap: {status}
  CWV: LCP {N}s, INP {N}ms, CLS {N}
  Structured data: {N} types, valid: {yes|no}
  Lighthouse SEO: {N}/100
  Verdict: PASS (>=90) | NEEDS WORK (>=70) | FAIL
```
Commit: `"seo: {target} -- fix {N} issues"`

## Key Behaviors
1. **Crawlability first.** Robots, sitemap, canonicals.
2. **CWV affects ranking.** Google ranking signals.
3. **JSON-LD earns rich results.** Improves CTR.
4. **Meta tags are the sales pitch.** Write for humans.
5. **Open Graph is not optional.**
6. **SEO is ongoing.** Audit every deploy.
7. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. EVERY page: unique title (50-60 chars) + description.
2. EVERY page: canonical URL. No duplicate content.
3. EVERY image: alt text. Decorative = alt="".
4. NEVER client-render SEO-critical content.
5. Structured data MUST match visible content.
6. AUTO-GENERATE sitemap on deploy.
7. EVERY page: single H1, logical heading hierarchy.
8. CWV targets: LCP <2.5s, INP <200ms, CLS <0.1.

## Auto-Detection
```bash
grep -r "next-seo\|react-helmet\|vue-meta" \
  package.json 2>/dev/null
ls public/sitemap.xml public/robots.txt 2>/dev/null
grep -r "JsonLd\|json-ld\|application/ld+json" \
  src/ --include="*.tsx" --include="*.vue" -l 2>/dev/null
```

## TSV Logging
Append to `.godmode/seo-results.tsv`:
`timestamp\tpage\taction\tmetric\tbefore\tafter\tstatus`

## Output Format
Print: `SEO: Lighthouse {N}/100. CWV: LCP {N}s, INP {N}ms, CLS {N}. Verdict: {verdict}.`

## Keep/Discard Discipline
```
KEEP if: Lighthouse SEO >= previous AND CWV held
  AND structured data validates
DISCARD if: SEO dropped OR CWV regressed
  OR structured data errors
```

## Stop Conditions
```
STOP when:
  - Lighthouse SEO >= 95 AND all CWV good
  - All pages have titles/descriptions/canonicals
  - Valid structured data on all page types
  - User requests stop OR max 10 iterations
```
