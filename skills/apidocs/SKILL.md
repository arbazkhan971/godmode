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
```

If the user hasn't specified, ask: "Do you want to write the spec first and generate code from it (spec-first), or generate the spec from existing code (code-first)?"

### Step 2: Spec-First — Writing OpenAPI from Scratch
For spec-first (contract-first) development, produce a complete OpenAPI document:

```yaml
# Template: OpenAPI 3.1 Spec-First
openapi: "3.1.0"
info:
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

```

Framework-specific setup:
- **Express**: `swagger-jsdoc` + `swagger-ui-express` with JSDoc `@openapi` annotations
- **NestJS**: `@nestjs/swagger` with `DocumentBuilder` and `ApiProperty` decorators
- **FastAPI**: Built-in OpenAPI generation from Pydantic models
- **Spring Boot**: `springdoc-openapi` with `@Tag`, `@Operation` annotations
- **tsoa**: TypeScript decorators, `npx tsoa spec` generates spec
- **Go**: `swaggo/swag` with comment annotations, `swag init` generates spec

### Step 4: Schema Reuse with $ref and Components
Enforce DRY specs by extracting shared schemas:

```
SCHEMA REUSE CHECKLIST:
| Pattern | Extract to |
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
```

### Step 5: Examples and Mocking
Every operation must have realistic examples for documentation and mocking:

```yaml
# Inline examples in schema
properties:
  email:
```

Mock server setup:

```bash
# Prism — mock server from OpenAPI spec
npm install -g @stoplight/prism-cli
prism mock openapi.yaml                     # Start mock server on :4010
```

### Step 6: Documentation Renderers
Set up interactive documentation from the OpenAPI spec:

#### Swagger UI
```bash
npm install swagger-ui-express
# or standalone
docker run -p 8080:8080 -e SWAGGER_JSON=/spec/openapi.yaml \
```

```javascript
// Express integration
const swaggerUi = require("swagger-ui-express");
const spec = require("./openapi.json");
```

#### Redoc
```html
<!-- Static HTML — zero dependencies -->
<!DOCTYPE html>
<html>
```

```bash
# Build static docs
npx @redocly/cli build-docs openapi.yaml -o docs/index.html

```

#### Stoplight Elements
```html
<!-- Embed in any HTML page -->
<script src="https://unpkg.com/@stoplight/elements/web-components.min.js"></script>
<link rel="stylesheet" href="https://unpkg.com/@stoplight/elements/styles.min.css">
```

### Step 7: Versioning in Specs
Handle API versioning within OpenAPI specs:

```
SPEC VERSIONING STRATEGIES:
| Strategy | How to Represent in OpenAPI |
```

### Step 8: CI Validation & Linting
Validate specs in CI to prevent regressions:

```yaml
# .github/workflows/api-docs.yml
name: API Docs CI
on:
```

```yaml
# .spectral.yaml — custom linting rules
extends: ["spectral:oas"]

```

```bash
# Optic — track breaking changes over time
npx @useoptic/optic diff openapi.yaml --base main --check

```

### Step 9: SDK Generation
Generate client SDKs from the OpenAPI spec:

```bash
# openapi-generator — supports 50+ languages
npm install -g @openapitools/openapi-generator-cli

```

```yaml
# Alternative: openapi-typescript (lightweight, type-only)
# Generates TypeScript types from OpenAPI — no runtime, just types
npx openapi-typescript openapi.yaml -o src/api/schema.d.ts
```

```yaml
# CI workflow for SDK generation
name: Generate SDKs
on:
```

### Step 10: Changelog Generation from Spec Diffs
Automatically generate API changelogs from spec differences:

```bash
# oasdiff — diff two OpenAPI specs and generate changelog
npm install -g oasdiff
# or
```

```
CHANGELOG OUTPUT EXAMPLE:
  API Changelog: v1.0.0 → v2.0.0
```

```yaml
# CI: auto-generate changelog on spec changes
name: API Changelog
on:
```

### Step 11: Validation & Quality Gate
Validate the documentation setup against completeness standards:

```
APIDOCS VALIDATION:
| Check | Status |
```

### Step 12: Deliverables
Generate the final artifacts:

```
APIDOCS COMPLETE:

Artifacts:
```

Commit: `"apidocs: <service> — OpenAPI spec, <renderer> setup, CI validation configured"`

## Key Behaviors

1. **Every field gets a description and an example.** An undocumented field is an undocumented bug. Consumers should never have to guess what a field means.
2. **$ref everything shared.** Pagination parameters, error responses, auth schemes — extract once, reference everywhere. A duplicated schema is a schema that will drift.
3. **Validate in CI, not only locally.** Specs break silently. Spectral catches lint issues, Optic catches breaking changes, Redocly catches structural problems. Run all three.
4. **Use realistic examples.** `"string"` as an example for an email field is useless. Use `"jane.doe@example.com"`. Consumers copy-paste examples.
5. **Generate, don't handwrite, when code exists.** If you have a NestJS app with decorators, generate the spec from code. If you have a greenfield project, write the spec first.
6. **Publish docs automatically.** Docs that live in a YAML file nobody reads are not docs. Render them with Swagger UI, Redoc, or Stoplight and deploy on every merge.
7. **Track breaking changes.** A spec diff in CI is worth a thousand "we accidentally broke the mobile app" incidents.

## HARD RULES

Never ask to continue. Loop autonomously until spec validates and all endpoints have examples.

1. **NEVER write endpoint docs without realistic examples.** A schema without examples is a guessing game. Every request and response must have at least one realistic example.
2. **NEVER duplicate schemas.** Extract shared shapes to `components/schemas` and use `$ref`. Duplicated schemas drift.
3. **NEVER skip CI validation.** Lint and validate the OpenAPI spec on every PR. A spec valid last week can break today.
4. **NEVER hand-edit generated specs in code-first workflows.** Modify annotations in code instead. The generator overwrites manual edits.
5. **NEVER ignore breaking changes.** Use Optic or oasdiff in CI to catch removed endpoints, renamed parameters, and type changes.
6. **NEVER skip security scheme documentation.** Undocumented auth forces every consumer to reverse-engineer your auth flow.
7. **ALWAYS serve docs in all environments** or publish static docs. Docs behind `if (env === 'development')` are invisible to production consumers.
8. **ALWAYS use `example:` with realistic values** -- `"jane.doe@example.com"` not `"string"`.

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

## Iterative API Documentation Loop

```
current_iteration = 0
max_iterations = 12
doc_tasks = [discovery, spec_writing, schema_extraction, examples, renderer_setup, ci_validation]
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

DO NOT STOP only because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```


## Error Recovery
| Failure | Action |
|--|--|
| OpenAPI spec validation fails | Run `swagger-cli validate` to get specific errors. Fix schema references, missing required fields, and invalid types. |
| Generated docs drift from implementation | Add CI check: compare spec against route handlers. Use spec-first or code-first consistently, never mix. |
| Examples fail validation against schema | Ensure example values match declared types, enums, and patterns. Auto-generate examples from schema as fallback. |
| Docs build breaks after API change | Pin docs generator version. Run docs build in CI on every PR that touches API routes. |

## Output Format
Print: `APIDocs: {endpoints} endpoints documented. Schema valid: {yes|no}. Examples: {N}/{M} passing. Coverage: {pct}%. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH documentation change:
  KEEP if: spec validates AND examples pass AND docs build succeeds
  DISCARD if: validation fails OR examples broken OR docs build errors
  On discard: revert. Fix schema first, then update docs.
```
