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

# ... (condensed)
```

Present inventory:
```
DOCUMENTATION INVENTORY:
  Documentation Status
| Category | Count | Coverage |
|---|---|---|
| README files | 3 | root, api, shared |
| API docs | 1 | OpenAPI 3.0 (partial) |
| Code docs | 47/120 | 39% of public exports |
| Runbooks | 0 | None |
| Architecture docs | 2 | ADRs only |
| Guides | 1 | Getting started |
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
# ... (condensed)
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
# ... (condensed)
```

#### For Python (docstrings):
```python
def function_name(param: Type) -> ReturnType:
    """<Brief description derived from function name and body>.

    Args:
        param: <description from usage context>

# ... (condensed)
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
  Documentation Health Report
| # | Issue | Severity | File |
|---|---|---|---|
| 1 | Stale: references removed API | HIGH | api.md:42 |
| 2 | Missing: no docs for /users | HIGH | (none) |
| 3 | Broken link: ./setup.md | MEDIUM | README:15 |
| 4 | Outdated example: uses v1 API | MEDIUM | guide.md:8 |
| 5 | Typo: "recieve" (x3) | LOW | various |
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
6. **Runbooks are commands, not prose.** Write every runbook step as a copy-pasteable command with expected output. Narrative text belongs in guides, not runbooks.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive documentation generation |
| `--api` | Generate API documentation only (OpenAPI/Swagger) |
| `--code` | Generate code documentation only (JSDoc/docstrings) |

## HARD RULES

1. **Never generate documentation from function names alone.** Read the implementation body. `getUserById` can soft-delete check, cache-first, or throw specific errors. Describe actual behavior.
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
| Doc type | <API | code | runbook | README> |
|---|---|---|---|---|
| Files documented | <N> |
| Functions/endpoints | <N> documented / <N> total |
| Coverage | <N>% of public API documented |
| Stale docs found | <N> (modified code, unchanged docs) |
| Links validated | <N> valid / <N> broken |
| Examples included | <N> code examples |
| Verdict | PASS | NEEDS REVISION |
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
3. Every throwable error is documented with its condition
4. Code examples are included and syntactically correct (copy-pasteable)
5. No stale documentation (docs last modified before code was last modified)
6. All internal links resolve (no broken cross-references)
7. Runbooks (if any) contain exact commands verified to work

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
```

## Keep/Discard Discipline
```
After EACH documentation batch:
  1. MEASURE: Run link check — are all internal references valid? Does doc match current code?
  2. COMPARE: Did coverage increase? Are stale docs reduced?
  3. DECIDE:
     - KEEP if: all links resolve AND doc matches current code behavior AND coverage increased
     - DISCARD if: broken links OR doc contradicts code OR describes deleted functions
  4. COMMIT kept changes. Fix discarded docs before the next batch.

Never merge documentation that references functions or endpoints that no longer exist.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All public functions/endpoints have descriptions, parameters, and error cases
  - Zero broken internal links
  - No stale docs (doc modification date >= code modification date)
  - User explicitly requests stop

DO NOT STOP just because:
  - Private/internal functions lack docs (public API is the priority)
  - Runbooks are not yet created (code docs come first)
```

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
```

