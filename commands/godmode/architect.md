# /godmode:architect

Design system architecture with pattern evaluation, trade-off analysis, C4 diagrams, and Architecture Decision Records. Covers monolith, microservices, serverless, event-driven, CQRS, and hexagonal architectures.

## Usage

```
/godmode:architect                                # Full architecture analysis
/godmode:architect --quick                        # Recommend based on constraints, skip comparison matrix
/godmode:architect --compare monolith microservices serverless  # Compare specific patterns
/godmode:architect --c4                           # Generate C4 diagrams for existing architecture
/godmode:architect --adr                          # Generate Architecture Decision Record only
/godmode:architect --context-map                  # Generate bounded context map only
/godmode:architect --migrate                      # Migration analysis (current → target)
/godmode:architect --validate                     # Validate architecture against requirements
```

## What It Does

1. Gathers requirements (scale, team size, deployment, constraints, compliance)
2. Evaluates 3+ candidate architecture patterns with trade-off analysis
3. Presents a weighted comparison matrix with scores
4. Produces C4 diagrams (Context, Container, Component, Code levels)
5. Maps bounded contexts and their relationships
6. Analyzes quality attributes (scalability, reliability, maintainability, security, observability)
7. Writes an Architecture Decision Record documenting the rationale

## Output
- Architecture document at `docs/architecture/<system>-architecture.md`
- ADR at `docs/adr/<number>-<decision>.md`
- Commit: `"architect: <system> — <pattern> architecture with C4 diagrams and ADR"`

## Next Step
After architect completes:
- `/godmode:ddd` to define domain boundaries and aggregates
- `/godmode:api` to design the API layer
- `/godmode:plan` to decompose into implementation tasks

## Examples

```
/godmode:architect Design architecture for a real-time chat platform with 100K concurrent users
/godmode:architect --compare microservices event-driven
/godmode:architect --c4                              # Diagram existing architecture
/godmode:architect --migrate We need to break up our monolith
/godmode:architect --adr Document why we chose event-driven over request-response
```
