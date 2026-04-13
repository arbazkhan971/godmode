---
name: infra
description: |
  Infrastructure as Code skill. Terraform, CloudFormation,
  Pulumi, CDK. IaC testing, cost estimation, drift
  detection, policy enforcement. Triggers on:
  /godmode:infra, "terraform plan", "provision
  infrastructure", "infrastructure review".
---

# Infra — Infrastructure as Code

## Activate When
- User invokes `/godmode:infra`
- User says "terraform plan", "provision infrastructure"
- User says "check drift", "estimate costs"
- Deployment requires new cloud resources

## Workflow

### Step 1: Discover Infrastructure Context

```bash
# Detect IaC tool
ls *.tf template.yaml Pulumi.yaml cdk.json \
  2>/dev/null

# Check state backend
grep -r 'backend\s*"s3"\|backend\s*"gcs"' *.tf \
  2>/dev/null

# List existing resources
terraform state list 2>/dev/null | head -20
```

```
INFRASTRUCTURE CONTEXT:
IaC Tool: Terraform | CloudFormation | Pulumi | CDK
Provider: AWS | GCP | Azure | Multi-cloud
State: S3 | GCS | Azure Blob | Terraform Cloud | Local
Environments: dev | staging | production

IF no IaC detected: scaffold new project
IF state is local: migrate to remote immediately
IF no policy checks: add OPA/Sentinel
```

### Step 2: Validate Infrastructure

```bash
# Terraform validation
terraform fmt -check -recursive
terraform validate
terraform init -backend=false
terraform plan -out=tfplan

# CloudFormation validation
aws cloudformation validate-template \
  --template-body file://template.yaml
cfn-lint template.yaml

# Pulumi / CDK
pulumi preview --diff
cdk synth && cdk diff
```

### Step 3: Security & Policy Enforcement

```
POLICY CHECKLIST:
  [ ] No public S3 buckets or storage
  [ ] No SGs with 0.0.0.0/0 on sensitive ports
  [ ] Encryption at rest on all data stores
  [ ] TLS 1.2+ enforced in transit
  [ ] No hardcoded secrets in IaC
  [ ] IAM least-privilege (no * actions)
  [ ] All resources tagged: env, team, cost-center
  [ ] VPC flow logs enabled
  [ ] CloudTrail / audit logging enabled

THRESHOLDS:
  CRITICAL: public data store, leaked secrets, * IAM
  HIGH: missing encryption, no tags, no audit logs
  MEDIUM: suboptimal instance type, missing flow logs
  IF any CRITICAL: block deployment immediately
```

### Step 4: Cost Estimation

```bash
# Infracost for Terraform
infracost breakdown --path .
infracost diff --path . \
  --compare-to infracost-base.json
```

```
COST ESTIMATE:
| Resource                  | Monthly  | Change   |
|---------------------------|----------|----------|
| aws_instance.api (t3.lg)  | $60.74   | NEW      |
| aws_rds.primary (r5.lg)   | $172.80  | —        |
| aws_elasticache.redis      | $48.62   | NEW      |
| TOTAL                      | $306.73  | +$109.36 |

THRESHOLDS:
  IF cost delta > 20% of current: require approval
  IF monthly > budget ceiling: suggest optimizations
  IF cost per request > $0.01: investigate alternatives
```

### Step 5: Drift Detection

```bash
# Terraform drift
terraform plan -detailed-exitcode
# Exit 0=no changes, 1=error, 2=drift detected

# CloudFormation drift
aws cloudformation detect-stack-drift \
  --stack-name <stack>
```

```
DRIFT REPORT:
  In sync: 14/16 resources
  Drifted: 2/16 resources
  IF drift found in security group: investigate ASAP
  IF drift found in instance type: update IaC or revert
```

### Step 6: IaC Testing

```bash
# Unit tests (Terratest)
cd test/ && go test -v -timeout 30m

# Integration tests
terraform apply -auto-approve -var-file=test.tfvars
./scripts/infra-integration-test.sh
terraform destroy -auto-approve -var-file=test.tfvars

# Compliance (InSpec)
inspec exec profiles/cloud-security --target aws://
```

### Step 7: Deployment Plan

```
DEPLOYMENT PLAN — <environment>:
  CREATE: <N> resources
  UPDATE: <N> resources
  DELETE: <N> resources
  UNCHANGED: <N> resources

SAFETY:
  IF any DELETE: require manual confirmation
  IF > 5 resources changing: deploy in stages
  IF database resource changing: take snapshot first
```

### Step 8: Apply & Verify

```bash
terraform apply tfplan
terraform output -json > outputs.json

# Post-deployment health check
curl -s -o /dev/null -w "%{http_code}" \
  https://api.example.com/health
```

Commit: `"infra: <description> — <N> resources
  (<cost delta>)"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Never apply without a plan.** Review first.
2. **Policy is mandatory.** Every change checked.
3. **Cost awareness.** Estimate with every change.
4. **Drift is a bug.** Detect and reconcile.
5. **State is sacred.** Never modify manually.
6. **Environments isolated.** Separate state/creds.
7. **Secrets never in IaC.** Use secret managers.

## HARD RULES

1. Never apply without reviewing plan output.
2. Never hardcode secrets in IaC files.
3. Never use local state in production.
4. Never use `*` in IAM policies.
5. Never skip resource tagging (env, team, cost-center).
6. Never share state between environments.
7. Never modify state files manually.
8. Always run policy checks before deployment.
9. Always include cost estimation with changes.
10. Always encrypt at rest and in transit (TLS 1.2+).

## Auto-Detection
```
1. IaC: *.tf, template.yaml, Pulumi.yaml, cdk.json
2. Provider: aws/google/azurerm blocks
3. State: backend "s3"/"gcs"/"azurerm"
```

<!-- tier-3 -->

## Quality Targets
- Target: <5min for infrastructure plan generation
- Target: 0 drift between declared and actual state
- Cost estimate accuracy: >=90% vs actual spend
- Target: <15min for full environment provisioning

## Output Format
Print: `Infra: {resources} resources,
  {modules} modules. Drift: {status}.
  Security: {violations}. Cost: ${monthly}/mo.
  Verdict: {verdict}.`

## TSV Logging
```
iteration	provider	resources	drift	policy_violations	status
```

## Keep/Discard Discipline
```
KEEP if: plan shows expected changes
  AND policy passes AND cost within budget
DISCARD if: unexpected destroys OR policy violations
  OR cost exceeds threshold
```

## Stop Conditions
```
STOP when ANY of:
  - All environments validated
  - All policy violations resolved
  - User requests stop
  - CRITICAL violation needs architectural change
```

## Error Recovery
- Unexpected destroys: check state, use `terraform state mv`.
- State lock stuck: force-unlock only if holder dead.
- Drift in prod: investigate, import or revert.
- Cost exceeds budget: check over-provisioned resources.

