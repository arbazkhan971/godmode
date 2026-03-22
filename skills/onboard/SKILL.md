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

# ... (condensed)
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full onboarding — architecture, key files, code tour, dependencies |
| `--quick` | Quick architecture overview only |
| `--tour` | Generate code tour only |

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
```

## Keep/Discard Discipline
```
After EACH onboarding step:
  1. MEASURE: Verify output contains no "<placeholder>" text. Confirm file paths and function names exist.
  2. COMPARE: Does the step add actionable information for a new developer?
  3. DECIDE:
     - KEEP if: all claims verified against source code AND output is populated with real data
     - DISCARD if: output contains unverified claims OR placeholder text remains
  4. COMMIT kept outputs. Re-run discarded steps with corrected analysis.

Never include unverified file paths or architectural claims in the onboarding report.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Architecture identified and verified against source code
  - Key files (7-10) documented with reading order
  - Code tour has at least 5 stops covering entry point through test pattern
  - Development setup verified (build + test from clean checkout)
  - User explicitly requests stop

DO NOT STOP just because:
  - The repo is large (focus on the 20 most-modified files)
  - Some modules lack documentation (note gaps in the report)
```

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
```

