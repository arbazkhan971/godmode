# /godmode:api

Design, specify, and validate REST, GraphQL, or gRPC APIs. Generates OpenAPI specs, enforces versioning strategies, designs rate limiting and pagination, and produces standardized error responses.

## Usage

```
/godmode:api                            # Full API design workflow
/godmode:api --type rest                # Design REST API (default)
/godmode:api --type graphql             # Design GraphQL API
/godmode:api --type grpc                # Design gRPC API
/godmode:api --validate                 # Validate existing API spec or routes
/godmode:api --spec                     # Generate OpenAPI spec only
/godmode:api --versioning url           # Force URL path versioning
/godmode:api --pagination cursor        # Force cursor-based pagination
/godmode:api --diff v1 v2               # Compare two API versions
/godmode:api --mock                     # Generate mock server from spec
```

## What It Does

1. Discovers project context, consumers, and constraints
2. Models resources with attributes, relationships, and constraints
3. Designs endpoints following REST/GraphQL/gRPC conventions
4. Selects and applies versioning strategy (URL, header, query, content negotiation)
5. Designs pagination (offset, cursor, keyset)
6. Defines consistent error response format and HTTP status code mapping
7. Designs rate limiting tiers with response headers
8. Generates complete OpenAPI 3.1 / GraphQL SDL / protobuf spec
9. Validates the design against 15 best-practice checks
10. Produces documentation and artifacts

## Output
- OpenAPI spec at `docs/api/<service>-openapi.yaml`
- API design doc at `docs/api/<service>-api-design.md`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"api: <service> — <N> endpoints, <M> resources, OpenAPI spec generated"`

## Next Step
After API design: `/godmode:contract` to define and test consumer contracts, or `/godmode:plan` to decompose implementation into tasks.

## Examples

```
/godmode:api Design a REST API for user management
/godmode:api --type graphql Design a product catalog API
/godmode:api --validate Check our existing API for issues
/godmode:api --diff v1 v2 Find breaking changes between versions
```
