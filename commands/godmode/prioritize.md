# /godmode:prioritize

Prioritize work items using structured scoring frameworks. Supports RICE, ICE, MoSCoW, and effort-vs-impact matrices with dependency-aware scheduling and technical debt trade-off analysis.

## Usage

```
/godmode:prioritize                           # Auto-select framework, prioritize all items
/godmode:prioritize --framework rice          # Use RICE scoring
/godmode:prioritize --framework ice           # Use ICE scoring
/godmode:prioritize --framework moscow        # Use MoSCoW categorization
/godmode:prioritize --framework matrix        # Use effort-vs-impact matrix
/godmode:prioritize --capacity 30             # Set sprint capacity in points
/godmode:prioritize --debt                    # Tech debt vs feature trade-off analysis
/godmode:prioritize --deps                    # Show dependency graph and critical path
/godmode:prioritize --top 5                   # Show only top 5 priorities
/godmode:prioritize --compare                 # Compare with previous prioritization
/godmode:prioritize --export csv              # Export as CSV
```

## What It Does

1. **Inventory** — Collects work items from issue tracker, git TODOs, retro actions, and user input
2. **Framework** — Applies chosen scoring framework (RICE, ICE, MoSCoW, or Effort-Impact)
3. **Score** — Quantitatively scores each item with reach, impact, confidence, and effort
4. **Dependencies** — Maps blocking relationships and adjusts ordering for critical path
5. **Debt Analysis** — Calculates tech debt ratio and recommends feature/debt allocation split
6. **Schedule** — Produces capacity-aware prioritized backlog with sprint/overflow separation

## Output
- Prioritized backlog saved to `docs/priorities/<date>-backlog.md`
- Dependency graph with critical path identification
- Technical debt ratio and recommended allocation
- Git commit with prioritization summary

## Next Step
After prioritize: `/godmode:plan` to plan top items, or `/godmode:scope` to scope the highest-priority feature.

## Examples

```
/godmode:prioritize --framework rice          # Quantitative scoring for large backlog
/godmode:prioritize --framework moscow --capacity 40  # Release scope planning
/godmode:prioritize --debt --deps             # Debt analysis with dependency graph
/godmode:prioritize --top 3 --export json     # Top 3 priorities as JSON
```
