# /godmode:ddd

Apply Domain-Driven Design to your domain. Covers strategic design (bounded contexts, context mapping, ubiquitous language), tactical design (aggregates, entities, value objects, domain events, repositories), and event storming facilitation.

## Usage

```
/godmode:ddd                                      # Full DDD session
/godmode:ddd --strategic                          # Strategic design only (contexts, map, language)
/godmode:ddd --tactical                           # Tactical design only (aggregates, entities, events)
/godmode:ddd --event-storm                        # Facilitated event storming session
/godmode:ddd --aggregate Order                    # Design a specific aggregate's internals
/godmode:ddd --context-map                        # Generate or update bounded context map
/godmode:ddd --language                           # Build ubiquitous language glossary
/godmode:ddd --scaffold                           # Generate directory structure from domain model
/godmode:ddd --validate                           # Validate domain model against DDD principles
```

## What It Does

1. Discovers the domain (core, supporting, generic subdomains)
2. Establishes the ubiquitous language with precise definitions
3. Facilitates event storming (events, timeline, commands, actors, aggregates, context boundaries)
4. Defines bounded contexts and draws the context map
5. Designs aggregate internals (root entity, child entities, value objects, invariants)
6. Catalogs domain events with payloads and schemas
7. Generates implementation scaffold (directory structure, skeleton code)

## Output
- Domain model at `docs/domain/<context>-domain-model.md`
- Event catalog at `docs/domain/event-catalog.md`
- Context map at `docs/domain/context-map.md`
- Ubiquitous language at `docs/domain/ubiquitous-language.md`
- Commit: `"ddd: <context> — bounded contexts, aggregates, and event catalog"`

## Next Step
After ddd completes:
- `/godmode:architect` to select architecture for the domain
- `/godmode:plan` to decompose aggregate implementation into tasks
- `/godmode:pattern` to select implementation patterns per aggregate

## Examples

```
/godmode:ddd Model the domain for our healthcare scheduling platform
/godmode:ddd --event-storm We're building a food delivery marketplace
/godmode:ddd --aggregate Payment                   # Design the Payment aggregate boundaries
/godmode:ddd --strategic                           # Just contexts and mapping, skip tactical
/godmode:ddd --scaffold                            # Generate code skeleton from existing model
/godmode:ddd --validate                            # Check our domain model for DDD violations
```
