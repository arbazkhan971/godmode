---
name: learn
description: |
  Learning and teaching skill. Activates when user wants to learn coding concepts, understand design patterns, get best practices for a language or framework, build a knowledge base from their codebase, or generate interactive tutorials. Adapts to skill level, provides hands-on examples from the actual codebase, and creates personalized learning paths. Triggers on: /godmode:learn, "teach me", "how does this work?", "best practices for", "what pattern should I use?", or when user is exploring unfamiliar code.
---

# Learn — Learning & Teaching

## When to Activate
- User invokes `/godmode:learn`
- User says "teach me," "how does this work?", "explain this code"
- User asks "what pattern should I use for X?"
- User wants best practices for a specific language or framework
- User is onboarding to an unfamiliar codebase
- User requests a tutorial or learning path

## Workflow

### Step 1: Assess Learning Context
Understand what the user wants to learn and their current level:

```
LEARNING CONTEXT:
Topic: <what the user wants to learn>
Category: <concept | pattern | language | framework | codebase | architecture>
Current level: <beginner | intermediate | advanced | unknown>
Learning style: <explain | tutorial | by-example | deep-dive>

Codebase context:
  Language(s): <languages in the project>
  Framework(s): <frameworks in use>
  Relevant files: <files related to the topic>
  Existing patterns: <patterns already used in the codebase>
```

If the user's level is unclear, ask ONE calibration question:
```
"Before I explain <topic>, quick calibration: are you familiar with <prerequisite concept>?
This helps me pitch the explanation at the right level."
```

### Step 2: Interactive Code Tutorials
Create hands-on tutorials using the actual codebase:

#### Tutorial Structure
```
TUTORIAL: <Title>
Level: <beginner | intermediate | advanced>
Prerequisites: <concepts the reader should already know>
Estimated time: <minutes>
Goal: <what the reader will be able to do after completing this>

STEP 1: <Title>
─────────────────
Context: <why this step matters>

Look at this code in your project:
  File: <actual file path>
  Lines: <line range>

```<language>
// The relevant code from the codebase
<actual code>
```

What's happening here:
  1. <explanation of line/block 1>
  2. <explanation of line/block 2>
  3. <explanation of line/block 3>

Key insight: <the one thing to remember from this step>

TRY IT: <hands-on exercise>
  1. <specific action the user should take>
  2. <what to observe>
  3. <what it demonstrates>

STEP 2: <Title>
─────────────────
...

STEP N: <Title>
─────────────────
...

CHECKPOINT:
  You should now understand:
  - [ ] <concept 1>
  - [ ] <concept 2>
  - [ ] <concept 3>

  Test your understanding:
  Q: <question that requires applying the concept, not just recalling>
  A: <answer, hidden until user asks>
```

### Step 3: Design Pattern Recommendations
When the user has a specific problem, recommend the right pattern:

```
PATTERN RECOMMENDATION:
Problem: <what the user is trying to solve>
Context: <constraints, scale, team size, language>

Recommended pattern: <Pattern Name>
Alternative patterns: <Pattern B (why not), Pattern C (when instead)>

WHY THIS PATTERN:
  Fits because: <specific reasons this pattern solves the problem>
  Trade-offs:
    PRO: <advantage 1>
    PRO: <advantage 2>
    CON: <trade-off 1>
    CON: <trade-off 2>

HOW IT WORKS:
```
<ASCII diagram of the pattern>
```

IMPLEMENTATION IN YOUR CODEBASE:

Before (current approach):
```<language>
// Current code that could benefit from this pattern
<actual code from codebase>
```

After (with pattern applied):
```<language>
// Same code restructured with the recommended pattern
<refactored code>
```

REAL-WORLD EXAMPLES IN YOUR CODEBASE:
  <file path>: Already uses this pattern for <purpose>
  <file path>: Could benefit from this pattern (currently <describes current approach>)

WHEN NOT TO USE THIS PATTERN:
  - <scenario where this pattern is overkill>
  - <scenario where a simpler approach works>
  - <scenario where a different pattern is better>
```

