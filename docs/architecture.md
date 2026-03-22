# Godmode Architecture Overview

## System Architecture

```
  GODMODE PLUGIN
|  | ORCHESTRATOR |  |
|  | /godmode command |  |
│  │                                                                   │  │
|  | Reads: git state, test state, file state, user intent |  |
|  | Decides: Which phase and skill to activate |  |
  └───────────────┬───────────────┬───────────────┬───────────────────┘
│                  │               │               │                      │
  ┌─────────────▼───┐ ┌────────▼────────┐ ┌───▼──────────────┐
|  | THINK PHASE |  | BUILD PHASE |  | OPTIMIZE PHASE |  |
│    │                 │ │                 │ │                  │       │
|  | think |  | plan |  | optimize |  |
|  | predict |  | build |  | debug |  |
|  | scenario |  | test |  | fix |  |
|  |  |  | review |  | secure |  |
|  | SHIP PHASE |  | META SKILLS (always available) |  |
│    │                 │ │                                     │         │
|  | ship |  | setup — configuration |  |
|  | finish |  | verify — evidence gate |  |
|  | AGENTS |  |
|  | code-reviewer — dispatched by build/review skills |  |
|  | spec-reviewer — dispatched by think skill |  |
|  | INFRASTRUCTURE |  |
|  | hooks/session-start — auto-detect and initialize |  |
|  | .godmode/config.yaml — project configuration |  |
|  | .godmode/*.tsv — results logs (optimize, fix, ship) |  |
```

## Skill Hierarchy

```
/godmode (orchestrator)
├── THINK
  ├── /godmode:think    → produces spec
  ├── /godmode:predict  → evaluates spec
  └── /godmode:scenario → explores edge cases
├── BUILD
  ├── /godmode:plan     → consumes spec, produces plan
  ├── /godmode:build    → consumes plan, produces code
  ├── /godmode:test     → writes/improves tests
  └── /godmode:review   → reviews code against spec
├── OPTIMIZE
  ├── /godmode:optimize → autonomous improvement loop
  ├── /godmode:debug    → investigates bugs
  ├── /godmode:fix      → remediates errors
  └── /godmode:secure   → security audit
├── SHIP
  ├── /godmode:ship     → deploy/PR workflow
  └── /godmode:finish   → branch cleanup
└── META
    ├── /godmode:setup    → configuration
    └── /godmode:verify   → evidence gate
```

## Data Flow

### Artifact Pipeline

```
User Request
    ▼
| think | ────▶ | plan | ────▶ | build |
│          │     │          │     │          │
| Output: |  | Output: |  | Output: |
| spec.md |  | plan.md |  | code + |
|  |  | branch |  | tests + |
|  |  |  |  | commits |
                    ┌──────────────────┤
                    ▼                  ▼
| optimize |  | review |
              │          │     │          │
| Output: |  | Output: |
| results |  | report |
| .tsv |  | scores |
              └────┬─────┘     └──────────┘
                   ▼
| secure | ────▶ | ship |
              │          │     │          │
| Output: |  | Output: |
| audit.md |  | PR/deploy |
|  |  | log.tsv |
```

### File System Layout

```
project/
├── .godmode/                    # Godmode working directory
  ├── config.yaml              # Project configuration
  ├── optimize-results.tsv     # Optimization experiment log
  ├── fix-log.tsv              # Error remediation log
  └── ship-log.tsv             # Deployment history
├── docs/
  ├── specs/                   # Specifications (from think)
│   │   └── <feature>.md
  ├── plans/                   # Implementation plans (from plan)
│   │   └── <feature>-plan.md
  ├── scenarios/               # Scenario matrices (from scenario)
│   │   └── <feature>-scenarios.md
  └── security/                # Security audits (from secure)
  └── <feature>-audit.md
├── src/                         # Source code (from build)
└── tests/                       # Test files (from build/test)
```

## Communication Patterns

### Skill-to-Skill Communication
Skills communicate through files, not direct calls:

```
think  ──writes──▶  docs/specs/feature.md  ──read by──▶  plan
plan   ──writes──▶  docs/plans/feature.md  ──read by──▶  build
secure ──writes──▶  docs/security/audit.md ──read by──▶  fix (if failures)
```

