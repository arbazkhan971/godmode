# Kubernetes Patterns Reference

> Deployment strategies, sidecar/ambassador/adapter patterns, resource management, and Helm chart best practices for Kubernetes.

---

## Deployment Patterns

### 1. Rolling Update (Default)

Gradually replaces old pods with new pods, ensuring zero downtime.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1          # Max pods above desired count during update
      maxUnavailable: 0    # Zero downtime — always keep all replicas running
  template:
    spec:
      containers:
      - name: my-app
        image: my-app:v2
        readinessProbe:      # CRITICAL — gates traffic to new pods
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
```

```
ROLLING UPDATE SEQUENCE (maxSurge=1, maxUnavailable=0, replicas=4):

Step 1: [v1] [v1] [v1] [v1]          ← Starting state
Step 2: [v1] [v1] [v1] [v1] [v2]     ← New pod created (surge)
Step 3: [v1] [v1] [v1] [v2]          ← v2 ready, old pod terminated
Step 4: [v1] [v1] [v1] [v2] [v2]     ← Another new pod
Step 5: [v1] [v1] [v2] [v2]          ← Old pod terminated
...
Final:  [v2] [v2] [v2] [v2]          ← All updated
```

**When to use:** Default deployment strategy. Stateless applications. When zero downtime is required and gradual rollout is acceptable.

**Trade-offs:**
- Zero downtime
- Automatic rollback on failed readiness probes
- Both versions run simultaneously during update (must be backward compatible)
- Slow for large replica counts

---

### 2. Blue-Green Deployment

Run two identical environments; switch traffic atomically.

```yaml
# Blue environment (current production)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-blue
  labels:
    app: my-app
    version: blue
spec:
  replicas: 4
  template:
    metadata:
      labels:
        app: my-app
        version: blue
    spec:
      containers:
      - name: my-app
        image: my-app:v1

---
# Green environment (new version)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-green
  labels:
    app: my-app
    version: green
spec:
  replicas: 4
  template:
    metadata:
      labels:
        app: my-app
        version: green
    spec:
      containers:
      - name: my-app
        image: my-app:v2

---
# Service — switch selector to cut over
apiVersion: v1
kind: Service
metadata:
  name: my-app
spec:
  selector:
    app: my-app
    version: blue     # ← Change to "green" to switch traffic
  ports:
  - port: 80
    targetPort: 8080
```

```
BLUE-GREEN SEQUENCE:

Phase 1: Blue is live
  Service → [Blue v1] [Blue v1] [Blue v1] [Blue v1]
            [Green v2] [Green v2] [Green v2] [Green v2]  ← Ready, not serving

Phase 2: Switch (change Service selector)
  Service → [Green v2] [Green v2] [Green v2] [Green v2]  ← Now serving
            [Blue v1] [Blue v1] [Blue v1] [Blue v1]      ← Standby for rollback

Phase 3: Rollback if needed
  Service → [Blue v1] [Blue v1] [Blue v1] [Blue v1]      ← Instant rollback
```

**When to use:** When you need instant rollback capability. Database migrations that are backward compatible. When you can afford 2x the resources temporarily.

**Trade-offs:**
- Instant traffic switch and rollback
- Full testing of green environment before cutover
- Requires 2x resources during deployment
- Database schema changes must be compatible with both versions

---

### 3. Canary Deployment

Route a small percentage of traffic to the new version, gradually increasing.

```yaml
# Using Istio VirtualService for traffic splitting
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-app
spec:
  hosts:
  - my-app
  http:
  - route:
    - destination:
        host: my-app
        subset: stable
      weight: 90       # 90% to current version
    - destination:
        host: my-app
        subset: canary
      weight: 10       # 10% to new version

---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: my-app
spec:
  host: my-app
  subsets:
  - name: stable
    labels:
      version: v1
  - name: canary
    labels:
      version: v2
```

```
CANARY PROGRESSION:

Step 1:  [v1 90%] ─────────── [v2 10%]    Observe error rates, latency
Step 2:  [v1 75%] ─────────── [v2 25%]    Metrics look good
Step 3:  [v1 50%] ─────────── [v2 50%]    Continue monitoring
Step 4:  [v1 25%] ─────────── [v2 75%]    Nearly complete
Step 5:  [v1  0%] ─────────── [v2 100%]   Full rollout

AUTOMATED CANARY (with Flagger or Argo Rollouts):
  - Automatically advance if error rate < 1% and p99 latency < 500ms
  - Automatically rollback if metrics degrade
