# AWS Developer Guide

How to use Godmode's full skill set to build, deploy, optimize, and secure applications on Amazon Web Services.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects AWS via ~/.aws/credentials, CDK projects, or CloudFormation templates
```

### Example `.godmode/config.yaml`
```yaml
platform: aws
region: us-east-1
iac_tool: cdk                    # or cloudformation, terraform, pulumi
deploy_target: ecs-fargate       # or eks, lambda, ec2
test_command: npm test
verify_command: aws sts get-caller-identity
cost_budget: 500                 # monthly USD threshold
```

---

## Skill-to-Service Mapping

### Compute

| AWS Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **EC2** | `infra`, `deploy`, `secure` | `/godmode:infra` generates CDK constructs for EC2 instances with AMI selection, security groups, and auto-scaling groups. `/godmode:deploy` handles rolling updates and blue-green deployments via target groups. `/godmode:secure` audits security group rules and SSH access. |
| **ECS (Fargate)** | `infra`, `k8s`, `deploy`, `observe` | `/godmode:infra` scaffolds ECS task definitions, services, and ALB listeners. `/godmode:deploy` manages canary and blue-green deployments using CodeDeploy integration. `/godmode:observe` configures CloudWatch Container Insights. |
| **EKS** | `k8s`, `infra`, `deploy`, `scale` | `/godmode:k8s` generates Helm charts and Kubernetes manifests. `/godmode:infra` provisions the EKS cluster, managed node groups, and Fargate profiles via CDK. `/godmode:deploy` handles Argo Rollouts or Flagger for progressive delivery. |
| **Lambda** | `infra`, `deploy`, `optimize`, `observe` | `/godmode:infra` defines Lambda functions with layers, VPC config, and event source mappings. `/godmode:optimize` targets cold start reduction, memory tuning, and provisioned concurrency. `/godmode:observe` sets up X-Ray tracing and CloudWatch alarms. |

### Storage & Databases

| AWS Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **S3** | `infra`, `secure`, `cost` | `/godmode:infra` creates buckets with versioning, lifecycle rules, and replication. `/godmode:secure` audits bucket policies, ACLs, and public access settings. `/godmode:cost` recommends intelligent tiering and lifecycle transitions. |
| **RDS** | `infra`, `query`, `migrate`, `backup` | `/godmode:infra` provisions RDS instances with Multi-AZ, read replicas, and parameter groups. `/godmode:query` analyzes slow queries via Performance Insights. `/godmode:migrate` manages schema migrations with zero-downtime strategies. |
| **DynamoDB** | `infra`, `query`, `cost`, `optimize` | `/godmode:infra` defines tables with GSIs, LSIs, and auto-scaling. `/godmode:query` designs access patterns and optimizes key schemas. `/godmode:cost` evaluates on-demand vs. provisioned capacity and recommends reserved capacity. |

### Messaging & Integration

| AWS Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **SQS** | `infra`, `resilience`, `observe` | `/godmode:infra` creates queues with DLQs, visibility timeouts, and redrive policies. `/godmode:observe` monitors queue depth, age of oldest message, and consumer lag. |
| **SNS** | `infra`, `event` | `/godmode:infra` provisions topics with subscriptions, filter policies, and FIFO ordering. `/godmode:event` designs event-driven architectures with fan-out patterns. |
| **CloudFront** | `infra`, `webperf`, `secure` | `/godmode:infra` configures distributions with origins, behaviors, and cache policies. `/godmode:webperf` optimizes cache hit ratios and compression. `/godmode:secure` sets up WAF rules and Origin Access Identity. |

---

## AWS CDK / CloudFormation with `/godmode:infra`

### CDK Workflow

```bash
# Generate CDK stack for a typical web application
/godmode:infra "Create CDK stack: ALB + ECS Fargate + RDS PostgreSQL + ElastiCache Redis"

