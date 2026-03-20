---
name: docs
description: |
  Documentation generation and maintenance skill. Activates when the project needs API docs (OpenAPI/Swagger), code docs (JSDoc, docstrings), README generation, runbook creation, or documentation quality audits. Detects stale docs, missing coverage, and obsolescence. Triggers on: /godmode:docs, "generate docs", "update documentation", "write a README", "create runbook", or when shipping reveals undocumented public APIs.
---

# Docs — Documentation Generation & Maintenance

## When to Activate
- User invokes `/godmode:docs`
- User says "generate docs", "document this", "write a README"
- User asks for runbooks, API docs, or onboarding guides
- Shipping skill detects undocumented public APIs
- User says "are our docs up to date?" or "check documentation"

## Workflow

### Step 1: Determine Documentation Scope
Identify what documentation is needed:

```
SCOPE DETECTION:
- API: Generate OpenAPI/Swagger specs or endpoint documentation
- CODE: Generate JSDoc, docstrings, type annotations, inline comments
- README: Generate or update project/module README files
- RUNBOOK: Create operational runbooks for deployment, incidents, maintenance
- AUDIT: Check existing docs for staleness, gaps, and quality issues
- ALL: Full documentation sweep
```

### Step 2: Inventory Existing Documentation
Survey the current state:

```bash
# Find existing documentation files
find . -name "*.md" -not -path "./node_modules/*" -not -path "./.git/*" | sort

# Find OpenAPI/Swagger specs
find . -name "openapi*" -o -name "swagger*" | head -20

# Check for doc generation config
ls .jsdoc.json tsconfig.json typedoc.json mkdocs.yml 2>/dev/null

# Count documented vs undocumented exports
grep -r "export" --include="*.ts" --include="*.js" -l | head -20
```

Present inventory:
```
DOCUMENTATION INVENTORY:
┌──────────────────────────────────────────────────────┐
│  Documentation Status                                 │
├────────────────────┬─────────┬────────────────────────┤
│  Category          │  Count  │  Coverage              │
├────────────────────┼─────────┼────────────────────────┤
│  README files      │  3      │  root, api, shared     │
│  API docs          │  1      │  OpenAPI 3.0 (partial) │
│  Code docs         │  47/120 │  39% of public exports │
│  Runbooks          │  0      │  None                  │
│  Architecture docs │  2      │  ADRs only             │
│  Guides            │  1      │  Getting started       │
└────────────────────┴─────────┴────────────────────────┘
```

### Step 3: Generate API Documentation
For REST APIs, generate or update OpenAPI spec:

```yaml
# Scan routes/controllers for endpoints
# For each endpoint, generate:
openapi: "3.0.3"
info:
  title: <API name>
  version: <version>
paths:
  /api/<resource>:
    get:
      summary: <derived from handler name and code>
      parameters: <derived from query/path params>
      responses:
        200:
          description: <derived from return type>
          content:
            application/json:
              schema: <derived from response object>
        400:
          description: <derived from validation errors>
        401:
          description: <if auth middleware present>
```

For each endpoint:
1. Read the route definition and handler
2. Extract request parameters, body schema, and response shape
3. Identify authentication requirements from middleware
4. Document error responses from error handling code
5. Add examples from test fixtures when available

### Step 4: Generate Code Documentation
Analyze code and add documentation:

#### For TypeScript/JavaScript (JSDoc):
```typescript
/**
 * <Brief description derived from function name and body>
 *
 * @param <name> - <description from usage context>
 * @returns <description from return statements>
 * @throws <Error type> <when condition, from throw statements>
 * @example
 * <derived from test files or usage in codebase>
 */
```

#### For Python (docstrings):
```python
def function_name(param: Type) -> ReturnType:
    """<Brief description derived from function name and body>.

    Args:
        param: <description from usage context>

    Returns:
        <description from return statements>

    Raises:
        <ErrorType>: <when condition, from raise statements>

    Example:
        >>> <derived from test files or usage>
    """
```

Rules for code docs:
- Document ALL public exports (exported functions, classes, types, constants)
- Skip private/internal functions unless they are complex (>20 lines)
- Derive descriptions from actual code behavior, not guesses
- Include `@example` blocks from test files when available
- Document thrown errors by reading throw/raise statements

### Step 5: Generate README Files
For project or module READMEs:

```markdown
# <Project/Module Name>

<One-paragraph description derived from package.json, pyproject.toml, or code analysis>

## Installation

<Derived from package manager config and lock files>

## Quick Start

<Derived from test files, examples directory, or main entry point>

## API Reference

<Summary table of public exports with links to detailed docs>

## Configuration

<Derived from config files, environment variables, .env.example>

## Development

<Derived from scripts in package.json, Makefile, or similar>

## License

<Derived from LICENSE file>
```

