---
name: onboard
description: |
  Codebase onboarding skill. Activates when user needs to understand a new codebase, generate architecture walkthroughs, analyze naming conventions, visualize dependency graphs, or create code tours. Produces structured documentation that accelerates developer ramp-up. Triggers on: /godmode:onboard, "explain this codebase", "architecture walkthrough", "how does this project work", or when a new contributor needs orientation.
---

# Onboard — Codebase Onboarding

## When to Activate
- User invokes `/godmode:onboard`
- User says "explain this codebase", "how does this work?", "architecture overview"
- New team member needs to understand the project structure
- User asks "what are the key files?" or "walk me through this"
- User wants dependency graph or naming convention analysis
- Before starting work on an unfamiliar codebase

## Workflow

### Step 1: Project Discovery
Automatically scan the project to understand its nature:

```bash
# Identify project type
ls package.json Cargo.toml go.mod pyproject.toml pom.xml Gemfile *.csproj 2>/dev/null

# Count files by language
find . -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" | grep -v node_modules | grep -v .git | head -200

# Find entry points
find . -name "main.*" -o -name "index.*" -o -name "app.*" -o -name "server.*" | grep -v node_modules | grep -v .git

# Find configuration
find . -name "*.config.*" -o -name "*.yml" -o -name "*.yaml" -o -name "Dockerfile" -o -name "docker-compose*" | grep -v node_modules | grep -v .git

# Understand project structure
ls -la
ls -la src/ 2>/dev/null || ls -la lib/ 2>/dev/null || ls -la app/ 2>/dev/null
```

```
PROJECT PROFILE:
Name: <from package.json / go.mod / etc.>
Type: <web app | API | CLI | library | monorepo | microservice>
Primary language: <TypeScript | Python | Go | Rust | Java | etc.>
Framework: <Next.js | Express | Django | FastAPI | Gin | etc.>
Package manager: <npm | yarn | pnpm | pip | cargo | go mod | etc.>
Build system: <webpack | vite | tsc | make | cargo | etc.>
Test framework: <jest | pytest | go test | etc.>
Lines of code: <approximate>
Contributors: <from git log>
Last activity: <from git log>
```

### Step 2: Architecture Walkthrough
Generate a structured understanding of how the system is organized:

#### Directory Map
```
PROJECT ARCHITECTURE:
<project-name>/
├── src/                    # Application source code
│   ├── api/                # API route handlers — entry points for HTTP requests
│   │   ├── routes/         # Route definitions (URL → handler mapping)
│   │   └── middleware/     # Request processing pipeline (auth, logging, etc.)
│   ├── services/           # Business logic layer — core domain operations
│   ├── models/             # Data models and database schemas
│   ├── utils/              # Shared utilities and helper functions
│   └── config/             # Application configuration
├── tests/                  # Test files mirroring src/ structure
├── docs/                   # Documentation
├── scripts/                # Build, deploy, and maintenance scripts
└── infrastructure/         # IaC, Docker, CI/CD configs
```

#### Data Flow Diagram
```
REQUEST LIFECYCLE:
Client → [Load Balancer] → [Middleware Pipeline] → [Router]
                                                      │
                                    ┌─────────────────┼─────────────────┐
                                    ▼                 ▼                 ▼
                              [Controller A]    [Controller B]    [Controller C]
                                    │                 │                 │
                                    ▼                 ▼                 ▼
                              [Service A]       [Service B]       [Service C]
                                    │                 │                 │
                                    ▼                 ▼                 ▼
                              [Repository]      [Repository]      [Cache]
                                    │                 │                 │
                                    ▼                 ▼                 ▼
                              [Database]        [Database]        [Redis]
```

#### Layer Responsibilities
```
LAYER MAP:
┌─────────────┬──────────────────────────────────────────────────────────┐
│ Layer       │ Responsibility                                          │
├─────────────┼──────────────────────────────────────────────────────────┤
│ Routes      │ URL mapping, request parsing, response formatting       │
│ Middleware  │ Auth, rate limiting, logging, error handling             │
│ Controllers │ Request validation, orchestration, response shaping     │
│ Services    │ Business logic, domain rules, cross-service coordination│
│ Repositories│ Data access, queries, caching strategy                  │
│ Models      │ Data shapes, validation rules, relationships            │
│ Utils       │ Pure helper functions, shared across layers             │
└─────────────┴──────────────────────────────────────────────────────────┘
```

