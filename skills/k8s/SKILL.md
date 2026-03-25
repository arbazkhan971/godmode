---
name: k8s
description: |
  Kubernetes and container orchestration skill. Helm
  charts, deployment strategies (rolling, canary,
  blue-green), pod health, resource limits, scaling.
  Triggers on: /godmode:k8s, "deploy to kubernetes",
  "helm chart", "pod crashing", "OOMKilled".
---

# K8s — Kubernetes & Container Orchestration

## When to Activate
- User invokes `/godmode:k8s`
- User says "deploy to kubernetes", "create helm chart"
- User says "pod crashing", "OOMKilled", "CrashLoopBackOff"
- Application is containerized and needs manifests

## Workflow

### Step 1: Discover Kubernetes Context

```bash
# Gather cluster info
kubectl cluster-info
kubectl get deployments,services,ingresses \
  -n <namespace>
helm list -n <namespace>

# Check resource usage
kubectl top pods -n <namespace>
kubectl top nodes
```

```
KUBERNETES CONTEXT:
Cluster: <name>, Context: <kubectl context>
Namespace: <target>, Registry: <URL>
Workloads: <N> Deployments, <N> StatefulSets
Services: <N>, Ingresses: <N>
Helm releases: <list>

IF no cluster: generate manifests for local (minikube)
IF no namespace: create with resource quotas
IF no Helm: use raw manifests for simple apps
```

### Step 2: Generate or Validate Manifests

```bash
# Dry-run validation
kubectl apply --dry-run=server -f manifests/

# Lint with kubeval
kubeval manifests/*.yaml --strict

# Security scan
kubesec scan manifests/deployment.yaml
```

### Step 3: Helm Chart (if needed)

```
CHART STRUCTURE:
<chart>/
  Chart.yaml, values.yaml, values-{env}.yaml
  templates/
    deployment.yaml, service.yaml, ingress.yaml,
    hpa.yaml, pdb.yaml, configmap.yaml, secret.yaml
```

```bash
helm lint <chart-dir>
helm template <release> <chart> -f values-prod.yaml
```

### Step 4: Deployment Strategy

```
| Strategy    | When to Use            | Rollback  |
|-------------|------------------------|-----------|
| Rolling     | Standard, backward-compat| Automatic|
| Canary      | High-risk changes      | Auto at % |
| Blue-Green  | Need instant rollback  | Instant   |

ROLLING UPDATE CONFIG:
  maxSurge: 25%
  maxUnavailable: 0 (zero downtime)

CANARY RAMP:
  5% → 20% → 50% → 80% → 100%
  Gate: error rate < baseline + 0.5%
  Gate: p95 latency < baseline + 10%

THRESHOLDS:
  IF error rate > 5% at any stage: auto-rollback
  IF p95 latency > 2x baseline: auto-rollback
  IF high-risk change: always use canary
```

### Step 5: Pod Health & Resources

```
RESOURCE SIZING:
| Metric     | Recommended              |
|-----------|--------------------------|
| CPU req    | P95 usage + 20% buffer   |
| CPU limit  | 2x request (allow burst) |
| Mem req    | P95 usage + 20% buffer   |
| Mem limit  | Peak + GC overhead       |
| Pod count  | min 2 for HA             |

RULES:
  Never set CPU limit == request (causes throttling)
  Memory limit must accommodate GC overhead
  Requests = P95 + 20%, Limits = 2x requests

PROBE CONFIG:
  Liveness: detect deadlocked processes
    path: /healthz, period: 10s, threshold: 3
  Readiness: gate traffic to healthy pods
    path: /ready, period: 5s, threshold: 1
  Startup: slow-starting containers
    period: 5s, failureThreshold: 30 (= 150s max)

HPA:
  Min replicas: 2 (HA), Max: based on budget
  CPU target: 70%, scale up if exceeded
  Scale-down stabilization: 300s (prevent flapping)
```

### Step 6: Troubleshooting

```bash
# Quick diagnostics
kubectl describe pod <pod> -n <ns>
kubectl logs <pod> -n <ns> --previous
kubectl top pods -n <ns>
kubectl get events -n <ns> --sort-by='.lastTimestamp'
```

```
| Symptom           | First Check              |
|-------------------|--------------------------|
| CrashLoopBackOff  | logs --previous, probes  |
| OOMKilled         | increase memory limit    |
| ImagePullBackOff  | image name, credentials  |
| Pending           | resources, affinity      |
| Evicted           | disk pressure, quotas    |
| 502/503           | readiness probe, backend |
```

### Step 7: Deploy & Verify

```bash
helm upgrade --install <release> <chart> \
  -f values-<env>.yaml -n <ns> \
  --wait --timeout 5m

# Verify
kubectl rollout status deployment/<name> -n <ns>
kubectl get pods -n <ns>
```

```
DEPLOYMENT RESULT:
  <service> in <namespace>: 3/3 Ready
  Health: liveness OK, readiness OK
  No error logs in last 60 seconds
```

Commit: `"k8s: <service> — <strategy> (<N> replicas)"`

## Key Behaviors

1. **Resource requests+limits mandatory.**
2. **Health probes mandatory.**
3. **PDB required for production.**
4. **Never `latest` tag.** Pin SHA or semver.
5. **Namespace isolation** with quotas.
6. **Secrets not ConfigMaps** for sensitive data.
7. **Dry-run before apply.**
8. **Canary for high-risk changes.**

## HARD RULES

1. Never deploy without resource requests AND limits.
2. Never skip health probes.
3. Never use `latest` tag — pin SHA or semver.
4. Never put secrets in ConfigMaps.
5. Never set CPU limits == requests.
6. Never run as root — runAsNonRoot: true.
7. Always validate in dev/staging first.
8. Always create PDB for production.
9. Always validate: --dry-run=server, kubeval.
10. Always use namespaces with resource quotas.

## Auto-Detection
```
1. kubectl context, cluster-info
2. Manifests: k8s/, manifests/, deploy/
3. Helm: charts/, Chart.yaml, values*.yaml
4. App: Dockerfile, docker-compose.yml
```

## Output Format
Print: `K8s: {resources} resources. Health: {status}.
  Scaling: {min}-{max}. Verdict: {verdict}.`

## TSV Logging
```
iteration	namespace	resources	health	security	status
```

## Keep/Discard Discipline
```
KEEP if: validation passes AND pods Ready
  AND no error logs in 60s
DISCARD if: validation fails OR pods crash
  OR readiness probe fails
Rollback: helm rollback or kubectl rollout undo
```

## Stop Conditions
```
STOP when ANY of:
  - All pods Ready, passing probes
  - Deployment strategy configured and tested
  - User requests stop
  - Rollback triggered (investigate first)
```

## Error Recovery
- CrashLoopBackOff: check logs --previous, probes.
- Pending: kubectl describe for scheduling failures.
- ImagePullBackOff: verify image, imagePullSecrets.
- 503: check endpoints, readiness, selector match.
- HPA not scaling: verify metrics-server installed.
