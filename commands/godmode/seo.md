# /godmode:seo

SEO optimization and technical auditing covering meta tags, structured data (Schema.org JSON-LD), Core Web Vitals, Open Graph social meta, sitemap/robots.txt validation, and Lighthouse SEO scoring. Every finding includes severity, impact on search ranking, and concrete remediation code.

## Usage

```
/godmode:seo                              # Full SEO audit (meta, schema, CWV, social, crawlability)
/godmode:seo --meta-only                  # Audit meta tags only (title, description, canonical)
/godmode:seo --schema-only                # Structured data audit and implementation
/godmode:seo --cwv                        # Core Web Vitals analysis only
/godmode:seo --social                     # Open Graph and Twitter Card audit
/godmode:seo --sitemap                    # Sitemap and robots.txt audit
/godmode:seo --page /about                # Audit a specific page
/godmode:seo --fix                        # Auto-fix issues after audit
/godmode:seo --monitor                    # Set up Lighthouse CI monitoring
/godmode:seo --ci                         # CI-friendly output (exit code 1 on failure)
```

## What It Does

1. Discovers site SEO infrastructure (sitemap, robots.txt, meta tags, rendering mode)
2. Audits meta tags across all pages (title, description, canonical, robots)
3. Validates and implements Schema.org structured data (JSON-LD):
   - Organization, Article, Product, FAQPage, BreadcrumbList, SearchAction
4. Measures Core Web Vitals (LCP, INP, CLS, FCP, TTFB) with optimization recommendations
5. Audits Open Graph and Twitter Card meta tags for social sharing
6. Validates sitemap.xml and robots.txt for crawlability
7. Auto-fixes common issues (missing meta, canonical tags, image dimensions)
8. Produces findings with severity, search ranking impact, and remediation

## Output
- SEO report at `docs/seo/<target>-seo-audit.md`
- Auto-fix commit: `"seo: <target> — fix <N> SEO issues"`
- Report commit: `"seo: <target> — <verdict> (Lighthouse: <N>/100, CWV: <status>)"`
- Verdict: PASS / NEEDS WORK / FAIL

## Next Step
If FAIL: Fix priority items, then re-audit with `/godmode:seo`.
If PASS: `/godmode:webperf` for performance optimization, or `/godmode:ship` to deploy.

## Examples

```
/godmode:seo                              # Full audit
/godmode:seo --schema-only                # Add structured data to all pages
/godmode:seo --cwv                        # Diagnose Core Web Vitals issues
/godmode:seo --fix                        # Audit then auto-fix what is possible
```
