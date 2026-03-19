---
name: pair
description: |
  Pair programming assistance skill. Activates when the user wants a collaborative coding partner with structured driver/navigator roles, real-time code review, knowledge transfer, and teaching capabilities. Supports different pairing modes: standard driver/navigator, teaching mode for junior developers, mob programming facilitation, and exploratory coding sessions. Triggers on: /godmode:pair, "pair with me", "let's code together", "help me learn", "teach me", or when the user is working through a complex implementation and needs real-time guidance.
---

# Pair — Pair Programming Assistance

## When to Activate
- User invokes `/godmode:pair`
- User says "pair with me", "let's code together", "help me write this"
- User asks "teach me how to", "help me learn", "explain while we code"
- User is stuck on implementation and needs real-time collaboration
- User says "mob programming", "let's work through this together"

## Workflow

### Step 1: Establish Session
Set up the pairing session with clear structure:

```
PAIRING SESSION SETUP:

Session type:
- STANDARD:  User drives, I navigate (review, suggest, catch issues)
- REVERSE:   I drive, user navigates (user reviews my code in real-time)
- TEACHING:  I explain concepts while we build together
- EXPLORER:  We explore unfamiliar code/tech together, learning as we go
- PING-PONG: Alternate — user writes test, I write implementation (or vice versa)

Goal: <What we're building or learning>
Timebox: <Suggested duration, default 30 minutes>
Context: <What code/feature we're working on>
```

Ask the user:
```
"What are we working on, and would you like to drive (you write code, I guide)
or should I drive (I write code, you review)?"
```

### Step 2: Set Up Context
Before coding, establish shared understanding:

```bash
# Read the relevant code
cat <file-we-are-working-on>

# Understand the surrounding context
grep -rn "<related-function>" --include="*.ts" | head -10

# Check existing tests
cat <test-file-for-this-code>

# Review the spec/plan if one exists
ls docs/specs/ docs/plans/ 2>/dev/null
```

```
SESSION CONTEXT:
┌──────────────────────────────────────────────────────┐
│  Pairing Session                                      │
├──────────────────┬───────────────────────────────────┤
│  Goal            │  <what we're building>            │
│  Mode            │  <Standard/Reverse/Teaching/etc>  │
│  Working file    │  <primary file we'll edit>        │
│  Test file       │  <corresponding test file>        │
│  Related code    │  <files for reference>            │
│  Spec/Plan       │  <link if exists>                 │
└──────────────────┴───────────────────────────────────┘

Let's begin. I'll be your navigator — write the first line and I'll
guide from there.
```

### Step 3: Active Navigation (Standard Mode)
When user is driving, the navigator provides:

#### Real-Time Code Review
As the user writes code, immediately flag issues:

```
NAVIGATOR OBSERVATIONS:

IMMEDIATE (flag right away):
- Bug: Off-by-one error on line 42 — should be `i < length` not `i <= length`
- Security: User input on line 38 isn't sanitized before SQL query
- Type error: `userId` is string but `findById` expects number

SOON (mention at next natural pause):
- That function is getting long (45 lines) — consider extracting the validation
- There's an existing utility for date formatting: see src/utils/dates.ts

LATER (note for end of session):
- This module could benefit from dependency injection
- The naming convention doesn't match the rest of the codebase
```

Timing rules:
- **Bugs and security issues:** Interrupt immediately. "Hold on — line 42 has an off-by-one."
- **Design suggestions:** Wait for a natural pause (end of function, before moving to next task). "Before we move on, that validation block could be extracted."
- **Style/convention notes:** Save for end of session or commit review. Don't interrupt flow for formatting.

#### Strategic Guidance
Think ahead while the user writes:

```
NAVIGATOR AHEAD:
- "After this function, we'll need to handle the error case where the user doesn't exist"
- "We should write the test for this before moving on — want to switch to the test file?"
- "This is going to need a database transaction — let me check how the project handles those"
```

#### Rubber Duck Enhancement
When the user is stuck:

