---
name: cost
description: |
  Cloud cost optimization skill. Activates when user needs to analyze, reduce, or govern cloud spending across AWS,
    GCP, and Azure. Performs resource utilization analysis, right-sizing recommendations, waste detection, cost
    allocation tagging, and budget alerting. Uses evidence-based analysis of actual usage data to produce actionable
    savings recommendations with projected dollar impact. Triggers on: /godmode:cost, "reduce cloud costs", "optimize
    spending", "why is our bill so high?", or when infrastructure costs need governance.
---

# Cost — Cloud Cost Optimization

## When to Activate
- User invokes `/godmode:cost`
- User says "reduce cloud costs," "optimize spending," "why is our bill so high?"
- User asks about right-sizing, reserved instances, or spot pricing
- Godmode orchestrator detects infrastructure cost concerns
- After `/godmode:infra` provisions resources that need cost governance

## Workflow

### Step 1: Inventory Cloud Resources
Discover all provisioned resources and their current costs:

```
COST INVENTORY:
Provider: <AWS | GCP | Azure | Multi-cloud>
Account(s): <account IDs in scope>
Region(s): <regions in scope>
Time period: <billing period to analyze>

Resource categories:
  Compute: <EC2/GCE/VMs — count, types, monthly cost>
  Storage: <S3/GCS/Blob — volume, monthly cost>
  Database: <RDS/CloudSQL/CosmosDB — instances, monthly cost>
  Network: <data transfer, load balancers, monthly cost>
  Containers: <ECS/GKE/AKS — clusters, monthly cost>
  Serverless: <Lambda/Functions — invocations, monthly cost>
  Other: <CDN, DNS, monitoring, etc.>

```
### Step 2: Utilization Analysis
Measure actual usage versus provisioned capacity:

#### Compute Utilization
```
COMPUTE UTILIZATION:
| Instance | Type | Avg CPU | Avg Mem | Verdict |
|--|--|--|--|--|
| <instance-1> | m5.2xl | 12% | 25% | OVERSIZE |
| <instance-2> | t3.micro | 89% | 92% | UNDERSIZE |
| <instance-3> | c5.large | 45% | 60% | OK |
| <instance-4> | m5.xl | 3% | 8% | IDLE |

Thresholds:
  IDLE: < 5% CPU and < 10% memory for 14+ days
  OVERSIZE: < 30% CPU or < 40% memory sustained
  UNDERSIZE: > 80% CPU or > 85% memory sustained
  OK: within healthy range
```

#### Storage Utilization
```
STORAGE UTILIZATION:
| Bucket/Volume | Size | Access | Last Hit | Verdict |
|--|--:|--|--|--|
| <bucket-1> | 2.3 TB | Frequent | Today | OK |
| <bucket-2> | 500 GB | None | 90d ago | ARCHIVE |
| <volume-1> | 1 TB | None | Never | DELETE |
| <snapshot-old> | 200 GB | N/A | 180d ago | DELETE |
```

#### Database Utilization
```
DATABASE UTILIZATION:
| Instance | Type | Avg CPU | Storage | Verdict |
|--|--|--:|--:|--|
| <rds-prod> | db.r5.xl | 35% | 40% | OK |
| <rds-staging> | db.r5.xl | 5% | 10% | OVERSIZE |
| <rds-dev> | db.m5.lg | 2% | 5% | SCHEDULE |
```

### Step 3: Waste Detection
Identify resources that cost money but provide no value:

```
WASTE DETECTION:
| Category | Count | Monthly Cost | Action |
|--|--|--|--|
| Unattached EBS vols | 12 | $340 | DELETE |
| Old snapshots (>90d) | 45 | $180 | DELETE |
| Idle load balancers | 3 | $75 | DELETE |
| Unused Elastic IPs | 8 | $29 | RELEASE |
| Orphaned ENIs | 5 | $0 | CLEANUP |
| Dev envs running 24/7 | 4 | $1,200 | SCHEDULE |
| Oversized instances | 6 | $2,400 waste | RESIZE |
| Stale DNS records | 15 | $0 | CLEANUP |

Total identifiable waste: $4,224/month ($50,688/year)
```
### Step 4: Right-Sizing Recommendations
For each oversized or undersized resource, recommend the optimal size:

```
RIGHT-SIZING RECOMMENDATIONS:
| Resource | Current | Recommended | Monthly Savings |
|--|--|--|--|
| <instance-1> | m5.2xlarge | m5.large | $180 (65% less) |
| <rds-staging> | db.r5.xl | db.t3.medium | $420 (78% less) |
| <cache-prod> | r6g.xlarge | r6g.large | $95 (50% less) |
| <instance-4> | m5.xlarge | TERMINATE | $140 (100% saved) |

Basis: 14-day P95 utilization data.
Risk: LOW — all recommendations leave 40%+ headroom above P95.
```
### Step 5: Pricing Optimization
Recommend pricing model changes for stable workloads:

#### Reserved Instances / Savings Plans
```
RESERVATION RECOMMENDATIONS:
| Resource | On-Demand | Reserved(1y) | Savings |
|--|--|--|--|
| Prod compute (6x) | $2,400/mo | $1,560/mo | $840/mo (35%) |
| Prod database (2x) | $1,200/mo | $780/mo | $420/mo (35%) |
| Prod cache (2x) | $380/mo | $247/mo | $133/mo (35%) |

Prerequisites: Workload must have run for 3+ months with stable utilization.
Commitment: 1-year, no upfront (lowest risk).
```

#### Spot / Preemptible Instances
```
SPOT CANDIDATES:
- CI/CD runners: <N> instances, tolerant of interruption → 60-70% savings
- Batch processing: <N> instances, can retry → 60-70% savings
- Dev environments: <N> instances, non-critical → 60-70% savings

NOT spot-eligible: production web servers, databases, stateful services.
```

### Step 6: Cost Allocation & Tagging
Verify all resources are tagged for cost attribution:

```
TAGGING AUDIT:
| Required Tag | Coverage | Missing | Action |
|--|--|--|--|
| team | 72% | 45 res | TAG |
| environment | 85% | 24 res | TAG |
| project | 60% | 64 res | TAG |
| cost-center | 45% | 88 res | TAG |
| owner | 55% | 72 res | TAG |

Recommended tagging policy:
  REQUIRED: team, environment, project, cost-center
  RECOMMENDED: owner, created-by, expiry-date
  ENFORCED VIA: AWS Config rules / GCP Organization Policy / Azure Policy
```
### Step 7: Budget Alerts
Set up proactive cost monitoring:

```
BUDGET ALERT CONFIGURATION:
| Budget | Monthly Limit | Alert at | Notify |
|--|--|--|--|
| Total account | $15,000 | 50/80/100% | #finops, PagerDuty |
| Production | $10,000 | 80/100% | #infra |
| Development | $3,000 | 80/100% | #dev-team |
| Per-service | varies | 100/120% | service owner |

Anomaly detection:
  - Alert if daily spend exceeds 2x rolling 7-day average
  - Alert if any single resource exceeds $500/day
  - Weekly cost digest to #finops channel
```
### Step 8: Cost Optimization Report

```
  COST OPTIMIZATION REPORT
  Current monthly spend:        $<amount>
  Projected after optimization: $<amount>
  Total monthly savings:        $<amount> (<percentage>)
  Annual impact:                $<amount>
  Savings breakdown:
  Waste elimination:     $<amount> (<N> actions)
  Right-sizing:          $<amount> (<N> resources)
  Pricing optimization:  $<amount> (<N> reservations)
  Scheduling:            $<amount> (<N> environments)
  Implementation effort:
  Quick wins (< 1 day):  $<amount> savings
  Medium effort (1 week): $<amount> savings
  Long-term (1 month+):  $<amount> savings
  Risk: LOW — all changes are reversible
```
### Step 9: Commit and Transition
1. Save report as `docs/cost/<date>-cost-optimization.md`
2. Commit: `"cost: <scope> — $<savings>/month identified (<N> recommendations)"`
3. Provide actionable next steps with priority order