### Step 3: Key File Identification
Identify the most important files a new developer should read first:

```
KEY FILES (read in this order):
1. README.md — Project overview and setup instructions
2. <entry-point> — Application bootstrap (main.ts, app.py, main.go)
3. <router/routes> — All available endpoints/commands
4. <config> — Environment and feature configuration
5. <core-service> — Most important business logic file
6. <data-model> — Primary data structures/schemas
7. <middleware> — Request processing pipeline
8. <test-example> — Best example test file (shows testing patterns)

MOST MODIFIED FILES (from git history — where active development happens):
1. <file> — <N> commits in last 30 days — <what it does>
2. <file> — <N> commits in last 30 days — <what it does>
3. <file> — <N> commits in last 30 days — <what it does>

LARGEST FILES (potential complexity hotspots):
1. <file> — <N> lines — <what it does>
2. <file> — <N> lines — <what it does>
3. <file> — <N> lines — <what it does>
```

### Step 4: Naming Convention Analysis
Document the patterns used throughout the codebase:

```
NAMING CONVENTIONS:
Files:
  - Components: PascalCase (UserProfile.tsx)
  - Utilities: camelCase (formatDate.ts)
  - Constants: SCREAMING_SNAKE (API_ENDPOINTS.ts)
  - Tests: <name>.test.ts / <name>.spec.ts
  - Styles: <name>.module.css / <name>.styles.ts

Variables:
  - Local: camelCase (userName, isActive)
  - Constants: SCREAMING_SNAKE (MAX_RETRIES, DEFAULT_TIMEOUT)
  - Private: _prefixed or #private (_internalState)
  - Boolean: is/has/should prefix (isReady, hasPermission)

Functions:
  - Actions: verb-first (createUser, validateInput, fetchData)
  - Handlers: handle-prefix (handleSubmit, handleError)
  - Getters: get-prefix (getUserById, getConfig)
  - Predicates: is/has/can (isValid, hasAccess, canDelete)

Types/Interfaces:
  - Types: PascalCase (UserProfile, ApiResponse)
  - Interfaces: PascalCase, no I-prefix (User not IUser)
  - Enums: PascalCase with PascalCase members (Status.Active)
  - Generics: single uppercase (T, K, V) or descriptive (TResult)

API Endpoints:
  - Style: <REST | RPC | GraphQL | mixed>
  - Pattern: <kebab-case | camelCase | snake_case>
  - Versioning: <URL path /v1/ | header | query param | none>
  - Example: GET /api/v1/user-profiles/:id

Database:
  - Tables: <snake_case | PascalCase | plural | singular>
  - Columns: <snake_case | camelCase>
  - Foreign keys: <table_id pattern>
  - Indexes: <naming pattern>
```

### Step 5: Dependency Graph
Visualize internal and external dependencies:

#### Internal Module Dependencies
```
MODULE DEPENDENCY GRAPH:
┌─────────────────────────────────────────────────────────┐
│  Arrows show "depends on" relationships                 │
│                                                         │
│  routes ──→ controllers ──→ services ──→ repositories   │
│    │              │             │              │         │
│    ▼              ▼             ▼              ▼         │
│  middleware     validators    models        database     │
│    │                            │                        │
│    ▼                            ▼                        │
│  auth-service               migrations                  │
│                                                         │
│  Shared by all: utils, config, logger, types            │
└─────────────────────────────────────────────────────────┘

CIRCULAR DEPENDENCIES: <none | list>
HIGH FAN-OUT (depends on many): <file> imports <N> modules
HIGH FAN-IN (many depend on): <file> imported by <N> modules
```

#### External Dependencies
```
EXTERNAL DEPENDENCIES:
Critical (app won't work without):
  - <package> v<version> — <what it's used for>
  - <package> v<version> — <what it's used for>

Important (significant functionality):
  - <package> v<version> — <what it's used for>
  - <package> v<version> — <what it's used for>

Dev-only:
  - <package> v<version> — <testing/building/linting>

Outdated (update recommended):
  - <package> v<current> → v<latest> — <breaking changes? Y/N>

Vulnerable (security advisory):
  - <package> v<version> — <CVE/advisory>
```

### Step 6: Code Tour Generation
Create a guided tour through the codebase for new developers:

