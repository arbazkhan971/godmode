# Godmode

**Turn on Godmode for Claude Code.**

A skill plugin that gives your AI agent a complete, disciplined development workflow — from idea to shipped, optimized product. Every claim is verified. Every experiment is committed. Every decision has evidence.

```
/godmode
```

---

## The Problem

AI coding tools are good at generating code. They're bad at:
- Knowing **when** to write code (vs. when to design first)
- Writing **tests before** implementation (not after)
- **Measuring** whether their changes actually improved anything
- **Reverting** bad changes instead of piling more code on top
- Running a **complete workflow** from idea to production

Godmode fixes all of these.

## The Solution: A Disciplined Development Loop

```
THINK  ──▶  BUILD  ──▶  OPTIMIZE  ──▶  SHIP
  │           │            │              │
  ▼           ▼            ▼              ▼
Design     TDD +       Autonomous     Pre-flight
first    parallel      iteration      checks +
         agents        loops          monitoring
```

**THINK** — Design before you code. Brainstorm 2-3 approaches, evaluate with expert personas, explore edge cases, write a spec.

**BUILD** — Plan before you implement. Break the spec into 2-5 minute tasks. Execute with TDD (RED-GREEN-REFACTOR). Run parallel agents for independent tasks. Code review at every phase boundary.

**OPTIMIZE** — Measure before you claim. Run an autonomous loop: hypothesize, modify one thing, verify mechanically, keep if better or revert if worse. Git-as-memory. Every experiment tracked.

**SHIP** — Verify before you deploy. Pre-flight checklist. Dry run. Deploy. Smoke test. Monitor for 15 minutes. Rollback plan ready.

## Quick Start

### Install
```bash
# Install the Godmode plugin for Claude Code
claude plugin install godmode
```

### Use
```bash
# Let Godmode figure out what you need
/godmode I want to build a rate limiter for our API

# Or go directly to a skill
/godmode:think Design a caching layer
/godmode:plan
/godmode:build
/godmode:optimize --goal "reduce response time" --target "< 200ms"
/godmode:ship --pr
```

### The Full Workflow
```bash
# 1. Design the feature
/godmode:think I need WebSocket support for real-time notifications

# 2. Get expert opinions (optional)
/godmode:predict

# 3. Break into tasks
/godmode:plan

# 4. Build with TDD
/godmode:build

# 5. Optimize autonomously
/godmode:optimize --goal "reduce latency" --target "< 50ms"

# 6. Security audit
/godmode:secure

# 7. Ship it
/godmode:ship --pr
```

## All 16 Skills

### THINK Phase
| Command | What It Does |
|---------|-------------|
| `/godmode:think` | Brainstorm 2-3 approaches, produce a spec |
| `/godmode:predict` | 5 expert personas evaluate your design |
| `/godmode:scenario` | Explore edge cases across 12 dimensions |

### BUILD Phase
| Command | What It Does |
|---------|-------------|
| `/godmode:plan` | Decompose spec into 2-5 min atomic tasks |
| `/godmode:build` | Execute with TDD + parallel agents |
| `/godmode:test` | Write tests, enforce RED-GREEN-REFACTOR |
| `/godmode:review` | 2-stage code review (automated + agent) |

### OPTIMIZE Phase
| Command | What It Does |
|---------|-------------|
| `/godmode:optimize` | Autonomous iteration loop with mechanical verification |
| `/godmode:debug` | Scientific bug investigation (7 techniques) |
| `/godmode:fix` | Autonomous error remediation loop |
| `/godmode:secure` | STRIDE + OWASP security audit with red-team |

### SHIP Phase
| Command | What It Does |
|---------|-------------|
| `/godmode:ship` | 8-phase shipping workflow |
| `/godmode:finish` | Branch finalization (merge/PR/keep/discard) |

### Meta
| Command | What It Does |
|---------|-------------|
| `/godmode` | Auto-detect phase, suggest next action |
| `/godmode:setup` | Configure Godmode for your project |
| `/godmode:verify` | Evidence gate — prove claims with commands |

## What Makes Godmode Different

### vs. "Just using Claude Code"

| Capability | Claude Code | Claude Code + Godmode |
|-----------|-------------|----------------------|
| Generate code | Yes | Yes, with TDD |
| Design first | Sometimes | Always (spec required) |
| Test first | Rarely | Always (RED-GREEN-REFACTOR) |
| Measure improvements | Never | Every iteration (mechanical verification) |
| Revert bad changes | Never | Automatically (git-as-memory) |
| Security audit | If asked | Structured STRIDE + OWASP |
| Ship workflow | Manual | 8-phase with monitoring |
| Track experiments | No | TSV log with every result |
| Parallel agents | No | Yes, for independent tasks |
| Code review | If asked | Automated at phase boundaries |

