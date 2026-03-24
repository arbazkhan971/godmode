---
name: infra
description: |
  Infrastructure as Code skill. Activates when user needs to provision, validate, or manage cloud infrastructure. Supports Terraform, CloudFormation, Pulumi, and AWS CDK. Includes IaC testing, cost estimation, drift detection, and policy enforcement with Sentinel and OPA. Triggers on: /godmode:infra, "provision infrastructure", "terraform plan", "deploy to cloud", "infrastructure review", or when shipping requires infrastructure changes.
---

# Infra — Infrastructure as Code

## When to Activate
- User invokes `/godmode:infra`
- User says "provision infrastructure", "terraform plan", "set up cloud resources"
- User says "infrastructure review", "check drift", "estimate costs"
- Deployment requires infrastructure changes (new services, databases, queues)
- Pre-ship check identifies missing infrastructure definitions
- User asks about cloud architecture or resource provisioning

## Workflow

### Step 1: Discover Infrastructure Context
Identify the project's IaC toolchain and current state:

```
INFRASTRUCTURE CONTEXT:
IaC Tool: <Terraform | CloudFormation | Pulumi | CDK | None detected>
Provider: <AWS | GCP | Azure | Multi-cloud>
State Backend: <S3 | GCS | Azure Blob | Terraform Cloud | Local>
Existing Resources:
  - <list of .tf / template.yaml / Pulumi files / CDK stacks>
Environments: <dev | staging | production>
Modules/Stacks: <list of reusable modules or stacks>
```
If no IaC is detected: "No infrastructure code found. Shall I scaffold a new IaC project? Specify your preferred tool (Terraform, CloudFormation, Pulumi, CDK) and cloud provider."

### Step 2: Validate Infrastructure Definitions
Run static analysis and validation on all IaC files:

#### Terraform
```bash
# Format check
terraform fmt -check -recursive

# Validate syntax and configuration
terraform validate

# Initialize and check providers
terraform init -backend=false

# Generate plan (no apply)
terraform plan -out=tfplan

  ...
```

#### CloudFormation
```bash
# Validate template syntax
aws cloudformation validate-template --template-body file://template.yaml

# Lint with cfn-lint
cfn-lint template.yaml

# Check for security misconfigurations
cfn-nag template.yaml
```

#### Pulumi
```bash
# Preview changes
pulumi preview --diff

# Validate configuration
pulumi config
```

#### CDK
```bash
# Synthesize CloudFormation
cdk synth

# Diff against deployed stack
cdk diff

# Validate constructs
cdk doctor
```

### Step 3: Security & Policy Enforcement
Apply policy-as-code to catch violations before deployment:

#### Open Policy Agent (OPA)
```
POLICY CHECK — OPA:
- [ ] No public S3 buckets or storage containers
- [ ] No security groups with 0.0.0.0/0 ingress on sensitive ports
- [ ] Encryption at rest enabled for all data stores
- [ ] Encryption in transit enforced (TLS 1.2+)
- [ ] No hardcoded secrets or credentials in resource definitions
- [ ] IAM roles follow least-privilege principle
- [ ] All resources tagged with: environment, team, cost-center
- [ ] No overly permissive IAM policies (*, admin)
- [ ] VPC flow logs enabled
- [ ] CloudTrail / audit logging enabled
```

#### Sentinel (Terraform Enterprise/Cloud)
```
POLICY CHECK — Sentinel:
- [ ] Mandatory tags on all resources
- [ ] Approved instance types only
- [ ] Regions restricted to approved list
- [ ] No inline IAM policies
- [ ] Database instances not publicly accessible
- [ ] Load balancers use HTTPS listeners
```

For each violation:
```
POLICY VIOLATION <N>: <Title>
Severity: CRITICAL | HIGH | MEDIUM | LOW
Resource: <resource type and name>
File: <file:line>
Policy: <policy name>
Evidence:
  <code snippet showing the violation>
Remediation:
  <corrected code>
```

### Step 4: Cost Estimation
Estimate monthly costs for the planned infrastructure:

```bash
# Using Infracost (Terraform)
infracost breakdown --path .
infracost diff --path . --compare-to infracost-base.json
```
```
COST ESTIMATE:
  Monthly Cost Estimate
| Resource | Monthly | Change |
|--|--|--|
| aws_instance.api (t3.large) | $60.74 | +$60.74 NEW |
| aws_rds.primary (db.r5.lg) | $172.80 | — |
| aws_s3.assets | $2.30 | — |
| aws_elasticache.redis | $48.62 | +$48.62 NEW |
| aws_alb.main | $22.27 | — |
| TOTAL | $306.73 | +$109.36 |
| Previous | $197.37 |  |
| Delta | +$109.36 | +55.4% |
  ...
```
If cost exceeds threshold: "Estimated cost ($X) exceeds budget threshold ($Y). Use: <specific cost optimization suggestions>."

### Step 5: Drift Detection
Compare deployed infrastructure against the IaC definitions:

```bash
# Terraform drift detection
terraform plan -detailed-exitcode

# AWS CloudFormation drift
aws cloudformation detect-stack-drift --stack-name <stack>
aws cloudformation describe-stack-drift-detection-status --stack-drift-detection-id <id>
```
```
DRIFT REPORT:
  Drift Detection Results
  Resources in sync:  14/16
  Resources drifted:  2/16
  Resources deleted:  0/16
  DRIFTED RESOURCES:
  1. aws_security_group.api_sg
  - Ingress rule added manually (port 8080 from 0.0.0.0/0)
  - Action: REMOVE manual rule or UPDATE IaC definition
  2. aws_instance.worker
  - Instance type changed: t3.medium -> t3.large
  - Action: UPDATE IaC to t3.large or REVERT instance
```
### Step 6: IaC Testing
Run infrastructure tests to validate behavior:

#### Unit Tests (Module-level)
```bash
# Terraform with Terratest (Go)
cd test/
go test -v -timeout 30m

# Terraform with pytest-terraform (Python)
pytest tests/test_infrastructure.py -v
```

#### Integration Tests
```bash
# Deploy to test environment
terraform apply -auto-approve -var-file=test.tfvars

# Run integration checks
./scripts/infra-integration-test.sh

# Destroy test environment
terraform destroy -auto-approve -var-file=test.tfvars
```

#### Compliance Tests (InSpec / Chef InSpec)
```bash
# Run compliance profile
inspec exec profiles/cloud-security --target aws://

# Check specific controls
inspec exec profiles/cis-benchmark --target aws://
```

```
IaC TEST RESULTS:
Unit Tests:     12/12 passing
Integration:    8/8 passing
Compliance:     45/47 passing (2 warnings)
Policy:         All policies satisfied
```
### Step 7: Generate Deployment Plan
Produce a safe, reviewable deployment plan:

```
DEPLOYMENT PLAN:
  Infrastructure Deployment — <environment>
  Resources to CREATE:  3
  Resources to UPDATE:  1
  Resources to DELETE:  0
  Resources UNCHANGED:  12
  CREATE:
  + aws_instance.api_server (t3.large)
  + aws_security_group.api_sg
  + aws_elasticache_cluster.redis
  UPDATE:
  ~ aws_alb_listener.https (add new target group)
  ...
```
### Step 8: Apply Infrastructure Changes
Execute the deployment with safety guardrails:

```bash
# Apply with plan file (Terraform)
terraform apply tfplan

# Monitor deployment
terraform output -json > outputs.json
```
```
DEPLOYMENT RESULT:
Apply complete! Resources: N added, N changed, 0 destroyed.
Post-deployment: health check 200 OK, connectivity verified, SG rules verified.
```
### Step 9: Commit and Report
```
1. Save infrastructure report as `docs/infra/<environment>-deployment.md`
2. Commit IaC changes: "infra: <description> — <N> resources (<cost delta>)"
3. If policy violations found: "Policy violations detected. Fix before deploying."
4. If drift detected: "Infrastructure drift found. Reconcile before proceeding."
5. If all checks pass: "Infrastructure validated and ready. Run `terraform apply` to deploy."
```

