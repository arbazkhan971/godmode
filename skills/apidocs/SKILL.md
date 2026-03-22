---
name: apidocs
description: API documentation generation, OpenAPI/Swagger specs, contract-first development, interactive docs. Use when user mentions API docs, Swagger, OpenAPI, API reference, Redoc, API specification.
---

# APIDocs — Documentation Generation & Interactive Specs

## When to Activate
- User invokes `/godmode:apidocs`
- User says "generate API docs", "write OpenAPI spec", "set up Swagger"
- User says "add Redoc", "create API reference", "document my API"
- User says "auto-generate docs from code", "set up interactive docs"
- When `/godmode:api` finishes and documentation needs to be published
- When `/godmode:review` flags missing or outdated API documentation
- When a codebase has API routes but no corresponding spec or docs

## Workflow

### Step 1: Discovery & Approach Selection
Determine the documentation strategy before generating anything:

```
APIDOCS DISCOVERY:
Project: <name and purpose>
Language/Framework: <Node/Express, Python/FastAPI, Java/Spring, Go, NestJS, etc.>
Existing spec: <path to openapi.yaml/swagger.json if any>
Existing routes: <path patterns for route definitions>
Approach: SPEC-FIRST | CODE-FIRST
Output format: OpenAPI 3.0 | OpenAPI 3.1 | Swagger 2.0
    # ... (condensed)
Hosting: Self-hosted | GitHub Pages | Bump.sh | ReadMe.io | SwaggerHub
```

If the user hasn't specified, ask: "Do you want to write the spec first and generate code from it (spec-first), or generate the spec from existing code (code-first)?"

### Step 2: Spec-First — Writing OpenAPI from Scratch
For spec-first (contract-first) development, produce a complete OpenAPI document:

```yaml
# Template: OpenAPI 3.1 Spec-First
openapi: "3.1.0"
info:
  title: "<API Name>"
  version: "<version>"
  description: |
    <Multi-line description of the API, its purpose, and getting started guide.>
    # ... (condensed)
      name: X-API-Key
```

Rules for spec-first:
- Write the spec BEFORE any implementation. The spec is the contract.
- Every field must have a `description` and an `example`.
- Use `$ref` aggressively — never duplicate schema definitions.
- Group related endpoints under `tags`.
- Provide `examples` for every request body and response.
- Include `servers` for all environments.
- Add `x-` extensions for renderer-specific features (Redoc logo, Stoplight groups).

### Step 3: Code-First — Auto-Generate Spec from Code
For code-first, configure the framework's doc generation:

```
CODE-FIRST SETUP BY FRAMEWORK:

┌──────────────────────┬───────────────────────────────────────────────────┐
│  Framework           │  Tool & Setup                                     │
├──────────────────────┼───────────────────────────────────────────────────┤
│  Express / Koa       │  swagger-jsdoc + swagger-ui-express               │
│  NestJS              │  @nestjs/swagger (built-in decorators)            │
    # ... (condensed)
└──────────────────────┴───────────────────────────────────────────────────┘
```

#### Express + swagger-jsdoc
```javascript
// swagger.js — configuration
const swaggerJsdoc = require("swagger-jsdoc");
const swaggerUi = require("swagger-ui-express");

const options = {
  definition: {
    openapi: "3.1.0",
    # ... (condensed)
app.use("/docs", swaggerUi.serve, swaggerUi.setup(spec));
```

```javascript
// Route annotation example
/**
 * @openapi
 * /users:
 *   get:
 *     summary: List users
 *     tags: [Users]
    # ... (condensed)
router.get("/users", listUsers);
```

#### NestJS + @nestjs/swagger
```typescript
// main.ts — setup
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";

const config = new DocumentBuilder()
  .setTitle("<API Name>")
  .setDescription("<description>")
  .setVersion("<version>")
    # ... (condensed)
fs.writeFileSync("./openapi.json", JSON.stringify(document, null, 2));
```

```typescript
// DTO example with decorators
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateUserDto {
  @ApiProperty({ description: "User email address", example: "user@example.com" })
  email: string;

    # ... (condensed)
}
```

