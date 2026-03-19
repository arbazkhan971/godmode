# Google Cloud Developer Guide

How to use Godmode's full skill set to build, deploy, optimize, and secure applications on Google Cloud Platform.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects GCP via gcloud config, GOOGLE_APPLICATION_CREDENTIALS, or app.yaml
```

### Example `.godmode/config.yaml`
```yaml
platform: gcp
project_id: my-project-prod
region: us-central1
iac_tool: terraform              # or pulumi, deployment-manager
deploy_target: cloud-run         # or gke, cloud-functions, app-engine
test_command: npm test
verify_command: gcloud auth print-identity-token
cost_budget: 400                 # monthly USD threshold
```

---

## Skill-to-Service Mapping

### Compute

| GCP Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **GKE** | `k8s`, `infra`, `deploy`, `scale` | `/godmode:k8s` generates Kubernetes manifests and Helm charts for GKE. `/godmode:infra` provisions GKE Autopilot or Standard clusters with node pools via Terraform. `/godmode:deploy` handles Argo Rollouts for progressive delivery. `/godmode:scale` configures HPA, VPA, and cluster autoscaler. |
| **Cloud Run** | `infra`, `deploy`, `optimize`, `observe` | `/godmode:infra` defines Cloud Run services with concurrency, CPU allocation, and VPC connectors. `/godmode:deploy` manages traffic splitting for canary releases. `/godmode:optimize` tunes container startup time, min/max instances, and memory. |
| **Cloud Functions** | `infra`, `deploy`, `optimize` | `/godmode:infra` scaffolds function definitions with triggers (HTTP, Pub/Sub, Cloud Storage, Firestore). `/godmode:optimize` targets cold start reduction and memory allocation. `/godmode:deploy` handles function versioning and traffic migration. |
| **Compute Engine** | `infra`, `deploy`, `secure` | `/godmode:infra` creates instance templates, managed instance groups, and load balancers. `/godmode:secure` audits firewall rules, service accounts, and OS patching. |

### Storage & Databases

| GCP Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **Cloud SQL** | `infra`, `query`, `migrate` | `/godmode:infra` provisions Cloud SQL instances with HA, read replicas, and private IP. `/godmode:query` analyzes slow queries via Query Insights. `/godmode:migrate` manages zero-downtime schema changes. |
| **BigQuery** | `query`, `cost`, `pipeline` | `/godmode:query` optimizes BigQuery SQL — partition pruning, clustering, materialized views, and slot estimation. `/godmode:cost` identifies expensive queries and recommends flat-rate vs. on-demand pricing. `/godmode:pipeline` designs ELT workflows with dbt + BigQuery. |
| **Firestore** | `infra`, `query`, `secure` | `/godmode:infra` defines Firestore databases with composite indexes and TTL policies. `/godmode:query` designs document schemas and denormalization strategies. `/godmode:secure` generates Firestore security rules. |
| **Cloud Storage** | `infra`, `secure`, `cost` | `/godmode:infra` creates buckets with lifecycle rules, versioning, and retention policies. `/godmode:secure` audits IAM bindings and uniform bucket-level access. `/godmode:cost` recommends storage class transitions (Standard → Nearline → Coldline → Archive). |

### Messaging & Integration

| GCP Service | Godmode Skills | How They Work Together |
|-------------|---------------|----------------------|
| **Pub/Sub** | `infra`, `event`, `observe` | `/godmode:infra` creates topics and subscriptions with dead-letter policies, filtering, and ordering. `/godmode:event` designs event-driven architectures with fan-out patterns. `/godmode:observe` monitors subscription backlog and delivery latency. |
| **Cloud Tasks** | `infra`, `resilience` | `/godmode:infra` provisions task queues with rate limiting and retry policies. `/godmode:resilience` designs idempotent task handlers with deduplication. |
| **Eventarc** | `infra`, `event` | `/godmode:infra` configures Eventarc triggers for Cloud Run and Cloud Functions. `/godmode:event` maps domain events to Eventarc routing rules. |

---

## Terraform GCP with `/godmode:infra`

### Terraform Workflow

```bash
# Generate Terraform modules for a GCP web application
/godmode:infra --iac terraform "Cloud Run + Cloud SQL + Memorystore + Cloud CDN"

