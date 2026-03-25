---
name: docs
description: |
  Documentation generation and maintenance skill. Activates when the project needs API docs (OpenAPI/Swagger), code
    docs (JSDoc, docstrings), README generation, runbook creation, or documentation quality audits. Detects stale
    docs, missing coverage, and obsolescence. Triggers on: /godmode:docs, "generate docs", "update documentation",
    "write a README", "create runbook", or when shipping reveals undocumented public APIs.
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

```
Present inventory:
```
DOCUMENTATION INVENTORY:
  Documentation Status
| Category | Count | Coverage |
|--|--|--|
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
```

#### For Python (docstrings):
```python
def function_name(param: Type) -> ReturnType:
    """<Brief description derived from function name and body>.

    Args:
        param: <description from usage context>

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
|--|--|--|--|
| 1 | Stale: references removed API | HIGH | api.md:42 |
| 2 | Missing: no docs for /users | HIGH | (none) |
| 3 | Broken link: ./setup.md | MEDIUM | README:15 |
| 4 | Outdated example: uses v1 API | MEDIUM | guide.md:8 |
| 5 | Typo: "recieve" (x3) | LOW | multiple files |
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

Never ask to continue. Loop autonomously until done.

IF doc coverage < 80% of public API: prioritize undocumented exports.
WHEN doc modification date < code modification date: flag as stale.
IF broken links > 0: fix before committing.

1. **Derive, don't invent.** Read actual code, not guessing.
2. **Examples from tests.** Use real test cases as doc examples.
3. **Coverage over perfection.** 80% coverage beats 20% perfect.
4. **Detect staleness ruthlessly.** Wrong doc is worse than no doc.
5. **Match existing style.** JSDoc, NumPy-style, etc. No new conventions.
6. **Runbooks are commands, not prose.** Copy-pasteable commands + expected output.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive documentation generation |
| `--api` | Generate API documentation only (OpenAPI/Swagger) |
| `--code` | Generate code documentation only (JSDoc/docstrings) |

## HARD RULES

1. **Never generate documentation from function names alone.** Read the implementation body. `getUserById` can
soft-delete check, cache-first, or throw specific errors. Describe actual behavior.
2. **Never document stale code.** Before writing docs for a function, verify it still exists and matches the
current signature. `git log -1 -- <file>` to check recency.
3. **Never ship docs without a plain-text fallback.** Every HTML doc must have a Markdown or text equivalent.
Screen readers, terminals, and search indexers depend on it.
4. **Never commit docs with broken internal links.** Grep for `](./` and `](#` references and verify each
target exists before committing.
5. **Never include secrets, tokens, or real user data in documentation examples.** Use placeholder values like
`sk-test-xxx`, `user@example.com`.

## Auto-Detection
```
1. Scan for doc configs: .jsdoc.json, typedoc.json, mkdocs.yml, sphinx conf.py, openapi.yaml
2. Check package.json/pyproject.toml for doc scripts. Count documented vs undocumented exports.
3. Detect framework (JSDoc/TSDoc, Sphinx, godoc, Javadoc). Match existing style.
4. Prioritize undocumented public APIs. Skip recently documented items.
```

## Output Format

After each docs skill invocation, emit a structured report:

```
DOCUMENTATION REPORT:
| Doc type | <API | code | runbook | README> |
|--|--|--|--|--|
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
1. Every public function/endpoint has description, params, return type, error cases
2. Docs match actual code behavior (verified by reading source)
3. Code examples included and syntactically correct (copy-pasteable)
4. 0 stale docs (doc modified date >= code modified date)
5. 0 broken internal links
6. Runbooks contain exact commands verified to work

## Error Recovery
| Failure | Action |
|--|--|
| Docs don't match code | Read source, check git blame, update docs |
| Doc generation fails | Check comment syntax, tool version, run verbose |
| Broken links | Run markdown-link-check/linkinator, update refs |

## Keep/Discard Discipline
```
KEEP if: all links resolve AND doc matches code AND coverage increased
DISCARD if: broken links OR doc contradicts code OR describes deleted functions
```

## Stop Conditions
```
STOP when: all public APIs documented + 0 broken links + 0 stale docs.
Guard: link-check passes. On failure: git reset --hard HEAD~1.
```

