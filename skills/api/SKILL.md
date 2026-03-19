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
┌─────────────────────────────────────────────────┐
│  Resource: <Name>                                │
│  Description: <what it represents>               │
│  Attributes:                                     │
│    - id: string (UUID v4)                        │
│    - <field>: <type> (<constraints>)             │
│    - <field>: <type> (<constraints>)             │
│    - created_at: datetime (ISO 8601)             │
│    - updated_at: datetime (ISO 8601)             │
│  Relationships:                                  │
│    - belongs_to: <Resource> (via <foreign_key>)  │
│    - has_many: <Resource>                        │
│  Constraints:                                    │
│    - <uniqueness, required fields, validations>  │
└─────────────────────────────────────────────────┘
```

Rules:
- Use nouns for resource names, plural for collections
- Every resource has an `id`, `created_at`, `updated_at`
- Relationships must be explicit — no implicit joins
- Field types must map to the target format (JSON Schema for REST, SDL for GraphQL, protobuf for gRPC)

### Step 3: Endpoint Design (REST)
For REST APIs, design endpoints following RESTful conventions:

```
ENDPOINT CATALOG:
┌──────────┬──────────────────────────┬──────────────────────────────┐
│  Method  │  Path                    │  Description                 │
├──────────┼──────────────────────────┼──────────────────────────────┤
│  GET     │  /api/v1/<resources>     │  List <resources> (paginated)│
│  POST    │  /api/v1/<resources>     │  Create a <resource>         │
│  GET     │  /api/v1/<resources>/:id │  Get a single <resource>     │
│  PUT     │  /api/v1/<resources>/:id │  Replace a <resource>        │
│  PATCH   │  /api/v1/<resources>/:id │  Partial update a <resource> │
│  DELETE  │  /api/v1/<resources>/:id │  Delete a <resource>         │
└──────────┴──────────────────────────┴──────────────────────────────┘

Nested resources:
│  GET     │  /api/v1/<parents>/:id/<children>  │  List children of parent │
│  POST    │  /api/v1/<parents>/:id/<children>  │  Create child under parent│

Custom actions (use sparingly):
│  POST    │  /api/v1/<resources>/:id/<action>  │  Trigger <action>        │
```

For **GraphQL** APIs:
```graphql
type Query {
  <resource>(id: ID!): <Resource>
  <resources>(filter: <Filter>, pagination: Pagination): <ResourceConnection>
}

type Mutation {
  create<Resource>(input: Create<Resource>Input!): <Resource>!
  update<Resource>(id: ID!, input: Update<Resource>Input!): <Resource>!
  delete<Resource>(id: ID!): DeleteResult!
}

type <Resource> {
  id: ID!
  # fields...
  <relation>: [<RelatedResource>!]!
}
```

For **gRPC** APIs:
```protobuf
service <Resource>Service {
  rpc Get<Resource>(Get<Resource>Request) returns (<Resource>);
  rpc List<Resources>(List<Resources>Request) returns (List<Resources>Response);
  rpc Create<Resource>(Create<Resource>Request) returns (<Resource>);
  rpc Update<Resource>(Update<Resource>Request) returns (<Resource>);
  rpc Delete<Resource>(Delete<Resource>Request) returns (google.protobuf.Empty);
}
```

### Step 4: Versioning Strategy
Choose and implement an API versioning strategy:

```
VERSIONING STRATEGY:

Option A — URL Path Versioning (RECOMMENDED for public APIs):
  /api/v1/resources
  /api/v2/resources
  Pros: Explicit, easy to understand, easy to route
  Cons: URL pollution, harder to deprecate gradually

Option B — Header Versioning:
  Accept: application/vnd.<company>.<resource>.v2+json
  Pros: Clean URLs, content negotiation compliant
  Cons: Harder to test in browser, less discoverable

Option C — Query Parameter Versioning:
  /api/resources?version=2
  Pros: Simple, easy to test
  Cons: Breaks caching, not RESTful

Option D — Content Negotiation:
  Accept: application/json; version=2
  Pros: Standards-based, flexible
  Cons: Complex implementation

SELECTED: <Option> — <justification>

