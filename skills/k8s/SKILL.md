---
name: k8s
description: |
  Kubernetes and container orchestration skill. Activates when user needs to create, manage, or troubleshoot Kubernetes deployments. Generates Helm charts, configures deployment strategies (rolling, canary, blue-green), manages pod health, resource limits, and scaling policies. Triggers on: /godmode:k8s, "deploy to kubernetes", "create helm chart", "scale pods", "k8s troubleshoot", or when shipping containerized applications.
---

# K8s — Kubernetes & Container Orchestration

## When to Activate
- User invokes `/godmode:k8s`
- User says "deploy to kubernetes", "create helm chart", "scale the service"
- User says "k8s troubleshoot", "pod crashing", "OOMKilled", "CrashLoopBackOff"
- Application is containerized and needs deployment manifests
- User asks about deployment strategies, rollouts, or scaling
- Pre-ship check for containerized applications

## Workflow

### Step 1: Discover Kubernetes Context
Identify the cluster, namespace, and existing workloads:

```
KUBERNETES CONTEXT:
Cluster: <cluster name>
Context: <kubectl context>
Namespace: <target namespace>
Existing Workloads:
  Deployments: <list>
  StatefulSets: <list>
  Services: <list>
  Ingresses: <list>
Helm Releases: <list of deployed charts>
Container Registry: <registry URL>
```
```bash
# Gather cluster info
kubectl cluster-info
kubectl get deployments,services,ingresses -n <namespace>
helm list -n <namespace>
```
If no Kubernetes context is found: "No Kubernetes cluster configured. Shall I generate manifests for local development (minikube/kind) or production deployment?"

### Step 2: Generate or Validate Manifests
Create or review Kubernetes resource definitions:

#### Deployment Manifest
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <service-name>
  namespace: <namespace>
  labels:
```

#### Manifest Validation
```bash
# Dry-run validation
kubectl apply --dry-run=server -f manifests/

