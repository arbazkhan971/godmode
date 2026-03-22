# Godmode: Bringing Karpathy's Autoresearch to Every Coding Task

> How we took the autonomous optimization loop from [Karpathy's autoresearch](https://github.com/karpathy/autoresearch) and generalized it to 126 software engineering skills across 5 platforms.

---

## The Autoresearch Revolution

In early 2025, Andrej Karpathy released [autoresearch](https://github.com/karpathy/autoresearch) -- a deceptively simple system that let an AI agent optimize a neural network training script overnight, unsupervised. The agent would modify `train.py`, run the training loop, check whether the validation loss (measured as `val_bpb` -- bits per byte) improved, and either keep the change or throw it away. Then it would repeat. No human in the loop. No subjective judgment. Just measure, keep, discard.

The results were remarkable. Karpathy reported that the autoresearch agent produced meaningful improvements to a language model training pipeline by running autonomously for hours, trying dozens of ideas that a human researcher would have taken weeks to explore. The key was not that the AI was smarter than a human -- it was that the system was designed so the AI *could not go wrong in irreversible ways*. Every experiment was sandboxed. Every result was logged. Every bad idea was reverted.

What made autoresearch special was not the AI model powering it. It was the *protocol*: a set of constraints so tight that even a mediocre agent could produce good results over enough iterations. That protocol -- measure everything, keep only what improves, discard everything else -- is an idea that extends far beyond machine learning.

---

## The Core Idea: Measure, Keep, Discard

The autoresearch loop is brutally simple. It has six components:

1. **One instruction file (`program.md`)** -- tells the agent what to do, how to measure success, and when to stop. The agent reads this file at the start of every iteration.

2. **One file to modify (`train.py`)** -- the agent can only change one file. This bounds the blast radius. If something breaks, you know exactly where.

3. **One metric (`val_bpb`)** -- a single number, measured mechanically by running a command. No "I think it looks better." No vibes. One number, going up or going down.

4. **One log (`results.tsv`)** -- every experiment is appended to a log. The agent reads recent history to avoid repeating failed ideas.

5. **One time budget (5 minutes)** -- each experiment gets a hard cap. The agent cannot gold-plate. Ship something in five minutes or move on.

6. **One decision: keep or discard** -- if the metric improved, keep the change. If it did not, revert. No partial credit. No "it might help later." Binary.

Karpathy's autoresearch improved `val_bpb` by letting an AI agent experiment autonomously overnight. The agent tried ideas the researcher would never have had time to explore -- reshaping attention heads, adjusting learning rate schedules, rewriting data loading pipelines -- and the `results.tsv` log became a record of what worked and what did not, far more comprehensive than any human could produce manually.

The meta-principle is what matters most: **constrain the agent heavily so it can operate autonomously**. Fewer degrees of freedom means fewer ways to go wrong. The autoresearch protocol is not about being clever. It is about being disciplined.

---

## Beyond ML Training

Here is the insight that led to Godmode: the autoresearch loop is not specific to neural network training.

Think about what autoresearch actually does. It takes a task ("make this metric better"), gives an agent a constrained environment to experiment in, measures the result mechanically, and keeps or discards based on evidence. That pattern applies to nearly every iterative task in software engineering:

- **Performance optimization** -- replace `val_bpb` with response time, throughput, or memory usage. The loop is identical: change code, benchmark, keep or revert.

- **Bug fixing** -- replace the metric with "number of failing tests." Each iteration: try a fix, run the test suite, keep if tests pass, revert if they don't.

- **Security hardening** -- replace the metric with "number of findings from a security scanner." Each iteration: apply a remediation, rescan, keep if findings decreased.

- **Code quality** -- replace the metric with linter warnings, type errors, or complexity scores. Each iteration: refactor, re-measure, keep if quality improved.

- **Bundle size optimization** -- replace the metric with `du -sb dist/`. Each iteration: tree-shake, compress, remove unused code, measure, keep or revert.

- **Test coverage** -- replace the metric with coverage percentage. Each iteration: add a test, re-measure coverage, keep if it went up.

The autoresearch loop works for *anything you can measure with a shell command that outputs a number*. Karpathy built it for ML. We built Godmode to bring the same discipline to every coding task.

---

## How Godmode Implements Autoresearch

Godmode is a direct implementation of the autoresearch protocol, generalized for full-stack software engineering. Every concept in Karpathy's system has a concrete equivalent in Godmode:

### The Mapping

| Autoresearch | Godmode | Details |
|---|---|---|
| `program.md` | `SKILL.md` (meta-protocol) | One file governs the agent's behavior. Godmode has a root `SKILL.md` (universal protocol) plus 126 domain-specific skill files, each a self-contained `program.md` for its domain. |
| `train.py` | `task.files` (scoped per agent) | Instead of one global file, each agent gets a scoped list of files it can modify. This preserves autoresearch's bounded blast radius while allowing multi-file tasks. |
| `results.tsv` | `.godmode/<skill>-results.tsv` | Same format, same append-only semantics. Every experiment is logged with round number, change description, metric before, metric after, delta percentage, keep/discard status, and lines changed. |
| `val_bpb` | `metric_cmd` (any shell command) | Autoresearch hardcodes one metric. Godmode accepts any shell command that outputs a number -- response time, test count, bundle size, coverage percentage, linter warnings, whatever your project needs. |
| 5-minute budget | `max_rounds` / iteration budget | Autoresearch caps time. Godmode caps iterations (with a 5-minute timeout per individual agent). Both prevent gold-plating. |
| Single agent | Up to 5 parallel agents | Autoresearch runs one agent. Godmode dispatches up to 5 agents in isolated git worktrees, each running the same measure-keep-discard loop independently. |

### The Loop

The autoresearch loop is: `read program.md -> modify train.py -> run train -> check results.tsv -> keep or discard`.

The Godmode loop is:

```
REVIEW   -- read state: in-scope files, last 10 results from .tsv, git log
IDEATE   -- propose ONE change (or dispatch N parallel agents, each with ONE change)
MODIFY   -- implement the change, commit immediately
VERIFY   -- run guard (tests + lint + build must pass); run metric_cmd 3x, take median
DECIDE   -- metric improved AND guard passed? KEEP. Otherwise? DISCARD (git reset --hard HEAD~1)
LOG      -- append to .godmode/<skill>-results.tsv
```

The structure is identical to autoresearch. The additions -- guard checks, median-of-3 measurement, git-based revert -- are refinements, not departures. The core discipline is the same: **measure, keep, discard. No exceptions.**

### Keep/Discard: The Sacred Binary

Autoresearch's most important design decision is the binary keep/discard. No "maybe." No "it might help later." No partial credit. Godmode preserves this exactly:

```
KEEP    if  metric improved  AND  guard passed
DISCARD if  metric worse     OR   guard failed
DISCARD if  lines_added > 5  AND  metric_delta < 0.5%   (complexity tax)
KEEP    if  same metric + fewer lines                    (free simplification)
```

The one addition is the **complexity tax**. Autoresearch discards only when the metric gets worse. Godmode also discards when a change adds significant complexity for marginal improvement:

| Lines Added | Required Improvement |
|---|---|
| 1-5 | Any positive delta |
| 6-20 | >= 1% |
| 21-50 | >= 3% |
| 51+ | >= 5% |

This prevents the agent from adding 200 lines of caching infrastructure for a 0.3% speedup. Karpathy's autoresearch has this principle implicitly (simple solutions tend to win over time); Godmode makes it explicit.

---

## What Godmode Adds Beyond Autoresearch

Autoresearch is deliberately minimal. One agent, one file, one metric, one loop. That minimalism is a feature for ML training, where the task is well-defined and the metric is clear. Real-world software engineering needs more.

### Multi-Agent Orchestration

Autoresearch runs a single agent. Godmode dispatches up to 5 parallel agents per round, each operating in an isolated git worktree. The optimizer skill runs 3 competing hypotheses simultaneously and cherry-picks the winner. This multiplies throughput without sacrificing the keep/discard discipline -- each agent still follows the autoresearch loop independently.

### 126 Domain-Specific Skills

Autoresearch has one `program.md`. Godmode has 126 specialized skill files -- React, PostgreSQL, Kubernetes, security audits, accessibility, SEO, mobile, and more. Each skill is a self-contained `program.md` for its domain, encoding expert knowledge while following the universal autoresearch-inspired protocol. When you run `/godmode:optimize`, it behaves almost identically to Karpathy's autoresearch. When you run `/godmode:secure`, the same loop drives a STRIDE + OWASP security audit.

### Spec-Driven Planning

Autoresearch assumes you already know what to optimize. In practice, the biggest gains come from choosing the right target. Godmode adds a THINK phase before the loop begins -- brainstorming approaches, evaluating tradeoffs with simulated expert personas, exploring edge cases -- so the optimization loop runs against the right goal.

### Guard vs. Metric Separation

Autoresearch conflates "did it improve?" with "is it correct?" Godmode separates them:

- **Guard**: `test_cmd && lint_cmd && build_cmd` -- must all pass, non-negotiable
- **Metric**: single number, direction up or down -- the optimization target

A change that improves the metric but breaks the guard is discarded. This is critical for real-world software where "faster but broken" is worse than no change at all.

### Stuck Recovery

Autoresearch loops until the budget runs out, even when stuck. Godmode detects stuck states (5+ consecutive discards) and escalates through three recovery strategies:

1. Try the **opposite** of the last approach
2. Try a **radical rewrite** of the hotspot
3. **Accept defeat** -- stop, log "stuck," report the best result achieved

It also detects diminishing returns (last 3 keeps each < 1% improvement) and stops early. No wasted compute on marginal gains.

### 5-Platform Support

Autoresearch runs on one machine with one tool. Godmode adapts to 5 platforms -- [Claude Code](https://github.com/arbazkhan971/godmode), Gemini CLI, Codex, Cursor, and OpenCode -- through platform adapters. The same skills, the same autoresearch-inspired loop, the same keep/discard discipline, regardless of which AI assistant you use.

### 7 Specialized Subagents

Each Godmode agent has a defined role and capability boundary:

| Agent | Role | Capability |
|---|---|---|
| **planner** | Decomposes goals into parallel tasks | Read + write plans |
| **builder** | Implements tasks with TDD | Read + write code |
| **reviewer** | Code review across 7 dimensions | Read-only |
| **optimizer** | The autoresearch loop itself | Read + write scoped files |
| **explorer** | Codebase reconnaissance | Read-only |
| **security** | STRIDE + OWASP adversarial audit | Read-only |
| **tester** | Test generation and coverage | Read + write tests |

Read-only agents cannot write. Testers cannot touch production code. This capability matrix is an extension of the autoresearch principle of constraining the agent -- the tighter the constraints, the safer the autonomy.

---

## Getting Started

Three commands to experience the autoresearch loop in your own project:

```bash
# 1. Install Godmode
claude plugin install godmode

# 2. Let it auto-detect your project
/godmode:setup

# 3. Run the autoresearch-style optimization loop
/godmode:optimize reduce API response time below 200ms
```

That is it. Godmode detects your stack, your test command, your lint command. The optimize skill measures your baseline, starts the autoresearch loop, and iterates autonomously -- measuring, keeping, discarding -- until the goal is met or the budget runs out.

For a full walkthrough, see the [Getting Started guide](../getting-started.md). For other tasks:

```bash
/godmode:build add user authentication    # Spec -> plan -> parallel build -> review
/godmode:fix                              # Autonomous error remediation loop
/godmode:secure src/api/                  # STRIDE + OWASP security audit
/godmode:debug                            # Scientific debugging (7 techniques)
/godmode:ship                             # Pre-flight -> deploy -> verify -> monitor
```

Or let the orchestrator route automatically:

```bash
/godmode make this function faster        # Routes to optimize
/godmode fix the failing tests            # Routes to fix
/godmode build a rate limiter             # Routes to think -> plan -> build
```

---

## The Results: Autoresearch Applied to Itself

We used Godmode's autoresearch-inspired loop to optimize Godmode itself. The system ate its own dog food -- running the measure-keep-discard loop on its own skill definitions, trimming bloat, removing vagueness, deduplicating templates, and tightening every instruction file.

Here is the actual `.godmode/optimize-results.tsv` from that run:

| Round | Change | Before | After | Delta | Status |
|---|---|---|---|---|---|
| 0 | Baseline | 54.65 | 54.65 | -- | baseline |
| 1 | Add missing sections, trim bloat across 126 skills | 54.65 | 32.65 | -40.2% | KEPT |
| 2 | Aggressive trim: all skills under 500 lines | 32.65 | 1.03 | -96.8% | KEPT |
| 3 | Remove vague words, passive voice, trim | 1.03 | 0.59 | -42.7% | KEPT |
| 4 | Eliminate passive voice (194 rewrites) | 0.59 | 0.02 | -96.6% | KEPT |
| 5 | Eliminate ASCII table borders, fix dupes | 3.78 | 1.60 | -57.7% | KEPT |
| 6 | Remove condensed placeholders, dedup templates | 1.60 | **0.87** | -45.6% | KEPT |

**54.65 to 0.87. A 98.4% improvement in quality score over 6 rounds of autonomous iteration.**

No human reviewed individual changes during the run. The loop decided: measure the quality score, make a change, re-measure, keep or discard. Exactly the autoresearch protocol. The agent removed over 62,000 lines of bloat, rewrote 194 passive-voice instructions, deduplicated templates, and tightened every skill file -- all autonomously, all verified by measurement.

This is what Karpathy's autoresearch looks like when you point it at software engineering instead of neural network training. The loop is the same. The metric changes. The discipline holds.

---

## Why This Matters

Karpathy's autoresearch proved something important: an AI agent with the right constraints can do useful autonomous work overnight. The constraints are what make it work -- not the model, not the prompt, not the temperature setting. The protocol.

Godmode takes that proof and asks: what if the same protocol governed *all* of software engineering? What if every code change was measured? What if every regression was automatically reverted? What if the agent never stopped iterating until the goal was met?

That is what 126 autoresearch-inspired skills give you. Not a code generator that produces one draft and hopes for the best. An engineering system that measures, iterates, and proves -- the same way Karpathy's autoresearch agent improved `val_bpb` overnight, except applied to your API latency, your test coverage, your security posture, your bundle size, your accessibility score.

The autoresearch loop is the most important idea in autonomous AI coding. Godmode is the implementation that brings it to every project, every platform, every task.

---

## Further Reading

- [Karpathy's autoresearch repository](https://github.com/karpathy/autoresearch) -- the original system that inspired Godmode
- [Autoresearch Integration (technical deep-dive)](../autoresearch-integration.md) -- detailed mapping of every autoresearch concept to Godmode
- [The Godmode Philosophy](../PHILOSOPHY.md) -- design principles and the THINK-BUILD-OPTIMIZE-SHIP loop
- [SKILL.md (Universal Protocol)](../../SKILL.md) -- the root protocol that governs all 126 skills
- [Getting Started](../getting-started.md) -- installation and first-run walkthrough
- [GitHub Repository](https://github.com/arbazkhan971/godmode) -- source code, all 126 skills, all 7 agents

---

*Godmode is open source under the MIT License. Built for developers who believe AI coding assistants should be held to the same standard as the engineers who use them: measure everything, prove every claim, revert every mistake.*