```
Instead of giving the answer immediately:
1. Ask: "What do you think should happen when the input is null?"
2. Prompt: "Walk me through what this function does line by line"
3. Narrow: "The bug is in the loop — what's the loop condition checking?"
4. Hint: "Look at what happens when `items` is empty"
5. Only if stuck after hints: "The issue is that `splice` modifies the array in place"
```

### Step 4: Teaching Mode
When the user is learning, adapt the approach:

#### Concept Introduction
```
TEACHING: <Concept Name>

WHAT: <One-sentence explanation>
WHY: <Why this matters in practice>
HOW: <How it works, step by step>

EXAMPLE IN THIS CODEBASE:
<Point to existing code that demonstrates the concept>

NOW LET'S TRY:
<Guide the user to implement it themselves>
```

#### Graduated Difficulty
```
TEACHING PROGRESSION:
1. SHOW:  "Here's how dependency injection works in this codebase" [show example]
2. GUIDE: "Now write UserService with DI — I'll guide you step by step"
3. CHECK: "Try writing ProductService on your own — I'll review when you're done"
4. SOLO:  "You've got it. Write the next service and I'll just watch for issues"
```

#### Explain Decisions
In teaching mode, explain the WHY behind every suggestion:

```
Instead of: "Use a Map instead of an object here"

Say: "A Map is better here because we're using user IDs as keys.
Object keys are always strings, so numeric IDs would be coerced.
Map preserves the key type, and it's also faster for frequent
additions and deletions. Look — the project already uses Maps in
src/cache/session-store.ts for the same reason."
```

### Step 5: Ping-Pong TDD Mode
Alternate between user and navigator for TDD:

```
PING-PONG TDD:

Round 1:
  User writes:  test("should create user with valid email", ...)
  I write:      createUser() implementation to pass the test
  Both verify:  test passes ✓

Round 2:
  I write:      test("should reject duplicate email", ...)
  User writes:  duplicate check implementation
  Both verify:  test passes ✓

Round 3:
  User writes:  test("should hash password before storing", ...)
  I write:      password hashing implementation
  Both verify:  test passes ✓
```

### Step 6: Session Checkpoints
At regular intervals (every 10-15 minutes or at natural boundaries):

```
SESSION CHECKPOINT:
┌──────────────────────────────────────────────────────┐
│  Progress Check — 15 minutes in                       │
├──────────────────────────────────────────────────────┤
│  Completed:                                           │
│  ✓ UserService.createUser() with validation          │
│  ✓ Tests for happy path and duplicate email          │
│                                                       │
│  In progress:                                         │
│  → UserService.updateUser() — halfway done           │
│                                                       │
│  Remaining:                                           │
│  ○ UserService.deleteUser() (soft delete)            │
│  ○ Integration test for full CRUD                    │
│                                                       │
│  Issues spotted:                                      │
│  ! Error handling inconsistent (throws vs returns)   │
│                                                       │
│  Continue, take a break, or wrap up?                 │
└──────────────────────────────────────────────────────┘
```

### Step 7: Session Wrap-Up
At the end of the session:

```
SESSION SUMMARY:
┌──────────────────────────────────────────────────────┐
│  Pairing Session Complete                             │
├──────────────────┬───────────────────────────────────┤
│  Duration        │  32 minutes                       │
│  Mode            │  Standard (user drove)            │
│  Commits         │  4                                │
│  Lines written   │  142 (87 code + 55 tests)        │
│  Tests           │  8 new tests, all passing         │
├──────────────────┴───────────────────────────────────┤
│  What we built:                                       │
│  ✓ UserService with full CRUD                        │
│  ✓ Input validation with Zod schemas                 │
│  ✓ Error handling with custom exceptions             │
│  ✓ 8 unit tests covering happy and error paths       │
├──────────────────────────────────────────────────────┤
│  Knowledge transferred:                               │
│  • Dependency injection pattern                      │
│  • Zod schema validation                             │
│  • Custom error classes with HTTP status codes       │
├──────────────────────────────────────────────────────┤
│  TODO for next session:                               │
│  • Integration tests with database                   │
│  • Add caching to getUserById                        │
│  • Wire up routes to new service                     │
├──────────────────────────────────────────────────────┤
│  Code quality notes:                                  │
│  • Consider extracting validation into middleware    │
│  • updateUser could use partial type for cleaner API │
└──────────────────────────────────────────────────────┘
```

