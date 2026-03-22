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

## Output Format

After each docs skill invocation, emit a structured report:

```
DOCUMENTATION REPORT:
┌──────────────────────────────────────────────────────┐
│  Doc type            │  <API | code | runbook | README>│
│  Files documented    │  <N>                            │
│  Functions/endpoints │  <N> documented / <N> total     │
│  Coverage            │  <N>% of public API documented  │
│  Stale docs found    │  <N> (modified code, unchanged docs) │
│  Links validated     │  <N> valid / <N> broken         │
│  Examples included   │  <N> code examples              │
│  Verdict             │  PASS | NEEDS REVISION          │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every documentation action for tracking:

```
timestamp	skill	target	action	coverage_pct	stale_count	status
2026-03-20T14:00:00Z	docs	src/api/	api_docs	85	3	needs_update
2026-03-20T14:10:00Z	docs	runbooks/	runbook_create	100	0	pass
```

## Success Criteria

The docs skill is complete when ALL of the following are true:
1. Every public function/method/endpoint has a description, parameters, return type, and error cases
2. Documentation matches the actual code behavior (verified by reading the source)
3. Every error that can be thrown is documented with its condition
4. Code examples are included and syntactically correct (copy-pasteable)
5. No stale documentation (docs last modified before code was last modified)
6. All internal links resolve (no broken cross-references)
7. Runbooks (if any) contain exact commands that have been verified to work

## Error Recovery

```
IF documentation does not match code behavior:
  1. Read the actual source code (never document from memory or assumptions)
  2. Run the function/endpoint to verify behavior before documenting
  3. Check git blame to see if the code changed after docs were written
  4. Update the documentation to match current behavior, not intended behavior

IF doc generation tool fails:
  1. Check for syntax errors in doc comments (JSDoc, docstrings, godoc)
  2. Verify the doc tool version is compatible with the project's language version
  3. Run the tool in verbose mode to identify the failing file
  4. Fix the source comment and re-run

IF links in documentation are broken:
  1. Use a link checker tool (markdown-link-check, linkinator)
  2. Update moved references to their new locations
  3. Remove references to deleted files/sections
  4. Add a CI check to catch broken links on every PR

IF runbook commands fail:
  1. Run every command in the runbook on a clean environment to verify
  2. Check for environment-specific dependencies (PATH, env vars, permissions)
  3. Add prerequisite checks to the runbook ("Before running, verify X is installed")
  4. Never publish a runbook without executing every command in it
```

## Anti-Patterns

- **Do NOT write documentation without reading the code.** Generated docs that don't match the code are worse than no docs at all.
- **Do NOT document private internals extensively.** Focus on public APIs and interfaces. Internal code changes frequently; documenting it creates maintenance burden.
- **Do NOT copy function names as descriptions.** "`getUserById` — Gets a user by ID" adds zero value. Describe what it actually does: "`getUserById` — Fetches user profile from PostgreSQL, returns null if not found or if user is soft-deleted."
- **Do NOT skip error documentation.** Callers need to know what can go wrong. Document every thrown error and when it occurs.
- **Do NOT generate docs and forget.** Documentation rots faster than code. Use `--audit` regularly to catch staleness.
- **Do NOT write runbooks from memory.** Run the actual commands, verify they work, then document them. A runbook with a wrong command is dangerous.


## Documentation Audit Loop

Systematic protocol for scoring documentation coverage, detecting staleness, and validating API docs:

```
DOCUMENTATION AUDIT LOOP:
current_iteration = 0
max_iterations = 5
audit_phases = [coverage_scoring, stale_detection, api_doc_validation, link_integrity, freshness_enforcement]