# Lint with kubeval
kubeval manifests/*.yaml --strict

```

```
MANIFEST VALIDATION:
Syntax:       PASS (all manifests valid)
kubeval:      PASS (schema-compliant)
kubesec:      Score 8/10 (2 advisories)
kube-linter:  3 warnings, 0 errors
```
### Step 3: Helm Chart Generation
When a reusable, parameterized deployment is needed:

```
HELM CHART STRUCTURE:
<chart-name>/
  Chart.yaml            — Chart metadata and dependencies
  values.yaml           — Default configuration values
  values-dev.yaml       — Development overrides
  values-staging.yaml   — Staging overrides
  values-prod.yaml      — Production overrides
  templates/
    _helpers.tpl         — Template helper functions
    deployment.yaml      — Deployment manifest
    service.yaml         — Service manifest
    ingress.yaml         — Ingress manifest
    hpa.yaml             — HorizontalPodAutoscaler
    pdb.yaml             — PodDisruptionBudget
    serviceaccount.yaml  — ServiceAccount with RBAC
    configmap.yaml       — ConfigMap
    secret.yaml          — Secret (external-secrets or sealed-secrets)
    NOTES.txt            — Post-install instructions
  tests/
    test-connection.yaml — Helm test for connectivity
```
```bash
# Validate chart
helm lint <chart-dir>

# Template rendering (dry-run)
helm template <release-name> <chart-dir> -f values-prod.yaml

```
### Step 4: Deployment Strategy Selection
Choose and configure the correct deployment strategy:

#### Rolling Update (Default — Zero-Downtime)
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%        # Max pods above desired count during update
    maxUnavailable: 0     # Never reduce below desired count
```
```
USE WHEN:
- Standard deployments with backward-compatible changes
- Services behind a load balancer
- No need for traffic splitting

SAFETY:
- readinessProbe gates traffic to new pods
- maxUnavailable: 0 ensures no downtime
- Automatic rollback on failed health checks
```

#### Canary Deployment (Progressive — Risk Reduction)
```yaml
# Using Flagger or Argo Rollouts
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: <service-name>-rollout
spec:
```
```
USE WHEN:
- High-risk changes (new features, major refactors)
- Need to validate with real traffic before full rollout
- Metrics-driven promotion decisions

SAFETY:
- Automatic rollback if error rate exceeds threshold
- Progressive traffic shifting (5% -> 20% -> 50% -> 80% -> 100%)
- Analysis templates validate success rate at each step
```

#### Blue-Green Deployment (Instant Switch — Full Rollback)
```yaml
# Two deployments: blue (current) and green (new)
# Service selector switches between them
apiVersion: v1
kind: Service
metadata:
  name: <service-name>-svc
```
```
USE WHEN:
- Need instant rollback capability
- Database migrations that are backward-compatible
- Compliance requires full environment validation before switch

SAFETY:
- Full new environment validated before traffic switch
- Instant rollback by switching service selector
- Old environment kept running until confidence is high
```

### Step 5: Pod Health & Resource Management
Configure health checks, resource limits, and disruption budgets:

#### Resource Sizing Guidelines
```
RESOURCE SIZING:
  Service: <service-name>
| Metric | Current | P95 | Recommended |
|--|--|--|--|
| CPU usage | 120m | 280m | req: 200m lim: 500m |
| Memory usage | 256Mi | 384Mi | req: 300Mi lim: 512Mi |
| Pod count | 3 | 3 | min: 2 max: 10 |
| Startup time | 8s | 12s | startupProbe: 30s |
| Request rate | 150 rps | 420 rps | HPA target: 300 rps |

Rules:
- Requests = P95 usage + 20% buffer
- Limits = 2x requests (allow bursting)
- Never set CPU limit equal to request (causes throttling)
- Memory limit must accommodate peak + GC overhead
```

#### HorizontalPodAutoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: <service-name>-hpa
spec:
  scaleTargetRef:
```

#### PodDisruptionBudget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: <service-name>-pdb
spec:
  minAvailable: 1    # Or use maxUnavailable: 1
```

### Step 6: Troubleshooting
Diagnose common Kubernetes issues:

```
TROUBLESHOOTING CHECKLIST:
| Symptom | Check |
|--|--|
| CrashLoopBackOff | kubectl logs <pod> |
|  | Check startup/liveness probe |
|  | Check resource limits |
| OOMKilled | Increase memory limit |
|  | Check for memory leaks |
| ImagePullBackOff | Check image name/tag |
|  | Check registry credentials |
| Pending | Check resource availability |
|  | Check node affinity/taints |
| Evicted | Check disk pressure |
|  | Check resource quotas |
| Connection refused | Check service selector |
|  | Check port configuration |
| Ingress 502/503 | Check readiness probe |
|  | Check backend service |
```
```bash
# Quick diagnostics
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous
kubectl top pods -n <namespace>
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```
### Step 7: Deploy and Verify
Execute the deployment with verification:

```bash
# Helm deployment
helm upgrade --install <release> <chart> \
  -f values-<env>.yaml \
  -n <namespace> \
  --wait \
  --timeout 5m
```
```
DEPLOYMENT RESULT:
  <service> in <namespace>: 3/3 Ready, Rolling Update, Complete.
  Health: liveness OK, readiness OK, endpoint 200, no errors in 60s.
```
### Step 8: Commit and Report
```
Save manifests in `k8s/` or `charts/`. Commit: `"k8s: <description> — <strategy> (<N> replicas)"`
```

## Key Behaviors
1. **Resource requests+limits mandatory.** Unbounded pods cause noisy-neighbor issues.
2. **Health probes mandatory.** Liveness, readiness, startup probes on all pods.
3. **PDB required.** Without PDB, node drains take down all pods.
4. **Never `latest` tag.** Pin with SHA digest or semver.
5. **Namespace isolation.** Per service/team with quotas and network policies.
6. **Secrets not ConfigMaps.** Use K8s Secrets or external-secrets-operator.
7. **Dry-run before apply.** `kubectl apply --dry-run=server` catches issues early.
8. **Canary for high-risk.** Do not push straight to 100% traffic.

## HARD RULES
1. NEVER deploy without resource requests AND limits — unbounded pods starve workloads.
2. NEVER skip health probes — K8s sends traffic to broken pods without them.
3. NEVER use `latest` tag — pin with SHA or semver.
4. NEVER put secrets in ConfigMaps — use K8s Secrets or external-secrets-operator.
5. NEVER set CPU limits == requests — causes throttling with spare capacity.
6. NEVER run as root — `runAsNonRoot: true`, `readOnlyRootFilesystem: true`.
7. ALWAYS validate in dev/staging before production.
8. ALWAYS create PDB for production workloads.
9. ALWAYS validate manifests: `--dry-run=server`, kubeval, kube-linter.
10. ALWAYS use namespaces with resource quotas.

## Auto-Detection
```
1. kubectl context: current-context, cluster-info
2. Manifests: k8s/, manifests/, deploy/ directories, apiVersion: apps/v1
3. Helm: charts/, Chart.yaml, values*.yaml
4. App: Dockerfile, docker-compose.yml, EXPOSE ports
5. CI: .github/workflows/ with kubectl/helm steps
```

## Keep/Discard Discipline
```
KEEP if: validation passes AND pods Ready AND no error logs in last 60s
DISCARD if: validation fails OR pods crash OR readiness probe fails
Rollback: helm rollback / kubectl rollout undo. Never promote if current stage is unhealthy.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ANY of these are true:
  - All pods are Ready and passing all probes
  - Deployment strategy (rolling/canary/blue-green) is configured and tested
  - User explicitly requests stop
  - A rollback was triggered (investigate before retrying)

DO NOT STOP because:
  - HPA is not yet configured (get pods healthy first, then add autoscaling)
  - Network policies are not yet applied (apply after core deployment is stable)
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Validate manifests and show deployment plan |
| `--generate` | Generate new Kubernetes manifests or Helm chart |
| `--deploy` | Deploy to the target cluster |

## Output Format
Print on completion: `K8s: {resource_count} resources across {namespace_count} namespaces. Health: {health_status}. Security: {security_score}. Scaling: {min_replicas}-{max_replicas}. Verdict: {verdict}.`

## TSV Logging
Log every Kubernetes operation to `.godmode/k8s-results.tsv`:
```
iteration	task	namespace	resources_created	resources_modified	health_check	security_issues	status
```

## Success Criteria
- Resource requests+limits on all pods. Liveness+readiness probes on all deployments.
- Non-root containers, read-only rootfs. No plain-text secrets. Pinned image tags (no `latest`).
- HPA configured with correct min/max. NetworkPolicies restrict ingress/egress.
- All manifests pass `kubectl --dry-run=server` validation.

## Error Recovery
- **CrashLoopBackOff**: Check `kubectl logs <pod> --previous`. Increase `initialDelaySeconds`. Check OOMKilled.
- **Pending**: `kubectl describe pod` for scheduling failures. Check CPU/memory, affinity, PVC.
- **ImagePullBackOff**: Verify image, `imagePullSecrets`, registry credentials.
- **503**: Check endpoints, readiness probe, pod label/selector match.
- **HPA not scaling**: Verify metrics-server, resource requests set.
- **ConfigMap/Secret stale**: `kubectl rollout restart deployment/<name>`.
