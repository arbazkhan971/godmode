# /godmode:nextjs

Master Next.js application architecture. Covers App Router, Server Components vs Client Components, data fetching patterns, middleware, rendering strategies, and asset optimization.

## Usage

```
/godmode:nextjs                            # Full Next.js architecture workflow
/godmode:nextjs --audit                    # Audit existing Next.js project
/godmode:nextjs --migrate                  # Migrate from Pages Router to App Router
/godmode:nextjs --routes                   # Design route structure only
/godmode:nextjs --data                     # Design data fetching strategy only
/godmode:nextjs --optimize                 # Image, font, script, bundle optimization
/godmode:nextjs --middleware               # Design middleware configuration
/godmode:nextjs --api                      # Design route handlers and API layer
/godmode:nextjs --deploy vercel            # Configure for Vercel deployment
/godmode:nextjs --deploy docker            # Configure for Docker/self-hosted
```

## What It Does

1. Assesses project requirements (router, rendering needs, data sources, deployment)
2. Designs App Router architecture (layouts, loading, error boundaries, route groups)
3. Applies Server vs Client Component decision tree (push 'use client' to leaves)
4. Selects data fetching patterns (Server Components, Server Actions, revalidation)
5. Designs middleware for cross-cutting concerns (auth, A/B testing, geo routing)
6. Chooses rendering strategy per route (SSG, ISR, SSR, streaming)
7. Configures asset optimization (next/image, next/font, next/script)
8. Designs route handlers for API endpoints and webhooks
9. Validates against Next.js best practices (16-point audit)
10. Generates route structure and component inventory

## Output
- App Router directory structure with layouts, loading, and error boundaries
- Server/Client Component boundary map
- Data fetching strategy per route
- Rendering strategy selection (SSG/ISR/SSR/streaming per route)
- Best practices audit with PASS/NEEDS REVISION verdict
- Commit: `"nextjs: <project> — App Router architecture, <N> routes, <rendering strategy>"`

## Next Step
After Next.js architecture: `/godmode:build` to implement routes, `/godmode:perf` for Core Web Vitals, or `/godmode:deploy` for deployment.

## Examples

```
/godmode:nextjs Build an e-commerce storefront with product pages and checkout
/godmode:nextjs --audit Check our Next.js app for best practice violations
/godmode:nextjs --migrate Move our Pages Router app to App Router
/godmode:nextjs --data Design caching and revalidation strategy for our CMS-driven site
/godmode:nextjs --optimize Run image, font, and bundle optimization pass
```
