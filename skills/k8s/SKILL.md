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
# ... (condensed)
```

#### Manifest Validation
```bash
# Dry-run validation
kubectl apply --dry-run=server -f manifests/

# Lint with kubeval
kubeval manifests/*.yaml --strict

# ... (condensed)
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

# ... (condensed)
```

### Step 4: Deployment Strategy Selection
Choose and configure the appropriate deployment strategy:

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
  name: <service-name>
spec:
# ... (condensed)
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
  name: <service-name>
# ... (condensed)
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
|---|---|---|---|
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
  name: <service-name>
spec:
  scaleTargetRef:
# ... (condensed)
```

#### PodDisruptionBudget
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: <service-name>
spec:
  minAvailable: 1    # Or use maxUnavailable: 1
# ... (condensed)
```

### Step 6: Troubleshooting
Diagnose common Kubernetes issues:

```
TROUBLESHOOTING CHECKLIST:
| Symptom | Check |
|---|---|
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
# ... (condensed)
```

```
DEPLOYMENT RESULT:
  Deployment: <service-name>
  Namespace: <namespace>
  Strategy: Rolling Update
  Pods: 3/3 Ready
  Replicas: 3 desired, 3 available, 0 unavailable
  Image: <registry>/<image>:<new-tag>
  Rollout: Complete (took 45s)
  Health Checks:
  [x] All pods passing liveness probe
  [x] All pods passing readiness probe
  [x] Service endpoint returning 200
  [x] No error logs in last 60 seconds
```

### Step 8: Commit and Report
```
1. Save Kubernetes manifests in `k8s/` or `charts/` directory
2. Commit: "k8s: <description> — <strategy> deployment (<N> replicas)"
3. If validation failed: "Manifest validation failed. Fix issues before deploying."
4. If deployment succeeded: "Deployment complete. All pods healthy."
5. If rollback needed: "Deployment failed. Run `kubectl rollout undo` or `helm rollback`."
```

## Key Behaviors

1. **Always set resource requests AND limits.** Pods without resource definitions cause noisy-neighbor problems and make scheduling unpredictable.
2. **Always configure health probes.** Liveness, readiness, and startup probes are mandatory. Without them, Kubernetes cannot manage pod lifecycle correctly.
3. **PodDisruptionBudget is required.** Without a PDB, node drains will take down all your pods simultaneously.
4. **Never use `latest` tag.** Pin image versions with SHA digests or semantic version tags. `latest` is not reproducible.
5. **Namespace isolation.** Each service or team gets its own namespace with resource quotas and network policies.
6. **Secrets are not ConfigMaps.** Use Kubernetes Secrets (or external-secrets-operator) for sensitive data. Never put credentials in ConfigMaps.
7. **Test manifests before deploying.** `kubectl apply --dry-run=server` catches issues before they hit the cluster.
8. **Canary before yolo.** For high-risk changes, use canary deployments with automated analysis. Do not push straight to 100% traffic.

## HARD RULES
1. NEVER deploy without resource requests AND limits on every container — unbounded pods starve other workloads.
2. NEVER skip health probes (liveness, readiness, startup) — without them, K8s sends traffic to broken pods.
3. NEVER use the `latest` image tag — pin versions with SHA digests or semantic version tags. `latest` is not reproducible.
4. NEVER put secrets in plain ConfigMaps or environment variables in manifests — use Kubernetes Secrets or external-secrets-operator.
5. NEVER set CPU limits equal to CPU requests — this causes throttling even when the node has spare capacity.
6. NEVER run containers as root — use `securityContext.runAsNonRoot: true` and `readOnlyRootFilesystem: true`.
7. NEVER deploy straight to production without validating in dev/staging first.
8. ALWAYS create a PodDisruptionBudget for production workloads — without PDB, node drains take down all pods.
9. ALWAYS validate manifests before applying: `kubectl apply --dry-run=server`, kubeval, kube-linter.
10. ALWAYS use namespaces for isolation — each service/team gets its own namespace with resource quotas.

## Auto-Detection
On activation, detect Kubernetes context automatically:
```
AUTO-DETECT:
1. Check kubectl context:
   - kubectl config current-context
   - kubectl cluster-info
2. Scan for existing manifests:
   - k8s/, manifests/, deploy/, kubernetes/ directories
   - *.yaml files with apiVersion: apps/v1 or similar
3. Scan for Helm:
   - charts/ directory, Chart.yaml, values*.yaml
   - helm list (if cluster accessible)
4. Detect application:
   - Dockerfile, docker-compose.yml → containerized app
   - Parse Dockerfile for EXPOSE ports, CMD/ENTRYPOINT
5. Detect deployment tooling:
   - .github/workflows/ with kubectl/helm steps → GitHub Actions
```

## Iterative Deployment Protocol
Kubernetes deployments are validated iteratively:
```
current_step = 0
steps = ["validate", "lint", "security", "dry-run", "deploy-dev", "deploy-staging", "deploy-prod"]

WHILE current_step < len(steps):
  step = steps[current_step]
  1. EXECUTE step:
     - validate: kubectl apply --dry-run=client
     - lint: helm lint / kubeval / kube-linter
     - security: kubesec scan, check securityContext
     - dry-run: kubectl apply --dry-run=server
     - deploy-*: helm upgrade --install --wait
  2. VERIFY step passed:
     - IF errors → REPORT and HALT (do not proceed)
     - IF warnings → REPORT, continue if non-critical
  3. POST-DEPLOY verification (for deploy-* steps):
```

## Keep/Discard Discipline
```
After EACH manifest change or deployment:
  1. MEASURE: Run kubectl apply --dry-run=server, kubeval, kubesec — do they pass?
  2. COMPARE: Are pods healthier, more secure, or better-sized than before?
  3. DECIDE:
     - KEEP if: validation passes AND pods are Ready AND no error logs in last 60s
     - DISCARD if: validation fails OR pods crash OR readiness probe fails
  4. COMMIT kept changes. Rollback discarded changes (helm rollback / kubectl rollout undo).

Never promote a deployment stage if the current stage is unhealthy.
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to get pods healthy:
  1. Check previous pod logs: `kubectl logs <pod> --previous` — crash reason is often in the last log line.
  2. Check events: `kubectl get events --sort-by=.lastTimestamp` — scheduling and image pull issues surface here.
  3. Simplify: remove resource limits temporarily to rule out OOMKill, then add them back with higher values.
  4. If still stuck → log stop_reason=stuck, capture pod describe output, escalate to user.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All pods are Ready and passing all probes
  - Deployment strategy (rolling/canary/blue-green) is configured and tested
  - User explicitly requests stop
  - A rollback was triggered (investigate before retrying)

DO NOT STOP just because:
  - HPA is not yet configured (get pods healthy first, then add autoscaling)
  - Network policies are not yet applied (apply after core deployment is stable)
```

## Simplicity Criterion
```
PREFER the simpler Kubernetes configuration:
  - Deployment before StatefulSet (unless you genuinely need stable pod identity)
  - ClusterIP service before LoadBalancer (use Ingress for external access)
  - Helm values overrides before custom Helm templates
  - Namespace-level RBAC before pod-level service accounts (until fine-grained access is needed)
  - Fewer replicas with right-sized resources before many tiny replicas
  - Rolling update before canary (unless the change is high-risk)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Validate manifests and show deployment plan |
| `--generate` | Generate new Kubernetes manifests or Helm chart |
| `--deploy` | Deploy to the target cluster |

## Output Format
Print on completion: `K8s: {resource_count} resources across {namespace_count} namespaces. Health: {health_status}. Security: {security_score}. Scaling: {min_replicas}-{max_replicas}. Verdict: {verdict}.`

## TSV Logging
Log every Kubernetes operation to `.godmode/k8s-results.tsv`:
```
iteration	task	namespace	resources_created	resources_modified	health_check	security_issues	status
1	manifests	app-prod	12	0	all_ready	2	created
2	security	app-prod	0	5	all_ready	0	hardened
3	scaling	app-prod	0	3	all_ready	0	configured
4	observability	monitoring	4	0	all_ready	0	deployed
```
Columns: iteration, task, namespace, resources_created, resources_modified, health_check, security_issues, status(created/modified/hardened/configured/deployed).

## Success Criteria
- All pods have resource requests AND limits configured.
- All deployments have liveness and readiness probes.
- All containers run as non-root with read-only root filesystem.
- No secrets in plain-text manifests (using Secrets or external-secrets).
- Image tags are pinned to specific versions (no `latest`).
- HPA configured for production deployments with appropriate min/max replicas.
- NetworkPolicies restrict ingress/egress to required paths only.
- All manifests pass `kubectl --dry-run=server` validation.

## Error Recovery
- **Pod stuck in CrashLoopBackOff**: Check logs with `kubectl logs <pod> --previous`. Verify liveness probe is not too aggressive (increase `initialDelaySeconds`). Check resource limits (OOMKilled = memory limit too low).
- **Pod stuck in Pending**: Check `kubectl describe pod` for scheduling failures. Common causes: insufficient CPU/memory on nodes, node affinity/taint mismatch, PVC not bound.
- **ImagePullBackOff**: Verify image exists in registry. Check `imagePullSecrets` on the service account. Verify registry credentials are valid and not expired.
- **Service returns 503**: Check if endpoints exist (`kubectl get endpoints <service>`). Verify readiness probe is passing. Check if the pod labels match the service selector.
- **HPA not scaling**: Verify metrics-server is running. Check `kubectl describe hpa` for conditions. Verify resource requests are set (HPA needs requests to calculate utilization).
- **ConfigMap/Secret changes not picked up**: Restart pods to pick up ConfigMap/Secret changes unless using volume mounts with `subPath`. Use a rolling restart: `kubectl rollout restart deployment/<name>`.

