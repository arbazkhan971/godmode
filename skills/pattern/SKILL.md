---
name: pattern
description: |
  Design pattern recommendation skill. Activates when user needs to choose the right design pattern, detect anti-patterns in existing code, or implement patterns in a specific language. Covers Gang of Four patterns with modern when-to-use guidance, distributed system patterns (Circuit Breaker, Saga, Outbox, CQRS, Strangler Fig), and anti-pattern detection with remediation. Every recommendation includes rationale, trade-offs, and language-specific implementation. Triggers on: /godmode:pattern, "what pattern should I use", "detect anti-patterns", "refactor this to use a pattern", or when the orchestrator detects structural design decisions.
---

# Pattern — Design Pattern Recommendation

## When to Activate
- User invokes `/godmode:pattern`
- User says "what pattern should I use", "design pattern for this", "is there a pattern for..."
- User says "detect anti-patterns", "code smells", "refactor this structure"
- When `/godmode:review` identifies structural issues that a pattern would solve
- When `/godmode:architect` needs implementation-level pattern recommendations
- When code has repeated structural problems across multiple files

## Workflow

### Step 1: Problem Analysis
Understand the design problem before recommending a pattern:

```
PATTERN CONTEXT:
Problem: <What is the design challenge?>
Language: <Primary implementation language>
```

### Step 2: Pattern Classification
Classify the problem into one of four categories, then evaluate patterns within that category:

#### Category A: Creational Patterns
When the problem is about object creation — too many constructors, complex initialization, or inflexible instantiation.

```
CREATIONAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
```

#### Category B: Structural Patterns
When the problem is about composing objects — how to assemble classes and objects into larger structures.

```
STRUCTURAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
```

#### Category C: Behavioral Patterns
When the problem is about object communication — how objects interact and distribute responsibilities.

```
BEHAVIORAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
```

#### Category D: Modern / Distributed System Patterns
When the problem involves distributed systems, resilience, or data consistency across services.

```
MODERN PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
```

### Step 3: Pattern Recommendation
For each candidate pattern, provide a structured recommendation:

```
PATTERN RECOMMENDATION:
┌────────────────────────────────────────────────────────────────────┐
│  Pattern: <Name>                                                   │
```

### Step 4: Language-Specific Implementation
Produce implementation in the project's language with:

```
IMPLEMENTATION GUIDE:
1. Interface/type definitions
2. Core pattern implementation
```

Adapt to language idioms:
- **TypeScript/JavaScript**: Use interfaces, generics, dependency injection
- **Python**: Use protocols (typing.Protocol), abstract base classes, decorators
- **Go**: Use interfaces (implicit satisfaction), functional options, embedding
- **Java/Kotlin**: Use interfaces, generics, Spring annotations where appropriate
- **Rust**: Use traits, enums, generics, the type system

### Step 5: Anti-Pattern Detection
Scan the codebase for common anti-patterns:

```
ANTI-PATTERN SCAN:
┌──────────────────────┬──────────────────────────────────────────────────┐
│ Anti-Pattern         │ Detection Signals                               │
```

For each detected anti-pattern:
```
ANTI-PATTERN FINDING:
Name: <anti-pattern name>
Location: <file:line>
```
Impact: <why this is harmful>
Remediation pattern: <which design pattern fixes this>
Refactored code:
```<language>
// The improved code
```
```

### Step 6: Artifacts & Transition
1. Save pattern analysis: `docs/patterns/<feature>-pattern-analysis.md`
```
AUTO-DETECT SEQUENCE:
1. Language and framework:
   - Detect from package.json / go.mod / Cargo.toml / pyproject.toml / pom.xml
   - Framework: Express, NestJS, Django, FastAPI, Gin, Actix, Spring, etc.

