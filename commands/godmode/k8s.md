# /godmode:k8s

Manage Kubernetes deployments, generate Helm charts, configure deployment strategies, and troubleshoot pod issues.

## Usage

```
/godmode:k8s                            # Validate manifests and show deployment plan
/godmode:k8s --generate                 # Generate Kubernetes manifests or Helm chart
/godmode:k8s --deploy                   # Deploy to the target cluster
/godmode:k8s --rollback                 # Rollback to previous revision
/godmode:k8s --status                   # Show current deployment status
/godmode:k8s --troubleshoot             # Diagnose pod/deployment issues
/godmode:k8s --scale 5                  # Scale deployment to 5 replicas
/godmode:k8s --strategy canary          # Use canary deployment strategy
/godmode:k8s --env staging              # Target staging environment
/godmode:k8s --dry-run                  # Render and validate without applying
```

## What It Does

1. Discovers Kubernetes context (cluster, namespace, workloads)
2. Generates or validates deployment manifests and Helm charts
3. Configures deployment strategies (rolling, canary, blue-green)
4. Sets resource requests/limits, health probes, HPA, PDB
5. Runs manifest validation (kubeval, kubesec, kube-linter)
6. Deploys with rollout verification and health checks
7. Troubleshoots common issues (CrashLoopBackOff, OOMKilled, etc.)

## Output
- Kubernetes manifests or Helm chart in `k8s/` or `charts/`
- Deployment plan with strategy and replica count
- Troubleshooting diagnosis with root cause and fix
- Commit: `"k8s: <description> — <strategy> deployment (<N> replicas)"`

## Next Step
After deployment: `/godmode:observe` to set up monitoring, or `/godmode:secure` for security review.

## Examples

```
/godmode:k8s --generate                 # Create Helm chart for the service
/godmode:k8s --deploy --env staging     # Deploy to staging
/godmode:k8s --troubleshoot             # Fix crashing pods
/godmode:k8s --strategy canary          # Canary deployment to production
```