### Skill-to-Agent Communication
Skills dispatch agents with context:

```
build ──dispatches──▶ code-reviewer agent
  │ Sends:               │ Returns:
  │ - spec               │ - scores (1-10 per dimension)
  │ - plan               │ - MUST FIX items
  │ - diff               │ - SHOULD FIX items
  └───receives────────────┘

think ──dispatches──▶ spec-reviewer agent
  │ Sends:               │ Returns:
  │ - spec               │ - completeness score
  │ - codebase context   │ - issues found
  │                       │ - questions to resolve
  └───receives────────────┘
```

### Verify Gate Pattern
The verify skill is called internally by other skills:

```
optimize  ──"tests pass?"──▶  verify  ──runs npm test──▶  "47/47 passing" ──▶  CONFIRMED
fix       ──"error fixed?"──▶  verify  ──runs specific test──▶  "PASS" ──▶  CONFIRMED
ship      ──"CI green?"──▶  verify  ──runs gh pr checks──▶  "all passing" ──▶  CONFIRMED
```

## The Autonomous Loop (Core Architecture)

The optimize skill runs a state machine:

```
  SETUP
  (one-time)
                ▼
    ┌───▶│  ANALYZE    │
|  | Form |
|  | hypothesis |
  ▼
    │    ┌─────────────┐
|  | MODIFY |
|  | One change |
|  | Commit |
  ▼
    │    ┌─────────────┐     ┌──────────┐
    │    │  GUARD      │─NO─▶│  REVERT  │──┐
|  | RAILS |  | log |  |
  └──────┬──────┘     └──────────┘
|  | YES |
  ▼
|  | MEASURE |  |
|  | 3 runs, |  |
|  | median |  |
  ▼
|  | COMPARE |  |
|  | vs baseline |  |
  IMPROVED?
  ╱        ╲
  YES         NO
    │    │           │                     │
  ▼           ▼
|  | KEEP |  | REVERT |  |
|  | log |  | log |  |
    │    │           │                     │
  └─────┬─────┘◀────────────────────┘
  ▼
    │    ┌─────────────┐
|  | CONTINUE? |
|  | target met? |
|  | max iter? |
|  | 3 reverts? |
    │      YES  │  NO
    │       │   ▼
    │       │ ┌──────────┐
    └───────┘ │   STOP   │
  report
```

## Configuration Architecture

```yaml
# .godmode/config.yaml — single source of truth
project:
  name: "my-app"           # Auto-detected or user-provided
  language: "typescript"    # Auto-detected

commands:
  test: "npm test"         # Used by: build, fix, review, ship, verify
  lint: "npm run lint"     # Used by: build, fix, review, ship
  typecheck: "npx tsc"     # Used by: build, fix, review
  build: "npm run build"   # Used by: ship

optimization:
  goal: "response time"    # Used by: optimize
  metric: "ms"             # Used by: optimize
  verify: "curl ..."       # Used by: optimize, verify
  target: "< 200"          # Used by: optimize
  max_iterations: 25       # Used by: optimize

scope:
  include: ["src/"]        # Used by: optimize, secure, review
  exclude: ["node_modules/"] # Used by: optimize, secure, review

guard_rails:               # Used by: optimize
  - command: "npm test"
    name: "Tests"
    must_pass: true
  - command: "npm run lint"
    name: "Lint"
    must_pass: true
```

## Extension Points

### Adding New Skills
1. Create `skills/<name>/SKILL.md` following the standard structure
2. Add command file at `commands/godmode/<name>.md`
3. Register in `.claude-plugin/marketplace.json`

### Adding New Agents
1. Create `agents/<name>.md` with the agent's system prompt
2. Register in `.claude-plugin/marketplace.json`
3. Reference from the skill that dispatches it

### Adding New Hooks
1. Add hook script to `hooks/`
2. Register in `hooks/hooks.json`
3. Supported events: `on_session_start`

### Adding New Reference Documents
1. Create under `skills/<skill>/references/`
2. These are loaded by the skill for deep reference information