#### Common Pattern Categories
```
CREATIONAL PATTERNS:
  Factory, Builder, Singleton, Prototype, Dependency Injection

STRUCTURAL PATTERNS:
  Adapter, Decorator, Facade, Proxy, Composite, Bridge

BEHAVIORAL PATTERNS:
  Strategy, Observer, Command, State, Chain of Responsibility,
  Template Method, Iterator, Mediator, Visitor

ARCHITECTURAL PATTERNS:
  MVC, MVVM, Repository, CQRS, Event Sourcing, Hexagonal,
  Microservices, Monolith, Modular Monolith, Serverless

CONCURRENCY PATTERNS:
  Producer-Consumer, Fan-Out/Fan-In, Pipeline, Saga,
  Circuit Breaker, Bulkhead, Retry with Backoff
```

### Step 4: Best Practices Enforcement
Provide language- and framework-specific best practices:

```
BEST PRACTICES: <Language/Framework>

CATEGORY: <Error Handling | Performance | Security | Testing | Style>

Practice: <specific best practice>
Why: <the reasoning behind it>
Level: <MUST | SHOULD | MAY> (RFC 2119 levels)

Good:
```<language>
// Code that follows the practice
<example>
```

Bad:
```<language>
// Code that violates the practice
<example>
```

In your codebase:
  FOLLOWS practice: <file:line> — <description>
  VIOLATES practice: <file:line> — <description and how to fix>
```

#### Framework-Specific Checklists
```
BEST PRACTICES CHECKLIST: <Framework>
┌──────────────────────────────────────────────────────────┐
│ Category        │ Practice                 │ Codebase    │
├──────────────────────────────────────────────────────────┤
│ Performance     │ <practice>               │ FOLLOWS/NOT │
│ Performance     │ <practice>               │ FOLLOWS/NOT │
│ Security        │ <practice>               │ FOLLOWS/NOT │
│ Security        │ <practice>               │ FOLLOWS/NOT │
│ Error Handling  │ <practice>               │ FOLLOWS/NOT │
│ Testing         │ <practice>               │ FOLLOWS/NOT │
│ Architecture    │ <practice>               │ FOLLOWS/NOT │
└──────────────────────────────────────────────────────────┘

Overall adherence: <N>/<total> practices followed
Priority fixes: <top 3 practices to adopt first>
```

### Step 5: Codebase Knowledge Base
Build a structured understanding of the codebase:

```
CODEBASE KNOWLEDGE BASE:

Architecture overview:
  Pattern: <monolith | microservices | modular monolith | serverless>
  Entry points: <main files, route definitions>
  Data flow: <request → handler → service → repository → database>

Module map:
┌──────────────────────────────────────────────────────────┐
│ Module          │ Purpose              │ Key files        │
├──────────────────────────────────────────────────────────┤
│ <module-1>      │ <what it does>       │ <key files>      │
│ <module-2>      │ <what it does>       │ <key files>      │
│ <module-3>      │ <what it does>       │ <key files>      │
└──────────────────────────────────────────────────────────┘

Dependency graph:
  <module-1> → <module-2> (uses <interface>)
  <module-2> → <module-3> (uses <interface>)
  <module-3> → <external service> (via <client>)

Conventions:
  Naming: <conventions used — camelCase, snake_case, PascalCase>
  File structure: <how files are organized>
  Error handling: <how errors are handled — exceptions, Result types, error codes>
  Testing: <testing approach — unit, integration, e2e, test file locations>
  Configuration: <how config is managed — env vars, config files, feature flags>

Key domain concepts:
  <Concept 1>: <definition, where it lives in code>
  <Concept 2>: <definition, where it lives in code>
  <Concept 3>: <definition, where it lives in code>

Gotchas & tribal knowledge:
  1. <non-obvious thing that trips up newcomers>
  2. <historical decision that seems wrong but has a reason>
  3. <performance-sensitive area that needs careful handling>
```

### Step 6: Skill Assessment & Learning Path
Evaluate current skill level and generate a personalized learning path:

```
SKILL ASSESSMENT: <User> — <Domain>

Assessment method: Code review of recent contributions + conversation

┌──────────────────────────────────────────────────────────┐
│ Skill Area         │ Level        │ Evidence             │
├──────────────────────────────────────────────────────────┤
│ Language basics     │ <1-5>        │ <observation>        │
│ Design patterns     │ <1-5>        │ <observation>        │
│ Error handling      │ <1-5>        │ <observation>        │
│ Testing             │ <1-5>        │ <observation>        │
│ Performance         │ <1-5>        │ <observation>        │
│ Security            │ <1-5>        │ <observation>        │
│ Architecture        │ <1-5>        │ <observation>        │
│ Code readability    │ <1-5>        │ <observation>        │
│ Debugging           │ <1-5>        │ <observation>        │
│ Tools & workflow    │ <1-5>        │ <observation>        │
└──────────────────────────────────────────────────────────┘

Overall level: <beginner | intermediate | advanced>
Strongest areas: <top 3>
Growth areas: <top 3>

PERSONALIZED LEARNING PATH:

Week 1-2: <Focus area>
  Goal: <what to achieve>
  Resources:
    - Tutorial: <specific tutorial or exercise>
    - Practice: <specific task in the codebase>
    - Read: <specific file in the codebase to study>

Week 3-4: <Focus area>
  Goal: <what to achieve>
  Resources:
    - Tutorial: <specific tutorial or exercise>
    - Practice: <specific task in the codebase>
    - Read: <reference material>

Week 5-6: <Focus area>
  Goal: <what to achieve>
  Resources:
    - Project: <small project that exercises the skill>
    - Review: <PR or code to review for learning>
    - Teach: <concept to explain to someone else>

Milestones:
  [ ] <Milestone 1 — verifiable achievement>
  [ ] <Milestone 2 — verifiable achievement>
  [ ] <Milestone 3 — verifiable achievement>
```

### Step 7: Transition
After teaching:
```
Ready to apply what you learned? Here are some next steps:
- `/godmode:build` to implement something using the pattern we discussed
- `/godmode:review` to get feedback on your implementation
- `/godmode:optimize` to improve performance using the techniques covered
- `/godmode:learn --next` to continue to the next topic in your learning path
```

## Key Behaviors

1. **Use the actual codebase.** Never teach with generic examples when the user's own codebase has relevant examples. "Here's how YOUR code uses the Observer pattern" is 10x more effective than a textbook example.
2. **Calibrate to level.** A beginner needs "what" and "why." An advanced developer needs "when" and "trade-offs." Do not over-explain to experts or under-explain to beginners.
3. **One concept at a time.** Do not dump 15 patterns on the user. Recommend the ONE pattern that solves their problem, explain it thoroughly, and let them ask for more.
4. **Hands-on over theory.** Every concept should have a "TRY IT" exercise. Reading about patterns does not build skill. Applying them does.
5. **Show trade-offs, not just solutions.** Every pattern has costs. "This adds indirection" or "this increases complexity" are important to mention. No pattern is universally good.
6. **Build on existing knowledge.** Connect new concepts to things the user already knows. "This is like the Strategy pattern you already use in your auth module, but applied to..."
7. **Learning paths are personalized.** A React developer learning Go needs a different path than a Go developer learning React. Assess what they already know and build from there.

## Example Usage

