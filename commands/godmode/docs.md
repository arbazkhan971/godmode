# /godmode:docs

Generate and maintain project documentation. Produces API docs (OpenAPI/Swagger), code docs (JSDoc/docstrings), READMEs, runbooks, and audits existing documentation for staleness.

## Usage

```
/godmode:docs                             # Interactive documentation generation
/godmode:docs --api                       # Generate API documentation (OpenAPI)
/godmode:docs --code                      # Generate code docs (JSDoc/docstrings)
/godmode:docs --readme                    # Generate or update README files
/godmode:docs --runbook <topic>           # Create operational runbook
/godmode:docs --audit                     # Audit docs for staleness and gaps
/godmode:docs --coverage                  # Report documentation coverage
/godmode:docs --fix-links                 # Find and fix broken links
/godmode:docs --format <fmt>              # Output format: markdown, html, json
```

## What It Does

1. Inventories existing documentation across the project
2. Scans code for public APIs, exports, and endpoints
3. Generates documentation matching existing project style and conventions
4. Detects stale docs by cross-referencing against actual codebase
5. Creates operational runbooks from deployment scripts and CI/CD configs
6. Reports documentation coverage and identifies gaps

## Output
- Documentation files in appropriate locations (docs/, README.md, inline)
- A git commit: `"docs: <scope> — <summary of what was documented>"`
- Audit reports with staleness, gaps, and quality issues

## Next Step
After generating docs: `/godmode:review` to verify docs match implementation.
Run `--audit` periodically to catch documentation rot.

## Examples

```
/godmode:docs --api                       # Generate OpenAPI spec from routes
/godmode:docs --code                      # Add JSDoc to undocumented exports
/godmode:docs --runbook deployment        # Create deployment runbook
/godmode:docs --audit                     # Find stale and missing docs
/godmode:docs --coverage                  # See what % of public API is documented
```
