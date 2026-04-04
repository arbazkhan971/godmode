# Autoresearch Integration

How godmode implements and extends Karpathy's autoresearch principles.

---

## 1. Autoresearch Core Principles

Autoresearch encodes six ideas for autonomous AI-driven optimization:

1. **Single instruction file (program.md)** -- one document tells the agent what to do, how to measure, and when to stop. The agent reads it and loops.
2. **Minimal edit surface (train.py)** -- the agent modifies a single file. This bounds the blast radius and keeps experiments comparable.
3. **Append-only log (results.tsv)** -- every experiment is recorded. The agent reads recent history to avoid repeating failures.
4. **Single scalar metric (val_bpb)** -- one number, measured mechanically. No subjective judgment. Improvement is unambiguous.
5. **Fixed time budget (5 minutes)** -- each experiment gets a hard cap. The agent does not gold-plate.
6. **Binary keep/discard** -- if the metric improved, keep. Otherwise, revert. No partial credit, no "it feels better."

The meta-principle: constrain the agent heavily so it can operate autonomously. Fewer degrees of freedom means fewer ways to go wrong.

---

## 2. How Godmode Implements Each Principle

| Autoresearch Concept | Godmode Equivalent | Where It Lives |
|---|---|---|
| `program.md` (single instruction file) | Root `SKILL.md` (universal protocol) + per-skill `skills/<name>/SKILL.md` | `/SKILL.md`, `/skills/*/SKILL.md` |
| `train.py` (single file to modify) | `task.files` -- scoped file list per agent dispatch | Planner output in `.godmode/plan.yaml` |
| `results.tsv` (append-only log) | `.godmode/<skill>-results.tsv` + `.godmode/session-log.tsv` | Created on first write, never overwritten |
| `val_bpb` (single scalar metric) | `metric_cmd` -- any shell command that outputs one number | Configured per project in setup, cached by orchestrator |
| 5-minute time budget | `max_rounds` / iteration budget + 5-min agent timeout | `SKILL.md` loop: `WHILE budget_not_exhausted` |
| Binary keep/discard | KEEP/DISCARD with `git reset --hard HEAD~1` on discard | Universal protocol section 2 |
| "NEVER STOP" | "Do NOT pause. Do NOT wait for confirmation. Loop until goal, budget, or stuck." | Root `SKILL.md` section 1 |
| Simplicity criterion (implicit) | Explicit complexity thresholds: lines added vs required improvement % | Root `SKILL.md` section 3 |

### Key implementation details

**The loop** is identical in spirit. Autoresearch: `read program.md -> modify train.py -> run train -> check results.tsv -> keep or discard`. Godmode: `REVIEW -> IDEATE -> MODIFY -> VERIFY -> DECIDE -> LOG`.

**Metric measurement** uses median of 3 runs to reduce noise (autoresearch uses single runs). If variance exceeds 5%, godmode escalates to 10 runs with outlier trimming.

**Discard** means `git reset --hard HEAD~1`. Every experiment is committed before verification, so revert is always clean. Autoresearch uses file-level backup; godmode uses git as the undo mechanism.

---

## 3. Where Godmode Extends Autoresearch

Autoresearch is deliberately minimal -- one agent, one file, one metric. Godmode scales the same principles to real-world software projects.

### Multi-agent dispatch

Autoresearch runs one agent. Godmode dispatches up to 5 parallel agents per round, each in an isolated git worktree. The optimizer skill runs 3 competing hypotheses simultaneously and cherry-picks the winner.

### Spec-driven planning

Autoresearch assumes the goal is implicit in `program.md`. Godmode adds an explicit THINK phase (brainstorm, predict, scenario) before the loop begins. The spec becomes the contract that the loop optimizes against.

### Phase state machine

Autoresearch has one phase: optimize. Godmode has four: THINK -> BUILD -> OPTIMIZE -> SHIP. The orchestrator detects which phase the project is in and routes to the right skill automatically.

### 126 specialized skills

Autoresearch has one `program.md`. Godmode has 126 domain-specific SKILL.md files (React, Postgres, Kubernetes, security audits, etc.), each encoding domain expertise while following the universal protocol.

### Guard vs metric separation

Autoresearch conflates "did it improve?" with "is it correct?" Godmode separates them:
- **Guard**: `test_cmd && lint_cmd && build_cmd` -- must all pass (non-negotiable)
- **Metric**: single number, direction up or down (optimization target)