WHILE current_iteration < max_iterations:
  phase = audit_phases[current_iteration]
  current_iteration += 1

  IF phase == "coverage_scoring":
    1. INVENTORY all documentable targets:
       public_functions = count exported/public functions across all source files
       public_types = count exported types/interfaces/classes
       api_endpoints = count route definitions (REST, GraphQL, gRPC)
       config_vars = count environment variables / config keys
       modules = count top-level source directories or packages

    2. MEASURE documentation coverage for each category:
       FOR each category in [functions, types, endpoints, config, modules]:
         documented = count items with JSDoc/docstring/OpenAPI entry
         total = count total items
         coverage_pct = (documented / total) * 100

    3. SCORE with letter grades:
       A: >= 90% coverage
       B: 70-89% coverage
       C: 50-69% coverage
       D: 30-49% coverage
       F: < 30% coverage

    4. REPORT:
       DOCUMENTATION COVERAGE SCORECARD:
       ┌────────────────────┬──────────┬───────────┬───────┐
       │  Category          │ Covered  │ Total     │ Grade │
       ├────────────────────┼──────────┼───────────┼───────┤
       │  Public functions  │  47      │  120      │  D    │
       │  Public types      │  18      │  32       │  C    │
       │  API endpoints     │  12      │  14       │  B    │
       │  Config variables  │  3       │  22       │  F    │
       │  Module READMEs    │  2       │  8        │  D    │
       ├────────────────────┼──────────┼───────────┼───────┤
       │  Overall           │  82      │  196      │  D    │
       └────────────────────┴──────────┴───────────┴───────┘

    5. PRIORITIZE gaps (highest impact first):
       - Undocumented public API endpoints (external consumers depend on these)
       - Undocumented configuration variables (setup blockers)
       - Undocumented public functions with >5 callers (high fan-in)
       - Undocumented types used in API request/response (contract clarity)

  IF phase == "stale_detection":
    1. FOR each documented item, compare modification dates:
       doc_modified = git log -1 --format="%aI" -- {doc_file}
       code_modified = git log -1 --format="%aI" -- {code_file}

       IF code_modified > doc_modified:
         staleness_days = (code_modified - doc_modified).days
         stale_items.append({ doc_file, code_file, staleness_days })

    2. FOR each doc file, check for references to deleted code:
       - Extract function/class/endpoint names referenced in docs
       - Cross-reference against actual codebase symbols
       - Flag any reference that no longer exists as ORPHAN

    3. FOR each doc file, check for outdated signatures:
       - Extract parameter lists and return types from docs
       - Compare against actual function signatures in code
       - Flag mismatches as SIGNATURE_DRIFT

    4. SCORE staleness:
       stale_docs = count(doc_modified < code_modified by >7 days)
       orphan_refs = count(references to deleted code)
       signature_drifts = count(mismatched parameter/return docs)

    5. REPORT:
       STALENESS REPORT:
       ┌─────────────────────────────────────────────────────┐
       │  Stale docs (code changed, docs not):  <N>          │
       │  Orphan references (deleted code):     <N>          │
       │  Signature drifts (params changed):    <N>          │
       │  Freshest doc:  <file> (<N> days ago)               │
       │  Stalest doc:   <file> (<N> days ago)               │
       │  Average doc age vs code age:  <N> days behind      │
       └─────────────────────────────────────────────────────┘

  IF phase == "api_doc_validation":
    1. DETECT API documentation format:
       - OpenAPI/Swagger: openapi.yaml, openapi.json, swagger.*
       - GraphQL schema: schema.graphql, *.graphqls
       - Postman collection: *.postman_collection.json
       - Custom markdown: docs/api/*.md

    2. VALIDATE API docs against actual implementation:
       FOR each documented endpoint:
         a. VERIFY route exists in code (path + method match)
         b. VERIFY request parameters match actual handler params
         c. VERIFY response schema matches actual response shape
         d. VERIFY authentication requirements match middleware chain
         e. VERIFY documented error responses match actual error handling
         f. VERIFY examples are valid (parseable JSON, correct field names)

    3. DETECT undocumented endpoints:
       - Scan all route definitions in code
       - Cross-reference against API docs
       - Flag any endpoint with no documentation

    4. VALIDATE OpenAPI spec (if exists):
       - Schema validates against OpenAPI 3.x specification
       - All $ref references resolve
       - All examples validate against their schemas
       - No unused schema definitions

    5. REPORT:
       API DOC VALIDATION:
       ┌─────────────────────────────────────────────────────┐
       │  Documented endpoints:     <N> / <N total>          │
       │  Route matches:            <N> / <N> correct        │
       │  Parameter matches:        <N> / <N> correct        │
       │  Response schema matches:  <N> / <N> correct        │
       │  Auth doc matches:         <N> / <N> correct        │
       │  Valid examples:           <N> / <N>                │
       │  Spec validation:          PASS / FAIL (<errors>)   │
       │  Undocumented endpoints:   <N> (list)               │
       └─────────────────────────────────────────────────────┘

  IF phase == "link_integrity":
    1. SCAN all documentation files for internal links:
       - Markdown links: [text](./path) and [text](#anchor)
       - Image references: ![alt](./image.png)
       - Code references: `path/to/file.ts` or backtick code refs

    2. VERIFY each link target exists:
       FOR each link in all_links:
         IF link is file reference: test -f {resolved_path}
         IF link is anchor reference: grep -q "^#{anchor}" {file}
         IF link is URL: skip (external link checking is optional)

    3. REPORT:
       LINK INTEGRITY:
       - Total internal links: <N>
       - Valid links: <N>
       - Broken links: <N>
         - {file}:{line} → {broken_target} (MISSING)
         - {file}:{line} → {broken_target} (MOVED to {new_path})

  IF phase == "freshness_enforcement":
    1. DEFINE freshness policy:
       - API docs: must be updated within 7 days of endpoint changes
       - README: must be updated within 14 days of major feature changes
       - Code docs (JSDoc/docstrings): must match current function signature
       - Runbooks: must be reviewed quarterly (90 days)
       - Architecture docs (ADRs): no staleness requirement (historical)

    2. CHECK each doc against policy:
       FOR each doc_file:
         last_updated = git log -1 --format="%aI" -- {doc_file}
         related_code_files = find code files referenced by this doc
         latest_code_change = max(git log -1 --format="%aI" -- {f} for f in related_code_files)
         freshness_gap = latest_code_change - last_updated

         IF freshness_gap > policy_threshold:
           violations.append({ doc_file, gap_days, policy_threshold })

    3. GENERATE freshness report with actionable items:
       FRESHNESS VIOLATIONS:
       ┌──────────────────────┬──────────┬────────────┬───────────┐
       │  Doc File            │ Gap      │ Policy     │ Priority  │
       ├──────────────────────┼──────────┼────────────┼───────────┤
       │  docs/api/users.md   │ 23 days  │ 7 days     │ HIGH      │
       │  README.md           │ 18 days  │ 14 days    │ MEDIUM    │
       │  runbooks/deploy.md  │ 112 days │ 90 days    │ HIGH      │
       └──────────────────────┴──────────┴────────────┴───────────┘

  REPORT: "Phase {current_iteration}/{max_iterations}: {phase} — {PASS | NEEDS ATTENTION}"

FINAL DOCUMENTATION HEALTH:
┌──────────────────────────────────────────────────────────┐
│  DOCUMENTATION AUDIT SUMMARY                              │
├──────────────────────┬────────┬───────────────────────────┤
│  Phase               │ Grade  │ Action Items               │
├──────────────────────┼────────┼───────────────────────────┤
│  Coverage scoring    │  <A-F> │  <N> items to document     │
│  Stale detection     │  <A-F> │  <N> docs to update        │
│  API doc validation  │  <A-F> │  <N> endpoints to fix      │
│  Link integrity      │  <A-F> │  <N> broken links          │
│  Freshness           │  <A-F> │  <N> violations            │
├──────────────────────┼────────┼───────────────────────────┤
│  Overall             │  <A-F> │  <priority action>         │
└──────────────────────┴────────┴───────────────────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run documentation tasks sequentially: API docs, then code docs, then runbooks/README.
- Use branch isolation per task: `git checkout -b godmode-docs-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
