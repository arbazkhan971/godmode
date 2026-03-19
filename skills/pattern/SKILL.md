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
Framework: <Framework in use, if any>
Constraints:
  - Performance: <latency/throughput requirements>
  - Testability: <unit test isolation needs>
  - Extensibility: <expected future changes>
  - Team familiarity: <patterns the team already uses>
Current code:
  - File(s): <files exhibiting the problem>
  - Symptom: <what feels wrong — duplication, coupling, complexity, rigidity>
```

### Step 2: Pattern Classification
Classify the problem into one of four categories, then evaluate patterns within that category:

#### Category A: Creational Patterns
When the problem is about object creation — too many constructors, complex initialization, or inflexible instantiation.

```
CREATIONAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Factory Method   │ A class can't anticipate the type of objects it needs │
│                  │ to create. Subclasses should decide.                  │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Abstract Factory │ You need families of related objects without          │
│                  │ specifying their concrete classes.                    │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Builder          │ Object construction requires many optional parameters │
│                  │ or multi-step initialization.                         │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Singleton        │ Exactly one instance is needed system-wide AND it     │
│                  │ must be globally accessible. (Prefer DI instead.)     │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Prototype        │ Creating new objects is expensive, and similar        │
│                  │ objects already exist to clone.                       │
└──────────────────┴────────────────────────────────────────────────────────┘
```

#### Category B: Structural Patterns
When the problem is about composing objects — how to assemble classes and objects into larger structures.

```
STRUCTURAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Adapter          │ You need to use a class with an incompatible          │
│                  │ interface. Wraps it to match what the client expects. │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Bridge           │ You want to vary both abstraction and implementation  │
│                  │ independently. Separates what from how.               │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Composite        │ You have tree structures where individual objects and │
│                  │ groups should be treated uniformly.                   │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Decorator        │ You need to add responsibilities to objects           │
│                  │ dynamically without modifying the class.              │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Facade           │ You want a simplified interface to a complex          │
│                  │ subsystem. Reduces coupling to internals.             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Flyweight        │ You have many similar objects and need to reduce      │
│                  │ memory usage by sharing common state.                 │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Proxy            │ You need controlled access to an object — lazy init,  │
│                  │ access control, logging, caching.                     │
└──────────────────┴────────────────────────────────────────────────────────┘
```

#### Category C: Behavioral Patterns
When the problem is about object communication — how objects interact and distribute responsibilities.

```
BEHAVIORAL PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Strategy         │ You have multiple algorithms for a task and want to   │
│                  │ switch between them at runtime.                       │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Observer         │ One object's state change should notify many          │
│                  │ dependents automatically.                             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Command          │ You need to parameterize actions, queue them, or      │
│                  │ support undo/redo.                                    │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Chain of Resp.   │ Multiple handlers might process a request, and you    │
│                  │ don't want the sender coupled to a specific handler.  │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Template Method  │ You have an algorithm skeleton where subclasses       │
│                  │ override specific steps.                              │
├──────────────────┼────────────────────────────────────────────────────────┤
│ State            │ Object behavior changes based on internal state, and  │
│                  │ you're replacing large if/switch blocks.              │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Mediator         │ Many objects communicate in complex ways. Centralize  │
│                  │ communication to reduce coupling.                     │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Iterator         │ You need to traverse a collection without exposing    │
│                  │ its internal structure.                               │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Visitor          │ You need to add operations to a class hierarchy       │
│                  │ without modifying the classes.                        │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Memento          │ You need to capture and restore object state          │
│                  │ (snapshots, undo).                                    │
└──────────────────┴────────────────────────────────────────────────────────┘
```

#### Category D: Modern / Distributed System Patterns
When the problem involves distributed systems, resilience, or data consistency across services.

```
MODERN PATTERNS:
┌──────────────────┬────────────────────────────────────────────────────────┐
│ Pattern          │ Use When                                             │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Repository       │ You want to decouple domain logic from data access.   │
│                  │ Provides collection-like interface to the data store. │
├──────────────────┼────────────────────────────────────────────────────────┤
│ CQRS             │ Read and write models have different optimization     │
│                  │ needs. Separate command and query responsibilities.   │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Saga             │ You need distributed transactions across services.    │
│                  │ Orchestration (central) or choreography (events).     │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Circuit Breaker  │ Calls to an external service may fail or hang.        │
│                  │ Fail fast when the service is unhealthy.              │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Outbox           │ You need to publish events AND update a database      │
│                  │ atomically. Write events to an outbox table first.    │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Strangler Fig    │ You need to incrementally migrate from a legacy       │
│                  │ system. Route traffic gradually to the new system.    │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Event Sourcing   │ You need a complete audit trail and the ability to    │
│                  │ rebuild state from events.                            │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Bulkhead         │ You need to isolate failures so one component's       │
│                  │ failure doesn't cascade to the entire system.         │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Sidecar          │ You need to attach cross-cutting concerns (logging,   │
│                  │ proxy, config) to services without modifying them.    │
├──────────────────┼────────────────────────────────────────────────────────┤
│ Backend for      │ Different clients (web, mobile, IoT) need different   │
│ Frontend (BFF)   │ API shapes from the same backend services.            │
└──────────────────┴────────────────────────────────────────────────────────┘
```

### Step 3: Pattern Recommendation
For each candidate pattern, provide a structured recommendation:

```
PATTERN RECOMMENDATION:
┌────────────────────────────────────────────────────────────────────┐
│  Pattern: <Name>                                                   │
│  Category: <Creational | Structural | Behavioral | Modern>        │
│  Confidence: <HIGH | MEDIUM | LOW>                                │
├────────────────────────────────────────────────────────────────────┤
│  Problem it solves:                                               │
│  <1-2 sentences describing the exact problem>                     │
│                                                                    │
│  Why this pattern:                                                │
│  <1-2 sentences connecting the pattern to the user's situation>   │
│                                                                    │
│  Trade-offs:                                                      │
│  ✓ <benefit 1>                                                    │
│  ✓ <benefit 2>                                                    │
│  ✗ <drawback 1>                                                   │
│  ✗ <drawback 2>                                                   │
│                                                                    │
│  Alternatives considered:                                         │
│  - <pattern A>: rejected because <reason>                         │
│  - <pattern B>: also viable if <condition>                        │
└────────────────────────────────────────────────────────────────────┘
```

### Step 4: Language-Specific Implementation
Produce implementation in the project's language with:

```
IMPLEMENTATION GUIDE:
1. Interface/type definitions
2. Core pattern implementation
3. Usage example
4. Unit test demonstrating the pattern
5. Integration notes (how it connects to existing code)
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
├──────────────────────┼──────────────────────────────────────────────────┤
│ God Object           │ Class with 500+ lines, 20+ methods, touching    │
│                      │ multiple domains. Low cohesion, high coupling.   │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Spaghetti Code       │ No clear structure, goto-like control flow,     │
│                      │ deeply nested conditionals, no separation.      │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Shotgun Surgery      │ A single change requires modifying many files.  │
│                      │ Related logic scattered across the codebase.    │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Feature Envy         │ A method uses more data from another class than │
│                      │ its own. Likely belongs in the other class.     │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Primitive Obsession  │ Using primitives (string, int) instead of       │
│                      │ domain types (Email, Money, UserId).            │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Anemic Domain Model  │ Domain objects are pure data holders with no    │
│                      │ behavior. All logic lives in service classes.   │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Circular Dependency  │ Module A depends on B, B depends on A.          │
│                      │ Break with dependency inversion or events.      │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Leaky Abstraction    │ Implementation details leak through the public  │
│                      │ interface. Database columns exposed in API.     │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Distributed Monolith │ Microservices that must be deployed together.   │
│                      │ All the costs of distribution, none of the      │
│                      │ benefits of independence.                       │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Golden Hammer        │ Using one pattern/tool for everything. Not      │
│                      │ every problem is a nail.                        │
└──────────────────────┴──────────────────────────────────────────────────┘
```

For each detected anti-pattern:
```
ANTI-PATTERN FINDING:
Name: <anti-pattern name>
Location: <file:line>
Evidence:
```<language>
// The problematic code
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
2. Commit: `"pattern: <feature> — <pattern name> (<language>)"`
3. Suggest next steps:
   - "Pattern identified. Run `/godmode:refactor` to apply the pattern."
   - "Anti-patterns detected. Run `/godmode:fix` to remediate."
   - "Pattern designed. Run `/godmode:test` to write tests for the new structure."

## Key Behaviors

1. **Diagnose before prescribing.** Understand the actual problem in the codebase before recommending a pattern. A pattern applied to the wrong problem creates complexity, not clarity.
2. **One pattern at a time.** Recommend the single most impactful pattern first. Layering multiple patterns simultaneously makes code harder to understand.
3. **Show, don't tell.** Every recommendation includes language-specific implementation code. Abstract UML is not enough.
4. **Anti-patterns are patterns too.** Recognizing what NOT to do is as valuable as knowing what to do. Always scan for anti-patterns alongside recommendations.
5. **Context over dogma.** The "right" pattern depends on the language, framework, team, and problem. A Singleton in Go (package-level variable) is different from Singleton in Java.
6. **Simplicity wins.** If a problem can be solved with a function and an interface, don't recommend a full pattern. The simplest solution that works is the best solution.
7. **Teach the principle.** Explain the underlying principle (dependency inversion, open/closed, single responsibility) so the team can recognize when to apply the pattern themselves.

## Example Usage

### Finding a pattern for a problem
```
User: /godmode:pattern I have a notification system that needs to send
      via email, SMS, Slack, and push. New channels keep getting added.

