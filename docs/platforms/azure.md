# Azure Developer Guide

How to use Godmode's full skill set to build, deploy, optimize, and secure applications on Microsoft Azure.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Azure via ~/.azure/, bicep files, or ARM templates
```

### Example `.godmode/config.yaml`
```yaml
platform: azure
subscription_id: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
region: eastus
iac_tool: bicep                  # or arm, terraform, pulumi
deploy_target: app-service       # or aks, functions, container-apps
test_command: dotnet test
verify_command: az account show
cost_budget: 600                 # monthly USD threshold
```

---

## Skill-to-Service Mapping

### Compute

| Azure Service | Godmode Skills | How They Work Together |
|---------------|---------------|----------------------|
| **AKS** | `k8s`, `infra`, `deploy`, `scale` | `/godmode:k8s` generates Kubernetes manifests and Helm charts for AKS. `/godmode:infra` provisions AKS clusters with node pools, Azure CNI, and Workload Identity via Bicep. `/godmode:deploy` handles progressive delivery with Flagger or Argo Rollouts. `/godmode:scale` configures HPA, KEDA for event-driven scaling, and cluster autoscaler. |
| **App Service** | `infra`, `deploy`, `optimize`, `observe` | `/godmode:infra` defines App Service plans, web apps, and deployment slots. `/godmode:deploy` manages blue-green deployments via slot swaps. `/godmode:optimize` right-sizes App Service plans and tunes auto-scale rules. `/godmode:observe` configures Application Insights. |
| **Azure Functions** | `infra`, `deploy`, `optimize` | `/godmode:infra` scaffolds function apps with bindings (HTTP, Queue, Timer, Blob, Cosmos DB). `/godmode:optimize` targets cold start reduction, premium plan evaluation, and Flex Consumption plan tuning. `/godmode:deploy` handles function versioning and slot-based deployments. |
| **Container Apps** | `infra`, `deploy`, `scale` | `/godmode:infra` creates Container Apps environments with Dapr integration and VNET injection. `/godmode:deploy` manages revision-based traffic splitting. `/godmode:scale` configures KEDA-based auto-scaling rules (HTTP, Queue, Custom). |

### Storage & Databases

| Azure Service | Godmode Skills | How They Work Together |
|---------------|---------------|----------------------|
| **Cosmos DB** | `infra`, `query`, `cost`, `optimize` | `/godmode:infra` provisions Cosmos DB accounts with multi-region writes, consistency levels, and partition key design. `/godmode:query` optimizes RU consumption, cross-partition queries, and indexing policies. `/godmode:cost` evaluates serverless vs. provisioned throughput and reserved capacity. |
| **Azure SQL** | `infra`, `query`, `migrate` | `/godmode:infra` creates SQL databases with elastic pools, geo-replication, and failover groups. `/godmode:query` analyzes slow queries via Query Performance Insight and automatic tuning. `/godmode:migrate` handles schema migrations with zero-downtime strategies. |
| **Blob Storage** | `infra`, `secure`, `cost` | `/godmode:infra` creates storage accounts with lifecycle management, versioning, and immutability policies. `/godmode:secure` audits access keys, SAS tokens, and Azure AD authentication. `/godmode:cost` recommends access tier transitions (Hot → Cool → Cold → Archive). |

### Messaging & Integration

| Azure Service | Godmode Skills | How They Work Together |
|---------------|---------------|----------------------|
| **Service Bus** | `infra`, `event`, `resilience` | `/godmode:infra` creates namespaces with queues, topics, subscriptions, and dead-letter queues. `/godmode:event` designs message-driven architectures with sessions and message deferral. `/godmode:resilience` implements retry policies, duplicate detection, and poison message handling. |
| **Event Grid** | `infra`, `event` | `/godmode:infra` provisions Event Grid topics, system topics, and event subscriptions with filtering. `/godmode:event` designs reactive architectures with domain events routed to multiple subscribers. |
| **Event Hubs** | `infra`, `pipeline`, `observe` | `/godmode:infra` creates Event Hubs namespaces with partitions, capture, and schema registry. `/godmode:pipeline` designs streaming data pipelines. `/godmode:observe` monitors throughput and consumer group lag. |

---

## Bicep / ARM with `/godmode:infra`

### Bicep Workflow

```bash
# Generate Bicep modules for a typical web application
/godmode:infra --iac bicep "App Service + Azure SQL + Redis Cache + Front Door"

