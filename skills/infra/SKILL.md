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

# Convert plan to readable output
terraform show -json tfplan > plan.json
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
|---|---|---|
| aws_instance.api (t3.large) | $60.74 | +$60.74 NEW |
| aws_rds.primary (db.r5.lg) | $172.80 | — |
| aws_s3.assets | $2.30 | — |
| aws_elasticache.redis | $48.62 | +$48.62 NEW |
| aws_alb.main | $22.27 | — |
| TOTAL | $306.73 | +$109.36 |
| Previous | $197.37 |  |
| Delta | +$109.36 | +55.4% |

Cost threshold: $500/mo — WITHIN BUDGET
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
  Estimated time: 4-6 minutes
  Estimated cost delta: +$109.36/mo
  Risk level: LOW (no destructive changes)
  Pre-deployment checklist:
  [x] terraform plan reviewed
  [x] Policy checks passed
  [x] Cost within budget
  [x] No drift detected
  [x] Tests passing
  [ ] Manual approval (required for production)
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
Apply complete! Resources: 3 added, 1 changed, 0 destroyed.

Outputs:
  api_endpoint = "https://api.example.com"
  redis_endpoint = "redis.example.internal:6379"
  security_group_id = "sg-0abc123def456789"

Post-deployment verification:
  [x] Health check: https://api.example.com/health — 200 OK
  [x] Redis connectivity — CONNECTED
  [x] Security group rules — VERIFIED
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

1. **Never apply without a plan.** Always run `plan` first and review changes before `apply`. No blind deployments.
2. **Policy is mandatory.** Every change must pass OPA/Sentinel policy checks. No exceptions for "quick fixes."
3. **Cost awareness.** Every change includes a cost estimate. Flag unexpected cost increases before they happen.
4. **Drift is a bug.** Manual changes to infrastructure are technical debt. Detect and reconcile immediately.
5. **Test infrastructure like code.** Unit tests for modules, integration tests for stacks, compliance tests for security.
6. **State is sacred.** Never modify state files manually. Use `terraform state` commands or equivalent tooling.
7. **Environments are isolated.** Dev, staging, and production use separate state, separate accounts/projects, and separate credentials.
8. **Secrets never in IaC.** Use variable references, secret managers, or parameter stores. Never hardcode credentials.

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
On activation, detect infrastructure context automatically:
```
AUTO-DETECT:
1. Scan for IaC tool:
   - *.tf, terraform.tfstate → Terraform
   - template.yaml, *.cfn.yml → CloudFormation
   - Pulumi.yaml, Pulumi.*.yaml → Pulumi
   - cdk.json, cdk.context.json → AWS CDK
2. Detect cloud provider:
   - aws provider blocks, AWS:: resources, aws-cdk imports → AWS
   - google provider blocks, gcp:: resources → GCP
   - azurerm provider blocks, Microsoft.* resources → Azure
3. Detect state backend:
   - backend "s3", backend "gcs", backend "azurerm", cloud {} block
4. Scan for environments:
   - *.tfvars files, environments/ directories, workspace list
5. Detect modules/stacks:
   - modules/ directory, source references in .tf files
6. Check for existing CI/CD:
   - .github/workflows/ with terraform/cdk/pulumi steps
   - Terraform Cloud/Enterprise workspace configuration
7. Detect cost tooling:
   - .infracost.yml, infracost-*.json
```

## Iterative Validation Protocol
Infrastructure validation is iterative across environments:
```
current_env = 0
environments = ["dev", "staging", "production"]

WHILE current_env < len(environments):
  env = environments[current_env]
  1. INIT: terraform init -backend-config={env}.backend.hcl
  2. VALIDATE: terraform validate
  3. PLAN: terraform plan -var-file={env}.tfvars -out={env}.tfplan
  4. POLICY CHECK: Run OPA/Sentinel against plan output
  5. COST CHECK: infracost diff --path . --compare-to baseline
  6. IF policy violations OR cost threshold exceeded:
     - REPORT violations with remediation steps
     - HALT — do not proceed to next environment
     - WAIT for user to fix and re-run
  7. IF all checks pass:
     - REPORT: "{env} validated — {N} resources, ${cost}/mo"
     - current_env += 1
  8. DRIFT CHECK (production only):
     - terraform plan -detailed-exitcode
     - If drift detected → report and halt

EXIT when all environments validated OR user halts
```