```

**When to use:** High-risk deployments. When you need real production traffic validation. Systems with strong observability.

**Trade-offs:**
- Real-world validation with limited blast radius
- Automated promotion/rollback based on metrics
- Requires service mesh or ingress controller with traffic splitting
- More complex setup than rolling updates
- Canary users may experience issues

---

### 4. A/B Testing Deployment

Route traffic based on request attributes (headers, cookies, user segments).

```yaml
# Istio VirtualService with header-based routing
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-app
spec:
  hosts:
  - my-app
  http:
  - match:
    - headers:
        x-user-group:
          exact: "beta"
    route:
    - destination:
        host: my-app
        subset: v2
  - route:
    - destination:
        host: my-app
        subset: v1
```

**When to use:** Feature testing with specific user segments. Comparing performance or behavior of two implementations. Gradual feature rollout to internal users first.

---

### 5. Recreate (All-at-Once)

Terminate all old pods, then create new pods. Brief downtime.

```yaml
spec:
  strategy:
    type: Recreate
```

```
RECREATE SEQUENCE:

Step 1: [v1] [v1] [v1] [v1]    ← Running
Step 2: [ ] [ ] [ ] [ ]         ← All terminated (DOWNTIME)
Step 3: [v2] [v2] [v2] [v2]    ← All new pods starting
Step 4: [v2] [v2] [v2] [v2]    ← Ready
```

**When to use:** Development environments. Applications that cannot run two versions simultaneously (shared file locks, single-instance databases). When brief downtime is acceptable.

---

### Deployment Pattern Comparison

```
┌─────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────┐
│  Criterion          │ Rolling   │ Blue-Green│ Canary    │ A/B Test  │ Recreate  │
├─────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┤
│  Zero downtime      │ Yes       │ Yes       │ Yes       │ Yes       │ No        │
│  Instant rollback   │ Slow      │ Yes       │ Yes       │ Yes       │ No        │
│  Resource overhead  │ Low       │ 2x        │ Low       │ Low       │ None      │
│  Traffic control    │ None      │ All/none  │ Percentage│ Attribute │ None      │
│  Complexity         │ Low       │ Medium    │ High      │ High      │ Low       │
│  Infra required     │ K8s only  │ K8s only  │ Mesh/Ingr.│ Mesh/Ingr.│ K8s only  │
│  Version coexist    │ Brief     │ Yes       │ Yes       │ Yes       │ No        │
│  Metric validation  │ Manual    │ Manual    │ Automated │ Automated │ None      │
└─────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────┘
```

---

## Sidecar, Ambassador, and Adapter Patterns

### Sidecar Pattern

A helper container running alongside the main application container in the same pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  # Main application
  - name: app
    image: my-app:v1
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app

  # Sidecar: log collector
  - name: log-collector
    image: fluentd:v1.16
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/app
      readOnly: true
    env:
    - name: FLUENTD_CONF
      value: "fluent.conf"

  volumes:
  - name: shared-logs
    emptyDir: {}
```

**Common sidecar use cases:**

```
┌────────────────────────┬────────────────────────────────────────────────┐
│  Use Case              │  Sidecar                                       │
├────────────────────────┼────────────────────────────────────────────────┤
│  Log collection        │  Fluentd, Fluent Bit, Filebeat                 │
│  Service mesh proxy    │  Envoy (Istio), Linkerd-proxy                  │
│  TLS termination       │  Envoy, Nginx                                  │
│  Secret management     │  Vault agent (auto-renews secrets)             │
│  Config reloading      │  Custom sidecar watches ConfigMap changes      │
│  Monitoring            │  Prometheus exporter (when app cannot expose)  │
│  Database proxy        │  Cloud SQL Proxy, PgBouncer                    │
│  Auth proxy            │  OAuth2-proxy, Keycloak gatekeeper             │
└────────────────────────┴────────────────────────────────────────────────┘
```

### Ambassador Pattern

A proxy sidecar that handles outbound connections to external services.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: app
    image: my-app:v1
    env:
    - name: EXTERNAL_API_URL
      value: "http://localhost:9090"     # App talks to ambassador

  - name: ambassador
    image: ambassador-proxy:v1
    ports:
    - containerPort: 9090
    env:
    - name: UPSTREAM_URL
      value: "https://external-api.example.com"
    - name: RETRY_COUNT
      value: "3"
    - name: CIRCUIT_BREAKER_THRESHOLD
      value: "5"
    - name: TIMEOUT_MS
      value: "5000"