## Key Behaviors
1. **Never apply without a plan.** Review changes before `apply`.
2. **Policy is mandatory.** OPA/Sentinel checks on every change.
3. **Cost awareness.** Cost estimate with every change.
4. **Drift is a bug.** Detect and reconcile immediately.
5. **State is sacred.** Never modify state files manually.
6. **Environments isolated.** Separate state, accounts, credentials.
7. **Secrets never in IaC.** Use secret managers or variable references.

## HARD RULES
1. NEVER apply infrastructure changes without reviewing the plan output first. No blind `terraform apply`.
2. NEVER hardcode secrets, credentials, or API keys in IaC files — use secret managers or variable references.
3. NEVER use local state in production — always use remote state backend with locking (S3, GCS, Terraform Cloud).
4. NEVER use `*` in IAM policies — specify exact actions on exact resources (least privilege).
5. NEVER skip mandatory resource tagging (environment, team, cost-center) — untagged resources become orphans.
6. NEVER share state between environments — each environment gets its own state file and credentials.
7. NEVER modify state files manually — use `terraform state` commands or equivalent tooling.
8. ALWAYS run policy checks (OPA/Sentinel) before deployment — no exceptions for "quick fixes."
9. ALWAYS include cost estimation with every infrastructure change.
10. ALWAYS encrypt data at rest and in transit — TLS 1.2+ minimum, encryption enabled on all data stores.

## Auto-Detection
```
1. Scan for IaC: *.tf→Terraform, template.yaml→CloudFormation, Pulumi.yaml→Pulumi, cdk.json→CDK
2. Detect provider: aws/google/azurerm blocks
3. Detect state backend: backend "s3"/"gcs"/"azurerm", cloud {} block
```

## Keep/Discard Discipline
```
KEEP if: plan shows expected changes AND policy checks pass AND cost within budget
DISCARD if: unexpected destroys OR policy violations OR cost exceeds threshold
Never apply without reviewing plan output first.
```

## Autonomy
Never ask to continue. Loop autonomously. Loop until target or budget. Never pause. Measure before/after. Guard: test_cmd && lint_cmd.

## Stop Conditions
```
STOP when ANY of these are true:
  - All environments validated (plan, policy, cost, drift)
  - All policy violations resolved
  - User explicitly requests stop
  - A CRITICAL policy violation is found that requires architectural changes (escalate to user)

DO NOT STOP because:
  - Cost is higher than expected (report it, but still validate security and drift)
  - Non-production environments have minor policy warnings
```

## Flags & Options
| Flag | Description |
|--|--|
| (none) | Full validation: lint, plan, policy, cost, drift |
| `--validate` | Syntax and config validation only |
| `--plan` | Generate and review execution plan |
| `--cost` | Cost estimation only |
| `--drift` | Drift detection only |
| `--policy` | Policy enforcement check only |
| `--scaffold` | Generate new IaC project structure |
| `--apply` | Apply changes (requires prior plan review) |
| `--env <name>` | Target a specific environment (dev, staging, prod) |

## Output Format
Print on completion: `Infra: {resource_count} resources across {module_count} modules. Drift: {drift_status}. Security: {policy_violations} violations. Cost: ${monthly_estimate}/mo. Verdict: {verdict}.`

## TSV Logging
Log every infrastructure operation to `.godmode/infra-results.tsv`:
```
iteration	task	provider	resources_planned	resources_changed	drift_detected	policy_violations	status
```

## Success Criteria
- All infra in code. Remote state with locking. Resources tagged. IAM least-privilege.
- Secrets in secret manager. Cost reviewed before apply. Drift detection scheduled. No state in VCS.

## Error Recovery
- **Unexpected destroys**: Check state corruption, use `terraform state mv`.
- **State lock stuck**: `force-unlock` only if holder confirmed dead.
- **Drift in prod**: Investigate, import if intentional, revert if accidental.
- **Cost exceeds budget**: Check over-provisioned resources, auto-scaling limits.