## Keep/Discard Discipline
```
After EACH infrastructure change:
  1. MEASURE: Run terraform plan — are the changes as expected? Run policy checks — do they pass?
  2. COMPARE: Is the infrastructure more secure/compliant/cost-effective than before?
  3. DECIDE:
     - KEEP if: plan shows expected changes AND policy checks pass AND cost within budget
     - DISCARD if: plan shows unexpected destroys OR policy violations OR cost exceeds threshold
  4. COMMIT kept changes. Revert discarded changes before proceeding.

Never apply infrastructure changes without reviewing the plan output first.
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to resolve a policy violation or drift issue:
  1. Re-read the policy definition — the violation may be a false positive from an overly strict policy.
  2. Check state consistency: run `terraform state list` and compare with actual cloud resources.
  3. If state is corrupted: use `terraform import` to reconcile, not manual state editing.
  4. If still stuck → log stop_reason=stuck, document the issue, halt deployment for this environment.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All environments validated (plan, policy, cost, drift)
  - All policy violations resolved
  - User explicitly requests stop
  - A CRITICAL policy violation is found that requires architectural changes (escalate to user)

DO NOT STOP just because:
  - Cost is higher than expected (report it, but still validate security and drift)
  - Non-production environments have minor policy warnings
```

## Simplicity Criterion
```
PREFER the simpler infrastructure approach:
  - Managed services (RDS, Cloud SQL) before self-managed databases
  - Standard module patterns before custom module abstractions
  - Fewer resources with right-sized capacity before many small resources
  - Built-in cloud encryption before custom KMS key management
  - Single state file per environment before complex state partitioning
  - Terraform workspaces before duplicated directory structures (for simple cases)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full validation: lint, plan, policy, cost, drift |
| `--validate` | Syntax and configuration validation only |
| `--plan` | Generate and review execution plan |
| `--cost` | Cost estimation only |
| `--drift` | Drift detection only |
| `--policy` | Policy enforcement check only |
| `--test` | Run IaC tests (unit, integration, compliance) |
| `--scaffold` | Generate new IaC project structure |
| `--apply` | Apply changes (requires prior plan review) |
| `--env <name>` | Target a specific environment (dev, staging, prod) |

## Output Format
Print on completion: `Infra: {resource_count} resources across {module_count} modules. Drift: {drift_status}. Security: {policy_violations} violations. Cost: ${monthly_estimate}/mo. Verdict: {verdict}.`

## TSV Logging
Log every infrastructure operation to `.godmode/infra-results.tsv`:
```
iteration	task	provider	resources_planned	resources_changed	drift_detected	policy_violations	status
1	modules	aws	24	24	0	3	created
2	security	aws	0	8	0	0	hardened
3	cost	aws	0	2	0	0	optimized
4	drift	aws	0	0	0	0	clean
```
Columns: iteration, task, provider, resources_planned, resources_changed, drift_detected, policy_violations, status(created/modified/hardened/optimized/clean/drifted).

## Success Criteria
- All infrastructure defined in code (zero manual console changes).
- Remote state backend configured with locking (S3+DynamoDB, GCS, Terraform Cloud).
- All resources tagged with owner, environment, cost-center, and managed-by.
- IAM policies follow least privilege (no `*` actions or resources).
- Secrets managed through a secret manager (not hardcoded in `.tf` files).
- Cost estimate reviewed before every apply.
- Drift detection runs on schedule (daily or per-PR).
- State file never committed to version control.

## Error Recovery
- **`terraform plan` shows unexpected destroys**: Check for state file corruption. Run `terraform state list` to verify resources. If resource was renamed, use `terraform state mv` instead of destroy+recreate.
- **State lock stuck**: Identify the lock holder with `terraform force-unlock <LOCK_ID>`. Only force-unlock if the holding process is confirmed dead. Never force-unlock during an active apply.
- **Provider authentication failure**: Check environment variables or credential files. Verify IAM roles/service accounts have required permissions. Check token expiration.
- **Drift detected in production**: Do not auto-apply to fix drift. Investigate why manual changes were made. Import the manual change into state if intentional, or revert it in the console if accidental. Then apply from code.
- **Module version conflict**: Pin module versions explicitly. Use version constraints (`~> 3.0`). Check for breaking changes in the module changelog before upgrading.
- **Cost estimate exceeds budget**: Review the plan for over-provisioned resources. Check for resources belonging in a lower tier. Verify auto-scaling max limits are set.