Pattern: Analyzing the design problem...

PATTERN CONTEXT:
Problem: Multiple notification channels with new ones added frequently
Symptom: Growing if/else or switch statements in notification sending code
Category: Behavioral

PATTERN RECOMMENDATION:
┌────────────────────────────────────────────────────────────────────┐
│  Pattern: Strategy                                                │
│  Category: Behavioral                                             │
│  Confidence: HIGH                                                 │
├────────────────────────────────────────────────────────────────────┤
│  Problem it solves:                                               │
│  Multiple algorithms (channels) for the same operation (send      │
│  notification) with the expectation of adding more.               │
│                                                                    │
│  Why this pattern:                                                │
│  Encapsulates each channel as a strategy. Adding a new channel    │
│  means adding a new class, not modifying existing code (OCP).     │
│                                                                    │
│  Trade-offs:                                                      │
│  ✓ Open for extension (new channels = new class only)             │
│  ✓ Each channel is independently testable                         │
│  ✓ Channels can be swapped at runtime                             │
│  ✗ More files/classes than a simple switch                        │
│                                                                    │
│  Alternatives considered:                                         │
│  - Observer: rejected — this is not a 1-to-many broadcast         │
│  - Chain of Responsibility: viable if channels have priority/     │
│    fallback behavior (try email, fall back to SMS)                │
└────────────────────────────────────────────────────────────────────┘