```
CODE TOUR: <project-name>
Duration: ~<N> minutes reading time

Stop 1: Entry Point (<file>)
  What: Application bootstrap — where everything starts
  Key lines: <start>-<end>
  Note: <important detail about initialization order, config loading, etc.>

Stop 2: Configuration (<file>)
  What: How the app reads and validates its configuration
  Key lines: <start>-<end>
  Note: <environment handling, defaults, validation>

Stop 3: Routing (<file>)
  What: How requests are mapped to handlers
  Key lines: <start>-<end>
  Note: <middleware chain, auth requirements, versioning>

Stop 4: Core Business Logic (<file>)
  What: The most important domain logic
  Key lines: <start>-<end>
  Note: <key algorithms, business rules, domain concepts>

Stop 5: Data Layer (<file>)
  What: How data is stored and retrieved
  Key lines: <start>-<end>
  Note: <ORM usage, query patterns, migration strategy>

Stop 6: Error Handling (<file>)
  What: How errors propagate and are reported
  Key lines: <start>-<end>
  Note: <error types, logging, user-facing messages>

Stop 7: Testing Pattern (<file>)
  What: Example of a well-written test in this project
  Key lines: <start>-<end>
  Note: <test structure, mocking approach, fixtures>
```

### Step 7: Generate Onboarding Report

```
┌────────────────────────────────────────────────────────────┐
│  CODEBASE ONBOARDING — <project-name>                     │
├────────────────────────────────────────────────────────────┤
│  Project: <type> built with <framework>                    │
│  Language: <primary> (+<secondary>)                        │
│  Size: ~<N> files, ~<N>K lines                             │
│                                                            │
│  Architecture: <monolith | microservices | serverless>     │
│  Pattern: <MVC | Clean Architecture | Hexagonal | etc.>    │
│  Data: <PostgreSQL | MongoDB | etc.> via <ORM/driver>      │
│                                                            │
│  Key files to read first:                                  │
│  1. <file> — <why>                                         │
│  2. <file> — <why>                                         │
│  3. <file> — <why>                                         │
│                                                            │
│  Code tour: <N> stops, ~<M> min reading time               │
│  Dependencies: <N> runtime, <M> dev                        │
│  Naming: <convention summary>                              │
│                                                            │
│  HEALTH SIGNALS:                                           │
│  Test coverage: <X>%                                       │
│  Last commit: <date>                                       │
│  Open issues: <N>                                          │
│  Outdated deps: <N>                                        │
│  Circular deps: <N>                                        │
└────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Save onboarding report as `docs/onboarding/<project>-onboarding.md`
2. Save code tour as `docs/onboarding/<project>-code-tour.md`
3. Commit: `"onboard: <project> — architecture walkthrough with <N>-stop code tour"`
4. Suggest: "Onboarding complete. Start with the code tour, then try `/godmode:think` to design your first feature."

## Key Behaviors

1. **Read before writing.** Scan the entire project structure before making any claims about architecture. Don't guess — verify.
2. **Follow the data.** The best way to understand a system is to trace a request from entry to response. Follow the data flow.
3. **Git history tells the story.** The most-modified files are where active development happens. Recent commits reveal current priorities.
4. **Naming conventions are tribal knowledge.** Document them explicitly so new developers don't have to guess.
5. **Dependencies reveal architecture.** The import graph shows how modules relate. Circular dependencies indicate design problems.
6. **Key files first.** A new developer shouldn't need to read 500 files. Identify the 7-10 files that explain 80% of the system.
7. **Code tours beat documentation.** Walking through actual code with commentary is more useful than abstract architecture docs.

## Example Usage

### Onboarding to a new project
```
User: /godmode:onboard Walk me through this codebase

Onboard: Scanning project...

PROJECT PROFILE:
Name: acme-api
Type: REST API
Language: TypeScript
Framework: Express + Prisma
Size: 247 files, ~18K lines
Last commit: 2 hours ago

Architecture: Clean Architecture (controllers → services → repositories)
Data: PostgreSQL via Prisma ORM

KEY FILES (read in this order):
1. src/server.ts — Express app bootstrap, middleware chain
2. src/routes/index.ts — All 23 endpoints mapped
3. src/services/order.service.ts — Core business logic (most complex)
4. prisma/schema.prisma — 12 data models, relationships
5. src/middleware/auth.ts — JWT validation, role checking

CODE TOUR: 7 stops, ~25 min reading time
Starting tour...
```

### Quick architecture check
```
User: /godmode:onboard --quick Just the architecture overview

Onboard: Quick scan...

