---
name: mlops
description: MLOps and model deployment.
---

## Activate When
- `/godmode:mlops`, "deploy model", "model serving"
- "model drift", "retrain", "A/B test models"
- Trained model ready for production deployment

## Workflow

### 1. Model Readiness
```
Model: <name and version>
Source: EXP-<ID>
Checklist:
  [ ] Evaluation complete (test metrics documented)
  [ ] Bias/fairness check passed
  [ ] Artifacts saved (weights, config, preprocessor)
  [ ] Input/output schema documented
  [ ] Latency benchmarked (< target p99 ms)
  [ ] Size acceptable (< N MB)
```
IF latency p99 > 100ms: apply optimization.
IF model size > 500MB: consider distillation/pruning.

### 2. Serving Infrastructure
```
Options:
  TF Serving: TensorFlow models, gRPC/REST
  Triton: multi-framework, ONNX/TensorRT
  SageMaker: managed AWS, auto-scaling
  FastAPI/Ray Serve: custom, flexible
```
```bash
# Check for serving frameworks
pip list | grep -iE "fastapi|ray|triton|sagemaker"
ls model_repository/ serve/ 2>/dev/null
```

### 3. Inference Optimization
```
| Optimization | Latency | Size | Accuracy |
| Baseline FP32 | <ms> | <MB> | <val> |
| FP16 quant | <ms> | <MB> | <val> |
| INT8 quant | <ms> | <MB> | <val> |
| ONNX | <ms> | <MB> | <val> |
| Distillation | <ms> | <MB> | <val> |
```
IF accuracy drop > 1% from quantization: use FP16 only.
IF latency target not met: try TensorRT or distillation.

Batching: static (fixed workload), dynamic (variable
  traffic, max_queue_delay_ms), adaptive (auto-tune).

### 4. Model Versioning
```
| Version | Metric | Status | Traffic |
| v3.1 | F1=0.891 | CHAMPION | 90% |
| v3.2 | F1=0.903 | CANARY | 10% |
| v3.0 | F1=0.879 | ARCHIVED | 0% |
Lifecycle: STAGED->CANARY->CHAMPION->ARCHIVED
```

### 5. A/B Testing
```
Champion: v<N>  Challenger: v<N>
Split: <champion%>/<challenger%>
Routing: random|user-hash|feature-flag
Duration: <minimum days>
Sample size: <minimum per variant>
Success: primary metric >= <threshold> improvement
Guardrails: latency p99, error rate, business KPIs
```
IF p-value > 0.05 after min samples: no winner.
IF guardrail regresses > 2%: stop test, revert.

### 6. Drift Detection
```
Feature drift (PSI):
  < 0.1: no drift
  0.1-0.2: moderate — monitor closely
  > 0.2: significant — trigger retraining
Performance:
  < 2% drop: normal variance
  2-5% drop: warning — schedule review
  > 5% drop: alert — trigger retraining
```

### 7. Retraining
```
Trigger: scheduled|drift-based|performance-based
Frequency: daily|weekly|monthly
Data window: last N days
Auto_deploy: false (requires A/B or human gate)
Cooldown: minimum time between retraining runs
```

### 8. Monitoring Dashboard
```
Requests/sec: <current> (avg/peak)
Latency p50/p95/p99: <ms>/<ms>/<ms>
Error rate: <pct>
Primary metric (7d rolling): <val>
Drift status: NONE|LOW|MODERATE|HIGH
```

## Hard Rules
1. NEVER deploy without readiness checklist complete.
2. NEVER 100% traffic to new model on day one.
   Start shadow->5% canary->ramp.
3. ALWAYS keep previous champion ready for rollback.
4. NEVER auto-promote without validation gate.
5. Rollback must take < 5 minutes.

## TSV Logging
Append `.godmode/mlops-results.tsv`:
```
timestamp	model	version	action	latency_p99	status
```

## Keep/Discard
```
KEEP if: metrics improve AND no guardrail regression
  AND pipeline runs end-to-end.
DISCARD if: metrics regress OR pipeline fails.
  Revert and log reason.
```

## Stop Conditions
```
STOP when FIRST of:
  - Model stable at 100% for 24h
  - Drift monitoring configured
  - Rollback tested < 5 min
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| OOM during training | Resume checkpoint, reduce batch |
| Performance degrades | Check drift, trigger retrain |
| A/B no difference | Verify sample size, document null |
