# /godmode:cost

Cloud cost optimization using evidence-based analysis of resource utilization, waste detection, right-sizing, pricing optimization, and cost governance. Every recommendation includes projected dollar savings and risk level.

## Usage

```
/godmode:cost                                    # Full cost analysis and optimization
/godmode:cost --provider aws                     # AWS-specific analysis
/godmode:cost --waste                            # Waste detection only
/godmode:cost --rightsize                        # Right-sizing recommendations only
/godmode:cost --tags                             # Cost allocation tagging audit
/godmode:cost --budget                           # Budget alert configuration
/godmode:cost --quick                            # Top 10 savings opportunities
/godmode:cost --threshold 100                    # Only show savings above $100/month
```

## What It Does

1. Inventories all cloud resources and current costs
2. Analyzes utilization (compute, storage, database, network)
3. Detects waste (idle resources, unattached volumes, orphaned snapshots)
4. Recommends right-sizing based on actual usage data
5. Suggests pricing optimizations (reserved instances, spot, savings plans)
6. Audits cost allocation tagging coverage
7. Configures budget alerts and anomaly detection
8. Produces optimization report with prioritized actions

## Output
- Cost optimization report at `docs/cost/<date>-cost-optimization.md`
- Commit: `"cost: <scope> — $<savings>/month identified (<N> recommendations)"`
- Prioritized action items: quick wins, medium effort, long-term

## Next Step
After cost optimization: `/godmode:infra` to implement infrastructure changes, or `/godmode:comply` to verify cost governance meets compliance requirements.

## Examples

```
/godmode:cost                                    # Full analysis
/godmode:cost --provider aws --waste             # AWS waste detection
/godmode:cost --rightsize --threshold 50         # Right-sizing above $50/month savings
/godmode:cost --budget                           # Set up budget alerts
/godmode:cost --quick                            # Quick wins only
```
