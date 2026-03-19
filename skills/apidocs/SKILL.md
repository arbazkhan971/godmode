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
Doc renderer: Swagger UI | Redoc | Stoplight Elements | Custom
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
  contact:
    name: "<team or maintainer>"
    email: "<email>"
    url: "<support URL>"
  license:
    name: "<license>"
    identifier: "<SPDX identifier>"
  x-logo:
    url: "<logo URL for Redoc>"

servers:
  - url: "https://api.<domain>/v1"
    description: "Production"
  - url: "https://staging-api.<domain>/v1"
    description: "Staging"
  - url: "http://localhost:<port>/v1"
    description: "Local development"

tags:
  - name: "<ResourceGroup>"
    description: "<Description of this group of endpoints>"

paths:
  /<resource>:
    get:
      tags: ["<ResourceGroup>"]
      summary: "List <resources>"
      description: "Returns a paginated list of <resources>."
      operationId: "list<Resources>"
      parameters:
        - $ref: "#/components/parameters/Cursor"
        - $ref: "#/components/parameters/Limit"
        - $ref: "#/components/parameters/Sort"
      responses:
        "200":
          description: "Paginated list of <resources>"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/<Resource>List"
              examples:
                default:
                  $ref: "#/components/examples/<Resource>ListExample"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "429":
          $ref: "#/components/responses/RateLimitExceeded"
      security:
        - BearerAuth: []
    post:
      tags: ["<ResourceGroup>"]
      summary: "Create a <resource>"
      operationId: "create<Resource>"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/Create<Resource>Request"
            examples:
              default:
                $ref: "#/components/examples/Create<Resource>Example"
      responses:
        "201":
          description: "<Resource> created"
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/<Resource>"
        "400":
          $ref: "#/components/responses/BadRequest"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "409":
          $ref: "#/components/responses/Conflict"

components:
  schemas:
    <Resource>:
      type: object
      required: [id, <required_fields>, created_at, updated_at]
      properties:
        id:
          type: string
          format: uuid
          description: "Unique identifier"
          example: "550e8400-e29b-41d4-a716-446655440000"
        # ... all fields with types, formats, descriptions, examples
        created_at:
          type: string
          format: date-time
          description: "ISO 8601 creation timestamp"
        updated_at:
          type: string
          format: date-time
          description: "ISO 8601 last update timestamp"

    Error:
      type: object
      required: [error]
      properties:
        error:
          type: object
          required: [code, message]
          properties:
            code:
              type: string
              description: "Machine-readable error code"
            message:
              type: string
              description: "Human-readable error description"
            details:
              type: array
              items:
                type: object
                properties:
                  field:
                    type: string
                  code:
                    type: string
                  message:
                    type: string
            request_id:
              type: string
              format: uuid

  parameters:
    Cursor:
      name: cursor
      in: query
      description: "Pagination cursor from a previous response"
      schema:
        type: string
    Limit:
      name: limit
      in: query
      description: "Maximum number of items to return"
      schema:
        type: integer
        minimum: 1
        maximum: 100
        default: 20
    Sort:
      name: sort
      in: query
      description: "Sort field and direction (e.g., created_at:desc)"
      schema:
        type: string

  examples:
    <Resource>ListExample:
      summary: "A paginated list of <resources>"
      value:
        data:
          - id: "550e8400-e29b-41d4-a716-446655440000"
            # ... example fields
        pagination:
          next_cursor: "eyJpZCI6MTAwfQ=="
          has_more: true

  responses:
    BadRequest:
      description: "Invalid request parameters"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"
          example:
            error:
              code: "VALIDATION_ERROR"
              message: "Request validation failed"
              details:
                - field: "email"
                  code: "INVALID_FORMAT"
                  message: "Must be a valid email address"
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
    Conflict:
      description: "Resource conflict"
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/Error"

  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
    ApiKeyAuth:
      type: apiKey
      in: header
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
│  FastAPI (Python)    │  Built-in (auto at /docs and /redoc)              │
│  Django REST         │  drf-spectacular or drf-yasg                      │
│  Flask               │  flask-smorest or flasgger                        │
│  Spring Boot (Java)  │  springdoc-openapi-starter-webmvc-ui              │
│  Go (Gin/Echo/Chi)   │  swaggo/swag (comment annotations)               │
│  .NET                │  Swashbuckle.AspNetCore or NSwag                  │
│  tsoa (TypeScript)   │  tsoa (generates routes + OpenAPI from models)    │
│  Hono                │  @hono/zod-openapi                                │
│  tRPC                │  trpc-openapi (adapter to REST + OpenAPI)         │
│  Elysia (Bun)       │  @elysiajs/swagger                                │
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
    info: {
      title: "<API Name>",
      version: "<version>",
      description: "<description>",
    },
    servers: [{ url: "/api/v1" }],
    components: {
      securitySchemes: {
        BearerAuth: { type: "http", scheme: "bearer", bearerFormat: "JWT" },
      },
    },
  },
  apis: ["./src/routes/*.js", "./src/models/*.js"], // Files with JSDoc annotations
};