### vs. Other AI Coding Tools

| Feature | Cursor | Copilot | Windsurf | Godmode |
|---------|--------|---------|----------|---------|
| Code generation | Good | Good | Good | Good |
| Full workflow (idea→ship) | No | No | No | **Yes** |
| Autonomous optimization | No | No | No | **Yes** |
| Mechanical verification | No | No | No | **Yes** |
| Security audit framework | No | No | No | **Yes** |
| Git-as-memory | No | No | No | **Yes** |
| Parallel agent dispatch | No | No | No | **Yes** |
| Evidence-based claims | No | No | No | **Yes** |

## Three Guiding Principles

### 1. Discipline Before Speed
Design before code. Tests before implementation. Evidence before claims. Godmode will slow you down at first and save you weeks later.

### 2. Autonomy Within Constraints
The agent works independently — but within guardrails. Tests must pass. Metrics must be measured. Guard rails are sacred. The agent has freedom to experiment, but not freedom to break things.

### 3. Git Is Memory
Every experiment is committed. Every revert is committed. The git log IS the experiment log. Three weeks from now, you can see exactly what was tried, what worked, and what didn't.

## The Autonomous Loop (The Core Feature)

The `/godmode:optimize` skill is the heart of Godmode. It runs a disciplined experimental loop:

```
┌─────────────────────────────────────────────────────────┐
│                  THE AUTONOMOUS LOOP                    │
│                                                         │
│  1. MEASURE baseline (3 runs, median)                   │
│  2. HYPOTHESIZE (analyze code, form theory)             │
│  3. MODIFY (one change only)                            │
│  4. VERIFY (run command, read output, compare)          │
│  5. KEEP if better, REVERT if not                       │
│  6. LOG results (every iteration)                       │
│  7. REPEAT until target reached                         │
│                                                         │
│  Seven Principles:                                      │
│  - Mechanical verification only                         │
│  - One change per iteration                             │
│  - Git is memory                                        │
│  - Evidence before claims                               │
│  - Guard rails are sacred                               │
│  - Reverts are data                                     │
│  - Know when to stop                                    │
└─────────────────────────────────────────────────────────┘
```

Example output from a real optimization run:
```
OPTIMIZATION COMPLETE
Goal: Reduce /api/products response time
Baseline:  847ms → Final: 198ms (76.6% improvement)

Top improvements:
1. Add database index on category_id    -34.5%
2. Enable gzip compression              -31.0%
3. Add eager loading for relations       -27.7%
4. Increase connection pool              -18.2%

9 iterations: 5 kept, 3 reverted, 1 guard rail failure
```

## Project Structure

```
godmode/
├── commands/
│   ├── godmode.md              # Main command
│   └── godmode/
│       ├── think.md            # Subcommands
│       ├── plan.md
│       ├── build.md
│       ├── optimize.md
│       ├── debug.md
│       ├── fix.md
│       ├── secure.md
│       └── ship.md
├── skills/
│   ├── godmode/SKILL.md        # Orchestrator
│   ├── think/SKILL.md          # 16 skill definitions
│   ├── predict/SKILL.md
│   ├── scenario/SKILL.md
│   ├── plan/SKILL.md
│   ├── build/SKILL.md
│   ├── test/SKILL.md
│   ├── review/SKILL.md
│   ├── optimize/SKILL.md
│   ├── debug/SKILL.md
│   ├── fix/SKILL.md
│   ├── secure/SKILL.md
│   ├── ship/SKILL.md
│   ├── finish/SKILL.md
│   ├── setup/SKILL.md
│   └── verify/SKILL.md
├── agents/
│   ├── code-reviewer.md        # Review agent
│   └── spec-reviewer.md        # Spec review agent
├── hooks/
│   ├── hooks.json              # Hook configuration
│   └── session-start           # Session initialization
├── docs/
│   ├── godmode-design.md       # Design document
│   ├── getting-started.md      # First-time guide
│   ├── architecture.md         # System architecture
│   ├── domain-guide.md         # Domain-specific usage
│   ├── chaining.md             # Skill chaining guide
│   └── ci-cd.md                # CI/CD integration
└── .claude-plugin/
    └── marketplace.json        # Plugin metadata
```

## License

MIT

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to add new skills, improve existing ones, or contribute to the core plugin.