Express API with Clean Architecture:
  routes/ → controllers/ → services/ → repositories/ → Prisma → PostgreSQL

Key patterns: dependency injection, repository pattern, middleware chain
Entry point: src/server.ts
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full onboarding — architecture, key files, code tour, dependencies |
| `--quick` | Quick architecture overview only |
| `--tour` | Generate code tour only |
| `--deps` | Dependency graph and analysis only |
| `--naming` | Naming convention analysis only |
| `--files` | Key file identification only |
| `--health` | Project health signals only |

## HARD RULES

1. **NEVER make architectural claims without reading the actual code.** Directory names lie. Read the files.
2. **NEVER list more than 10 key files.** The goal is 10-20% of files that explain 80% of the system. More than 10 means you have not prioritized.
3. **NEVER skip the git history.** `git log --oneline -20` and `git log --since="30 days ago" --pretty=format:"%h %s" --diff-filter=M` are mandatory steps.
4. **NEVER generate onboarding docs without verifying claims against source code.** Every file path, function name, and architectural statement must be confirmed.
5. **NEVER assume REST.** Detect the actual protocol: REST, GraphQL, gRPC, WebSocket, CLI, event-driven. Read the router/handler code.
6. **ALWAYS read the README first if it exists.** It sets context even if outdated.
7. **ALWAYS identify the entry point before anything else.** The entry point is the root of understanding.
8. **ALWAYS include the test file in the code tour.** Tests document expected behavior better than comments.

## Auto-Detection

Before starting onboarding, automatically detect the project context:

```
AUTO-DETECT SEQUENCE:
1. Project type detection:
   - ls package.json → Node.js/TypeScript
   - ls Cargo.toml → Rust
   - ls go.mod → Go
   - ls pyproject.toml / setup.py / requirements.txt → Python
   - ls pom.xml / build.gradle → Java/Kotlin
   - ls Gemfile → Ruby
   - ls *.csproj / *.sln → C#/.NET

2. Framework detection:
   - grep "next" package.json → Next.js
   - grep "express" package.json → Express
   - grep "fastapi\|flask\|django" requirements.txt → Python web
   - grep "gin\|echo\|fiber" go.mod → Go web
   - grep "actix\|axum\|rocket" Cargo.toml → Rust web

3. Architecture detection:
   - ls src/api/ src/services/ src/models/ → layered/clean architecture
   - ls apps/ packages/ → monorepo
   - ls cmd/ internal/ pkg/ → Go standard layout
   - ls docker-compose* → multi-service
   - ls serverless* / template.yaml → serverless

4. Populate PROJECT PROFILE automatically from detection results.
```

## Explicit Loop Protocol

Onboarding involves iterative exploration -- each pass deepens understanding:

```
current_iteration = 0
onboard_steps = [discovery, architecture, key_files, naming, dependencies, code_tour, report]

WHILE onboard_steps is not empty AND current_iteration < 7:
    current_iteration += 1
    step = onboard_steps.pop(0)

    1. EXECUTE step (scan, analyze, document)
    2. VERIFY output is populated (no "<placeholder>" left)
    3. IF step produced unexpected findings (e.g., monorepo detected):
        ADJUST remaining steps (e.g., repeat architecture per workspace)
    4. REPORT: "Step {step}: DONE -- iteration {current_iteration}/7"

OUTPUT: Onboarding report with all sections populated from verified data.
```

## Multi-Agent Dispatch

For large monorepos or multi-service projects, dispatch parallel agents:

```
MULTI-AGENT ONBOARDING:
Dispatch 2-4 agents in parallel worktrees for monorepo/multi-service projects.

Agent 1 (worktree: onboard-frontend):
  - Scan frontend app structure, routing, state management
  - Identify key components and data flow
  - Document frontend-specific conventions

Agent 2 (worktree: onboard-backend):
  - Scan API routes, services, data models
  - Map database schema and ORM usage
  - Document backend-specific patterns

Agent 3 (worktree: onboard-infra):
  - Analyze CI/CD, Docker, Kubernetes, IaC
  - Map deployment topology
  - Document infrastructure conventions

Agent 4 (worktree: onboard-shared):
  - Analyze shared libraries, types, configs
  - Map cross-service dependencies
  - Document API contracts between services

MERGE: Combine into single onboarding report ordered by reading priority.
CONFLICT ZONES: None (read-only operation, separate documentation sections).
```