```

**Ambassador responsibilities:**
- Connection pooling and reuse
- Retries with exponential backoff
- Circuit breaking
- Authentication token management (OAuth client credentials)
- Rate limiting outbound requests
- TLS/mTLS negotiation
- Protocol translation (HTTP to gRPC, etc.)

### Adapter Pattern

A sidecar that transforms the application's output to a standard format expected by external consumers.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: legacy-app
spec:
  containers:
  - name: legacy-app
    image: legacy-app:v1
    ports:
    - containerPort: 8080
    volumeMounts:
    - name: metrics-socket
      mountPath: /tmp/metrics

  # Adapter: converts proprietary metrics format to Prometheus format
  - name: prometheus-adapter
    image: metrics-adapter:v1
    ports:
    - containerPort: 9090
      name: metrics
    volumeMounts:
    - name: metrics-socket
      mountPath: /tmp/metrics
      readOnly: true

  volumes:
  - name: metrics-socket
    emptyDir: {}
```

**Adapter use cases:**
- Convert legacy log format to structured JSON
- Translate proprietary metrics to Prometheus exposition format
- Transform legacy API responses to modern schema
- Normalize health check endpoints to standard `/healthz` format

---

## Resource Management Patterns

### Resource Requests and Limits

```yaml
containers:
- name: app
  resources:
    requests:              # Guaranteed resources (scheduling)
      cpu: "250m"          # 0.25 CPU cores
      memory: "256Mi"      # 256 MiB RAM
    limits:                # Maximum resources (throttling/OOM)
      cpu: "1000m"         # 1 CPU core (throttled beyond this)
      memory: "512Mi"      # 512 MiB (OOM killed beyond this)
```

**Guidelines:**

```
RESOURCE SIZING:
┌─────────────────────────────────────────────────────────────────────────┐
│  Rule of Thumb                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│  Requests = observed average usage + 20% headroom                       │
│  CPU Limits = 2-4x requests (or no limit for CPU, let it burst)         │
│  Memory Limits = observed peak + 25% headroom (memory is incompressible)│
│                                                                          │
│  IMPORTANT:                                                              │
│  - CPU is compressible: exceeding limit = throttled, not killed          │
│  - Memory is NOT compressible: exceeding limit = OOM killed              │
│  - Setting requests too low → pods get evicted under pressure            │
│  - Setting requests too high → wasted cluster resources                  │
│  - No limits → noisy neighbor problems                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

### Quality of Service (QoS) Classes

```
┌────────────────┬──────────────────────────────────────────────────────────┐
│  QoS Class     │  Configuration                                           │
├────────────────┼──────────────────────────────────────────────────────────┤
│  Guaranteed    │  requests == limits for all containers in pod             │
│                │  First to be scheduled, last to be evicted                │
│                │  Use for: databases, stateful services, critical apps     │
├────────────────┼──────────────────────────────────────────────────────────┤
│  Burstable     │  requests < limits (or only requests set)                 │
│                │  Gets guaranteed minimum, can burst beyond                │
│                │  Use for: web servers, API services, workers              │
├────────────────┼──────────────────────────────────────────────────────────┤
│  BestEffort    │  No requests or limits set                                │
│                │  First to be evicted under pressure                       │
│                │  Use for: dev workloads, batch jobs, non-critical tasks   │
└────────────────┴──────────────────────────────────────────────────────────┘
```

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 3
  maxReplicas: 20
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60    # Wait 60s before scaling up again
      policies:
      - type: Pods
        value: 4                        # Add max 4 pods at a time
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300   # Wait 5 min before scaling down
      policies:
      - type: Percent
        value: 25                       # Remove max 25% of pods at a time
        periodSeconds: 60
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  - type: Pods
    pods:
      metric:
        name: requests_per_second
      target:
        type: AverageValue
        averageValue: "100"
```

### Vertical Pod Autoscaler (VPA)

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: my-app
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  updatePolicy:
    updateMode: "Auto"           # Auto, Recreate, Initial, Off
  resourcePolicy:
    containerPolicies:
    - containerName: app
      minAllowed:
        cpu: "100m"
        memory: "128Mi"
      maxAllowed:
        cpu: "2000m"
        memory: "2Gi"
      controlledResources: ["cpu", "memory"]
```

**VPA modes:**
- `Off` — only produces recommendations, does not apply them
- `Initial` — sets resources only at pod creation
- `Auto` — adjusts running pods (may cause restarts)

**Warning:** Do NOT use HPA and VPA together on the same metric (e.g., both scaling on CPU). HPA scales horizontally while VPA adjusts vertically — they can conflict.

### Pod Disruption Budget (PDB)

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app
spec:
  minAvailable: 3          # At least 3 pods must always be running
  # OR
  # maxUnavailable: 1      # At most 1 pod can be down at a time
  selector:
    matchLabels:
      app: my-app
```

