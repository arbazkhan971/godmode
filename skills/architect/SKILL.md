---
name: architect
description: |
  Software architecture skill. Activates when user needs to design system architecture, select architecture patterns, create C4 diagrams, or apply domain-driven design at the strategic level. Evaluates trade-offs across monolith, microservices, serverless, event-driven, CQRS, and hexagonal architectures. Produces architecture decision records, C4 diagrams, and bounded context maps. Triggers on: /godmode:architect, "design the architecture", "system design", "how should I structure this", or when the orchestrator detects architecture-level decisions.
---

# Architect — Software Architecture Design

## When to Activate
- User invokes `/godmode:architect`
- User says "design the architecture", "system design", "how should I structure this"
- User asks about monolith vs. microservices, serverless, or event-driven decisions
- When starting a greenfield project that needs structural decisions
- When `/godmode:think` identifies architecture as the primary concern
- When a system is hitting scaling, reliability, or maintainability walls

## Workflow

### Step 1: Context & Requirements Gathering
Understand the system before recommending architecture:

```
ARCHITECTURE CONTEXT:
System: <name and purpose>
Stage: <greenfield | evolving | rewrite | migration>
```

### Step 2: Architecture Pattern Evaluation
Evaluate candidate patterns against the requirements. Always evaluate at least 3 patterns:

#### Pattern Evaluation Template
For each candidate (evaluate at least 3), fill:
```
PATTERN: <Name>
├── Structure: <one-line architecture summary>
├── Strengths: <key advantages for this system>
├── Weaknesses: <key disadvantages and operational cost>
└── Best when: <conditions where this pattern wins>
```

Candidate patterns: Modular Monolith, Microservices, Serverless/FaaS, Event-Driven, CQRS, Hexagonal (Ports & Adapters). Evaluate the most relevant 3-6 for the system.

### Step 3: Architecture Comparison Matrix
Present a structured comparison:

```
  ARCHITECTURE COMPARISON — <system name>
```

### Step 4: C4 Architecture Diagrams
Produce diagrams at all four C4 levels for the chosen architecture:

#### Level 1: System Context
Who uses the system and what external systems does it interact with?
```
C4 CONTEXT DIAGRAM:
  Users / Actors
```

#### Level 2: Container Diagram
What are the major deployable units?
```
C4 CONTAINER DIAGRAM:
  <<System>> <System Name>
```

#### Level 3: Component Diagram
What are the major components within each container?
```
C4 COMPONENT DIAGRAM — <Container Name>:
  <<Container>> API Service
```

#### Level 4: Code Diagram
What are the key classes/modules and their relationships?
```
C4 CODE DIAGRAM — <Component>:
Show key interfaces, classes, and their relationships.
Use the codebase's actual language idioms (classes for Java/C#,
```

### Step 5: Domain-Driven Design — Strategic View
Map bounded contexts and their relationships:

```
BOUNDED CONTEXT MAP:
```

### Step 6: Quality Attribute Analysis
For the recommended architecture, analyze non-functional requirements:

```
QUALITY ATTRIBUTES:
| Attribute | How the architecture addresses it |
```

### Step 7: Architecture Decision Record
Document the decision formally:

```markdown
# ADR-<number>: <Architecture Decision Title>

## Status
```

### Step 8: Artifacts & Transition
1. Save architecture document: `docs/architecture/<system>-architecture.md`
2. Save ADR: `docs/adr/<number>-<decision>.md`
3. Save diagrams inline in the architecture document
4. Commit: `"architect: <system> — <pattern> architecture with C4 diagrams and ADR"`
5. Suggest next steps:
   - "Architecture designed. Run `/godmode:ddd` to define domain boundaries and aggregates."
   - "Architecture designed. Run `/godmode:plan` to decompose into implementation tasks."
   - "Architecture designed. Run `/godmode:api` to design the API layer."

## Key Behaviors

Never ask to continue. Loop autonomously until architecture comparison matrix, C4 diagrams, and ADR are complete.

1. **Requirements before patterns.** Never recommend an architecture without understanding scale expectations, team size, and constraints. A microservice architecture for a 2-person team is malpractice.
2. **Always compare at least 3 options.** Even if the answer seems obvious, the comparison matrix forces rigorous thinking and documents why alternatives were rejected.
3. **C4 diagrams are mandatory.** At minimum produce Level 1 (Context) and Level 2 (Container) diagrams. Level 3 and 4 are produced when the user asks for detail.
4. **Trade-offs are honest.** Every pattern has real downsides. Never present an architecture as having no weaknesses.
5. **ADRs capture the "why."** The Architecture Decision Record explains the reasoning, not only the decision. Future developers will thank you.
6. **Bounded contexts before microservices.** If recommending microservices, the bounded context map must come first. Services without clear domain boundaries become a distributed monolith.
7. **Validate against the team.** The best architecture is one the team can actually build and operate. Factor in team experience and operational maturity.

## Output Format
Print on completion:
```
ARCHITECTURE: {system_name}
Pattern: {selected_pattern} (scored {weighted_total} vs {runner_up_score} for {runner_up})
C4 diagrams: {levels_produced} levels produced
```

## TSV Logging
Log every architecture session to `.godmode/architect-results.tsv`:
```
timestamp	system	pattern_selected	patterns_compared	c4_levels	bounded_contexts	quality_attrs	adr_number	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. At least 3 architecture patterns compared in a weighted matrix before recommendation.
2. C4 Level 1 (Context) and Level 2 (Container) diagrams produced for every session.
3. Architecture Decision Record created with Context, Decision, and Consequences sections.
4. Quality attributes table completed with specific mechanisms, not generic labels.
5. Bounded context map produced when recommending microservices or event-driven architecture.
6. Team size and operational maturity factored into the recommendation justification.
7. All artifacts committed with descriptive commit message.

## Keep/Discard Discipline
```
After EACH architecture decision:
  1. MEASURE: Score the decision against the weighted comparison matrix.
  2. COMPARE: Does the recommended pattern score highest? Are trade-offs documented honestly?
```

## Stop Conditions
```
STOP when ANY of these are true:
  - At least 3 patterns compared in weighted matrix with clear winner
  - C4 Level 1 and Level 2 diagrams produced
```

## Architecture Review Loop

Continuously audit architecture health with coupling metrics, dependency analysis, and SOLID violation detection:

```
ARCHITECTURE REVIEW LOOP:

current_iteration = 0
```

### Coupling Metrics

```
COUPLING ANALYSIS:
| Metric | Threshold | Measured | Status |
```

### Dependency Analysis

```
DEPENDENCY ANALYSIS:
| Check | Status | Details |
```

### SOLID Violation Detection

```
SOLID VIOLATION SCAN:
| Principle | Detection Signal | Count |
```

### Architecture Health Scorecard

```
ARCHITECTURE HEALTH SCORECARD:
| Dimension | Score (1-10) | Weight | Weighted |
```


## Error Recovery
| Failure | Action |
|--|--|
| Architecture decision contested by team | Document tradeoffs in an ADR (Architecture Decision Record). Present alternatives with pros/cons. Let data decide — prototype competing approaches if needed. |
| Chosen pattern does not fit after implementation starts | Revisit constraints. If <30% implemented, pivot early. If >30%, adapt the pattern rather than restarting. Document the pivot in the ADR. |
| Dependency creates vendor lock-in | Introduce an adapter/port layer. Abstract the dependency behind an interface so you swap it easily. |
| Performance bottleneck in chosen architecture | Profile first. Check if the bottleneck is in the architecture or implementation. Add caching, async processing, or read replicas before restructuring. |