A change that improves the metric but breaks the guard is discarded.

### Complexity thresholds

Autoresearch discards if the metric got worse. Godmode adds a complexity tax:

| Lines added | Required improvement |
|---|---|
| 1-5 | Any positive delta |
| 6-20 | >= 1% |
| 21-50 | >= 3% |
| 51+ | >= 5% |

This prevents the agent from adding 200 lines of caching for a 0.3% speedup.

### Stuck recovery

Autoresearch loops until budget. Godmode detects stuck states (5+ consecutive discards) and escalates through three strategies: opposite approach, radical rewrite, accept defeat. It also detects diminishing returns (last 3 keeps each < 1%) and stops early.

### Environment isolation

Optional Docker wrapping for metric commands. AutoAgent requires Docker; Godmode makes it optional but recommended when variance > 5%.

### Security and platform abstraction

Autoresearch runs on one machine. Godmode enforces agent capability matrices (read-only agents cannot write, testers cannot touch production code) and adapts to 5 platforms (Claude Code, Gemini CLI, Codex, Cursor, OpenCode).

---

## 4. Design Decisions

### Why SKILL.md per skill instead of one program.md

Autoresearch's single file works for "optimize one thing." Real projects need different protocols for testing, security auditing, deployment, and refactoring. Each SKILL.md is a self-contained program.md for its domain. The root SKILL.md is the universal protocol that governs all of them.

**When simpler is better:** If your task is "make this function faster," you do not need 126 skills. Use `/godmode:optimize` directly -- it behaves almost identically to autoresearch.

### Why git instead of file backup

Autoresearch backs up `train.py` before each experiment. Git gives us: full history, branching for parallel experiments, worktree isolation for concurrent agents, and `git reset` as a reliable undo. The cost is complexity. The benefit is that git log becomes the complete audit trail.

**When simpler is better:** For single-file optimization where you never need history, autoresearch's backup approach has less overhead.

### Why median of 3 instead of single measurement

Noisy metrics cause false keeps and false discards. A single outlier measurement can keep a harmful change or discard a beneficial one. The median-of-3 protocol reduces this at the cost of 3x measurement time.

**When simpler is better:** If your metric is deterministic (e.g., binary size, line count), single measurement is fine. Godmode's `setup` skill detects low-variance metrics.

### Why separate THINK phase

Autoresearch assumes you already know what to optimize. In practice, the biggest gains come from choosing the right target, not from optimizing the wrong one harder. The THINK phase (brainstorm, predict, scenario) exists to prevent wasted optimization loops.

**When simpler is better:** If the goal is crystal clear and the metric is defined, skip THINK entirely. Run `/godmode:optimize` with the metric command.

---

## 5. For Contributors

When adding a new skill, follow these autoresearch-aligned rules:

### Every iterative skill must implement The Loop

```
REVIEW -> IDEATE -> MODIFY -> VERIFY -> DECIDE -> LOG
```

No exceptions. If your skill modifies code, it must commit before verify and revert on failure. Read root `SKILL.md` sections 1-2.

### Every skill must have a mechanical metric

If the skill cannot be measured by a shell command that outputs a number, it is not an iterative skill. Make it a one-shot skill (like `think` or `plan`) instead.

### Log everything to .godmode/

Append to `.godmode/<skill>-results.tsv` with the standard columns:
```
round  change  metric_before  metric_after  delta%  status  lines_changed
```

Never overwrite. Never skip logging. The log is how the agent (and future contributors) learn what works.

### Respect the complexity tax

Do not add 50 lines to a SKILL.md to handle a rare edge case. The simplicity criterion applies to skill definitions too, not just to code changes. If your skill file exceeds 120 lines, justify each section.

### Test with the autoresearch mental model

Ask: "If this were a single program.md, a single train.py, and a single metric, would my skill still make sense?" If the answer is no, the skill is too complex. Simplify until the answer is yes, then add only the extensions that real-world usage demands.

### Preserve the keep/discard binary

Never add a "maybe" or "partial keep" state. Changes are atomic: they either improve the metric and pass the guard, or they are reverted. This is the most important autoresearch principle. Do not weaken it.

---

## Summary

Godmode is autoresearch scaled to full software engineering. The core loop (modify, measure, keep or discard) is unchanged. The extensions (multi-agent, planning, security, 126 skills) exist because real projects are larger than one file and one metric. When in doubt, default to autoresearch's simpler approach. Add complexity only when the project demands it.