# Godmode produces:
# - lib/network-stack.ts       — VPC, subnets, NAT gateways
# - lib/database-stack.ts      — RDS, ElastiCache, security groups
# - lib/compute-stack.ts       — ECS cluster, task def, service, ALB
# - lib/monitoring-stack.ts    — CloudWatch dashboards, alarms, SNS alerts
```

### CDK Best Practices Godmode Enforces

1. **Stack separation** — Network, data, compute, and monitoring in separate stacks with cross-stack references
2. **Removal policies** — Production databases always use `RemovalPolicy.RETAIN`
3. **Tagging** — All resources tagged with `Environment`, `Project`, `CostCenter`, `ManagedBy: godmode`
4. **Secrets** — Database credentials stored in Secrets Manager, never hardcoded
5. **Outputs** — Stack outputs exported for downstream consumption

### CloudFormation Workflow

```bash
# Generate CloudFormation templates
/godmode:infra --iac cloudformation "Three-tier web app with WAF"

# Godmode produces:
# - templates/network.yaml
# - templates/database.yaml
# - templates/compute.yaml
# - templates/waf.yaml
# - templates/main.yaml          — nested stack orchestrator
```

### Terraform Workflow

```bash
# Generate Terraform for AWS
/godmode:infra --iac terraform "EKS cluster with Karpenter autoscaling"

# Godmode produces:
# - modules/vpc/main.tf
# - modules/eks/main.tf
# - modules/karpenter/main.tf
# - environments/production/main.tf
# - environments/staging/main.tf
```

---

## Cost Optimization with `/godmode:cost`

```bash
/godmode:cost "Analyze current AWS spend and recommend savings"
```

### What Godmode Analyzes

| Category | Checks |
|----------|--------|
| **Compute** | Right-sizing EC2/Fargate, Reserved Instances vs. Savings Plans, Spot Instance candidates, idle instances, over-provisioned Lambda memory |
| **Storage** | S3 lifecycle policies, EBS volume optimization (gp3 vs. gp2), unused snapshots, DynamoDB capacity mode |
| **Data transfer** | Cross-AZ traffic, NAT Gateway costs, CloudFront vs. direct S3, VPC endpoint opportunities |
| **Database** | RDS instance right-sizing, Aurora Serverless v2 candidates, DynamoDB reserved capacity, ElastiCache node optimization |
| **Unused resources** | Unattached EBS volumes, unused Elastic IPs, idle load balancers, orphaned snapshots |

### Example Cost Report

```
  AWS Cost Optimization Report
  Current monthly spend:           $12,450
  Projected savings:               $3,820 (30.7%)
  Top recommendations:
  1. Switch 4x m5.xlarge → Savings Plan    → −$1,200/mo
  2. Enable S3 Intelligent-Tiering         → −$680/mo
  3. Right-size RDS db.r5.2xl → db.r5.xl  → −$520/mo
  4. Replace NAT Gateway with VPC endpoints→ −$440/mo
  5. Move infrequent DynamoDB tables to OD → −$380/mo
  6. Delete 47 unused EBS snapshots        → −$320/mo
  7. Enable gp3 for 12 gp2 EBS volumes    → −$280/mo
```

---

## Security with IAM, VPC, WAF

### IAM Security with `/godmode:secure`

```bash
/godmode:secure "Audit IAM policies and roles for least-privilege violations"
```

**What Godmode checks:**
- Wildcard (`*`) actions and resources in IAM policies
- IAM users with console access but no MFA
- Cross-account role trust policies
- Service-linked roles with excessive permissions
- Access Advisor data for unused permissions
- IAM Access Analyzer findings

### IAM Policy Generation

```bash
/godmode:infra "Create least-privilege IAM role for ECS task accessing DynamoDB and S3"

# Generates:
# - Scoped to specific table ARNs and bucket prefixes
# - Condition keys for VPC source and encryption
# - Session tags for ABAC
# - Permission boundary attached
```

### VPC Security

```bash
/godmode:secure "Audit VPC configuration for security gaps"
```

**What Godmode checks:**
- Security group rules allowing `0.0.0.0/0` ingress
- NACLs with overly permissive rules
- Public subnets with instances that should be private
- VPC Flow Logs enabled and analyzed
- Transit Gateway and peering misconfigurations
- DNS resolution and DNSSEC settings

### WAF Configuration

```bash
/godmode:infra "Configure WAF for CloudFront distribution protecting API Gateway"