### Step 6: Create Runbooks
For operational documentation:

```markdown
# Runbook: <Operation Name>

## Overview
<What this runbook covers and when to use it>

## Prerequisites
- <Access requirements>
- <Tools needed>
- <Environment setup>

## Procedure

### Step 1: <Action>
```command
<exact command to run>
```
**Expected output:** <what you should see>
**If it fails:** <troubleshooting step>

### Step 2: <Action>
...

## Rollback
<How to undo this operation if something goes wrong>

## Verification
<How to confirm the operation succeeded>

## Contacts
<Who to escalate to if this runbook doesn't resolve the issue>
```

Runbook sources:
- Deployment scripts and CI/CD configs
- Existing operational procedures (even if undocumented)
- Common incident patterns from git history
- Environment configuration files

### Step 7: Documentation Quality Audit
Check all existing documentation for issues:

```
QUALITY AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Documentation Health Report                                  │
├──────┬───────────────────────────────┬──────────┬─────────────┤
│  #   │  Issue                        │  Severity│  File       │
├──────┼───────────────────────────────┼──────────┼─────────────┤
│  1   │  Stale: references removed API│  HIGH    │  api.md:42  │
│  2   │  Missing: no docs for /users  │  HIGH    │  (none)     │
│  3   │  Broken link: ./setup.md      │  MEDIUM  │  README:15  │
│  4   │  Outdated example: uses v1 API│  MEDIUM  │  guide.md:8 │
│  5   │  Typo: "recieve" (x3)        │  LOW     │  various    │
└──────┴───────────────────────────────┴──────────┴─────────────┘
```

Staleness detection strategies:
```bash
# Find docs referencing files/functions that no longer exist
# Extract code references from docs
grep -oP '`[a-zA-Z_]+\(\)`' docs/*.md | sort -u

# Cross-reference with actual codebase
# Flag any reference that doesn't match a real function/file

# Find docs older than their subject
# Compare doc modification date with code modification date
git log -1 --format="%ai" -- <doc-file>
git log -1 --format="%ai" -- <code-file>
```

### Step 8: Commit Documentation
```
git add docs/ README.md
git commit -m "docs: <scope> — <summary of what was documented>"
```

## Key Behaviors

1. **Derive, don't invent.** Documentation must come from reading actual code, not guessing. If you can't determine what a function does from the code, say so.
2. **Examples from tests.** The best documentation examples come from test files. Use real test cases as doc examples whenever possible.
3. **Coverage over perfection.** 80% coverage with good docs beats 20% coverage with perfect docs. Get the public API documented first.
4. **Detect staleness ruthlessly.** A wrong doc is worse than no doc. Cross-reference everything against the actual codebase.
5. **Match existing style.** If the project uses JSDoc, write JSDoc. If it uses NumPy-style docstrings, use those. Don't introduce a new convention.
6. **Runbooks are commands, not prose.** Every runbook step should be a copy-pasteable command with expected output. Narrative text belongs in guides, not runbooks.

## Example Usage

### Generating API docs
```
User: /godmode:docs Generate OpenAPI spec for our API

Docs: Scanning the codebase for API endpoints...

Found 14 endpoints in src/routes/:
- GET    /api/users          (src/routes/users.ts:12)
- POST   /api/users          (src/routes/users.ts:34)
- GET    /api/users/:id      (src/routes/users.ts:56)
- PUT    /api/users/:id      (src/routes/users.ts:78)
- DELETE /api/users/:id      (src/routes/users.ts:92)
...

Auth middleware detected on 12/14 endpoints (all except POST /auth/*)
Validation schemas found for 8/14 endpoints

Generating OpenAPI 3.0 spec...
Saved to docs/api/openapi.yaml

Coverage: 14/14 endpoints documented
Missing schemas: 6 request bodies need manual review
```

