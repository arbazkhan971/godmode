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
┌──────────────────────────────────────────────────────────┐
│  Monthly Cost Estimate                                    │
├──────────────────────────────────────────────────────────┤
│  Resource                    │ Monthly    │ Change        │
│  ─────────────────────────────────────────────────────── │
│  aws_instance.api (t3.large) │ $60.74     │ +$60.74 NEW   │
│  aws_rds.primary (db.r5.lg)  │ $172.80    │ —             │
│  aws_s3.assets               │ $2.30      │ —             │
│  aws_elasticache.redis       │ $48.62     │ +$48.62 NEW   │
│  aws_alb.main                │ $22.27     │ —             │
│  ─────────────────────────────────────────────────────── │
│  TOTAL                       │ $306.73    │ +$109.36      │
│  Previous                    │ $197.37    │               │
│  Delta                       │ +$109.36   │ +55.4%        │
└──────────────────────────────────────────────────────────┘

Cost threshold: $500/mo — WITHIN BUDGET
```

If cost exceeds threshold: "Estimated cost ($X) exceeds budget threshold ($Y). Consider: <specific cost optimization suggestions>."

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
┌──────────────────────────────────────────────────────────┐
│  Drift Detection Results                                  │
├──────────────────────────────────────────────────────────┤
│  Resources in sync:  14/16                                │
│  Resources drifted:  2/16                                 │
│  Resources deleted:  0/16                                 │
├──────────────────────────────────────────────────────────┤
│  DRIFTED RESOURCES:                                       │
│  1. aws_security_group.api_sg                             │
│     - Ingress rule added manually (port 8080 from 0.0.0.0/0) │
│     - Action: REMOVE manual rule or UPDATE IaC definition │
│  2. aws_instance.worker                                   │
│     - Instance type changed: t3.medium -> t3.large        │
│     - Action: UPDATE IaC to t3.large or REVERT instance   │
└──────────────────────────────────────────────────────────┘
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
┌──────────────────────────────────────────────────────────┐
│  Infrastructure Deployment — <environment>                │
├──────────────────────────────────────────────────────────┤
│  Resources to CREATE:  3                                  │
│  Resources to UPDATE:  1                                  │
│  Resources to DELETE:  0                                  │
│  Resources UNCHANGED:  12                                 │
├──────────────────────────────────────────────────────────┤
│  CREATE:                                                  │
│  + aws_instance.api_server (t3.large)                     │
│  + aws_security_group.api_sg                              │
│  + aws_elasticache_cluster.redis                          │
│                                                           │
│  UPDATE:                                                  │
│  ~ aws_alb_listener.https (add new target group)          │
│                                                           │
│  Estimated time: 4-6 minutes                              │
│  Estimated cost delta: +$109.36/mo                        │
│  Risk level: LOW (no destructive changes)                 │
├──────────────────────────────────────────────────────────┤
│  Pre-deployment checklist:                                │
│  [x] terraform plan reviewed                              │
│  [x] Policy checks passed                                 │
│  [x] Cost within budget                                   │
│  [x] No drift detected                                    │
│  [x] Tests passing                                        │
│  [ ] Manual approval (required for production)            │
└──────────────────────────────────────────────────────────┘
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

## Example Usage

### Validating a Terraform project
```
User: /godmode:infra Validate our Terraform setup

Infra: Discovering infrastructure context...

INFRASTRUCTURE CONTEXT:
IaC Tool: Terraform v1.6.2
Provider: AWS (us-east-1)
State Backend: S3 (terraform-state-prod)
Modules: vpc, ecs-cluster, rds, redis, alb
Environments: dev, staging, production

Running validation...
  terraform fmt -check: PASS
  terraform validate: PASS
  terraform plan: 16 resources, 0 changes

Running policy checks...
  POLICY VIOLATION 1: S3 bucket missing encryption
  Severity: HIGH
  Resource: aws_s3_bucket.uploads
  Remediation: Add server_side_encryption_configuration block

Cost estimate: $197.37/mo (no change)
Drift detection: 0 drifted resources

Verdict: 1 policy violation to fix before shipping.
```

### Scaffolding new infrastructure
```
User: /godmode:infra Set up Terraform for a new microservice on AWS

Infra: Scaffolding Terraform project...

Created:
  terraform/
    main.tf          — Provider config, backend
    variables.tf     — Input variables with defaults
    outputs.tf       — Stack outputs
    versions.tf      — Required provider versions
    environments/
      dev.tfvars     — Dev environment values
      staging.tfvars — Staging environment values
      prod.tfvars    — Production environment values
    modules/
      ecs-service/   — ECS Fargate service module
      alb/           — Application Load Balancer module
      rds/           — RDS PostgreSQL module

All modules include:
  - Input validation
  - Mandatory tagging
  - Encryption at rest
  - Least-privilege IAM
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

## Anti-Patterns

- **Do NOT apply without reviewing the plan.** Blind `terraform apply` destroys things. Always review the plan output.
- **Do NOT hardcode secrets.** Use `var.db_password` from a secret manager, not `password = "hunter2"` in your `.tf` files.
- **Do NOT use local state in production.** S3, GCS, or Terraform Cloud backend with state locking. Always.
- **Do NOT skip tagging.** Untagged resources become orphans that cost money and confuse incident response.
- **Do NOT use `*` in IAM policies.** Least privilege means specifying exactly which actions on which resources.
- **Do NOT manually modify infrastructure.** If you changed it in the console, it will drift. Change it in code.
- **Do NOT share state between environments.** Each environment gets its own state file and its own credentials.
- **Do NOT ignore cost estimates.** A missing cost review is how you get a $50,000 surprise bill.
