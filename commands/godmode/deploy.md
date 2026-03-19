# /godmode:deploy

Advanced deployment strategy design and orchestration. Supports blue-green deployments, canary releases, progressive rollouts, automated rollback, feature flag coordination, and zero-downtime migrations. Every plan includes rollback procedures and monitoring criteria.

## Usage

```
/godmode:deploy                                  # Full deployment planning
/godmode:deploy --canary                         # Canary release plan
/godmode:deploy --blue-green                     # Blue-green deployment plan
/godmode:deploy --progressive                    # Progressive rollout with stages
/godmode:deploy --rollback                       # Rollback plan design
/godmode:deploy --flags                          # Feature flag orchestration
/godmode:deploy --migration                      # Zero-downtime migration plan
/godmode:deploy --dry-run                        # Generate plan without executing
/godmode:deploy --checklist                      # Pre-deployment checklist
```

## What It Does

1. Assesses deployment context (change type, risk level, rollback complexity)
2. Recommends appropriate strategy based on risk assessment
3. Designs deployment plan with stages:
   - **Blue-Green**: Two environments, instant switchover, instant rollback
   - **Canary**: Percentage-based traffic splitting with automated gates
   - **Progressive**: Multi-stage rollout with manual and automated gates
   - **Rolling**: Instance-by-instance update with health checks
4. Defines automated rollback triggers and execution procedures
5. Orchestrates feature flags for complex rollouts
6. Plans zero-downtime database migrations (expand-contract pattern)
7. Generates pre-deployment checklist and communication plan

## Output
- Deployment plan at `docs/deploy/<date>-<feature>-deployment.md`
- Commit: `"deploy: <feature> — <strategy> with <N> stages"`
- Go/No-Go decision with justification

## Next Step
After deployment: monitor for 24 hours, then clean up feature flags.
After rollback: investigate with `/godmode:debug`, fix with `/godmode:fix`.

## Examples

```
/godmode:deploy                                  # Full plan with strategy recommendation
/godmode:deploy --canary                         # Canary release with 5 stages
/godmode:deploy --migration                      # Zero-downtime DB migration
/godmode:deploy --rollback                       # Design rollback procedures
/godmode:deploy --flags                          # Feature flag rollout plan
```