# Godmode produces:
# - modules/network/main.tf         — VPC, subnets, Cloud NAT, Private Service Connect
# - modules/database/main.tf        — Cloud SQL, Memorystore, IAM
# - modules/compute/main.tf         — Cloud Run services, IAM, VPC connector
# - modules/cdn/main.tf             — Cloud CDN, external HTTPS LB, SSL cert
# - modules/monitoring/main.tf      — Cloud Monitoring dashboards, alert policies
# - environments/production/main.tf — Production variable values
# - environments/staging/main.tf    — Staging variable values
```

### Terraform Best Practices Godmode Enforces

1. **Module structure** — Reusable modules in `modules/`, environment-specific configs in `environments/`
2. **State management** — Remote state in Cloud Storage with state locking
3. **Service accounts** — Dedicated service accounts per workload with least-privilege IAM
4. **Labeling** — All resources labeled with `environment`, `project`, `team`, `managed-by: godmode`
5. **Secrets** — Sensitive values stored in Secret Manager, referenced via data sources
6. **Networking** — Private Google Access enabled, VPC Service Controls for sensitive projects

### Pulumi Workflow

```bash
# Generate Pulumi program for GCP
/godmode:infra --iac pulumi "GKE Autopilot with Workload Identity"

# Godmode produces TypeScript Pulumi program:
# - index.ts
# - network.ts
# - cluster.ts
# - workload-identity.ts
```

---

## Cost Optimization with `/godmode:cost`

```bash
/godmode:cost "Analyze current GCP spend and recommend savings"
```

### What Godmode Analyzes

| Category | Checks |
|----------|--------|
| **Compute** | Right-sizing GKE nodes, committed use discounts (CUDs), preemptible/spot VMs, idle instances, Cloud Run min instances |
| **BigQuery** | Query cost by user/project, slot utilization, flat-rate vs. on-demand analysis, partition pruning opportunities, BI Engine candidates |
| **Storage** | Cloud Storage class optimization, unused persistent disks, Firestore read/write costs, BigQuery storage billing model |
| **Networking** | Cross-region egress, Cloud NAT costs, CDN cache hit ratio, Private Google Access savings, Cloud Interconnect vs. VPN |
| **Database** | Cloud SQL instance sizing, HA overhead, read replica utilization, Memorystore tier optimization |

### Example Cost Report

```
┌─────────────────────────────────────────────────────────┐
│ GCP Cost Optimization Report                            │
├─────────────────────────────────────────────────────────┤
│ Current monthly spend:           $8,200                 │
│ Projected savings:               $2,460 (30.0%)        │
│                                                         │
│ Top recommendations:                                    │
│  1. Purchase 3-year CUDs for GKE nodes    → −$780/mo   │
│  2. Switch BigQuery to flat-rate slots    → −$520/mo   │
│  3. Right-size Cloud SQL db-n1-std-8      → −$340/mo   │
│  4. Enable Cloud CDN (reduce egress)      → −$310/mo   │
│  5. Move cold GCS data to Coldline        → −$280/mo   │
│  6. Use spot VMs for batch GKE workloads  → −$230/mo   │
└─────────────────────────────────────────────────────────┘
```

---

## Security

### IAM Security with `/godmode:secure`

```bash
/godmode:secure "Audit GCP IAM for least-privilege violations"
```

**What Godmode checks:**
- Primitive roles (`roles/editor`, `roles/owner`) on service accounts
- Over-permissive IAM bindings at project and organization level
- Service account key usage (prefer Workload Identity)
- IAM Recommender suggestions for unused permissions
- Cross-project access and organization policy constraints
- Domain-restricted sharing violations

### Workload Identity Configuration

```bash
/godmode:infra "Configure Workload Identity for GKE pods accessing Cloud SQL and Pub/Sub"