**When to use:** Always for production workloads. Prevents cluster operations (node drain, upgrades) from taking down too many pods simultaneously.

### Resource Quotas and Limit Ranges

```yaml
# Namespace-level resource quota
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a
spec:
  hard:
    requests.cpu: "10"
    requests.memory: "20Gi"
    limits.cpu: "20"
    limits.memory: "40Gi"
    pods: "50"
    services: "10"
    persistentvolumeclaims: "20"

---
# Default resource limits for pods in namespace
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: team-a
spec:
  limits:
  - default:               # Default limits (if not specified)
      cpu: "500m"
      memory: "512Mi"
    defaultRequest:         # Default requests (if not specified)
      cpu: "100m"
      memory: "128Mi"
    max:                    # Maximum allowed
      cpu: "4"
      memory: "8Gi"
    min:                    # Minimum allowed
      cpu: "50m"
      memory: "64Mi"
    type: Container
```

---

## Health Check Patterns

```yaml
containers:
- name: app
  # Startup probe: for slow-starting apps
  # Disables liveness/readiness until startup succeeds
  startupProbe:
    httpGet:
      path: /healthz/startup
      port: 8080
    failureThreshold: 30       # 30 * 10s = 5 min max startup time
    periodSeconds: 10

  # Liveness probe: is the app alive?
  # Failure = pod is restarted
  livenessProbe:
    httpGet:
      path: /healthz/live
      port: 8080
    initialDelaySeconds: 0     # Startup probe handles delay
    periodSeconds: 10
    failureThreshold: 3
    timeoutSeconds: 5

  # Readiness probe: can the app serve traffic?
  # Failure = removed from Service endpoints (no traffic)
  readinessProbe:
    httpGet:
      path: /healthz/ready
      port: 8080
    initialDelaySeconds: 0
    periodSeconds: 5
    failureThreshold: 3
    timeoutSeconds: 3
```

**Probe design:**

```
┌────────────────┬────────────────────────────────────────────────────────────┐
│  Probe         │  What to check                                             │
├────────────────┼────────────────────────────────────────────────────────────┤
│  Startup       │  App initialization complete (DB migrations, cache warm)    │
│  Liveness      │  App is not deadlocked. Keep it SIMPLE. Do NOT check       │
│                │  external dependencies — a DB outage should not restart     │
│                │  all your pods.                                             │
│  Readiness     │  App CAN serve requests. Check critical dependencies       │
│                │  (DB connection, required config loaded).                   │
└────────────────┴────────────────────────────────────────────────────────────┘

ANTI-PATTERN: Liveness probe that checks database connectivity.
  If DB goes down → all pods restart → thundering herd on DB recovery.
  Instead: Use readiness probe for dependency checks (removes from traffic).
           Use liveness probe only for app-internal health (deadlock detection).
```

---

## Helm Chart Best Practices

### Chart Structure

```
my-chart/
├── Chart.yaml              # Chart metadata (name, version, dependencies)
├── values.yaml             # Default configuration values
├── values-dev.yaml         # Environment-specific overrides
├── values-staging.yaml
├── values-prod.yaml
├── templates/
│   ├── _helpers.tpl        # Template helper functions
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   ├── pdb.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── networkpolicy.yaml
│   └── tests/
│       └── test-connection.yaml
├── charts/                 # Dependency charts
└── .helmignore
```

### Values File Design

```yaml
# values.yaml — well-structured defaults
replicaCount: 3

image:
  repository: my-app
  tag: ""                          # Set via --set or CI/CD (not hardcoded)
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: nginx
  annotations: {}
  hosts:
  - host: app.example.com
    paths:
    - path: /
      pathType: Prefix
  tls: []

resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 512Mi

autoscaling:
  enabled: false
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

podDisruptionBudget:
  enabled: true
  minAvailable: 2

probes:
  liveness:
    path: /healthz/live
    port: 8080
    initialDelaySeconds: 15
    periodSeconds: 10
  readiness:
    path: /healthz/ready
    port: 8080
    initialDelaySeconds: 5
    periodSeconds: 5

env: []
# - name: DATABASE_URL
#   valueFrom:
#     secretKeyRef:
#       name: app-secrets
#       key: database-url

nodeSelector: {}
tolerations: []
affinity: {}
```

### Template Best Practices

```yaml
# templates/_helpers.tpl

# Standard labels (applied to all resources)
{{- define "my-chart.labels" -}}
helm.sh/chart: {{ include "my-chart.chart" . }}
app.kubernetes.io/name: {{ include "my-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

# Selector labels (used in selectors — DO NOT change after initial deploy)
{{- define "my-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
```

