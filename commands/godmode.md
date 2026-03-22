# /godmode

Turn on Godmode for Claude Code. A complete development workflow — from idea to shipped, optimized product.

## Usage

```
/godmode                    # Auto-detect phase, suggest next action
/godmode:<skill>            # Invoke a specific skill directly
/godmode --status           # Show project status without taking action
/godmode --loop             # Continuous mode: execute, re-evaluate, repeat
```

## Available Skills

### THINK Phase (Design & Discovery)
| Command | Description |
|--|--|
| `/godmode:think` | Brainstorm and design — produces a spec |
| `/godmode:predict` | Multi-persona expert evaluation of a proposal |
| `/godmode:scenario` | Edge case exploration across 12 dimensions |

### BUILD Phase (Plan & Implement)
| Command | Description |
|--|--|
| `/godmode:plan` | Decompose spec into 2-5 min tasks |
| `/godmode:build` | Execute plan with TDD + parallel agents |
| `/godmode:test` | Write tests, improve coverage |
| `/godmode:review` | 2-stage code review (automated + agent) |

### OPTIMIZE Phase (Autonomous Iteration)
| Command | Description |
|--|--|
| `/godmode:optimize` | Autonomous improvement loop — the core of Godmode |
| `/godmode:debug` | Scientific bug investigation (7 techniques) |
| `/godmode:fix` | Autonomous error remediation loop |
| `/godmode:secure` | STRIDE + OWASP security audit |

### SHIP Phase (Deliver)
| Command | Description |
|--|--|
| `/godmode:ship` | 8-phase shipping workflow |
| `/godmode:finish` | Branch finalization (merge/PR/keep/discard) |

### Meta
| Command | Description |
|--|--|
| `/godmode:setup` | Configure Godmode for this project |
| `/godmode:verify` | Evidence gate — prove claims with commands |

## The Godmode Loop

```
THINK → BUILD → OPTIMIZE → SHIP → REPEAT
```

Most projects follow this flow:

1. **Think** — Design the feature with `/godmode:think`
2. **Predict** — Get expert opinions with `/godmode:predict` (optional)
3. **Plan** — Break into tasks with `/godmode:plan`
4. **Build** — Implement with TDD via `/godmode:build`
5. **Optimize** — Improve autonomously with `/godmode:optimize`
6. **Secure** — Audit with `/godmode:secure`
7. **Ship** — Deploy with `/godmode:ship`

You can jump to any phase at any time. Godmode will warn you if you're skipping important steps.

## Three Principles

1. **Discipline before speed** — Design before code, tests before implementation, evidence before claims
2. **Autonomy within constraints** — Agent works independently within guardrails (metrics, tests, review gates)
3. **Git is memory** — Every experiment committed, every decision traceable, every failure logged