const spec = swaggerJsdoc(options);
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
 *     parameters:
 *       - $ref: '#/components/parameters/Cursor'
 *       - $ref: '#/components/parameters/Limit'
 *     responses:
 *       200:
 *         description: Paginated user list
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/UserList'
 */
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
  .addBearerAuth()
  .addTag("<resource>")
  .build();

const document = SwaggerModule.createDocument(app, config);
SwaggerModule.setup("docs", app, document);

// Export spec to file for CI validation
const fs = require("fs");
fs.writeFileSync("./openapi.json", JSON.stringify(document, null, 2));
```

```typescript
// DTO example with decorators
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateUserDto {
  @ApiProperty({ description: "User email address", example: "user@example.com" })
  email: string;

  @ApiProperty({ description: "Display name", minLength: 2, maxLength: 100 })
  name: string;

  @ApiPropertyOptional({ description: "Profile avatar URL" })
  avatar_url?: string;
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
    docs_url="/docs",       # Swagger UI
    redoc_url="/redoc",     # Redoc
    openapi_url="/openapi.json",
)

class User(BaseModel):
    """User resource."""
    id: str = Field(..., description="Unique identifier", json_schema_extra={"example": "550e8400-e29b-41d4-a716-446655440000"})
    email: str = Field(..., description="User email address", json_schema_extra={"example": "user@example.com"})
    name: str = Field(..., description="Display name", min_length=2, max_length=100)

    model_config = {"json_schema_extra": {"examples": [{"id": "550e...", "email": "user@example.com", "name": "Jane"}]}}

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
    title: "<API Name>"
    version: "<version>"
    description: "<description>"
```

```java
@Tag(name = "Users", description = "User management")
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Operation(summary = "List users", description = "Returns a paginated list of users")
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Success",
            content = @Content(schema = @Schema(implementation = UserListResponse.class))),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping
    public UserListResponse listUsers(
        @Parameter(description = "Pagination cursor") @RequestParam(required = false) String cursor,
        @Parameter(description = "Page size", example = "20") @RequestParam(defaultValue = "20") int limit
    ) { /* ... */ }
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
  },
  "routes": {
    "routesDir": "src/generated"
  }
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
  @Get()
  @Security("bearerAuth")
  public async listUsers(
    @Query() cursor?: string,
    @Query() limit: number = 20
  ): Promise<UserListResponse> { /* ... */ }

  /**
   * Creates a new user.
   * @param body The user creation payload
   */
  @Post()
  @Security("bearerAuth")
  public async createUser(@Body() body: CreateUserRequest): Promise<User> { /* ... */ }
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

// @Summary List users
// @Tags Users
// @Produce json
// @Param cursor query string false "Pagination cursor"
// @Param limit query int false "Page size" default(20)
// @Success 200 {object} UserListResponse
// @Failure 401 {object} ErrorResponse
// @Router /users [get]
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

MULTI-FILE $ref (for large APIs):
  $ref: "./schemas/User.yaml"
  $ref: "./paths/users.yaml#/list"
  $ref: "./parameters/pagination.yaml#/Cursor"