# Godmode produces:
# - modules/network.bicep          — VNET, subnets, NSGs, Private Endpoints
# - modules/database.bicep         — Azure SQL, Redis Cache, Private DNS
# - modules/compute.bicep          — App Service Plan, Web App, slots
# - modules/frontdoor.bicep        — Front Door, WAF policy, custom domains
# - modules/monitoring.bicep       — Application Insights, Log Analytics, alerts
# - main.bicep                     — Orchestrator with module references
# - main.bicepparam                — Environment-specific parameters
```

### Bicep Best Practices Godmode Enforces

1. **Module composition** — Reusable modules with clear input/output contracts
2. **Parameter files** — Environment-specific `.bicepparam` files for dev, staging, production
3. **Naming conventions** — Consistent resource naming with `uniqueString()` for global uniqueness
4. **Managed Identity** — System-assigned or user-assigned managed identities, never access keys
5. **Private Endpoints** — All PaaS services connected via Private Endpoints and Private DNS zones
6. **Tagging** — All resources tagged with `environment`, `project`, `costCenter`, `managedBy: godmode`
7. **Diagnostic settings** — All resources send logs and metrics to Log Analytics workspace

### ARM Template Workflow

```bash
# Generate ARM templates
/godmode:infra --iac arm "AKS cluster with Azure AD integration and Key Vault"

# Godmode produces:
# - templates/network.json
# - templates/keyvault.json
# - templates/aks.json
# - templates/monitoring.json
# - azuredeploy.json               — linked template orchestrator
# - azuredeploy.parameters.json
```

### Terraform Workflow

```bash
# Generate Terraform for Azure
/godmode:infra --iac terraform "AKS with AGIC and Azure AD Pod Identity"

# Godmode produces:
# - modules/network/main.tf
# - modules/aks/main.tf
# - modules/agic/main.tf
# - environments/production/main.tf
# - environments/staging/main.tf
```

---

## Cost Optimization with `/godmode:cost`

```bash
/godmode:cost "Analyze current Azure spend and recommend savings"
```

### What Godmode Analyzes

| Category | Checks |
|----------|--------|
| **Compute** | Right-sizing VMs/App Service plans, Azure Reservations, Spot VMs for batch, B-series burstable for dev/test, Azure Hybrid Benefit for Windows/SQL |
| **Database** | Cosmos DB RU optimization (serverless vs. autoscale vs. provisioned), Azure SQL elastic pools, DTU vs. vCore model, reserved capacity |
| **Storage** | Blob lifecycle policies, unused managed disks, premium vs. standard storage, reserved capacity for consistent workloads |
| **Networking** | Bandwidth costs, Front Door vs. CDN, ExpressRoute vs. VPN, Private Endpoint costs, NAT Gateway optimization |
| **Dev/Test** | Dev/Test pricing eligibility, environment auto-shutdown schedules, Azure Dev/Test subscriptions |

### Example Cost Report

```
┌─────────────────────────────────────────────────────────┐
│ Azure Cost Optimization Report                          │
├─────────────────────────────────────────────────────────┤
│ Current monthly spend:           $10,800                │
│ Projected savings:               $3,240 (30.0%)        │
│                                                         │
│ Top recommendations:                                    │
│  1. Purchase 3-year reservations for AKS   → −$920/mo  │
│  2. Enable Azure Hybrid Benefit (12 VMs)   → −$680/mo  │
│  3. Switch Cosmos DB to autoscale           → −$480/mo  │
│  4. Right-size App Service to P1v3          → −$420/mo  │
│  5. Move dev/test to B-series VMs           → −$380/mo  │
│  6. Enable Blob lifecycle management        → −$360/mo  │
└─────────────────────────────────────────────────────────┘
```

---

## Security

### Azure AD / Entra ID with `/godmode:secure`

```bash
/godmode:secure "Audit Azure AD and RBAC for least-privilege violations"
```

**What Godmode checks:**
- Over-permissive RBAC role assignments (Owner, Contributor at subscription level)
- Custom roles with wildcard actions
- Service principals with excessive API permissions
- Conditional Access policy gaps
- Managed Identity adoption (vs. stored credentials)
- Azure AD Privileged Identity Management (PIM) configuration
- App registrations with expired or long-lived secrets

### Managed Identity Configuration

```bash
/godmode:infra "Configure managed identity for App Service accessing Key Vault and Azure SQL"

