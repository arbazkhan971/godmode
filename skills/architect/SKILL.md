---
name: architect
description: |
  Software architecture skill. Activates when user needs to design system architecture, select architecture patterns,
    create C4 diagrams, or apply domain-driven design at the strategic level. Evaluates trade-offs across monolith,
    microservices, serverless, event-driven, CQRS, and hexagonal architectures. Produces architecture decision
    records, C4 diagrams, and bounded context maps. Triggers on: /godmode:architect, "design the architecture",
    "system design", "how should I structure this", or when the orchestrator detects architecture-level decisions.
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

Candidate patterns: Modular Monolith, Microservices, Serverless/FaaS, Event-Driven, CQRS, Hexagonal (Ports &
Adapters). Evaluate the top 3-6 for the system.

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

```bash
# Analyze architecture dependencies and coupling
npx madge --circular --extensions ts src/
npx dependency-cruiser --validate .dependency-cruiser.cjs src/
```

IF team size < 5: prefer modular monolith over microservices.
WHEN afferent coupling > 10 on any module: refactor to reduce.
IF circular dependencies > 0: break cycles before adding features.

1. **Requirements before patterns.** Understand scale, team, constraints.
2. **Compare >= 3 options.** Comparison matrix forces rigor.
3. **C4 diagrams mandatory.** Minimum Level 1 + Level 2.
4. **Trade-offs are honest.** Every pattern has real downsides.
5. **ADRs capture the "why."** Reasoning, not just decision.
6. **Bounded contexts before microservices.** Map first, split second.
7. **Validate against the team.** Best arch = team can build it.

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

## Quality Targets
- Target: <500ms p99 latency for critical paths
- Target: >80% code coverage on core modules
- Target: 0 circular dependencies between bounded contexts
- Max coupling: <5 imports between modules

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
| Architecture decision contested | Document tradeoffs in ADR. Prototype if needed. |
| Pattern doesn't fit after start | If < 30% done: pivot. If > 30%: adapt. Document. |
| Vendor lock-in risk | Add adapter/port layer. Abstract behind interface. |
| Performance bottleneck | Profile first. Add caching/async before restructuring. |
