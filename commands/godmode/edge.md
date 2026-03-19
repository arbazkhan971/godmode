# /godmode:edge

Design, build, deploy, and optimize edge functions and serverless applications. Covers edge platforms (Cloudflare Workers, Vercel Edge, Deno Deploy), serverless (AWS Lambda, GCP Cloud Functions), cold start optimization, edge caching, and distributed state.

## Usage

```
/godmode:edge                           # Full edge/serverless design workflow
/godmode:edge --cloudflare              # Target Cloudflare Workers
/godmode:edge --vercel                  # Target Vercel Edge Functions
/godmode:edge --lambda                  # Target AWS Lambda
/godmode:edge --gcp                     # Target GCP Cloud Functions
/godmode:edge --deno                    # Target Deno Deploy
/godmode:edge --cold-start              # Analyze and optimize cold starts
/godmode:edge --cache                   # Design edge caching strategy
/godmode:edge --state                   # Design distributed state (KV, Durable Objects)
/godmode:edge --cost                    # Estimate and optimize costs
/godmode:edge --migrate                 # Migrate from server to edge/serverless
/godmode:edge --test                    # Generate test suite with local emulators
```

## What It Does

1. Discovers project context, platform, latency targets, and state requirements
2. Designs edge functions within platform constraints (CPU limits, memory, API surface)
3. Architects serverless functions with proper event sources, IAM, and configuration
4. Analyzes and optimizes cold starts (bundle size, lazy init, provisioned concurrency, runtime selection)
5. Designs edge caching strategies (stale-while-revalidate, tiered caching, cache invalidation)
6. Configures distributed state (KV for read-heavy data, Durable Objects for consistency, edge SQL)
7. Generates Infrastructure as Code (SAM, Serverless Framework, wrangler.toml)
8. Sets up observability (structured logging, metrics, distributed tracing)
9. Creates test suites with local platform emulators (Miniflare, sam local, vercel dev)

## Output
- Functions: `src/functions/<name>.ts`
- Configuration: `wrangler.toml` / `serverless.yml` / `template.yaml`
- Infrastructure: IaC definitions for all resources
- Tests: `tests/<name>.test.ts` (unit + integration)
- CI/CD: `.github/workflows/deploy-edge.yml`
- Commit: `"edge: <service> — <N> functions, <platform>, p99 <X>ms, caching configured"`

## Next Step
After edge design: `/godmode:observe` to set up monitoring, or `/godmode:perf` to load test and optimize cold starts.

## Examples

```
/godmode:edge --cloudflare Build an API gateway with KV caching on Workers
/godmode:edge --cold-start Our Lambda functions have 3-second cold starts
/godmode:edge --state Implement distributed rate limiting with Durable Objects
/godmode:edge --lambda --cache Design a serverless API with edge caching
/godmode:edge --cost Estimate monthly cost for 100M requests on Cloudflare
```