Shall I generate the TypeScript implementation?
```

### Detecting anti-patterns
```
User: /godmode:pattern --detect Scan the codebase for anti-patterns

Pattern: Scanning...

ANTI-PATTERN FINDING 1:
Name: God Object
Location: src/services/UserService.ts:1-847
Evidence: 847 lines, 34 methods, handles auth, profile, billing, notifications
Impact: Any change risks breaking unrelated features. Impossible to test in isolation.
Remediation: Extract into focused services (AuthService, ProfileService,
             BillingService, NotificationService) using Facade if a unified
             interface is still needed.

ANTI-PATTERN FINDING 2:
Name: Primitive Obsession
Location: src/models/Order.ts:12
Evidence: `price: number` instead of `Money`, `email: string` instead of `Email`
Impact: No validation at the type level. Invalid values propagate silently.
Remediation: Introduce Value Objects (→ /godmode:ddd)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Analyze the current problem and recommend a pattern |
| `--detect` | Scan codebase for anti-patterns without recommending new patterns |
| `--gof` | Limit recommendations to Gang of Four patterns only |
| `--modern` | Limit recommendations to modern/distributed patterns only |
| `--implement <pattern>` | Skip analysis, implement a specific pattern directly |
| `--compare <p1> <p2>` | Compare two specific patterns for the current problem |
| `--language <lang>` | Generate implementation in a specific language |
| `--teach` | Extended explanation with underlying SOLID principles |

## Anti-Patterns

- **Do NOT recommend patterns without understanding the problem.** "Use a Factory" means nothing without knowing what creation problem exists. Diagnose first.
- **Do NOT apply patterns prophylactically.** A pattern should solve a current problem, not a theoretical future one. YAGNI applies to patterns too.
- **Do NOT recommend Singleton for dependency sharing.** Use dependency injection instead. Singleton is rarely the right answer in modern codebases.
- **Do NOT stack multiple patterns at once.** Recommend one pattern, let the team implement it, then evaluate if another is needed. Pattern layering causes accidental complexity.
- **Do NOT ignore language idioms.** A Visitor in Python (which has duck typing) looks very different from Visitor in Java. Respect the language's strengths.
- **Do NOT confuse patterns with frameworks.** "Use Redux" is not a pattern recommendation. The pattern is "unidirectional data flow" or "event sourcing on the client."
- **Do NOT treat patterns as sacred.** Partial implementations are fine. You don't need the full GoF specification to benefit from the core idea of a pattern.
