---
name: cost
description: |
  Cloud cost optimization skill. Activates when user needs to analyze, reduce, or govern cloud spending across AWS, GCP, and Azure. Performs resource utilization analysis, right-sizing recommendations, waste detection, cost allocation tagging, and budget alerting. Uses evidence-based analysis of actual usage data to produce actionable savings recommendations with projected dollar impact. Triggers on: /godmode:cost, "reduce cloud costs", "optimize spending", "why is our bill so high?", or when infrastructure costs need governance.
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

Total monthly spend: $<amount>
Month-over-month trend: <increasing/stable/decreasing> (<percentage>)
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
|--|--|--|--|--|
| <bucket-1> | 2.3 TB | Frequent | Today | OK |
| <bucket-2> | 500 GB | None | 90d ago | ARCHIVE |
| <volume-1> | 1 TB | None | Never | DELETE |
| <snapshot-old> | 200 GB | N/A | 180d ago | DELETE |
```

#### Database Utilization
```
DATABASE UTILIZATION:
| Instance | Type | Avg CPU | Storage | Verdict |
|--|--|--|--|--|
| <rds-prod> | db.r5.xl | 35% | 40% | OK |
| <rds-staging> | db.r5.xl | 5% | 10% | OVERSIZE |
| <rds-dev> | db.m5.lg | 2% | 5% | SCHEDULE |
```

### Step 3: Waste Detection
Identify resources that cost money but provide no value:

```
WASTE DETECTION:
| Category | Count | Monthly Cost | Action |
|---|---|---|---|
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
|---|---|---|---|
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
|---|---|---|---|
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
Ensure all resources are properly tagged for cost attribution:

```
TAGGING AUDIT:
| Required Tag | Coverage | Missing | Action |
|---|---|---|---|
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
|---|---|---|---|
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
  Confidence: HIGH — based on 14+ days of usage data
```

### Step 9: Commit and Transition
1. Save report as `docs/cost/<date>-cost-optimization.md`
2. Commit: `"cost: <scope> — $<savings>/month identified (<N> recommendations)"`
3. Provide actionable next steps with priority order

## Key Behaviors

1. **Data-driven only.** Back every recommendation with actual utilization data. Never recommend changes based on assumptions.
2. **Dollar impact required.** Every recommendation must include the projected savings in dollars. "This instance is oversized" is not actionable. "$180/month savings by downsizing from m5.2xl to m5.large" is actionable.
3. **Risk assessment included.** Every change has a risk level. Deleting an unattached volume is LOW risk. Downsizing a production database is MEDIUM risk. Switching to spot instances is HIGH risk for stateful workloads.
4. **Reversibility matters.** Prefer changes you undo quickly. Right-sizing reverses in minutes. Reserved instance purchases do not.
5. **Environment awareness.** Production optimizations stay conservative. Dev/staging optimizations go aggressive. Never apply dev-level recommendations to production.
6. **Tagging is foundational.** Cost optimization without proper tagging is guesswork. Fix tagging first, then optimize.
7. **Continuous, not one-time.** Cost optimization is a recurring practice, not a project. Set up alerts and schedules for ongoing governance.

## Flags & Options

| Flag | Description |
|------|-------------|
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
            recommendation = {type: "TERMINATE", savings: resource.monthly_cost}
        ELIF utilization.cpu_avg < 30 OR utilization.mem_avg < 40:
            right_size = calculate_right_size(resource, utilization)
            recommendation = {type: "RESIZE", from: resource.type, to: right_size, savings: delta}
        ELIF resource.is_unattached OR resource.last_access > 90_days:
            recommendation = {type: "DELETE", savings: resource.monthly_cost}
        ELSE:
            CONTINUE  # Resource is appropriately sized

        all_recommendations.append(recommendation)

    IF current_iteration % 3 == 0:
        total = sum(r.savings for r in all_recommendations)
        print(f"Progress: {current_iteration} categories, ${total}/month identified")

sort_by_savings(all_recommendations)
generate_report(all_recommendations)
git commit report
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
   ls .infracost/ 2>/dev/null
   grep -r "cost\|budget\|billing" .github/workflows/ 2>/dev/null

5. Tagging policy:
   # Check for tag enforcement
   grep -ri "required_tags\|tag.policy\|tag.compliance" terraform/ 2>/dev/null

