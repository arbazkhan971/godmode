# /godmode:pattern

Recommend the right design pattern for your problem. Covers Gang of Four patterns, modern distributed system patterns (Repository, CQRS, Saga, Circuit Breaker, Outbox, Strangler Fig), anti-pattern detection, and language-specific implementations.

## Usage

```
/godmode:pattern                                  # Analyze current problem and recommend a pattern
/godmode:pattern --detect                         # Scan codebase for anti-patterns
/godmode:pattern --gof                            # Limit to Gang of Four patterns only
/godmode:pattern --modern                         # Limit to modern/distributed patterns only
/godmode:pattern --implement <pattern>            # Implement a specific pattern directly
/godmode:pattern --compare strategy observer      # Compare two patterns for the current problem
/godmode:pattern --language python                # Generate implementation in a specific language
/godmode:pattern --teach                          # Extended explanation with SOLID principles
```

## What It Does

1. Analyzes the design problem (what feels wrong, what needs to change)
2. Classifies into Creational, Structural, Behavioral, or Modern/Distributed
3. Evaluates candidate patterns with confidence rating
4. Recommends a pattern with trade-offs and rejected alternatives
5. Produces language-specific implementation with tests
6. Optionally scans for anti-patterns (God Object, Spaghetti Code, Shotgun Surgery, Primitive Obsession, Anemic Domain, Circular Dependency, Distributed Monolith)

## Output
- Pattern analysis at `docs/patterns/<feature>-pattern-analysis.md`
- Commit: `"pattern: <feature> — <pattern name> (<language>)"`

## Next Step
After pattern completes:
- `/godmode:refactor` to apply the pattern to existing code
- `/godmode:test` to write tests for the new structure
- `/godmode:fix` to remediate detected anti-patterns

## Examples

```
/godmode:pattern I have 5 notification channels and keep adding more
/godmode:pattern --detect                         # Find anti-patterns in the codebase
/godmode:pattern --implement circuit-breaker      # Implement circuit breaker directly
/godmode:pattern --compare saga outbox            # Compare saga vs outbox for our use case
/godmode:pattern --teach strategy                 # Deep explanation of Strategy with SOLID principles
```