```bash
# Check cloud cost reports
curl -s http://localhost:8080/api/costs/summary | jq .total
grep -r "instance_type" infra/ | head -5
```

## Key Behaviors

```bash
# Analyze cloud costs
aws ce get-cost-and-usage --time-period Start=2026-02-01,End=2026-03-01 --granularity MONTHLY --metrics BlendedCost
infracost diff --path .
```
1. **Data-driven only.** Actual utilization data, not assumptions.
2. **Dollar impact required.** "$180/mo savings" not "oversized".
3. **Risk assessment.** LOW/MEDIUM/HIGH per recommendation.
4. **Reversibility matters.** Right-sizing > reserved purchases.
5. **Environment awareness.** Conservative for prod, aggressive for dev.
6. **Tagging is foundational.** Fix tags before optimizing.
7. **Continuous, not one-time.** Alerts + monthly review.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full cost analysis and optimization report |
| `--provider <aws\|gcp\|azure>` | Target specific cloud provider |
| `--scope <account\|project\|service>` | Narrow analysis scope |
| `--waste` | Waste detection only |
| `--rightsize` | Right-sizing recommendations only |
| `--tags` | Cost allocation tagging audit only |
| `--budget` | Budget alert configuration only |
| `--quick` | Top 10 savings opportunities, skip deep analysis |
| `--report` | Generate report from last analysis |
| `--threshold <dollars>` | Only show savings above threshold |

## HARD RULES

1. **NEVER STOP** until all resource categories are analyzed and all savings are quantified in dollars.
2. **EVERY recommendation MUST include dollar impact** — "oversized" is not actionable, "$180/month savings" is.
3. **EVERY recommendation MUST include risk level** and reversibility assessment.
4. **NEVER recommend reserved instances for workloads with less than 3 months of stable data.**
5. **NEVER apply dev-level aggressive optimization to production resources.**
6. **ALWAYS fix tagging first** — cost optimization without attribution is guesswork.
7. **git commit BEFORE verify** — commit the cost report, then verify recommendations.
8. **TSV logging** — log every cost analysis:
   ```
   timestamp	provider	scope	current_spend	projected_savings	recommendations	quick_wins
   ```

## Explicit Loop Protocol

When analyzing resources across categories:

```
current_iteration = 0
resource_categories = [compute, storage, database, network, containers, serverless, other]
all_recommendations = []

WHILE resource_categories is not empty:
    current_iteration += 1
    category = resource_categories.pop(0)

    # Inventory
    resources = list_resources(category)

    FOR each resource in resources:
        utilization = get_utilization(resource, period="14d")

        IF utilization.cpu_avg < 5 AND utilization.mem_avg < 10:
```
## Auto-Detection

On activation, automatically detect cloud context:

```
AUTO-DETECT:
1. Cloud provider:
   aws sts get-caller-identity 2>/dev/null && echo "aws"
   gcloud config get-value project 2>/dev/null && echo "gcp"
   az account show 2>/dev/null && echo "azure"

2. Infrastructure as code:
   ls terraform/ *.tf 2>/dev/null && echo "terraform"
   ls pulumi/ Pulumi.yaml 2>/dev/null && echo "pulumi"
   ls cdk.json 2>/dev/null && echo "cdk"

3. Resource inventory tools:
   which aws-nuke cloud-nuke infracost 2>/dev/null

4. Existing cost tools:
```
## Output Format
Print on completion: `Cost: ${current_monthly}/mo → ${projected_monthly}/mo (-${savings}/mo, -{savings_pct}%).
Top waste: {top_waste}. Untagged: {untagged_count} resources. Reservations: {ri_recommendation}. Verdict:
{verdict}.`
