# /godmode:infra

Validate, plan, and deploy infrastructure using Infrastructure as Code. Supports Terraform, CloudFormation, Pulumi, and CDK with policy enforcement, cost estimation, and drift detection.

## Usage

```
/godmode:infra                          # Full validation: lint, plan, policy, cost, drift
/godmode:infra --validate               # Syntax and configuration validation only
/godmode:infra --plan                   # Generate and review execution plan
/godmode:infra --cost                   # Cost estimation only
/godmode:infra --drift                  # Drift detection only
/godmode:infra --policy                 # Policy enforcement check only (OPA, Sentinel)
/godmode:infra --test                   # Run IaC tests (unit, integration, compliance)
/godmode:infra --scaffold               # Generate new IaC project structure
/godmode:infra --apply                  # Apply changes (requires prior plan review)
/godmode:infra --env production         # Target a specific environment
```

## What It Does

1. Discovers IaC toolchain (Terraform, CloudFormation, Pulumi, CDK)
2. Validates syntax and configuration
3. Enforces security policies via OPA and Sentinel
4. Estimates monthly cost and flags budget overruns
5. Detects drift between IaC definitions and deployed infrastructure
6. Runs IaC tests (unit, integration, compliance)
7. Generates a safe, reviewable deployment plan
8. Applies changes with post-deployment verification

## Output
- Validation report with policy violations and remediations
- Cost estimate with monthly breakdown and delta
- Drift report showing out-of-sync resources
- Deployment plan with create/update/delete counts
- Commit: `"infra: <description> — <N> resources (<cost delta>)"`

## Next Step
After infrastructure is validated: `/godmode:k8s` to deploy services, or `/godmode:ship` to ship.

## Examples

```
/godmode:infra                          # Full infrastructure review
/godmode:infra --scaffold               # New Terraform project from scratch
/godmode:infra --cost --env production  # Cost estimate for production
/godmode:infra --drift                  # Check for manual changes
```