2. Existing patterns in use:
   - grep for class.*Repository → Repository pattern
   - grep for class.*Factory → Factory pattern
   - grep for class.*Strategy|interface.*Strategy → Strategy pattern
   - grep for @Injectable|@Inject|constructor(private → DI pattern
   - grep for EventEmitter|on\(|emit\( → Observer/Event pattern
   - grep for middleware|pipe|chain → Chain of Responsibility

3. Anti-pattern signals:
   - Find files > 500 lines → God Object candidates
   - Find functions > 50 lines → potential extract targets
   - grep for switch.*case.*case.*case → State/Strategy candidates
   - Detect circular imports → Dependency inversion needed

4. Output: PATTERN CONTEXT auto-populated with detected patterns and signals.
```

## Explicit Loop Protocol

```
current_iteration = 0
findings = []  # anti-patterns found, patterns to recommend

# Initial scan
SCAN codebase for: god objects, switch blocks, circular deps, primitive obsession
findings = scan_results

WHILE findings is not empty AND current_iteration < 8:
    current_iteration += 1
    finding = findings.pop(0)

    1. ANALYZE: understand the specific design problem
    2. CLASSIFY: categorize (Creational/Structural/Behavioral/Modern)
    3. RECOMMEND: select pattern with rationale and trade-offs
    4. IMPLEMENT: produce language-specific code with tests
    5. VERIFY: confirm the pattern resolves the original symptom
    6. IF new anti-patterns emerge from refactoring:
        findings.extend(new_findings)
    7. REPORT: "Finding {finding.name}: {pattern} applied -- iteration {current_iteration}"

OUTPUT: Pattern analysis report with all recommendations and implementations.
```

## HARD RULES

1. **NEVER recommend a pattern without understanding the problem first.** Diagnose before prescribing. Always complete Step 1 (Problem Analysis) before Step 3 (Pattern Recommendation).
2. **NEVER stack multiple patterns at once.** Recommend ONE pattern, let the team implement it, then evaluate if another is needed.
3. **NEVER recommend Singleton for dependency sharing.** Use dependency injection instead. Singleton is the last resort, not the first choice.
4. **NEVER apply patterns prophylactically.** A pattern should solve a CURRENT problem, not a theoretical future one. YAGNI applies to patterns.
5. **NEVER produce a recommendation without language-specific implementation code.** Abstract UML alone is insufficient. Show the actual code.
6. **ALWAYS include trade-offs.** Every recommendation must list both benefits AND drawbacks.
7. **ALWAYS show alternatives considered.** Explain why the recommended pattern was chosen over at least one alternative.
8. **ALWAYS include a unit test demonstrating the pattern.** If the pattern cannot be tested, reconsider the recommendation.

## Output Format
Print on completion:
```
PATTERN ANALYSIS: {feature_or_problem}
Recommended: {pattern_name} ({category}) — Confidence: {HIGH|MEDIUM|LOW}
Alternatives rejected: {alt_1} ({reason}), {alt_2} ({reason})
Anti-patterns found: {N} ({list with file:line})
Implementation: {language} — {N} files created/modified
Tests: {N} test cases covering the pattern
```

## TSV Logging
Log every pattern session to `.godmode/pattern-results.tsv`:
```
timestamp	feature	pattern_recommended	category	confidence	antipatterns_found	language	files_modified	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
```
After EACH pattern recommendation or refactoring:
  1. MEASURE: Does the applied pattern reduce the original symptom (duplication, coupling, complexity)?
  2. COMPARE: Is the code measurably better? Do tests still pass?
  3. DECIDE:
     - KEEP if: original symptom resolved AND tests pass AND code is no more complex than necessary
     - DISCARD if: pattern adds more complexity than it removes OR tests fail
  4. COMMIT kept changes. Revert discarded changes.

Never keep a pattern that adds more files/abstractions than the problem warrants.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - The original design problem is resolved with a tested implementation
  - Anti-pattern scan completed and findings prioritized
  - One pattern recommended with trade-offs and at least one rejected alternative
  - User explicitly requests stop

DO NOT STOP just because:
  - Additional anti-patterns exist (prioritize by severity/effort ratio)
  - The pattern could be extended further (ship the minimal viable pattern)
```

## Design Pattern Audit

```
DESIGN PATTERN AUDIT LOOP:

current_iteration = 0
max_iterations = 12
audit_queue = [pattern_detection, anti_pattern_flagging, pattern_misuse, missing_patterns, refactor_suggestions]
audit_findings = []

WHILE audit_queue is not empty AND current_iteration < max_iterations:
    current_iteration += 1
    audit_aspect = audit_queue.pop(0)

    1. SCAN codebase for signals related to {audit_aspect}
    2. CLASSIFY each finding: correct usage | misuse | missing opportunity | anti-pattern
    3. SCORE severity: LOW (style) | MEDIUM (maintainability) | HIGH (correctness risk)
    4. GENERATE specific refactor suggestion with before/after code
    5. IF new concerns surface → audit_queue.append(related_aspect)
    6. REPORT "Audit iteration {current_iteration}: {audit_aspect} — {findings_count} findings"

FINAL: Pattern audit report with prioritized refactor suggestions
```

### Pattern Detection

```
PATTERN DETECTION SCAN:
┌──────────────────────────────────────────────────────────────┐
│  Pattern          │ Detection Signal              │ Found    │
├───────────────────┼───────────────────────────────┼──────────┤
│  Singleton        │ static instance, getInstance()│ <files>  │
│  Factory          │ create*, Factory class/func   │ <files>  │
│  Builder          │ .setX().setY().build()        │ <files>  │
│  Strategy         │ interface + multiple impls    │ <files>  │
│                   │ injected at construction      │          │
│  Observer         │ on(), emit(), subscribe(),    │ <files>  │
│                   │ EventEmitter, addEventListener│          │
│  Repository       │ class.*Repository, findBy*,   │ <files>  │
│                   │ save(), delete()              │          │
│  Decorator        │ wraps another instance of     │ <files>  │
│                   │ same interface, delegates calls│         │
│  Command          │ execute(), undo(), command    │ <files>  │
│                   │ objects with action payload   │          │
│  Mediator         │ central coordinator, handles  │ <files>  │
│                   │ cross-component communication │          │
│  Chain of Resp.   │ middleware chains, next(),    │ <files>  │
│                   │ pipe(), handler arrays        │          │
│  Adapter          │ wraps foreign interface to    │ <files>  │
│                   │ match expected interface      │          │
│  Facade           │ simplified interface to       │ <files>  │
│                   │ complex subsystem             │          │
│  State            │ state objects with behavior,  │ <files>  │
│                   │ context delegates to state    │          │
│  Proxy            │ same interface as target,     │ <files>  │
│                   │ controls access (cache, lazy) │          │
│  Circuit Breaker  │ failure counting, open/closed │ <files>  │
│                   │ /half-open states             │          │
│  Saga             │ compensation chains, saga     │ <files>  │
│                   │ orchestrator/choreography     │          │
│  Outbox           │ outbox table, event relay,    │ <files>  │
│                   │ transactional event publish   │          │
└───────────────────┴───────────────────────────────┴──────────┘

PATTERN HEALTH ASSESSMENT:
For each detected pattern:
  Pattern: <name>
  Location: <files>
  Implementation quality: CORRECT | PARTIAL | MISUSED
  Issues (if any):
    - <specific issue, e.g., "Singleton holds mutable state accessed from multiple threads">
    - <specific issue, e.g., "Repository leaks ORM entities through interface">
  Recommendation: KEEP | REFINE | REPLACE
```

### Anti-Pattern Flagging

```
ANTI-PATTERN AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Anti-Pattern       │ Severity │ Files │ Impact              │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  God Object         │ HIGH     │ <N>   │ Unmodifiable core   │
│  (class > 500 LOC,  │          │       │ module, high merge  │
│  > 20 methods,      │          │       │ conflict rate       │
│  multiple domains)  │          │       │                     │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Shotgun Surgery    │ HIGH     │ <N>   │ Single change       │
│  (one change =      │          │       │ requires modifying  │
│  many file edits)   │          │       │ N+ files            │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Feature Envy       │ MEDIUM   │ <N>   │ Method uses more    │
│  (method accesses   │          │       │ data from another   │
│  other class data)  │          │       │ class than its own  │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Primitive Obsession│ MEDIUM   │ <N>   │ No domain type      │
│  (string for email, │          │       │ validation, invalid │
│  int for money)     │          │       │ values propagate    │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Anemic Domain      │ MEDIUM   │ <N>   │ All logic in service│
│  (data-only models, │          │       │ layer, domain model │
│  no behavior)       │          │       │ adds no value       │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Circular Dependency│ HIGH     │ <N>   │ Cannot deploy or    │
│  (A imports B,      │          │       │ test independently  │
│  B imports A)       │          │       │                     │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Leaky Abstraction  │ MEDIUM   │ <N>   │ Implementation      │
│  (DB columns in API │          │       │ detail changes      │
│  response)          │          │       │ break consumers     │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Distributed        │ CRITICAL │ <N>   │ Must deploy all     │
│  Monolith           │          │       │ services together,  │
│  (coupled services) │          │       │ negates micro gains │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Golden Hammer      │ LOW      │ <N>   │ One pattern used    │
│  (same pattern for  │          │       │ everywhere even     │
│  everything)        │          │       │ when inappropriate  │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Speculative        │ LOW      │ <N>   │ Over-engineered     │
│  Generality         │          │       │ abstractions for    │
│  (unused flex pts)  │          │       │ theoretical futures │
├─────────────────────┼──────────┼───────┼─────────────────────┤
│  Copy-Paste         │ MEDIUM   │ <N>   │ Duplicated logic    │
│  Programming        │          │       │ drifts apart,       │
│  (cloned blocks)    │          │       │ bugs fixed in one   │
│                     │          │       │ but not the other   │
└─────────────────────┴──────────┴───────┴─────────────────────┘

DETECTION COMMANDS:
  # God Objects: files with high LOC and many exports
  find src/ -name "*.ts" | xargs wc -l | sort -rn | head -20

  # Circular Dependencies
  npx madge --circular src/
  # Or: dependency-cruiser --output-type err src/

  # Duplicated Code
  npx jscpd src/ --min-lines 10 --min-tokens 50

  # Feature Envy (heuristic: grep for excessive other-class field access)
  # Manual review guided by coupling metrics

  # Primitive Obsession: grep for untyped signatures
  grep -rn "email: string\|price: number\|id: string" --include="*.ts" src/
```

### Refactor Suggestions

```
REFACTOR SUGGESTION FORMAT:
┌──────────────────────────────────────────────────────────────┐
│  Anti-Pattern: <name>                                         │
│  Location: <file:line-range>                                  │
│  Severity: <CRITICAL|HIGH|MEDIUM|LOW>                         │
│  Effort: <S|M|L|XL>                                          │
├──────────────────────────────────────────────────────────────┤
│  Problem:                                                     │
│  <1-2 sentences: what is wrong and why it matters>            │
│                                                               │
│  Recommended Pattern: <design pattern that resolves this>     │
│                                                               │
│  Before (current):                                            │
│  ```<language>                                                │
│  // Problematic code snippet                                  │
│  ```                                                          │
│                                                               │
│  After (refactored):                                          │
│  ```<language>                                                │
│  // Improved code snippet using recommended pattern           │
│  ```                                                          │
│                                                               │
│  Steps:                                                       │
│  1. <specific first action>                                   │
│  2. <specific second action>                                  │
│  3. <run tests after each step>                               │
│                                                               │
│  Risk: <what could go wrong>                                  │
│  Prerequisite: <tests needed, dependencies to resolve first>  │
│  Related: <other findings this fix may resolve>               │
└──────────────────────────────────────────────────────────────┘

PRIORITIZATION MATRIX:
┌──────────────────────────────────────────────────────────────┐
│  Finding           │ Severity │ Effort │ Priority Score      │
│                    │ (1-4)    │ (1-4)  │ (severity/effort)   │
├────────────────────┼──────────┼────────┼─────────────────────┤
│  <finding 1>       │ <N>      │ <N>    │ <ratio>             │
│  <finding 2>       │ <N>      │ <N>    │ <ratio>             │
│  <finding 3>       │ <N>      │ <N>    │ <ratio>             │
├────────────────────┼──────────┼────────┼─────────────────────┤
│  RECOMMENDED ORDER: highest priority score first              │
│  (maximum impact per unit of effort)                          │
└──────────────────────────────────────────────────────────────┘
```

### Pattern Audit Report

```
PATTERN AUDIT SUMMARY:
  Codebase: {project_name}
  Patterns detected: {N} ({list with locations})
  Patterns correctly implemented: {N}
  Pattern misuses: {N} ({list with issues})
  Anti-patterns found: {N} (CRITICAL: {N}, HIGH: {N}, MEDIUM: {N}, LOW: {N})
  Refactor suggestions: {N} prioritized by severity/effort ratio
  Estimated effort: {total hours/days}
  Recommended first action: {highest priority refactor}
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Pattern adds complexity without benefit | Revert. Simple code that works beats elegant code that confuses. Only apply patterns to solve proven problems, not hypothetical ones. |
| Refactoring breaks existing tests | Run tests after each small step. If a single refactor step breaks tests, the step is too large — split into smaller steps. |
| Team unfamiliar with chosen pattern | Document the pattern with a concrete example from the codebase. Keep the implementation minimal — avoid gold-plating. |
| Pattern conflicts with framework conventions | Prefer framework conventions over textbook patterns. Adapt the pattern to fit the framework, not the other way around. |

## Keep/Discard Discipline
```
After EACH pattern application:
  KEEP if: all tests pass AND code complexity reduced or unchanged AND team can understand the change
  DISCARD if: tests break OR complexity increased OR pattern is over-engineered for the problem
  On discard: revert. The simplest working solution is the correct one.
```
