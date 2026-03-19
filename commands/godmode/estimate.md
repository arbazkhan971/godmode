# /godmode:estimate

Estimate effort for tasks, features, and projects. Provides complexity analysis, risk factor assessment, three-point estimation with confidence intervals, task decomposition, reference class forecasting, and sprint planning assistance. Never gives a single number -- always provides ranges.

## Usage

```
/godmode:estimate                             # Interactive estimation for a task
/godmode:estimate --sprint                    # Sprint planning mode (multiple tasks)
/godmode:estimate --quick                     # Quick t-shirt sizing (S/M/L/XL)
/godmode:estimate --decompose                 # Decompose into subtasks with estimates
/godmode:estimate --risk                      # Risk factor analysis only
/godmode:estimate --compare <task>            # Compare against similar past tasks
/godmode:estimate --capacity <N>              # Set team capacity (developer-days)
/godmode:estimate --confidence <N>            # Set confidence level (default: 90%)
/godmode:estimate --points                    # Output in story points
/godmode:estimate --batch                     # Estimate multiple tasks at once
```

## What It Does

1. Gathers context about the task, codebase, and constraints
2. Analyzes complexity across 6 dimensions (code, domain, uncertainty, integration, testing, deployment)
3. Identifies risk factors with probability and impact assessment
4. Produces three-point estimates (optimistic, most likely, pessimistic) with PERT weighted average
5. Calculates confidence intervals (68%, 90%, 95%)
6. Decomposes large tasks into estimable subtasks (1-3 days each)
7. Compares against reference classes (similar historical tasks) when available
8. Assists sprint planning with capacity calculation and load analysis

## Output
- Complexity analysis with dimensional ratings
- Risk factor assessment with multiplier
- Three-point estimate with confidence intervals
- Task decomposition (for tasks > 5 days)
- Sprint load analysis (for sprint planning mode)
- No git commit (estimates are planning artifacts, not code)

## Estimation Methods

| Method | When | Output |
|--------|------|--------|
| **Three-Point** | Single task | Range with PERT + confidence intervals |
| **Decomposition** | Large tasks (> 5 days) | Sum of subtask estimates |
| **Reference Class** | Repeating task types | Historical average and range |
| **T-Shirt Sizing** | Quick relative sizing | S (days) / M (week) / L (2wk) / XL (month+) |
| **Story Points** | Sprint planning | Fibonacci scale (1, 2, 3, 5, 8, 13, 21) |

## Next Step
After estimation: `/godmode:plan` to decompose into implementation tasks, then `/godmode:build` to execute.

## Examples

```
/godmode:estimate How long to add OAuth login?
/godmode:estimate --sprint Size these 8 tasks for our 2-week sprint
/godmode:estimate --quick Is adding rate limiting a 1-day or 1-week task?
/godmode:estimate --decompose Break down the search rewrite into subtasks
/godmode:estimate --risk What are the risks for the database migration?
/godmode:estimate --points Story points for the checkout feature
/godmode:estimate --batch Estimate all tasks in our backlog
```
