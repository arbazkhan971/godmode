---
name: api
description: |
  API design and specification skill. Activates when user needs to design, document, or validate REST, GraphQL, or gRPC APIs. Generates OpenAPI/Swagger specs, enforces versioning strategies, designs rate limiting and pagination, and produces standardized error responses. Every API endpoint gets a spec, example request/response, and validation. Triggers on: /godmode:api, "design an API", "create API spec", "validate my API", or when the orchestrator detects API-related work.
---

# API — Design & Specification

## When to Activate
- User invokes `/godmode:api`
- User says "design an API", "create API spec", "write API docs"
- User says "validate my API", "is this API well-designed?"
- When building a new service or microservice that exposes endpoints
- When `/godmode:plan` identifies API-related tasks
- When `/godmode:review` flags API design issues

## Workflow

### Step 1: Discovery & Context
Understand what the API needs to do before designing anything:

```
API DISCOVERY:
Project: <name and purpose>
Type: REST | GraphQL | gRPC | Hybrid
Consumers: <who will call this API — frontend, mobile, third-party, internal services>
Scale: <expected request volume — RPS, concurrent users>
Auth model: <API key, OAuth2, JWT, mTLS, none>
Existing APIs: <list any existing endpoints for consistency>
Constraints: <backward compatibility, regulatory, latency SLAs>
```
If the user hasn't specified, ask: "What kind of API are we designing? Who will consume it?"

### Step 2: Resource Modeling
Identify the core resources and their relationships:

```
RESOURCE MODEL:
  Resource: <Name>
  Description: <what it represents>
  Attributes:
  - id: string (UUID v4)
  - <field>: <type> (<constraints>)
  - <field>: <type> (<constraints>)
  - created_at: datetime (ISO 8601)
  - updated_at: datetime (ISO 8601)
  Relationships:
  - belongs_to: <Resource> (via <foreign_key>)
  - has_many: <Resource>
  ...
```
Rules:
- Use nouns for resource names, plural for collections
- Every resource has an `id`, `created_at`, `updated_at`
- Define relationships explicitly — no implicit joins
- Field types must map to the target format (JSON Schema for REST, SDL for GraphQL, protobuf for gRPC)

### Step 3: Endpoint Design (REST)
For REST APIs, design endpoints following RESTful conventions:

```
ENDPOINT CATALOG:
| Method | Path | Description |
|--|--|--|
| GET | /api/v1/<resources> | List <resources> (paginated) |
| POST | /api/v1/<resources> | Create a <resource> |
| GET | /api/v1/<resources>/:id | Get a single <resource> |
| PUT | /api/v1/<resources>/:id | Replace a <resource> |
| PATCH | /api/v1/<resources>/:id | Partial update a <resource> |
| DELETE | /api/v1/<resources>/:id | Delete a <resource> |

Nested resources:
| GET | /api/v1/<parents>/:id/<children> | List children of parent |
  ...
```
For **GraphQL**: Define Query (single + list with filter/pagination), Mutation (create, update, delete), and typed response objects.

For **gRPC**: Define service with rpc methods (Get, List, Create, Update, Delete) using typed request/response messages.

### Step 4: Versioning Strategy
URL path versioning (`/api/v1/`) is recommended for public APIs (explicit, easy to route). Header versioning (`Accept: application/vnd...`) is cleaner but less discoverable. Choose one and apply consistently.
### Step 5: Pagination Design
Design pagination for all list endpoints:

```
PAGINATION STRATEGY:

Option A — Offset/Limit (simple, most common):
  GET /api/v1/resources?offset=20&limit=10
  Response: { data: [...], total: 150, offset: 20, limit: 10 }
  Pros: Simple, random access
  Cons: Inconsistent with concurrent writes, slow on large datasets

Option B — Cursor-based (RECOMMENDED for large datasets):
  GET /api/v1/resources?cursor=<opaque_token>&limit=10
  Response: {
    data: [...],
  ...
```
### Step 6: Error Response Design
Define a consistent error response format across all endpoints:

```
ERROR RESPONSE FORMAT:
{
  "error": {
    "code": "<MACHINE_READABLE_CODE>",
    "message": "<Human-readable message for developers>",
    "details": [
      {
        "field": "<field_name>",
        "code": "<VALIDATION_CODE>",
        "message": "<Field-specific error message>"
      }
    ],
  ...
```
### Step 7: Rate Limiting Design
Design rate limiting strategy for all endpoints:

```
RATE LIMITING:
Algorithm: Token Bucket | Sliding Window | Fixed Window
Scope: Per API key | Per user | Per IP | Per endpoint

TIERS:
| Tier | Rate | Burst | Daily Cap |
|--|--|--|--|
| Free | 60/min | 10 | 1,000 |
| Standard | 600/min | 50 | 50,000 |
| Premium | 6,000/min | 200 | 500,000 |
| Internal | 60,000/min | 1,000 | Unlimited |

  ...
```
### Step 8: OpenAPI Specification Generation
Generate a complete OpenAPI 3.1 spec for the designed API:

```yaml
openapi: "3.1.0"
info:
  title: "<API Name>"
  version: "<version>"
  description: "<API description>"
  contact:
```
### Step 9: Validation
Validate the API design against best practices:

```
API DESIGN VALIDATION:
| Check | Status |
|--|--|
| Consistent naming (plural nouns) | PASS | FAIL |
| Proper HTTP method usage | PASS | FAIL |
| Correct status codes | PASS | FAIL |
| Error response consistency | PASS | FAIL |
| Pagination on all list endpoints | PASS | FAIL |
| Rate limiting defined | PASS | FAIL |
| Auth on protected endpoints | PASS | FAIL |
| Versioning strategy applied | PASS | FAIL |
| Request/response examples exist | PASS | FAIL |
  ...
```
If the project has an existing OpenAPI spec, validate it:
```bash
# Validate OpenAPI spec
npx @redocly/cli lint openapi.yaml
# or
npx swagger-cli validate openapi.yaml
```

### Step 10: API Documentation & Artifacts
Generate the deliverables:

1. **OpenAPI spec file**: `docs/api/<service>-openapi.yaml`
2. **API design doc**: `docs/api/<service>-api-design.md`
3. **Example request/response pairs**: embedded in the OpenAPI spec
4. **Postman/Insomnia collection**: exported from the OpenAPI spec (if requested)

```
API DESIGN COMPLETE:

Artifacts:
- OpenAPI spec: docs/api/<service>-openapi.yaml
- Design doc: docs/api/<service>-api-design.md
- Endpoints: <N> endpoints across <M> resources
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:contract — Generate contract tests for consumers
-> /godmode:build — Implement the API endpoints
-> /godmode:plan — Decompose implementation into tasks
```
Commit: `"api: <service> — <N> endpoints, <M> resources, OpenAPI spec generated"`

## Key Behaviors

1. **Spec before code.** Never implement an API without a spec. The spec IS the source of truth.
2. **Consistency is king.** Every endpoint must follow the same naming, error format, pagination, and auth patterns. No snowflakes.
3. **Design for consumers.** Think about who will call this API. Frontend devs want predictable responses. Third-party devs want clear docs. Internal services want performance.
4. **Version from day one.** Even if you think you'll never change the API, version it. /api/v1/ is cheap insurance.
5. **Error messages help developers.** "Bad Request" is useless. "Field 'email' requires a valid email address" is useful.
6. **Rate limit everything.** Every public endpoint needs rate limiting. Internal endpoints need it too — they get higher limits.
7. **Validate the spec.** Generate it, then validate it with tooling. A broken OpenAPI spec is worse than no spec.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full API design workflow |
| `--type rest` | Design REST API (default) |
| `--type graphql` | Design GraphQL API |

## Auto-Detection

Before prompting the user, automatically detect API context:

```
AUTO-DETECT SEQUENCE:
1. Detect existing API framework:
   - grep for 'express', 'fastify', 'koa', 'hono' (Node.js)
   - grep for 'flask', 'fastapi', 'django' (Python)
   - grep for 'gin', 'echo', 'fiber' (Go)
   - grep for 'spring-boot' (Java)
2. Detect existing API spec:
   - Find openapi.yaml, openapi.json, swagger.yaml, swagger.json
   - Find .proto files (gRPC)
   - Find schema.graphql, .graphql files (GraphQL)
3. Detect existing endpoints:
   - Scan route files for HTTP method + path patterns
  ...
```
## HARD RULES