## Output Format

After each onboarding skill invocation, emit a structured report:

```
ONBOARDING REPORT:
┌──────────────────────────────────────────────────────┐
│  Repository          │  <name>                        │
│  Languages           │  <list>                        │
│  Framework           │  <detected framework>          │
│  Architecture        │  <monolith | microservices | monorepo> │
│  Key files analyzed  │  <N>                           │
│  Entry points found  │  <N>                           │
│  Dependencies        │  <N> production / <N> dev      │
│  Test coverage       │  <N>% (detected)               │
│  Dev setup steps     │  <N> steps documented          │
│  Time to first run   │  ~<N> minutes                  │
│  Verdict             │  COMPLETE | NEEDS INVESTIGATION │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every onboarding analysis for tracking:

```
timestamp	skill	repo	files_analyzed	entry_points	setup_steps	status
2026-03-20T14:00:00Z	onboard	my-app	45	3	7	complete
```

## Success Criteria

The onboard skill is complete when ALL of the following are true:
1. Architecture is identified (monolith, microservices, monorepo, or hybrid)
2. All entry points are documented (main files, API routes, CLI commands)
3. Development setup instructions are verified (run from clean checkout to working dev server)
4. Key abstractions and patterns are identified (ORM, state management, auth, etc.)
5. Hot files are identified (most frequently modified, highest impact)
6. Test strategy is documented (how to run tests, what framework, current coverage)
7. Deployment process is documented (how code gets to production)
8. The report is actionable for a new developer joining the team

## Error Recovery

```
IF project fails to build from documented setup steps:
  1. Check for missing system dependencies (database, runtime version, native libraries)
  2. Verify environment variables are documented (check .env.example or config)
  3. Check for platform-specific issues (macOS vs Linux, ARM vs x86)
  4. Update the setup steps to include the fix

IF architecture is ambiguous:
  1. Check package.json/go.mod/pyproject.toml for framework clues
  2. Look at the entry point files (main.ts, app.py, cmd/main.go)
  3. Check for infrastructure configs (Dockerfile, docker-compose, k8s manifests)
  4. Ask the user if detection is still ambiguous after code analysis

IF test suite fails on clean checkout:
  1. Check for required test databases or services (docker-compose for test deps)
  2. Verify test environment variables are set
  3. Check for flaky tests (run twice to detect intermittent failures)
  4. Document the test requirements in the onboarding report

IF repository is too large to analyze fully:
  1. Focus on the top 20 most-modified files (git log --format="%s" --name-only)
  2. Analyze entry points and their immediate dependencies only
  3. Use directory-level analysis instead of file-level for large monorepos
  4. Document the scope of analysis and recommend further investigation areas
```

## Anti-Patterns

- **Do NOT assume architecture from directory names.** A folder called "services" might contain anything. Read the files.
- **Do NOT skip the git history.** File creation dates, modification frequency, and commit patterns reveal what matters.
- **Do NOT list every file.** The goal is to identify the 10-20% of files that explain 80% of the system. Be selective.
- **Do NOT ignore test files.** Tests document expected behavior. A good test file is often the best documentation.
- **Do NOT generate documentation without reading code.** Every claim in the onboarding report must be verified against actual source code.
- **Do NOT assume REST.** The project might use GraphQL, gRPC, WebSockets, or CLI patterns. Detect, don't assume.


## Onboarding Audit Loop

Systematic protocol for measuring and improving the onboarding experience with quantitative metrics:

```
ONBOARDING AUDIT LOOP:
current_iteration = 0
max_iterations = 5
audit_phases = [time_to_first_commit, setup_script_validation, knowledge_gap_detection, ramp_up_curve, onboarding_doc_completeness]