#### FastAPI (Python) — Built-in
```python
from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(
    title="<API Name>",
    description="<description>",
    version="<version>",
    # ... (condensed)
# Export spec for CI: python -c "import json; from main import app; print(json.dumps(app.openapi()))" > openapi.json
```

#### Spring Boot + springdoc
```xml
<!-- pom.xml -->
<dependency>
  <groupId>org.springdoc</groupId>
  <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
  <version>2.3.0</version>
</dependency>
```

```java
// application.yml
springdoc:
  api-docs:
    path: /v3/api-docs
  swagger-ui:
    path: /docs
  info:
    # ... (condensed)
    description: "<description>"
```

```java
@Tag(name = "Users", description = "User management")
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Operation(summary = "List users", description = "Returns a paginated list of users")
    @ApiResponses({
    # ... (condensed)
}
```

#### tsoa (TypeScript)
```json
// tsoa.json
{
  "entryFile": "src/index.ts",
  "noImplicitAdditionalProperties": "throw-on-extras",
  "controllerPathGlobs": ["src/controllers/**/*.ts"],
  "spec": {
    "outputDirectory": "docs",
    "specVersion": 3,
    "specFileBaseName": "openapi"
    # ... (condensed)
}
```

```typescript
// Controller with tsoa decorators
import { Controller, Get, Post, Body, Route, Tags, Security, Query } from "tsoa";

@Route("users")
@Tags("Users")
export class UserController extends Controller {
  /**
   * Retrieves a paginated list of users.
   */
    # ... (condensed)
}
```

```bash
# Generate spec and routes
npx tsoa spec     # outputs docs/openapi.json
npx tsoa routes   # outputs src/generated/routes.ts
```

#### Go + swaggo/swag
```go
// @title <API Name>
// @version <version>
// @description <description>
// @host localhost:8080
// @BasePath /api/v1
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization

    # ... (condensed)
func ListUsers(c *gin.Context) { /* ... */ }
```

```bash
# Generate spec
swag init -g cmd/server/main.go -o docs/
```

### Step 4: Schema Reuse with $ref and Components
Enforce DRY specs by extracting shared schemas:

```
SCHEMA REUSE CHECKLIST:
┌──────────────────────────────────────────────────────────────────────┐
│  Pattern                        │  Extract to                       │
├─────────────────────────────────┼───────────────────────────────────┤
│  Repeated object shapes         │  components/schemas/<Name>        │
│  Shared query params            │  components/parameters/<Name>     │
│  Common headers                 │  components/headers/<Name>        │
│  Error response bodies          │  components/responses/<Name>      │
│  Request body shapes            │  components/requestBodies/<Name>  │
│  Auth configs                   │  components/securitySchemes/<Name>│
│  Repeated examples              │  components/examples/<Name>       │
│  Shared link definitions        │  components/links/<Name>         │
└─────────────────────────────────┴───────────────────────────────────┘
    # ... (condensed)
  npx @redocly/cli bundle openapi.yaml -o dist/openapi-bundled.yaml
```

Rules:
- If a schema appears in 2+ places, extract it to `components/schemas`.
- Pagination parameters go in `components/parameters` — never inline them.
- Error responses go in `components/responses` — reference everywhere.
- Use `allOf` for composition and `oneOf`/`anyOf` for polymorphism:

```yaml
# Composition with allOf
CreateUserRequest:
  allOf:
    - $ref: "#/components/schemas/UserBase"
    - type: object
      required: [password]
      properties:
        password:
          type: string
          format: password

# Polymorphism with oneOf + discriminator
Notification:
    # ... (condensed)
      push: "#/components/schemas/PushNotification"
```

### Step 5: Examples and Mocking
Every operation must have realistic examples for documentation and mocking:

```yaml
# Inline examples in schema
properties:
  email:
    type: string
    format: email
    example: "jane.doe@example.com"

# Named examples per operation
paths:
  /users:
    post:
      requestBody:
        content:
    # ... (condensed)
                  role: "admin"
```

Mock server setup:

```bash
# Prism — mock server from OpenAPI spec
npm install -g @stoplight/prism-cli
prism mock openapi.yaml                     # Start mock server on :4010
prism mock openapi.yaml --dynamic           # Generate dynamic random data

# MSW (Mock Service Worker) — for frontend testing
# Generate handlers from spec:
npx msw-auto-mock openapi.yaml -o src/mocks/handlers.ts

# Microcks — full mock + contract testing platform
docker run -p 8080:8080 quay.io/microcks/microcks:latest
# Import spec via UI at localhost:8080
```

### Step 6: Documentation Renderers
Set up interactive documentation from the OpenAPI spec:

#### Swagger UI
```bash
npm install swagger-ui-express
# or standalone
docker run -p 8080:8080 -e SWAGGER_JSON=/spec/openapi.yaml \
  -v $(pwd):/spec swaggerapi/swagger-ui
```

```javascript
// Express integration
const swaggerUi = require("swagger-ui-express");
const spec = require("./openapi.json");

app.use("/docs", swaggerUi.serve, swaggerUi.setup(spec, {
  customCss: ".swagger-ui .topbar { display: none }",
  customSiteTitle: "<API Name> — API Reference",
  swaggerOptions: {
    persistAuthorization: true,
    displayRequestDuration: true,
    filter: true,
    tryItOutEnabled: true,
  },
}));
```

#### Redoc
```html
<!-- Static HTML — zero dependencies -->
<!DOCTYPE html>
<html>
<head>
  <title><API Name> — API Reference</title>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
  <style> body { margin: 0; padding: 0; } </style>
</head>
<body>
  <redoc spec-url="./openapi.yaml"
         expand-responses="200,201"
    # ... (condensed)
</html>
```

```bash
# Build static docs
npx @redocly/cli build-docs openapi.yaml -o docs/index.html

# Redoc with custom theme
npx @redocly/cli build-docs openapi.yaml \
  --theme.openapi.theme='{"colors":{"primary":{"main":"#1a73e8"}}}' \
  -o docs/index.html
```

#### Stoplight Elements
```html
<!-- Embed in any HTML page -->
<script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
<link rel="stylesheet" href="https://unpkg.com/@stoplight/elements/styles.min.css">

<elements-api
  apiDescriptionUrl="./openapi.yaml"
  router="hash"
  layout="sidebar"
  tryItCredentialsPolicy="same-origin"
/>
```

### Step 7: Versioning in Specs
Handle API versioning within OpenAPI specs:

```
SPEC VERSIONING STRATEGIES:
┌──────────────────────────────────────────────────────────────────────┐
│  Strategy           │  How to Represent in OpenAPI                   │
├─────────────────────┼───────────────────────────────────────────────┤
│  URL versioning     │  Separate spec per version: v1/openapi.yaml,  │
│                     │  v2/openapi.yaml. Or use servers[].url.       │
│                     │                                                │
│  Header versioning  │  Single spec, document via parameter:          │
│                     │  - name: X-API-Version                        │
│                     │    in: header                                   │
│                     │    schema: { enum: ["2024-01-01","2024-06-01"]}│
│                     │                                                │
│  Multi-version      │  Use OpenAPI overlays (3.1 feature) or        │
    # ... (condensed)
          description: "Added cursor-based pagination to all list endpoints"
```

### Step 8: CI Validation & Linting
Validate specs in CI to prevent regressions:

```yaml
# .github/workflows/api-docs.yml
name: API Docs CI
on:
  pull_request:
    paths: ["openapi.yaml", "openapi/**", "docs/api/**"]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Lint with Spectral (custom rules)
    # ... (condensed)
          path: dist/index.html
```

```yaml
# .spectral.yaml — custom linting rules
extends: ["spectral:oas"]

rules:
  # Enforce descriptions on all operations
  operation-description:
    severity: error
    given: "$.paths[*][*]"
    then:
      field: description
      function: truthy

  # Enforce examples on all schemas
    # ... (condensed)
        function: truthy
```

```bash
# Optic — track breaking changes over time
npx @useoptic/optic diff openapi.yaml --base main --check

# Optic output example:
# BREAKING: Removed path /users/{id}/profile
# BREAKING: Changed type of field 'age' from string to integer
# NON-BREAKING: Added optional field 'nickname' to User schema
# NON-BREAKING: Added new path /users/{id}/settings
```

