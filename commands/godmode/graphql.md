# /godmode:graphql

Design, build, optimize, and test GraphQL APIs. Covers schema design (SDL-first and code-first), resolver architecture, N+1 query detection with DataLoader patterns, subscriptions, federation, and performance hardening.

## Usage

```
/godmode:graphql                        # Full GraphQL design workflow
/godmode:graphql --sdl                  # SDL-first schema design
/godmode:graphql --code-first           # Code-first schema design (Pothos, Nexus, TypeGraphQL)
/godmode:graphql --federation           # Design federated schema with subgraphs
/godmode:graphql --subscriptions        # Add subscription support
/godmode:graphql --n+1                  # Detect and fix N+1 query problems
/godmode:graphql --perf                 # Add performance defenses (complexity, depth, persisted queries)
/godmode:graphql --test                 # Generate test suite for schema and resolvers
/godmode:graphql --validate             # Validate existing schema for best practices
/godmode:graphql --diff old new         # Detect breaking changes between schema versions
/godmode:graphql --allowlist            # Extract and register persisted queries
```

## What It Does

1. Discovers project context, framework, consumers, and scale requirements
2. Designs schema with types, queries, mutations, and subscriptions (SDL-first or code-first)
3. Architects resolvers with thin resolver layer, service layer, and DataLoader layer
4. Detects and eliminates N+1 query problems with batched DataLoaders
5. Implements subscriptions with appropriate pub/sub backend (Redis, Kafka, NATS)
6. Designs federated schemas for microservice architectures (Apollo Federation v2)
7. Adds performance defenses: query complexity limits, depth limiting, persisted queries
8. Generates comprehensive test suite (schema snapshots, resolver unit tests, N+1 regression)

## Output
- Schema: `src/graphql/schema.graphql` (SDL-first) or generated from code-first builders
- Resolvers: `src/graphql/resolvers/<entity>.resolver.ts`
- DataLoaders: `src/graphql/loaders/<entity>.loader.ts`
- Tests: `tests/graphql/<entity>.test.ts`
- Performance config: `src/graphql/plugins/{complexity,depth-limit}.ts`
- Commit: `"graphql: <service> — <N> types, <M> operations, DataLoaders, subscriptions configured"`

## Next Step
After GraphQL design: `/godmode:test` to write comprehensive tests, or `/godmode:perf` to load test the API.

## Examples

```
/godmode:graphql Design a GraphQL API for a blog platform
/godmode:graphql --n+1 Fix the N+1 queries in our posts resolver
/godmode:graphql --federation Split our monolith into user, product, and order subgraphs
/godmode:graphql --perf Add query complexity and depth limits to our API
/godmode:graphql --diff old-schema.graphql new-schema.graphql
```
