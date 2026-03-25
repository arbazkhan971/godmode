---
name: pattern
description: Design pattern recommendation and anti-pattern
  detection.
---

## Activate When
- `/godmode:pattern`, "what pattern should I use"
- "detect anti-patterns", "code smells", "refactor structure"
- Review skill identifies structural issues

## Workflow

### 1. Problem Analysis
```bash
find src/ -name "*.ts" | xargs wc -l \
  | sort -rn | head -20
npx madge --circular src/
```
```
Problem: <design challenge>
Language: <primary language>
Framework: <if applicable>
Existing patterns: <detected>
```

### 2. Pattern Classification

**Creational** (object creation problems):
Factory, Builder, Singleton (last resort -- use DI),
Prototype, Abstract Factory.

**Structural** (composition problems):
Adapter, Decorator, Facade, Proxy, Composite, Bridge.

**Behavioral** (communication problems):
Strategy, Observer, Command, State, Chain of
Responsibility, Mediator, Iterator, Template Method.

**Distributed** (resilience/consistency):
Circuit Breaker, Saga, Outbox, CQRS, Strangler Fig,
Bulkhead, Sidecar.

### 3. Pattern Recommendation
For each candidate:
- When to use, benefits, drawbacks
- Language-specific implementation
- Unit test demonstrating the pattern
- At least 1 rejected alternative with rationale

IF roles < 10 and stable: pure Strategy sufficient.
IF >3 switch/case on same type: consider State pattern.
IF files > 500 LOC: God Object -- extract classes.

### 4. Anti-Pattern Detection
```bash
find src/ -name "*.ts" | xargs wc -l \
  | sort -rn | head -20
npx jscpd src/ --min-lines 10 --min-tokens 50
grep -rn "email: string\|price: number" \
  --include="*.ts" src/
```
Key anti-patterns:
- God Object: >500 LOC, >20 methods (HIGH)
- Shotgun Surgery: 1 change = N file edits (HIGH)
- Feature Envy: method uses other class data (MEDIUM)
- Primitive Obsession: string for email/money (MEDIUM)
- Circular Dependency: A imports B, B imports A (HIGH)
- Distributed Monolith: coupled services (CRITICAL)
- Copy-Paste: duplicated logic drifts apart (MEDIUM)

### 5. Artifacts
Save: `docs/patterns/<feature>-pattern-analysis.md`
Commit: `"pattern: <feature> -- <pattern> (<confidence>)"`

## Hard Rules
1. NEVER recommend pattern without understanding problem.
2. NEVER stack multiple patterns at once.
3. NEVER recommend Singleton for dependency sharing.
4. NEVER apply patterns prophylactically (YAGNI).
5. NEVER produce recommendation without implementation.
6. ALWAYS include trade-offs (benefits AND drawbacks).
7. ALWAYS show alternatives considered.
8. ALWAYS include unit test demonstrating pattern.

## TSV Logging
Append `.godmode/pattern-results.tsv`:
```
timestamp	feature	pattern	category	confidence	antipatterns	language	files	verdict
```

## Keep/Discard
```
KEEP if: tests pass AND complexity reduced
  AND code no more complex than necessary.
DISCARD if: pattern adds more complexity than it
  removes OR tests fail.
```

## Stop Conditions
```
STOP when FIRST of:
  - Design problem resolved with tested implementation
  - Anti-pattern scan complete, findings prioritized
  - Pattern recommended with trade-offs + alternative
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Pattern adds complexity | Revert, simple code wins |
| Refactoring breaks tests | Smaller steps, test each |
| Team unfamiliar | Document with codebase example |
| Conflicts with framework | Prefer framework conventions |