WHILE current_iteration < max_iterations:
  phase = audit_phases[current_iteration]
  current_iteration += 1

  IF phase == "time_to_first_commit":
    1. MEASURE time-to-first-commit (TTFC) by simulating a clean onboarding:
       START_TIME = now()

       a. Clone the repository (fresh, no caches):
          git clone {repo_url} /tmp/godmode-onboard-test
          CHECKPOINT: clone_time = elapsed()

       b. Install dependencies:
          Run detected install command (npm ci, pip install, cargo build, etc.)
          CHECKPOINT: install_time = elapsed()

       c. Run the application:
          Run detected start/dev command
          Wait for "ready" signal (listening on port, "compiled successfully", etc.)
          CHECKPOINT: run_time = elapsed()

       d. Run tests:
          Run detected test command
          CHECKPOINT: test_time = elapsed()

       e. Make a trivial change and commit:
          Edit a comment in a source file
          Run lint + test to verify nothing broke
          git commit
          CHECKPOINT: first_commit_time = elapsed()

       TOTAL_TTFC = first_commit_time

    2. SCORE TTFC:
       Excellent: < 15 minutes
       Good:      15-30 minutes
       Fair:      30-60 minutes
       Poor:      1-2 hours
       Failing:   > 2 hours

    3. IDENTIFY bottlenecks:
       ┌────────────────────┬───────────┬───────────────────────┐
       │  Step              │  Duration │  Bottleneck?           │
       ├────────────────────┼───────────┼───────────────────────┤
       │  Clone             │  <N>s     │  Large repo? LFS?      │
       │  Install deps      │  <N>s     │  Many deps? No cache?  │
       │  First run         │  <N>s     │  Build step? DB setup? │
       │  Test suite        │  <N>s     │  Slow tests? Seeds?    │
       │  First commit      │  <N>s     │  Pre-commit hooks?     │
       ├────────────────────┼───────────┼───────────────────────┤
       │  TOTAL TTFC        │  <N>s     │  Grade: <A-F>          │
       └────────────────────┴───────────┴───────────────────────┘

    4. RECOMMEND optimizations for each bottleneck:
       - Clone slow: enable shallow clone instructions, consider sparse checkout
       - Install slow: add lockfile caching, suggest faster package manager
       - First run slow: add docker-compose for dependencies, prebuilt containers
       - Tests slow: suggest --bail for initial run, test splitting
       - Pre-commit slow: optimize hook pipeline, add lint-staged

  IF phase == "setup_script_validation":
    1. DETECT setup scripts:
       - scripts/setup.sh, scripts/bootstrap.sh, Makefile (setup target)
       - package.json scripts: "setup", "dev:setup", "bootstrap"
       - docker-compose.yml, devcontainer.json
       - README.md "Getting Started" section commands

    2. VALIDATE each setup path (on clean environment simulation):
       FOR each setup_method in detected_methods:
         a. Parse all commands from the setup method
         b. FOR each command:
            - CHECK: command exists on PATH (which {cmd})
            - CHECK: required env vars are documented (.env.example exists)
            - CHECK: required services are documented (DB, Redis, etc.)
            - CHECK: correct OS/arch assumptions (no macOS-only on Linux, etc.)
            - CHECK: correct permissions (no unnecessary sudo)
            - CHECK: idempotent (safe to run twice without side effects)
         c. RUN the full setup sequence
         d. VERIFY: application starts after setup
         e. VERIFY: tests pass after setup

    3. SCORE setup quality:
       [ ] Setup script exists: +2 (vs manual steps only)
       [ ] Single command setup: +2 (./scripts/setup.sh or make setup)
       [ ] .env.example provided: +1
       [ ] Required services documented: +1
       [ ] Docker-compose for dependencies: +1
       [ ] Works on macOS: +1
       [ ] Works on Linux: +1
       [ ] Idempotent (re-runnable): +1
       Total: <N>/10

    4. REPORT:
       SETUP SCRIPT VALIDATION:
       ┌─────────────────────────────────────────────────────┐
       │  Setup methods found:       <N>                      │
       │  Single-command setup:      YES / NO                 │
       │  .env.example present:      YES / NO                 │
       │  Services documented:       YES / NO                 │
       │  Docker support:            YES / NO                 │
       │  Cross-platform:            YES / NO / PARTIAL       │
       │  Idempotent:                YES / NO                 │
       │  Setup score:               <N>/10 (<grade>)         │
       │  Blocking issues:           <list>                   │
       └─────────────────────────────────────────────────────┘

  IF phase == "knowledge_gap_detection":
    1. IDENTIFY implicit knowledge not captured in documentation:
       - Undocumented environment variables: grep -r 'process.env\|os.environ\|os.Getenv' --include='*.{ts,py,go}' | extract var names | compare against .env.example
       - Undocumented CLI commands: grep -r 'scripts' package.json | list all script names | check if documented
       - Undocumented conventions: naming patterns, file placement rules, import conventions
       - Undocumented architecture decisions: check for docs/adr/ or ARCHITECTURE.md
       - Undocumented deployment process: check for documented deploy steps

    2. SCORE knowledge capture:
       env_vars_documented = documented_vars / total_vars * 100
       scripts_documented = documented_scripts / total_scripts * 100
       conventions_documented = YES / NO
       architecture_documented = YES / NO
       deploy_documented = YES / NO

    3. GENERATE knowledge gap report:
       KNOWLEDGE GAP ANALYSIS:
       ┌──────────────────────────┬────────┬────────────────────┐
       │  Knowledge Area          │ Status │ Gap                 │
       ├──────────────────────────┼────────┼────────────────────┤
       │  Environment variables   │ <N>%   │ <N> undocumented    │
       │  npm/make scripts        │ <N>%   │ <N> undocumented    │
       │  Naming conventions      │ YES/NO │ <details>           │
       │  Architecture decisions  │ YES/NO │ <details>           │
       │  Deployment process      │ YES/NO │ <details>           │
       │  Testing strategy        │ YES/NO │ <details>           │
       │  Error handling patterns │ YES/NO │ <details>           │
       └──────────────────────────┴────────┴────────────────────┘

  IF phase == "ramp_up_curve":
    1. ESTIMATE developer ramp-up time by complexity tier:
       Tier 1 — Bug fixes (simple, isolated changes):
         Estimated time to productive fix: <N> hours after setup
         Prerequisites: understand file structure + test runner

       Tier 2 — Small features (new endpoint, new component):
         Estimated time: <N> days after setup
         Prerequisites: understand architecture + data flow + testing patterns

       Tier 3 — Cross-cutting features (new domain, new integration):
         Estimated time: <N> weeks after setup
         Prerequisites: understand domain model + service boundaries + deployment

    2. IDENTIFY ramp-up accelerators and blockers:
       Accelerators:
       - [ ] Code tour exists (guided walkthrough of key files)
       - [ ] Architecture docs exist (ADRs, diagrams)
       - [ ] Good test examples (tests serve as executable documentation)
       - [ ] Consistent patterns (predictable code structure)
       - [ ] Low complexity (few circular dependencies, clear layers)

       Blockers:
       - [ ] No documentation (tribal knowledge only)
       - [ ] Inconsistent patterns (different styles in different modules)
       - [ ] High complexity (deep call chains, circular deps)
       - [ ] Flaky tests (new developers can't trust the test suite)
       - [ ] Manual setup steps (error-prone, undocumented)

  IF phase == "onboarding_doc_completeness":
    1. CHECK for required onboarding documents:
       REQUIRED:
       [ ] README.md with project overview and setup steps
       [ ] CONTRIBUTING.md with development workflow
       [ ] .env.example with all required environment variables
       [ ] Architecture overview (ADR, diagram, or ARCHITECTURE.md)

       RECOMMENDED:
       [ ] Code tour (docs/onboarding/code-tour.md or VS Code code tour)
       [ ] Troubleshooting guide (common issues and fixes)
       [ ] Glossary of domain terms
       [ ] Team contacts and escalation paths
       [ ] Development environment alternatives (Docker, devcontainer, cloud IDE)

    2. SCORE completeness:
       required_present = count(required items present) / 4
       recommended_present = count(recommended items present) / 5
       overall = (required_present * 0.7) + (recommended_present * 0.3)

    3. REPORT with prioritized action items

  REPORT: "Phase {current_iteration}/{max_iterations}: {phase} — Grade: {grade}"

FINAL ONBOARDING AUDIT:
┌──────────────────────────────────────────────────────────┐
│  ONBOARDING HEALTH REPORT                                 │
├──────────────────────┬────────┬───────────────────────────┤
│  Phase               │ Grade  │ Key Metric                 │
├──────────────────────┼────────┼───────────────────────────┤
│  Time to first commit│  <A-F> │  <N> minutes               │
│  Setup scripts       │  <A-F> │  <N>/10 quality score      │
│  Knowledge gaps      │  <A-F> │  <N> undocumented items    │
│  Ramp-up curve       │  <A-F> │  Tier 1: <N> hours         │
│  Doc completeness    │  <A-F> │  <N>% complete             │
├──────────────────────┼────────┼───────────────────────────┤
│  Overall             │  <A-F> │  <priority action>         │
└──────────────────────┴────────┴───────────────────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run onboarding tasks sequentially: frontend docs, then backend docs, then infra docs, then shared docs.
- Use branch isolation per task: `git checkout -b godmode-onboard-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