# Generates:
# - GCP service account with scoped IAM roles
# - Kubernetes service account with annotation
# - IAM binding between K8s SA and GCP SA
# - No exported service account keys
```

### VPC Security

```bash
/godmode:secure "Audit VPC and firewall rules"
```

**What Godmode checks:**
- Firewall rules allowing `0.0.0.0/0` ingress
- VPC Flow Logs enabled and exported to BigQuery
- Private Google Access enabled on all subnets
- VPC Service Controls perimeter configuration
- Cloud Armor WAF policies on external load balancers
- Hierarchical firewall policies

### Cloud Armor (WAF)

```bash
/godmode:infra "Configure Cloud Armor WAF policy for external HTTPS load balancer"

# Generates:
# - Rate limiting rules per IP
# - OWASP ModSecurity Core Rule Set
# - Geo-based access control
# - Preconfigured WAF rules (SQLi, XSS, LFI, RFI)
# - Adaptive Protection enabled
# - Bot management rules
```

---

## Common Architectures

### Serverless API

```bash
/godmode:think "Design serverless API on GCP"
/godmode:plan
/godmode:build

# Godmode produces:
# Cloud Run services behind API Gateway
# Firestore for data
# Pub/Sub for async processing
# Firebase Auth or Identity Platform
# Cloud CDN for caching
# Cloud Monitoring + Cloud Trace
```

### Data Platform

```bash
/godmode:think "Design analytics data platform on GCP"
/godmode:plan
/godmode:build

# Godmode produces:
# Pub/Sub → Dataflow → BigQuery (streaming)
# Cloud Storage → BigQuery (batch)
# dbt for transformations
# Looker / Looker Studio for visualization
# Data Catalog for governance
# BigQuery ML for in-warehouse ML
```

### Microservices on GKE

```bash
/godmode:think "Design microservices platform on GKE"
/godmode:plan
/godmode:build

# Godmode produces:
# GKE Autopilot cluster
# Anthos Service Mesh (Istio-based)
# Cloud Deploy for delivery pipelines
# Artifact Registry for container images
# Config Connector for GCP resource management
# Cloud Monitoring + Cloud Trace + Cloud Logging
```

---

## Observability on GCP

```bash
/godmode:observe "Set up full observability for Cloud Run services"
```

| Layer | GCP Service | Godmode Configuration |
|-------|------------|----------------------|
| **Metrics** | Cloud Monitoring | Custom dashboards, uptime checks, MQL alert policies |
| **Logs** | Cloud Logging | Structured logging, log-based metrics, log sinks to BigQuery |
| **Traces** | Cloud Trace | Distributed tracing with OpenTelemetry integration |
| **SLOs** | Cloud Monitoring SLOs | Service-level objectives with error budgets and burn-rate alerts |
| **Profiling** | Cloud Profiler | Continuous CPU and heap profiling in production |

---

## CI/CD on GCP

```bash
/godmode:cicd "Set up Cloud Build pipeline deploying to Cloud Run"
```

### Pipeline Stages

```
┌────────┐   ┌──────────┐   ┌──────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Push  │──▶│  Cloud   │──▶│ Test │──▶│ Artifact │──▶│  Cloud   │──▶│  Verify  │
│        │   │  Build   │   │Unit+ │   │ Registry │   │  Deploy  │   │  Canary  │
│        │   │  Trigger │   │ Intg │   │  Push    │   │ Staging  │   │  Check   │
└────────┘   └──────────┘   └──────┘   └──────────┘   └──────────┘   └──────────┘
                                                              │
                                                              ▼
                                                        ┌──────────┐
                                                        │  Cloud   │
                                                        │  Deploy  │
                                                        │Production│
                                                        └──────────┘
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Provision infrastructure | `/godmode:infra "Terraform for <service>"` |
| Deploy to GCP | `/godmode:deploy --target gcp` |
| Optimize costs | `/godmode:cost "Analyze GCP spend"` |
| Security audit | `/godmode:secure "GCP security review"` |
| Monitor services | `/godmode:observe "Cloud Monitoring for <service>"` |
| BigQuery optimization | `/godmode:query "Optimize BigQuery queries"` |
| Kubernetes management | `/godmode:k8s "GKE cluster operations"` |
| Incident response | `/godmode:incident "Investigate <issue>"` |