# Generates WAF rules for:
# - Rate limiting (IP-based and URI-based)
# - SQL injection detection
# - XSS protection
# - Geo-restriction
# - AWS Managed Rule Groups (Core, Known Bad Inputs, Bot Control)
# - Custom rules for application-specific patterns
```

---

## Common Architectures

### Serverless API

```bash
/godmode:think "Design serverless REST API on AWS"
/godmode:plan
/godmode:build

# Godmode produces:
# API Gateway → Lambda → DynamoDB
# Cognito for auth
# CloudWatch + X-Ray for observability
# WAF for protection
# CDK stack for all resources
```

### Container-Based Microservices

```bash
/godmode:think "Design microservices platform on EKS"
/godmode:plan
/godmode:build

# Godmode produces:
# EKS cluster with managed node groups
# Service mesh (App Mesh or Istio)
# ALB Ingress Controller
# Helm charts per service
# CI/CD with CodePipeline or GitHub Actions
# Prometheus + Grafana observability
```

### Event-Driven Architecture

```bash
/godmode:think "Design event-driven order processing system"
/godmode:plan
/godmode:build

# Godmode produces:
# EventBridge for event routing
# SQS queues for decoupling
# Lambda functions for processing
# DynamoDB for state
# SNS for notifications
# Step Functions for orchestration
# DLQs and retry policies for resilience
```

---

## Observability on AWS

```bash
/godmode:observe "Set up full observability for ECS Fargate services"
```

| Layer | AWS Service | Godmode Configuration |
|-------|------------|----------------------|
| **Metrics** | CloudWatch Metrics | Custom dashboards, composite alarms, anomaly detection |
| **Logs** | CloudWatch Logs | Structured JSON logging, metric filters, log insights queries |
| **Traces** | X-Ray | Distributed tracing across Lambda, ECS, API Gateway |
| **SLOs** | CloudWatch SLIs | Error rate, latency percentiles, availability targets |
| **Alerts** | SNS + PagerDuty | Tiered alerting with runbook links |

---

## CI/CD on AWS

```bash
/godmode:cicd "Set up GitHub Actions pipeline deploying to ECS Fargate"
```

### Pipeline Stages

```
| Push | ──▶ | Build | ──▶ | Test | ──▶ | ECR | ──▶ | Deploy | ──▶ | Verify |
|  |  | Docker |  | Unit+ |  | Push |  | Staging |  | Smoke + |
|  |  | Image |  | Intg |  |  |  |  |  | Canary |
                                                       ▼
  Deploy
  Production
```

### OIDC Authentication (No Long-Lived Keys)

```bash
/godmode:infra "Create GitHub Actions OIDC provider and IAM role for CI/CD"

# Generates:
# - IAM OIDC provider for token.actions.githubusercontent.com
# - IAM role with trust policy scoped to repo and branch
# - Least-privilege policy for ECR push + ECS deploy
```

---

## Disaster Recovery

```bash
/godmode:infra "Design multi-region DR strategy for production workload"
```

| Strategy | RPO | RTO | Godmode Implementation |
|----------|-----|-----|----------------------|
| **Backup & Restore** | Hours | Hours | S3 cross-region replication, RDS automated backups, DynamoDB PITR |
| **Pilot Light** | Minutes | 10-30 min | Minimal standby in DR region, Route 53 health checks, automated failover |
| **Warm Standby** | Seconds | Minutes | Scaled-down replica in DR region, Global Accelerator, Aurora Global Database |
| **Active-Active** | Zero | Zero | Multi-region deployment, DynamoDB Global Tables, CloudFront multi-origin |

---

## Quick Reference

| Task | Command |
|------|---------|
| Provision infrastructure | `/godmode:infra "CDK stack for <service>"` |
| Deploy to AWS | `/godmode:deploy --target aws` |
| Optimize costs | `/godmode:cost "Analyze AWS spend"` |
| Security audit | `/godmode:secure "AWS security review"` |
| Monitor services | `/godmode:observe "CloudWatch setup for <service>"` |
| Database optimization | `/godmode:query "RDS Performance Insights analysis"` |
| Incident response | `/godmode:incident "Investigate <issue>"` |
| Load test | `/godmode:loadtest "Stress test API Gateway + Lambda"` |
