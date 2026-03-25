---
name: onboard
description: Codebase onboarding and architecture walkthrough.
---

## Activate When
- `/godmode:onboard`, "explain this codebase"
- "architecture overview", "how does this work?"
- New team member needs project orientation

## Workflow

### 1. Project Discovery
```bash
ls package.json Cargo.toml go.mod pyproject.toml \
  pom.xml Gemfile *.csproj 2>/dev/null
find . -name "*.ts" -o -name "*.py" -o -name "*.go" \
  | grep -v node_modules | wc -l
git log --oneline -20
git log --since="30 days ago" --diff-filter=M \
  --pretty=format:"%h %s" | head -10
```
```
Name: <from manifest>
Type: web app|API|CLI|library|monorepo|microservice
Language: <primary>
Framework: <detected>
Build: <webpack|vite|tsc|make|cargo>
Tests: <jest|pytest|go test>
LOC: <approximate>
```

### 2. Architecture Walkthrough
```
Layer map:
| Layer | Responsibility |
| Routes | URL mapping, response formatting |
| Middleware | Auth, rate limiting, logging |
| Controllers | Validation, orchestration |
| Services | Business logic, domain rules |
| Repositories | Data access, caching |
| Models | Data shapes, relationships |

Data flow:
Client -> LB -> Middleware -> Router -> Controller
  -> Service -> Repository -> Database
```

### 3. Key Files (max 10)
```
Read in this order:
1. README.md — setup instructions
2. <entry-point> — bootstrap (main.ts, app.py)
3. <router> — all endpoints
4. <config> — environment, feature flags
5. <core-service> — main business logic
6. <data-model> — primary schema
7. <middleware> — request pipeline
8. <test-example> — testing patterns
```
IF README missing: note as gap, generate from code.
IF > 500 files: focus on 20 most-modified (git log).

### 4. Naming Conventions
```
Files: PascalCase (components), camelCase (utils)
Variables: camelCase locals, SCREAMING_SNAKE constants
Functions: camelCase, verb prefix (get, create, handle)
Types: PascalCase, I-prefix for interfaces (if TS)
Tests: <name>.test.ts / <name>.spec.ts
```

### 5. Dependency Graph
```
Internal: routes->controllers->services->repositories
  Shared: utils, config, logger, types
  Circular deps: <none | list with file paths>
External:
  Critical: <pkg — purpose>
  Dev-only: <pkg — purpose>
```

### 6. Code Tour (5+ stops)
```
Stop 1: Entry Point — where everything starts
Stop 2: Configuration — env handling
Stop 3: Core Route — a typical request lifecycle
Stop 4: Data Model — primary entities
Stop 5: Test File — testing patterns and conventions
```

### 7. Onboarding Report
```
Project: <type> with <framework>
Size: ~<N> files, ~<N>K lines
Architecture: <monolith|microservices|monorepo>
Pattern: <MVC|Clean|Hexagonal>
Key files: <N> identified
Setup: <N> steps to first run
```

## Hard Rules
1. NEVER claim architecture without reading code.
2. NEVER list > 10 key files (80/20 rule).
3. NEVER skip git history (most-modified files).
4. NEVER assume REST — detect actual protocol.
5. ALWAYS read README first if it exists.
6. ALWAYS identify entry point before anything else.
7. ALWAYS include test file in code tour.

## TSV Logging
Append `.godmode/onboard-results.tsv`:
```
timestamp	repo	files_analyzed	entry_points	status
```

## Keep/Discard
```
KEEP if: all claims verified against source code
  AND output populated with real data.
DISCARD if: unverified claims OR placeholder text.
```

## Stop Conditions
```
STOP when FIRST of:
  - Architecture identified + key files documented
  - Code tour has 5+ stops
  - Dev setup verified (build + test from clean)
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Build fails | Check system deps, env vars, platform |
| Architecture ambiguous | Check manifest, entry points, infra |
| Monorepo detected | Repeat architecture per workspace |