### Helm Best Practices Checklist

```
HELM CHART QUALITY:
├── Versioning
│   ├── Chart.yaml version follows SemVer (chart version)
│   ├── appVersion tracks the application version
│   └── Bump chart version on ANY template change
│
├── Values design
│   ├── Sensible defaults in values.yaml (works out of the box)
│   ├── Environment overrides via values-{env}.yaml
│   ├── No secrets in values files (use External Secrets, Sealed Secrets)
│   ├── All images use specific tags, never "latest"
│   └── Resource requests/limits set for all containers
│
├── Templates
│   ├── Use _helpers.tpl for reusable template functions
│   ├── Standard Kubernetes labels on all resources
│   ├── Consistent selector labels (never change after deploy)
│   ├── Use {{ .Release.Namespace }} instead of hardcoded namespaces
│   ├── Quote all string values: {{ .Values.foo | quote }}
│   ├── Use toYaml for complex nested values: {{ toYaml .Values.env | nindent 12 }}
│   └── Conditional resources: {{- if .Values.ingress.enabled }}
│
├── Security
│   ├── ServiceAccount per release (not default)
│   ├── SecurityContext: runAsNonRoot, readOnlyRootFilesystem
│   ├── NetworkPolicy to restrict traffic
│   ├── No privileged containers
│   └── Pod security standards enforced
│
├── Testing
│   ├── helm lint passes
│   ├── helm template renders correctly
│   ├── helm test runs (test-connection.yaml)
│   ├── Test with different values (dev, staging, prod)
│   └── Validate against Kubernetes schema (kubeconform)
│
└── Documentation
    ├── Chart.yaml has description and maintainers
    ├── values.yaml has comments for all fields
    └── NOTES.txt provides post-install instructions
```

### Security Context

```yaml
spec:
  securityContext:                   # Pod level
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:                 # Container level
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    volumeMounts:
    - name: tmp
      mountPath: /tmp               # Writable tmp since rootfs is read-only
  volumes:
  - name: tmp
    emptyDir: {}
```

---

## Networking Patterns

### Network Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: my-app
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway            # Only allow traffic from API gateway
    ports:
    - port: 8080
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres               # Allow DB connection
    ports:
    - port: 5432
  - to:                               # Allow DNS
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          k8s-app: kube-dns
    ports:
    - port: 53
      protocol: UDP
```

### Service Types Summary

```
┌──────────────┬─────────────────────────────────────────────────────────────┐
│  Type        │  Use Case                                                    │
├──────────────┼─────────────────────────────────────────────────────────────┤
│  ClusterIP   │  Internal service communication (default). Not exposed      │
│              │  outside the cluster.                                        │
├──────────────┼─────────────────────────────────────────────────────────────┤
│  NodePort    │  Development, debugging. Exposes on each node's IP at       │
│              │  a static port (30000-32767).                                │
├──────────────┼─────────────────────────────────────────────────────────────┤
│  LoadBalancer│  Cloud environments. Provisions a cloud load balancer.       │
│              │  One LB per service (can get expensive).                     │
├──────────────┼─────────────────────────────────────────────────────────────┤
│  ExternalName│  CNAME alias to external service. No proxying.              │
├──────────────┼─────────────────────────────────────────────────────────────┤
│  Headless    │  ClusterIP: None. Returns pod IPs directly. Used for        │
│              │  StatefulSets and service discovery.                         │
└──────────────┴─────────────────────────────────────────────────────────────┘
```

---

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| No resource requests/limits | Pods starve each other, unpredictable eviction | Always set requests; set memory limits |
| `latest` image tag | Unpredictable deployments, no rollback | Use specific immutable tags (git SHA or SemVer) |
| Liveness probe checks DB | DB outage cascades into pod restarts | Liveness = app-internal; readiness = dependencies |
| No PDB | Cluster upgrades take down all pods | Set minAvailable or maxUnavailable |
| Secrets in ConfigMaps | Secrets visible in plain text | Use Secrets (base64), or External Secrets Operator |
| Single replica in production | Zero fault tolerance | Minimum 2-3 replicas with PDB |
| No network policies | Any pod can talk to any pod | Default-deny, allowlist required traffic |
| Privileged containers | Container escape = full node access | Drop all capabilities, run as non-root, read-only rootfs |
| HPA + VPA on same metric | Autoscalers fight each other | Use one, or separate metrics (HPA on CPU, VPA on memory) |
| Hardcoded namespace | Cannot deploy to different namespaces | Use {{ .Release.Namespace }} |