### Step 9: SDK Generation
Generate client SDKs from the OpenAPI spec:

```bash
# openapi-generator — supports 50+ languages
npm install -g @openapitools/openapi-generator-cli

# TypeScript/Axios client
openapi-generator-cli generate \
  -i openapi.yaml \
  -g typescript-axios \
  -o sdk/typescript \
  --additional-properties=supportsES6=true,npmName=@myorg/api-client

# Python client
openapi-generator-cli generate \
  -i openapi.yaml \
    # ... (condensed)
done
```

```yaml
# Alternative: openapi-typescript (lightweight, type-only)
# Generates TypeScript types from OpenAPI — no runtime, just types
npx openapi-typescript openapi.yaml -o src/api/schema.d.ts

# Usage with fetch:
import type { paths } from "./schema";
type ListUsersResponse = paths["/users"]["get"]["responses"]["200"]["content"]["application/json"];
```

```yaml
# CI workflow for SDK generation
name: Generate SDKs
on:
  push:
    paths: ["openapi.yaml"]
    branches: [main]

jobs:
  generate:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        lang: [typescript-axios, python, go]
    # ... (condensed)
          # Publish to npm/pypi/go module registry
```

### Step 10: Changelog Generation from Spec Diffs
Automatically generate API changelogs from spec differences:

```bash
# oasdiff — diff two OpenAPI specs and generate changelog
npm install -g oasdiff
# or
go install github.com/tufin/oasdiff@latest

# Generate changelog
oasdiff changelog openapi-v1.yaml openapi-v2.yaml

# Check for breaking changes (use in CI)
oasdiff breaking openapi-v1.yaml openapi-v2.yaml

# Output formats
oasdiff changelog base.yaml revision.yaml --format json
oasdiff changelog base.yaml revision.yaml --format markdown
oasdiff changelog base.yaml revision.yaml --format html
```

```
CHANGELOG OUTPUT EXAMPLE:
┌──────────────────────────────────────────────────────────────────────┐
│  API Changelog: v1.0.0 → v2.0.0                                    │
├──────────────────────────────────────────────────────────────────────┤
│  BREAKING CHANGES:                                                   │
│  - DELETE /users/{id}/profile — endpoint removed                     │
│  - PATCH /users/{id} — field 'age' type changed string → integer    │
│  - GET /users — removed query parameter 'page'                      │
│                                                                      │
│  NEW FEATURES:                                                       │
│  - GET /users/{id}/settings — new endpoint                          │
│  - POST /users — added optional field 'nickname'                    │
│  - GET /users — added cursor-based pagination (cursor param)        │
    # ... (condensed)
└──────────────────────────────────────────────────────────────────────┘
```

```yaml
# CI: auto-generate changelog on spec changes
name: API Changelog
on:
  pull_request:
    paths: ["openapi.yaml"]

jobs:
  changelog:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
    # ... (condensed)
          path: changelog.md
```

### Step 11: Validation & Quality Gate
Validate the documentation setup against completeness standards:

```
APIDOCS VALIDATION:
┌──────────────────────────────────────────────────────────────┐
│  Check                                    │  Status          │
├───────────────────────────────────────────┼──────────────────┤
│  Valid OpenAPI 3.0/3.1 spec               │  PASS | FAIL     │
│  All operations have descriptions         │  PASS | FAIL     │
│  All schemas have field descriptions      │  PASS | FAIL     │
│  All schemas have examples                │  PASS | FAIL     │
│  $ref used for shared schemas (no dupes)  │  PASS | FAIL     │
│  Error responses defined on all endpoints │  PASS | FAIL     │
│  Security schemes applied to endpoints    │  PASS | FAIL     │
│  Tags defined and applied                 │  PASS | FAIL     │
│  Servers configured for all environments  │  PASS | FAIL     │
    # ... (condensed)
VERDICT: <PASS | NEEDS REVISION>
```

### Step 12: Deliverables
Generate the final artifacts:

```
APIDOCS COMPLETE:

Artifacts:
- OpenAPI spec: <path to spec file>
- Interactive docs: <URL or path to rendered docs>
- Spectral config: .spectral.yaml
- CI workflow: .github/workflows/api-docs.yml
- Approach: <SPEC-FIRST | CODE-FIRST>
- Renderer: <Swagger UI | Redoc | Stoplight Elements>
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:api — Design additional API endpoints
-> /godmode:test — Generate contract tests from the spec
-> /godmode:cicd — Set up full CI/CD pipeline including doc publishing
-> /godmode:sdk — Generate and publish client SDKs
```

Commit: `"apidocs: <service> — OpenAPI spec, <renderer> setup, CI validation configured"`

## Key Behaviors

1. **Every field gets a description and an example.** An undocumented field is an undocumented bug. Consumers should never have to guess what a field means.
2. **$ref everything shared.** Pagination parameters, error responses, auth schemes — extract once, reference everywhere. A duplicated schema is a schema that will drift.
3. **Validate in CI, not just locally.** Specs break silently. Spectral catches lint issues, Optic catches breaking changes, Redocly catches structural problems. Run all three.
4. **Examples must be realistic.** `"string"` as an example for an email field is useless. Use `"jane.doe@example.com"`. Consumers copy-paste examples.
5. **Generate, don't handwrite, when code exists.** If you have a NestJS app with decorators, generate the spec from code. If you have a greenfield project, write the spec first.
6. **Publish docs automatically.** Docs that live in a YAML file nobody reads are not docs. Render them with Swagger UI, Redoc, or Stoplight and deploy on every merge.
7. **Track breaking changes.** A spec diff in CI is worth a thousand "we accidentally broke the mobile app" incidents.

## Example Usage

### Generating docs for an existing Express API
```
User: /godmode:apidocs Generate API docs for our Express app

APIDocs: Starting discovery...

APIDOCS DISCOVERY:
Project: Express REST API
Language/Framework: Node.js / Express
Existing spec: None found
Existing routes: src/routes/users.js, src/routes/orders.js, src/routes/products.js
Approach: CODE-FIRST (existing routes, no spec)
Output format: OpenAPI 3.1
Doc renderer: Redoc (clean, modern UI)

Setting up swagger-jsdoc...
Adding JSDoc annotations to 3 route files...
Configuring Swagger UI at /docs...
```

### Writing a spec from scratch
```
User: /godmode:apidocs Write an OpenAPI spec for a payment gateway API

APIDocs: Starting spec-first workflow...

APIDOCS DISCOVERY:
Project: Payment Gateway API
Language/Framework: Not yet implemented (spec-first)
Approach: SPEC-FIRST
Output format: OpenAPI 3.1
Doc renderer: Stoplight Elements

Modeling resources:
- Transaction (id, amount, currency, status, merchant_id, customer_id, metadata)
- Refund (id, transaction_id, amount, reason, status)
- Webhook (id, url, events, secret, active)

```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full API docs workflow — discover, generate, validate |
| `--spec-first` | Write OpenAPI spec from scratch (contract-first) |
| `--code-first` | Generate spec from existing code annotations |
| `--renderer swagger-ui` | Use Swagger UI for interactive docs |
| `--renderer redoc` | Use Redoc for documentation (default) |
| `--renderer stoplight` | Use Stoplight Elements |
| `--validate` | Validate existing spec with Spectral + Redocly |
| `--breaking` | Check for breaking changes vs. main branch |
| `--mock` | Start Prism mock server from spec |
| `--sdk <lang>` | Generate client SDK (typescript, python, go, java, etc.) |

## HARD RULES

1. **NEVER write endpoint docs without realistic examples.** A schema without examples is a guessing game. Every request and response must have at least one realistic example.
2. **NEVER duplicate schemas.** Extract shared shapes to `components/schemas` and use `$ref`. Duplicated schemas drift.
3. **NEVER skip CI validation.** Lint and validate the OpenAPI spec on every PR. A spec that was valid last week can be broken today.
4. **NEVER hand-edit generated specs in code-first workflows.** Modify annotations in code instead. Manual edits will be overwritten.
5. **NEVER ignore breaking changes.** Use Optic or oasdiff in CI to catch removed endpoints, renamed parameters, and type changes.
6. **NEVER skip security scheme documentation.** Undocumented auth forces every consumer to reverse-engineer your auth flow.
7. **ALWAYS serve docs in all environments** or publish static docs. Docs behind `if (env === 'development')` are invisible to production consumers.
8. **ALWAYS use `example:` with realistic values** -- `"jane.doe@example.com"` not `"string"`.