Bundle command:
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
  oneOf:
    - $ref: "#/components/schemas/EmailNotification"
    - $ref: "#/components/schemas/SmsNotification"
    - $ref: "#/components/schemas/PushNotification"
  discriminator:
    propertyName: type
    mapping:
      email: "#/components/schemas/EmailNotification"
      sms: "#/components/schemas/SmsNotification"
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
          application/json:
            examples:
              basic:
                summary: "Create a basic user"
                value:
                  email: "jane@example.com"
                  name: "Jane Doe"
              admin:
                summary: "Create an admin user"
                value:
                  email: "admin@example.com"
                  name: "Admin User"
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
         hide-download-button="false"
         theme='{"colors":{"primary":{"main":"#1a73e8"}}}'
  ></redoc>
  <script src="https://cdn.redoc.ly/redoc/latest/bundles/redoc.standalone.js"></script>
</body>
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
│  single spec        │  x-since / x-until extensions per operation.  │
└─────────────────────┴───────────────────────────────────────────────┘

CHANGELOG IN SPEC (x- extensions):
info:
  x-changelog:
    - version: "2.0.0"
      date: "2025-06-01"
      changes:
        - type: "breaking"
          description: "Removed /users/:id/profile endpoint"
        - type: "added"
          description: "Added /users/:id/settings endpoint"
    - version: "1.1.0"
      date: "2025-03-01"
      changes:
        - type: "added"
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
      - name: Lint OpenAPI spec
        run: npx @stoplight/spectral-cli lint openapi.yaml --ruleset .spectral.yaml

      # Validate with Redocly CLI
      - name: Validate OpenAPI spec
        run: npx @redocly/cli lint openapi.yaml

      # Detect breaking changes with Optic
      - name: Check for breaking changes
        run: |
          npx @useoptic/optic diff openapi.yaml \
            --base main \
            --check

      # Build docs to verify rendering
      - name: Build docs
        run: npx @redocly/cli build-docs openapi.yaml -o dist/index.html

      # Upload docs artifact
      - name: Upload docs
        uses: actions/upload-artifact@v4
        with:
          name: api-docs
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
  schema-examples:
    severity: warn
    given: "$.components.schemas[*].properties[*]"
    then:
      field: example
      function: truthy

  # Enforce tags on all operations
  operation-tags:
    severity: error
    given: "$.paths[*][*]"
    then:
      field: tags
      function: truthy

  # Ban HTTP auth in favor of HTTPS
  no-http-servers:
    severity: error
    given: "$.servers[*].url"
    then:
      function: pattern
      functionOptions:
        notMatch: "^http://"

  # Require pagination on list endpoints
  pagination-on-lists:
    severity: warn
    given: "$.paths[*].get.parameters"
    then:
      function: length
      functionOptions:
        min: 1

  # Require error responses
  error-responses:
    severity: error
    given: "$.paths[*][*].responses"
    then:
      - field: "401"
        function: truthy
      - field: "500"
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
  -g python \
  -o sdk/python \
  --additional-properties=packageName=my_api_client

# Go client
openapi-generator-cli generate \
  -i openapi.yaml \
  -g go \
  -o sdk/go \
  --additional-properties=packageName=apiclient