DEPRECATION POLICY:
- Sunset header: Sunset: <date>
- Deprecation notice: X-API-Deprecated: true
- Migration guide: Link: <url>; rel="successor-version"
- Minimum support window: <N months/years>
```

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
    pagination: {
      next_cursor: "eyJpZCI6MTAwfQ==",
      has_more: true
    }
  }
  Pros: Consistent, performant at scale
  Cons: No random access, no total count

Option C — Keyset (page token):
  GET /api/v1/resources?after=<last_id>&limit=10
  Pros: Database-friendly, no offset skipping
  Cons: Requires stable sort key

SELECTED: <Option> — <justification>

DEFAULT LIMIT: <N> (e.g., 20)
MAX LIMIT: <N> (e.g., 100)
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
    "request_id": "<unique request identifier>",
    "documentation_url": "<link to relevant API docs>"
  }
}

HTTP STATUS CODE MAPPING:
┌──────┬─────────────────────────────────────────────────────┐
│ Code │ Usage                                                │
├──────┼─────────────────────────────────────────────────────┤
│ 200  │ Success (GET, PUT, PATCH)                            │
│ 201  │ Created (POST that creates a resource)               │
│ 204  │ No Content (DELETE, or PUT with no response body)    │
│ 400  │ Bad Request (validation errors, malformed input)     │
│ 401  │ Unauthorized (missing or invalid auth credentials)   │
│ 403  │ Forbidden (valid auth but insufficient permissions)  │
│ 404  │ Not Found (resource does not exist)                  │
│ 409  │ Conflict (duplicate, version conflict)               │
│ 422  │ Unprocessable Entity (valid syntax, invalid semantics)│
│ 429  │ Too Many Requests (rate limit exceeded)              │
│ 500  │ Internal Server Error (unexpected server failure)    │
│ 503  │ Service Unavailable (maintenance, overload)          │
└──────┴─────────────────────────────────────────────────────┘

ERROR CODES (machine-readable):
- VALIDATION_ERROR — input failed validation
- RESOURCE_NOT_FOUND — requested resource does not exist
- DUPLICATE_RESOURCE — resource with same unique key exists
- RATE_LIMIT_EXCEEDED — too many requests
- AUTHENTICATION_REQUIRED — no valid credentials provided
- PERMISSION_DENIED — credentials valid but access denied
- INTERNAL_ERROR — unexpected server error
```

### Step 7: Rate Limiting Design
Design rate limiting strategy for all endpoints:

```
RATE LIMITING:
Algorithm: Token Bucket | Sliding Window | Fixed Window
Scope: Per API key | Per user | Per IP | Per endpoint

TIERS:
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Tier        │  Rate        │  Burst       │  Daily Cap   │
├──────────────┼──────────────┼──────────────┼──────────────┤
│  Free        │  60/min      │  10          │  1,000       │
│  Standard    │  600/min     │  50          │  50,000      │
│  Premium     │  6,000/min   │  200         │  500,000     │
│  Internal    │  60,000/min  │  1,000       │  Unlimited   │
└──────────────┴──────────────┴──────────────┴──────────────┘

RESPONSE HEADERS:
X-RateLimit-Limit: <max requests per window>
X-RateLimit-Remaining: <requests remaining>
X-RateLimit-Reset: <unix timestamp when window resets>
Retry-After: <seconds to wait> (only on 429 responses)

EXCEEDED RESPONSE (429):
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Rate limit exceeded. Retry after <N> seconds.",
    "retry_after": <N>
  }
}
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
    name: "<team>"
    email: "<email>"
  license:
    name: "<license>"
servers:
  - url: "https://api.<domain>/v1"
    description: "Production"
  - url: "https://staging-api.<domain>/v1"
    description: "Staging"
paths:
  /<resource>:
    get:
      summary: "List <resources>"
      operationId: "list<Resources>"
      parameters:
        - $ref: "#/components/parameters/Cursor"
        - $ref: "#/components/parameters/Limit"
      responses:
        "200":
          description: "Success"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/<Resource>List"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "429":
          $ref: "#/components/responses/RateLimitExceeded"
      security:
        - BearerAuth: []
components:
  schemas:
    <Resource>:
      type: object
      required: [id, <required_fields>]
      properties:
        id:
          type: string
          format: uuid
        # ... all fields with types, formats, constraints
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  parameters:
    Cursor:
      name: cursor
      in: query
      schema:
        type: string
    Limit:
      name: limit
      in: query
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
  responses:
    Unauthorized:
      description: "Authentication required"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"
    RateLimitExceeded:
      description: "Rate limit exceeded"
      headers:
        Retry-After:
          schema:
            type: integer
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"
```

### Step 9: Validation
Validate the API design against best practices:

```
API DESIGN VALIDATION:
┌──────────────────────────────────────────────────────────────┐
│  Check                              │  Status                │
├──────────────────────────────────────┼────────────────────────┤
│  Consistent naming (plural nouns)   │  PASS | FAIL           │
│  Proper HTTP method usage           │  PASS | FAIL           │
│  Correct status codes               │  PASS | FAIL           │
│  Error response consistency         │  PASS | FAIL           │
│  Pagination on all list endpoints   │  PASS | FAIL           │
│  Rate limiting defined              │  PASS | FAIL           │
│  Auth on protected endpoints        │  PASS | FAIL           │
│  Versioning strategy applied        │  PASS | FAIL           │
│  Request/response examples exist    │  PASS | FAIL           │
│  No breaking changes (if updating)  │  PASS | FAIL | N/A     │
│  HATEOAS links (if applicable)      │  PASS | FAIL | N/A     │
│  Idempotency keys on mutations      │  PASS | FAIL           │
│  OpenAPI spec valid                 │  PASS | FAIL           │
│  Field naming convention consistent │  PASS | FAIL           │
│  No sensitive data in URLs          │  PASS | FAIL           │
└──────────────────────────────────────┴────────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
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
5. **Error messages help developers.** "Bad Request" is useless. "Field 'email' must be a valid email address" is useful.
6. **Rate limit everything.** Every public endpoint needs rate limiting. Internal endpoints need it too — they just get higher limits.
7. **Validate the spec.** Generate it, then validate it with tooling. A broken OpenAPI spec is worse than no spec.

## Example Usage

### Designing a REST API
```
User: /godmode:api Design a REST API for a task management system

API: Starting discovery...

API DISCOVERY:
Project: Task Management Service
Type: REST
Consumers: React frontend, mobile app, third-party integrations
Scale: ~1000 RPS peak
Auth: OAuth2 with JWT bearer tokens
Existing APIs: None (greenfield)

RESOURCE MODEL:
- Project (id, name, description, owner_id, status)
- Task (id, title, description, status, priority, assignee_id, project_id, due_date)
- Comment (id, body, author_id, task_id)
- Label (id, name, color)

ENDPOINT CATALOG:
GET    /api/v1/projects           List projects
POST   /api/v1/projects           Create project
GET    /api/v1/projects/:id       Get project
PATCH  /api/v1/projects/:id       Update project
DELETE /api/v1/projects/:id       Delete project
GET    /api/v1/projects/:id/tasks List tasks in project
POST   /api/v1/projects/:id/tasks Create task in project
...

Generating OpenAPI spec...
Validating design...
All 15 checks PASS.
```

### Validating an existing API
```
User: /godmode:api Validate our current API design

API: Scanning for existing API specs and routes...

Found: src/routes/*.ts (Express routes)
Found: docs/openapi.yaml (existing spec)

Running validation...

FINDINGS:
1. FAIL: Inconsistent naming — /api/v1/user (singular) vs /api/v1/tasks (plural)
2. FAIL: No pagination on GET /api/v1/tasks — returns all tasks
3. FAIL: Error responses use different formats across endpoints
4. PASS: HTTP methods used correctly
5. FAIL: No rate limiting headers in responses

Verdict: NEEDS REVISION — 4 issues found
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full API design workflow |
| `--type rest` | Design REST API (default) |
| `--type graphql` | Design GraphQL API |
| `--type grpc` | Design gRPC API |
| `--validate` | Validate existing API spec or routes |
| `--spec` | Generate OpenAPI spec only (skip design steps) |
| `--versioning <strategy>` | Force versioning strategy: `url`, `header`, `query`, `content` |
| `--pagination <strategy>` | Force pagination strategy: `offset`, `cursor`, `keyset` |
| `--diff <v1> <v2>` | Compare two API versions for breaking changes |
| `--mock` | Generate mock server from the spec |

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
   - Count endpoints and resources
4. Detect auth patterns:
   - grep for 'bearer', 'jwt', 'apiKey', 'oauth' in route middleware
5. Detect existing pagination:
   - grep for 'cursor', 'offset', 'limit', 'page' in query params
6. Detect error handling:
   - Check for centralized error handler or middleware
   - Analyze error response format consistency
7. Detect versioning:
   - Check URL patterns for /v1/, /v2/ prefixes
   - Check for version headers in middleware
8. Auto-configure:
   - No spec → generate OpenAPI from existing routes
   - Existing spec → validate against implementation
   - No versioning → recommend URL path versioning
```

## HARD RULES

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

## Anti-Patterns

- **Do NOT design APIs around database tables.** APIs expose resources, not tables. Aggregate data for the consumer's use case.
- **Do NOT use verbs in URLs.** `/api/v1/getUsers` is wrong. `GET /api/v1/users` is right. The HTTP method IS the verb.
- **Do NOT return different error formats from different endpoints.** One error schema for the entire API. No exceptions.
- **Do NOT skip pagination.** Every list endpoint must paginate. "We'll only have a few items" is how you get 10-second responses in production.
- **Do NOT embed sensitive data in URLs.** Query parameters end up in logs. Put tokens in headers, not query strings.
- **Do NOT design without consumers in mind.** An API designed in isolation will be redesigned when the first consumer tries to use it.
- **Do NOT generate a spec and skip validation.** Generated specs often have issues. Always validate with tooling.
- **Do NOT version reactively.** Version from the start. Adding versioning later means breaking existing consumers.