## Auto-Detection

On activation, detect the API documentation context:

```bash
# Detect existing OpenAPI specs
find . -name "openapi.*" -o -name "swagger.*" -o -name "*.openapi.*" 2>/dev/null

# Detect spec generation tools
grep -r "swagger\|tsoa\|nestjs/swagger\|springdoc\|drf-spectacular" package.json pom.xml build.gradle requirements.txt 2>/dev/null

# Detect doc rendering
grep -r "redoc\|swagger-ui\|stoplight\|scalar" package.json 2>/dev/null

# Detect validation tools
grep -r "spectral\|redocly\|optic\|oasdiff" package.json .github/ 2>/dev/null

## Output Format

After each apidocs skill invocation, emit a structured report:

```
APIDOCS REPORT:
┌──────────────────────────────────────────────────────┐
│  Approach            │  SPEC-FIRST / CODE-FIRST       │
│  Spec version        │  OpenAPI <3.0 | 3.1>           │
│  Endpoints           │  <N> documented                │
│  Schemas             │  <N> defined / <N> using $ref   │
│  Examples            │  <N> operations with examples   │
│  Renderer            │  <Swagger UI | Redoc | Stoplight> │
│  CI validation       │  CONFIGURED / NOT CONFIGURED    │

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	skill	action	endpoints	schemas	lint_errors	breaking_changes	status
2026-03-20T14:00:00Z	apidocs	generate_spec	12	8	0	0	pass
2026-03-20T14:10:00Z	apidocs	validate	12	8	2	1	needs_fix
```

## Success Criteria

The apidocs skill is complete when ALL of the following are true:
1. Valid OpenAPI 3.0/3.1 spec that parses without errors
2. All operations have descriptions, tags, and at least one example
3. All schemas have field descriptions and realistic examples
4. $ref is used for all shared schemas (no duplicated definitions)
5. Error responses defined on all endpoints (401, 400, 500 at minimum)
6. Security schemes documented and applied to endpoints
7. Spectral lint passes with zero errors
8. No breaking changes vs main branch (or breaking changes are documented)
9. Doc renderer builds and displays correctly

## Error Recovery

IF OpenAPI spec fails validation:
  1. Run npx @redocly/cli lint openapi.yaml for detailed error messages
IF Spectral lint reports errors:
  1. Check .spectral.yaml for custom rules that may need adjustment
IF breaking changes are detected in CI:
  1. Review each breaking change: is it intentional or accidental?
IF doc renderer fails to build:
  1. Check for YAML syntax errors (common: wrong indentation, missing quotes)

## Iterative API Documentation Loop

```
current_iteration = 0
max_iterations = 12
doc_tasks = [discovery, spec_writing, schema_extraction, examples, renderer_setup, ci_validation]

WHILE doc_tasks is not empty AND current_iteration < max_iterations:
    task = doc_tasks.pop(0)
    1. Execute the task (write spec, extract schemas, add examples, etc.)

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "apidocs-spec": OpenAPI spec writing (paths, schemas, components)
  Agent 2 — "apidocs-examples": Examples, mock server, SDK generation
  Agent 3 — "apidocs-ci": Spectral config, CI validation workflow, renderer setup

MERGE ORDER: spec → examples → ci
CONFLICT ZONES: openapi.yaml (spec is authoritative, examples and CI reference it)
```

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
  3. DECIDE:
     - KEEP if: tests pass AND quality improved AND no regressions introduced
     - DISCARD if: tests fail OR performance regressed OR new errors introduced
  4. COMMIT kept changes with descriptive message. Revert discarded changes before proceeding.
```


## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP just because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (that can be a follow-up pass)
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run API docs tasks sequentially: spec writing, then examples, then CI/renderer setup.
- Use branch isolation per task: `git checkout -b godmode-apidocs-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

```