Never ask to continue. Loop autonomously until OpenAPI spec validates with zero errors.

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. EVERY list endpoint MUST have pagination — no exceptions, no "we only have a few items."
2. EVERY endpoint MUST have a documented error response format — one schema for the entire API.
3. EVERY mutation endpoint MUST validate input — never trust client data.
4. EVERY public endpoint MUST have rate limiting defined.
5. NEVER put sensitive data in URLs or query parameters — use headers or body.
6. NEVER return stack traces or internal errors to API consumers — use error codes.
7. ALWAYS version from day one — /api/v1/ is cheap insurance.
8. ALWAYS validate the OpenAPI spec with tooling after generation.
9. git commit the spec file BEFORE implementing endpoints — spec is source of truth.
10. Log all API design decisions as TSV:
    ENDPOINT\tMETHOD\tPAGINATION\tAUTH\tRATE_LIMIT\tNOTES
```
## Keep/Discard Discipline
```
After EACH API design change:
  1. MEASURE: Run spectral/redocly lint on the OpenAPI spec. Run oasdiff for breaking changes.
  2. COMPARE: Does the spec validate with 0 errors? Are there 0 breaking changes?
  3. DECIDE:
     - KEEP if: spec validates AND 0 breaking changes AND all quality checks pass
     - DISCARD if: spec has validation errors OR breaking changes detected
  4. COMMIT kept changes. Revert discarded changes before the next resource.

Never keep a breaking change — add new fields additively instead.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - OpenAPI spec validates with 0 errors
  - All list endpoints have pagination, all mutations have validation
  - Rate limiting and auth defined for every endpoint
  - User explicitly requests stop

DO NOT STOP because:
  - Mock server is not yet generated (spec is the source of truth)
  - One endpoint lacks example responses (add it, but spec is functional)
```

## Output Format

```
API DESIGN COMPLETE:
  Spec: <path to OpenAPI/Swagger spec file>
  Endpoints: <N> resources, <M> total operations
  Versioning: <strategy> (URL path | header | query param)
  Pagination: <cursor | offset> on all list endpoints
  Auth: <mechanism> on <N> endpoints
  Rate limiting: <configured | recommended>
  Error schema: unified <format> across all endpoints
  Validation: <PASS | FAIL> (<N> issues)

ENDPOINT SUMMARY:
|  Resource        | GET | POST | PUT | PATCH | DELETE | Notes  |
  ...
```
## TSV Logging

Append to `.godmode/api-results.tsv`:
```
timestamp	project	endpoints_designed	spec_format	validation_status	issues_found	issues_fixed	commit_sha
```

## Success Criteria

```
API DESIGN SUCCESS CRITERIA:
|  Criterion                                  | Required         |
|--|--|
|  OpenAPI spec generated and valid           | YES              |
|  All list endpoints paginated               | YES              |
|  Unified error response schema              | YES              |
|  Versioning strategy applied                | YES              |
|  Auth defined for all non-public endpoints  | YES              |
|  Rate limit headers documented              | YES              |
|  Example request/response for each endpoint | YES              |
|  Spec validates with spectral/redocly lint  | YES              |
|  No breaking changes vs previous version    | YES (if exists)  |
  ...
```
## Error Recovery

```
ERROR RECOVERY — API:
1. Spec validation fails → Read error output, fix each violation, re-run until 0 errors.
2. Breaking change detected → Compare with oasdiff, revert breaking fields, add new fields additively.
3. Pagination missing → Add cursor-based parameters and PageInfo to response schema.
4. Inconsistent error format → Create shared error component in components, reference everywhere.
5. Auth model undefined → Add securitySchemes to components, apply security to each endpoint.
```
## Explicit Loop Protocol

```
API ENDPOINT BUILD LOOP:
current_iteration = 0
resources = [resource_1, resource_2, ...]  // from resource modeling

WHILE current_iteration < len(resources) AND NOT user_says_stop:
  1. SELECT next resource by dependency order (independent resources first)
  2. DESIGN endpoints: GET (single + list), POST, PATCH, DELETE per resource
  3. DEFINE request/response schemas with examples
  4. ADD pagination to list endpoints, filtering, sorting
  5. APPLY auth and rate limiting to each endpoint
  6. WRITE to OpenAPI spec file
  7. VALIDATE spec with linter (spectral or redocly)
  ...
```
```
