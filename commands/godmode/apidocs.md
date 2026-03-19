# /godmode:apidocs

Generate, validate, and publish API documentation from OpenAPI/Swagger specs. Supports spec-first and code-first workflows, interactive doc renderers, CI validation, SDK generation, and changelog tracking.

## Usage

```
/godmode:apidocs                            # Full API docs workflow
/godmode:apidocs --spec-first               # Write OpenAPI spec from scratch
/godmode:apidocs --code-first               # Generate spec from code annotations
/godmode:apidocs --renderer swagger-ui      # Use Swagger UI for docs
/godmode:apidocs --renderer redoc           # Use Redoc for docs (default)
/godmode:apidocs --renderer stoplight       # Use Stoplight Elements
/godmode:apidocs --validate                 # Validate existing spec with Spectral + Redocly
/godmode:apidocs --breaking                 # Check for breaking changes vs. main branch
/godmode:apidocs --mock                     # Start Prism mock server from spec
/godmode:apidocs --sdk typescript           # Generate TypeScript client SDK
/godmode:apidocs --ci                       # Generate CI workflow for spec validation
/godmode:apidocs --changelog                # Generate changelog from spec diff
/godmode:apidocs --bundle                   # Bundle multi-file spec into single file
```

## What It Does

1. Discovers project context, existing specs, routes, and framework
2. Selects approach: spec-first (write spec, generate code) or code-first (annotate code, generate spec)
3. Writes or generates complete OpenAPI 3.0/3.1 spec with descriptions, examples, and $ref reuse
4. Configures code-first generation (swagger-jsdoc, @nestjs/swagger, FastAPI, springdoc, tsoa, swaggo)
5. Enforces schema reuse via $ref and components — no duplicated definitions
6. Adds realistic examples and mocking (Prism, MSW, Microcks)
7. Sets up interactive doc renderer (Swagger UI, Redoc, or Stoplight Elements)
8. Handles versioning in specs (URL, header, overlays)
9. Configures CI validation (Spectral linting, Redocly validation, Optic breaking change detection)
10. Generates client SDKs via openapi-generator (TypeScript, Python, Go, Java, and more)
11. Generates changelogs from spec diffs (oasdiff)
12. Validates against 15 documentation quality checks

## Output
- OpenAPI spec at `docs/api/<service>-openapi.yaml`
- Interactive docs (Swagger UI, Redoc, or Stoplight Elements)
- Spectral config at `.spectral.yaml`
- CI workflow at `.github/workflows/api-docs.yml`
- SDK output at `sdk/<language>/`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"apidocs: <service> — OpenAPI spec, <renderer> setup, CI validation configured"`

## Next Step
After API docs: `/godmode:api` to design additional endpoints, `/godmode:test` for contract tests from the spec, or `/godmode:cicd` for full CI/CD including doc publishing.

## Examples

```
/godmode:apidocs Generate API docs for our Express REST API
/godmode:apidocs --spec-first Write an OpenAPI spec for a payment gateway
/godmode:apidocs --validate Check our existing spec for issues
/godmode:apidocs --breaking Detect breaking changes in this PR
/godmode:apidocs --sdk python Generate a Python client SDK
/godmode:apidocs --ci Set up CI to lint and validate our spec
/godmode:apidocs --changelog Show what changed between v1 and v2
```