# Generates:
# - System-assigned managed identity on App Service
# - Key Vault access policy or RBAC role assignment
# - Azure SQL contained database user mapped to managed identity
# - No connection strings with passwords
```

### Network Security

```bash
/godmode:secure "Audit network security posture"
```

**What Godmode checks:**
- NSG rules allowing `0.0.0.0/0` inbound
- Azure Firewall or NVA configuration
- Private Endpoint coverage for PaaS services
- DDoS Protection Standard enabled on VNETs
- Azure Bastion for VM access (no public RDP/SSH)
- Network Watcher flow logs enabled

### Azure WAF

```bash
/godmode:infra "Configure WAF policy for Front Door"

# Generates:
# - WAF policy with prevention mode
# - OWASP 3.2 managed rule set
# - Microsoft Bot Manager rule set
# - Rate limiting rules
# - Geo-filtering rules
# - Custom rules for application-specific protection
# - Exclusions for known false positives
```

---

## Common Architectures

### App Service Web App

```bash
/godmode:think "Design three-tier web app on Azure"
/godmode:plan
/godmode:build

# Godmode produces:
# Front Door + WAF → App Service → Azure SQL
# Redis Cache for sessions
# Key Vault for secrets
# Application Insights for monitoring
# Managed Identity for all service-to-service auth
# Bicep modules for all resources
```

### Microservices on AKS

```bash
/godmode:think "Design microservices platform on AKS"
/godmode:plan
/godmode:build

# Godmode produces:
# AKS cluster with Azure CNI and Workload Identity
# AGIC (Application Gateway Ingress Controller)
# Dapr for service-to-service communication
# Azure Service Bus for messaging
# Cosmos DB for polyglot persistence
# Azure DevOps or GitHub Actions CI/CD
# Prometheus + Grafana + Azure Monitor
```

### Event-Driven Serverless

```bash
/godmode:think "Design event-driven processing on Azure"
/godmode:plan
/godmode:build

# Godmode produces:
# Event Grid for event routing
# Azure Functions for processing
# Service Bus queues for reliable messaging
# Cosmos DB for state
# Durable Functions for orchestration
# Application Insights for end-to-end tracing
```

---

## Observability on Azure

```bash
/godmode:observe "Set up full observability for AKS microservices"
```

| Layer | Azure Service | Godmode Configuration |
|-------|------------|----------------------|
| **Metrics** | Azure Monitor Metrics | Custom dashboards, metric alerts, dynamic thresholds |
| **Logs** | Log Analytics | KQL queries, workbooks, log alerts, data export rules |
| **Traces** | Application Insights | Distributed tracing, application map, transaction search |
| **SLOs** | Azure Monitor SLIs | Availability, latency, and error rate objectives |
| **Profiling** | Application Insights Profiler | .NET and Java profiling in production |

---

## CI/CD on Azure

```bash
/godmode:cicd "Set up GitHub Actions pipeline deploying to AKS"
```

### Pipeline Stages

```
┌────────┐   ┌──────┐   ┌──────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
│  Push  │──▶│Build │──▶│ Test │──▶│   ACR    │──▶│  Deploy  │──▶│  Verify  │
│        │   │Docker│   │Unit+ │   │  Push    │   │ Staging  │   │  Smoke   │
│        │   │Image │   │ Intg │   │          │   │          │   │  Tests   │
└────────┘   └──────┘   └──────┘   └──────────┘   └──────────┘   └──────────┘
                                                         │
                                                         ▼
                                                   ┌──────────┐
                                                   │  Deploy  │
                                                   │Production│
                                                   └──────────┘
```

### Federated Identity (No Stored Secrets)

```bash
/godmode:infra "Create GitHub Actions OIDC federation for Azure CI/CD"

# Generates:
# - Azure AD app registration with federated credential
# - Scoped RBAC role assignment (ACR Push + AKS Contributor)
# - GitHub Actions workflow with azure/login action
# - No client secrets stored in GitHub
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Provision infrastructure | `/godmode:infra "Bicep for <service>"` |
| Deploy to Azure | `/godmode:deploy --target azure` |
| Optimize costs | `/godmode:cost "Analyze Azure spend"` |
| Security audit | `/godmode:secure "Azure security review"` |
| Monitor services | `/godmode:observe "Azure Monitor for <service>"` |
| Database optimization | `/godmode:query "Azure SQL Query Performance Insight"` |
| Kubernetes management | `/godmode:k8s "AKS cluster operations"` |
| Incident response | `/godmode:incident "Investigate <issue>"` |