-> Auto-select provider and configure API calls.
-> Auto-detect account/project scope.
-> Only ask user about time period if not obvious.
```

## Output Format
Print on completion: `Cost: ${current_monthly}/mo → ${projected_monthly}/mo (-${savings}/mo, -{savings_pct}%). Top waste: {top_waste}. Untagged: {untagged_count} resources. Reservations: {ri_recommendation}. Verdict: {verdict}.`

## TSV Logging
Log every cost optimization action to `.godmode/cost-results.tsv`:
```
iteration	category	resource	current_cost	projected_cost	savings	action	status
1	compute	ec2_oversized	$2400/mo	$1200/mo	$1200/mo	rightsize_m5.xlarge_to_m5.large	recommended
2	storage	ebs_unattached	$180/mo	$0/mo	$180/mo	delete_unattached	applied
3	transfer	cross_region	$500/mo	$200/mo	$300/mo	consolidate_region	recommended
4	reserved	ec2_stable	$3600/mo	$2160/mo	$1440/mo	1yr_reserved	recommended
```
Columns: iteration, category, resource, current_cost, projected_cost, savings, action, status(recommended/applied/deferred/rejected).

## Success Criteria
- All resources tagged with owner, environment, and cost-center.
- Idle/unused resources identified and cleaned up (unattached EBS, stopped instances, unused load balancers).
- Compute resources rightsized based on utilization data (not guesses).
- Reserved instances recommended only for workloads with 3+ months of stable usage.
- Data transfer costs analyzed (cross-region, internet egress).
- Cost alerts configured for budget thresholds (80%, 100%, 120%).
- Monthly cost review process established (not one-time optimization).
- Savings validated with before/after billing data.

## Error Recovery
- **Rightsizing breaks the application**: Never rightsize production without testing in staging first. Monitor CPU and memory for 24 hours after the change. Have a rollback plan (scale back up immediately if metrics degrade).
- **Deleting resources causes outage**: Always verify resources are truly unused before deleting. Check for dependencies (security group referenced by another resource, EBS snapshot used by AMI). Use the provider's "delete protection" feature for critical resources.
- **Reserved instance purchase is wasteful**: Only purchase reservations for workloads with 3+ months of stable, predictable usage. Start with 1-year no-upfront RIs (lower commitment). Monitor actual usage against the reservation.
- **Cost alerts fire too frequently**: Adjust thresholds to reduce noise. Separate alerts by service or team. Use anomaly detection instead of fixed thresholds for variable workloads.
- **Tagging audit reveals massive gaps**: Start with the top 10 most expensive resources. Tag those first. Then implement a tag enforcement policy (prevent untagged resource creation) for new resources.
- **Optimization savings not reflected in bill**: Allow one full billing cycle for changes to take effect. Check for amortized costs (reserved instance upfront payments spread across months). Verify the optimization was actually applied in the correct account/region.

## Iterative Loop Protocol
```
current_category = 0
categories = [compute, storage, transfer, reserved, idle, tagging]

WHILE current_category < len(categories):
  category = categories[current_category]
  1. ANALYZE: Pull utilization data and cost data for {category}
  2. IDENTIFY: Find optimization opportunities with savings estimate
  3. RANK: Sort by savings (highest first)
  4. RECOMMEND: For each opportunity, specify the action and expected savings
  5. APPLY (if approved): Make the change and log the result
  6. VERIFY: Check billing after one cycle to confirm savings
  7. LOG to .godmode/cost-results.tsv
  8. current_category += 1
  9. REPORT: "Category {current_category}/{total}: {category} — ${savings}/mo potential savings"

EXIT when all categories analyzed OR user requests stop
```

## Keep/Discard Discipline
```
After EACH cost optimization recommendation is applied:
  1. MEASURE: Verify the change took effect (resource resized, deleted, or reservation placed)
  2. COMPARE: Did actual billing decrease? Are monitored metrics (CPU, memory, latency) still healthy?
  3. DECIDE:
     - KEEP if: savings confirmed AND no performance regression AND no availability impact
     - DISCARD if: performance degraded OR availability dropped OR savings not realized
  4. COMMIT kept changes. Revert discarded changes immediately.

Never batch multiple optimizations without measuring between them — you cannot attribute savings if you change 5 things at once.
```

## Stuck Recovery
```
IF >3 consecutive recommendations produce no measurable savings:
  1. Re-read ALL resource utilization data — cached data may be stale.
  2. Widen scope: look at data transfer costs, NAT gateway, DNS queries — hidden cost drivers.
  3. Try a different category: if compute is already optimized, switch to storage or network.
  4. If still stuck → log stop_reason=optimization_plateau, report total savings so far, move on.
```

## Stop Conditions
```
STOP the loop when ANY of these are true:
  - All resource categories analyzed and all savings quantified
  - Total savings target met (if user specified one)
  - Remaining opportunities are below $50/month each (diminishing returns)
  - User explicitly requests stop
  - Max iterations (20) reached

DO NOT STOP just because:
  - One category has no savings (other categories can)
  - Reserved instance analysis is complex (still do the analysis)
```

## Simplicity Criterion
```
PREFER the simpler cost optimization:
  - Terminate idle resources before rightsizing active ones
  - Delete unattached storage before optimizing attached storage
  - Use on-demand pricing with right-sizing before committing to reservations
  - Fix tagging before building complex cost allocation dashboards
  - Use built-in cloud provider tools (AWS Cost Explorer) before third-party solutions
```