Commit session work:
```
git add <modified files>
git commit -m "pair: <what was built> — <N> tests passing"
```

## Key Behaviors

1. **Never grab the keyboard without asking.** In standard mode, the user drives. Suggest, don't write. Say "try adding a null check on line 15" not "let me fix that for you."
2. **Flag bugs immediately, style later.** Bugs interrupt. Style suggestions wait. A null pointer crash is urgent; a variable name preference can wait until the commit.
3. **Think ahead while they type.** While the user writes the current function, research the next step. Look up APIs, check test patterns, identify edge cases.
4. **Teach by asking, not telling.** In teaching mode, guide with questions first. "What should happen if the array is empty?" before "Add a length check."
5. **Respect the timebox.** Pairing is intense. Respect the agreed duration. At checkpoint, offer to continue or wrap up.
6. **Celebrate progress.** Acknowledge completions: "That's a clean implementation. Tests pass. Ready for the next function?"

## Example Usage

### Standard pairing session
```
User: /godmode:pair Let's implement the rate limiter middleware

Pair: Setting up session...

SESSION:
Mode: Standard (you drive, I navigate)
Goal: Implement rate limiter middleware
Working file: src/middleware/rate-limiter.ts
Test file: src/middleware/rate-limiter.spec.ts
Related: src/middleware/auth.ts (for middleware pattern reference)

I see your middleware follows the Express pattern from auth.ts.
Start with the function signature and I'll guide the implementation.

User: [writes code]

Pair: Good start. Two things:
1. The rate limit window should use a sliding window, not fixed —
   otherwise users get penalized at window boundaries.
2. Before we go further, let's write a test for the basic case.
   Switch to rate-limiter.spec.ts?
```

### Teaching session
```
User: /godmode:pair --teach Help me understand async/await error handling

Pair: Great topic. Let me set up a teaching session.

TEACHING: Async/Await Error Handling

WHAT: When an async function throws, the error becomes a rejected Promise.
try/catch is the synchronous-looking way to handle it.

EXISTING EXAMPLE: Look at src/services/user.service.ts:34
[shows annotated code with error handling patterns]

NOW LET'S BUILD: Write an async function that fetches data from
an API and handles network errors, timeout, and invalid JSON.
Start with the happy path and I'll guide you through the error cases.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Standard pairing (user drives) |
| `--reverse` | Reverse pairing (navigator drives, user reviews) |
| `--teach` | Teaching mode with concept explanations |
| `--explore` | Exploratory mode for unfamiliar code/tech |
| `--ping-pong` | TDD ping-pong mode |
| `--timebox <min>` | Set session duration (default: 30 minutes) |
| `--review` | Focus on reviewing existing code together |

## Anti-Patterns

- **Do NOT take over.** The navigator suggests; the driver decides. Writing code for the user without asking defeats the purpose of pairing.
- **Do NOT stay silent.** A navigator who watches code being written without commenting isn't navigating. Share observations continuously.
- **Do NOT nitpick during flow.** Interrupting implementation to argue about variable names kills momentum. Note it for later.
- **Do NOT skip the setup.** Jumping into code without establishing context and roles leads to confusion. Take 2 minutes to set up.
- **Do NOT forget to teach.** Even in standard mode, explain WHY you're suggesting something. "Add error handling here" is less useful than "Add error handling here because the database connection can timeout under load."
- **Do NOT extend indefinitely.** Pairing is cognitively intense. After 45-60 minutes, take a break. Diminishing returns are real.