### Auditing documentation
```
User: /godmode:docs --audit

Docs: Scanning documentation against codebase...

DOCUMENTATION HEALTH:
- README.md: OK (last updated 3 days ago)
- docs/api/openapi.yaml: STALE (missing 3 new endpoints added this week)
- src/services/: 12/20 public functions undocumented (60% coverage)
- docs/runbooks/: EMPTY (no runbooks exist)

RECOMMENDATIONS:
1. Update OpenAPI spec — 3 endpoints added since last update
2. Add JSDoc to 8 critical service functions
3. Create deployment runbook from CI/CD config
4. Fix 2 broken links in README.md
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive documentation generation |
| `--api` | Generate API documentation only (OpenAPI/Swagger) |
| `--code` | Generate code documentation only (JSDoc/docstrings) |
| `--readme` | Generate or update README files |
| `--runbook <topic>` | Create a runbook for a specific operation |
| `--audit` | Audit existing docs for staleness and gaps |
| `--coverage` | Report documentation coverage percentage |
| `--fix-links` | Find and fix broken documentation links |
| `--format <fmt>` | Output format: markdown, html, json (default: markdown) |

## HARD RULES

1. **Never generate documentation from function names alone.** Read the implementation body. `getUserById` might soft-delete check, cache-first, or throw specific errors. Describe actual behavior.
2. **Never document stale code.** Before writing docs for a function, verify it still exists and matches the current signature. `git log -1 -- <file>` to check recency.
3. **Never ship docs without a plain-text fallback.** Every HTML doc must have a Markdown or text equivalent. Screen readers, terminals, and search indexers depend on it.
4. **Never commit docs with broken internal links.** Grep for `](./` and `](#` references and verify each target exists before committing.
5. **Never include secrets, tokens, or real user data in documentation examples.** Use placeholder values like `sk-test-xxx`, `user@example.com`.

## Loop Protocol

```
documentation_queue = detect_doc_targets()  // list of modules/APIs/runbooks needing docs
current_iteration = 0

WHILE documentation_queue is not empty:
  batch = documentation_queue.take(5)
  current_iteration += 1

  FOR each target in batch:
    1. Read the source code for the target (function, endpoint, module)
    2. Read existing docs (if any) — check for staleness
    3. Generate or update documentation (JSDoc, docstring, OpenAPI, README section)
    4. Cross-reference links and examples against codebase
    5. IF stale or broken references found → fix or flag

  Log: "Iteration {current_iteration}: documented {batch.length} targets, {documentation_queue.remaining} remaining"

  IF documentation_queue is empty:
    Run full link-check and coverage report
    BREAK
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "api-docs":
  EnterWorktree("api-docs")
  Scan all route/controller/handler files
  Generate or update OpenAPI spec and endpoint docs
  Verify request/response schemas match code
  ExitWorktree()

Agent 2 — "code-docs":
  EnterWorktree("code-docs")
  Scan all public exports lacking JSDoc/docstrings
  Generate documentation from implementation + tests
  Add @example blocks from test fixtures
  ExitWorktree()

Agent 3 — "runbooks-and-readme":
  EnterWorktree("runbooks-and-readme")
  Generate/update README from package.json, config, entry points
  Create runbooks from CI/CD configs and deploy scripts
  Audit existing docs for broken links and staleness
  ExitWorktree()

MERGE: Combine all branches, resolve conflicts in shared files (README, index).
```

## Auto-Detection

```
AUTO-DETECT project documentation context:
  1. Grep for doc generation configs: .jsdoc.json, typedoc.json, mkdocs.yml, sphinx conf.py
  2. Check for existing OpenAPI/Swagger specs: openapi.yaml, swagger.json
  3. Scan package.json / pyproject.toml for doc scripts (docs:build, docs:generate)
  4. Count public exports vs documented exports → compute coverage percentage
  5. Check for .env.example → derive configuration documentation
  6. Detect framework:
     - JSDoc / TSDoc → TypeScript/JavaScript project
     - Sphinx / pydoc → Python project
     - godoc → Go project
     - Javadoc → Java project
  7. Check for docs/ directory structure → existing documentation conventions

  USE detected context to:
    - Match existing doc style and tooling
    - Prioritize undocumented public APIs
    - Skip already-documented items with recent modification dates
```

## Anti-Patterns

- **Do NOT write documentation without reading the code.** Generated docs that don't match the code are worse than no docs at all.
- **Do NOT document private internals extensively.** Focus on public APIs and interfaces. Internal code changes frequently; documenting it creates maintenance burden.
- **Do NOT copy function names as descriptions.** "`getUserById` — Gets a user by ID" adds zero value. Describe what it actually does: "`getUserById` — Fetches user profile from PostgreSQL, returns null if not found or if user is soft-deleted."
- **Do NOT skip error documentation.** Callers need to know what can go wrong. Document every thrown error and when it occurs.
- **Do NOT generate docs and forget.** Documentation rots faster than code. Use `--audit` regularly to catch staleness.
- **Do NOT write runbooks from memory.** Run the actual commands, verify they work, then document them. A runbook with a wrong command is dangerous.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run documentation tasks sequentially: API docs, then code docs, then runbooks/README.
- Use branch isolation per task: `git checkout -b godmode-docs-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