### Learning a design pattern
```
User: /godmode:learn What pattern should I use for handling different
      payment methods (credit card, PayPal, crypto)?

Learn: Great question. Let me assess the right pattern for this.

PATTERN RECOMMENDATION:
Problem: Multiple payment methods with different processing logic
Context: E-commerce app, TypeScript, 3 payment methods now, likely more later

Recommended pattern: Strategy Pattern
Alternative: Factory + Strategy (if payment creation is also complex)

WHY STRATEGY:
  Fits because:
  - Each payment method has the same interface (charge, refund, verify)
  - But different implementation logic
  - New payment methods should be addable without changing existing code
  - Runtime selection based on user choice

HOW IT WORKS:

  ┌─────────────┐     ┌───────────────────┐
  │ PaymentCtrl  │────▶│ PaymentStrategy   │ (interface)
  └─────────────┘     ├───────────────────┤
                      │ + charge(amount)  │
                      │ + refund(txId)    │
                      │ + verify(txId)    │
                      └───────┬───────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
     ┌──────────────┐ ┌────────────┐ ┌──────────────┐
     │ CreditCard   │ │  PayPal    │ │   Crypto     │
     │ Strategy     │ │  Strategy  │ │  Strategy    │
     └──────────────┘ └────────────┘ └──────────────┘

IMPLEMENTATION:

interface PaymentStrategy {
  charge(amount: number): Promise<Transaction>;
  refund(transactionId: string): Promise<void>;
  verify(transactionId: string): Promise<boolean>;
}

class CreditCardStrategy implements PaymentStrategy {
  async charge(amount: number) { /* Stripe API call */ }
  async refund(txId: string) { /* Stripe refund */ }
  async verify(txId: string) { /* Stripe verify */ }
}

// Add new payment methods by adding new classes — no existing code changes

TRY IT:
  1. Create the PaymentStrategy interface in src/services/payment/
  2. Implement CreditCardStrategy
  3. Write a test that swaps strategies and verifies both work
  4. Notice how adding PayPalStrategy requires ZERO changes to existing code
```

### Building a codebase knowledge base
```
User: /godmode:learn I just joined this team, help me understand the codebase

Learn: Let me build a knowledge base for you.

[Analyzes project structure, dependencies, patterns, and conventions]

CODEBASE KNOWLEDGE BASE:
Architecture: Modular monolith (Express.js)
Entry point: src/server.ts → src/routes/index.ts
Data flow: Route → Controller → Service → Repository → PostgreSQL

Module map:
  auth/     — Authentication (JWT, OAuth, session management)
  users/    — User management (CRUD, profiles, preferences)
  payments/ — Payment processing (Stripe integration)
  orders/   — Order lifecycle (create, fulfill, cancel)

Conventions:
  Files: kebab-case, one class per file
  Tests: co-located (user.service.ts → user.service.test.ts)
  Errors: Custom error classes extending AppError

Gotchas:
  1. The auth middleware runs BEFORE route validation — don't access
     req.body in auth middleware (it's not parsed yet)
  2. payments/ uses a saga pattern for multi-step transactions —
     don't add direct DB writes, use the saga coordinator

Start exploring: src/routes/index.ts (see all endpoints at a glance)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive learning session — ask what to learn |
| `--pattern <name>` | Explain a specific design pattern with codebase examples |
| `--best-practices <lang>` | Best practices for a specific language/framework |
| `--tutorial <topic>` | Create a step-by-step tutorial |
| `--codebase` | Build a knowledge base of the current codebase |
| `--assess` | Skill assessment and learning path generation |
| `--next` | Continue to next topic in learning path |
| `--level <level>` | Set explanation level: beginner, intermediate, advanced |
| `--quick` | Brief explanation without full tutorial |

## Anti-Patterns

- **Do NOT lecture.** Learning is interactive. After explaining a concept, give the user something to DO, not more to READ.
- **Do NOT use only textbook examples.** The user's codebase is the best teaching material. Use real code from their project whenever possible.
- **Do NOT overwhelm with options.** "Here are 12 patterns you could use" is not helpful. Recommend ONE, explain why, and mention alternatives briefly.
- **Do NOT skip trade-offs.** Every pattern, practice, and approach has costs. Presenting only benefits creates false confidence and poor decisions.
- **Do NOT assume skill level.** A senior developer might be a beginner in a new language. An intern might be advanced in a specific framework. Calibrate, do not assume.
- **Do NOT teach without context.** "The Observer pattern decouples subjects from observers" is a definition, not teaching. "In YOUR notification system, Observer would let you add email, SMS, and push notifications without changing the event emitter" is teaching.