# Generate ALL SDKs in CI
LANGUAGES=("typescript-axios" "python" "go" "java" "ruby" "csharp")
for lang in "${LANGUAGES[@]}"; do
  openapi-generator-cli generate -i openapi.yaml -g "$lang" -o "sdk/$lang"
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
    steps:
      - uses: actions/checkout@v4
      - name: Generate ${{ matrix.lang }} SDK
        run: |
          npx @openapitools/openapi-generator-cli generate \
            -i openapi.yaml \
            -g ${{ matrix.lang }} \
            -o sdk/${{ matrix.lang }}
      - name: Publish SDK
        run: |
          cd sdk/${{ matrix.lang }}
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
│                                                                      │
│  DEPRECATIONS:                                                       │
│  - GET /users?offset= — offset pagination deprecated, use cursor    │
│  - Header X-API-Token — deprecated in favor of Authorization bearer │
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

      - name: Get base spec
        run: git show origin/main:openapi.yaml > /tmp/base-spec.yaml

      - name: Generate changelog
        run: |
          npx oasdiff changelog /tmp/base-spec.yaml openapi.yaml \
            --format markdown > changelog.md

      - name: Check breaking changes
        run: |
          npx oasdiff breaking /tmp/base-spec.yaml openapi.yaml \
            || echo "::warning::Breaking changes detected"

      - name: Comment on PR
        uses: marocchino/sticky-pull-request-comment@v2
        with:
          header: api-changelog
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
│  No breaking changes vs. main branch      │  PASS | FAIL|N/A │
│  Doc renderer builds successfully         │  PASS | FAIL     │
│  Spectral lint passes (zero errors)       │  PASS | FAIL     │
│  Examples are realistic (not "string")    │  PASS | FAIL     │
│  Pagination documented on list endpoints  │  PASS | FAIL     │
│  Rate limit headers documented            │  PASS | FAIL     │
└───────────────────────────────────────────┴──────────────────┘

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
Building Redoc static docs...
Running Spectral validation...

12/15 checks PASS.
3 warnings: Missing examples on 3 schemas.

Artifacts:
- OpenAPI spec: docs/api/openapi.yaml
- Swagger UI: http://localhost:3000/docs
- Redoc: docs/api/index.html
- Spectral config: .spectral.yaml
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

Writing OpenAPI spec with 12 endpoints...
Adding request/response examples for all operations...
Configuring security (API key + webhook signature verification)...
Running Spectral validation...

15/15 checks PASS.

Artifacts:
- OpenAPI spec: docs/api/payment-gateway-openapi.yaml
- Stoplight Elements: docs/api/index.html
- Mock server: npx prism mock docs/api/payment-gateway-openapi.yaml
```

### Setting up CI validation
```
User: /godmode:apidocs Set up CI to validate our OpenAPI spec

APIDocs: Configuring CI pipeline...

Added:
- .spectral.yaml — custom lint rules (12 rules)
- .github/workflows/api-docs.yml — lint, validate, breaking change detection, doc build
- package.json scripts: "lint:api", "docs:build", "docs:breaking"

CI will:
1. Lint with Spectral (custom rules + spectral:oas defaults)
2. Validate with Redocly CLI
3. Detect breaking changes with Optic (vs. main branch)
4. Build Redoc static docs
5. Comment changelog on PRs
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
| `--ci` | Generate CI workflow for spec validation and doc publishing |
| `--changelog` | Generate changelog from spec diff |
| `--bundle` | Bundle multi-file spec into single file |
| `--export <format>` | Export spec as yaml, json, or html |

## Anti-Patterns

- **Do NOT write docs without examples.** A schema without examples is a guessing game. Every request body and response must have at least one realistic example.
- **Do NOT duplicate schemas.** If you see the same object shape in two places, extract it to `components/schemas` and use `$ref`. Duplicated schemas drift and cause consumer bugs.
- **Do NOT skip CI validation.** A spec that was valid last week can be broken by today's PR. Lint and validate on every change.
- **Do NOT use "string" as an example for typed fields.** `example: "string"` for an email field tells the consumer nothing. Use `example: "jane.doe@example.com"`.
- **Do NOT generate docs and never update them.** Stale docs are worse than no docs — they actively mislead consumers. Generate from code or validate the spec in CI to keep it current.
- **Do NOT hand-edit generated specs.** If using code-first, the generated spec is the source of truth. Edits to the generated file will be overwritten. Modify annotations in code instead.
- **Do NOT ignore breaking changes.** A field type change, a removed endpoint, a renamed parameter — these break consumers silently. Use Optic or oasdiff in CI to catch them.
- **Do NOT skip security scheme documentation.** An undocumented auth requirement means every new consumer has to reverse-engineer your auth flow.
- **Do NOT serve docs only in development.** If your docs endpoint is behind `if (env === 'development')`, your API consumers in staging and production have no reference. Serve docs in all environments or publish static docs.
- **Do NOT write a monolithic spec for a microservices architecture.** Each service owns its own spec. Use a gateway or portal (Backstage, Bump.sh) to aggregate them.
