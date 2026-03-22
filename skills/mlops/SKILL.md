---
name: mlops
description: |
  MLOps and model deployment skill. Activates when ML models need to move from experimentation to production serving. Manages model serving infrastructure, inference optimization, model versioning, A/B testing, drift detection, and retraining triggers. Supports TensorFlow Serving, Triton Inference Server, SageMaker, and custom serving solutions. Triggers on: /godmode:mlops, "deploy model", "serving infrastructure", "model drift", "retrain", or when a trained model needs production readiness.
---

# MLOps — MLOps & Model Deployment

## When to Activate
- User invokes `/godmode:mlops`
- User has a trained model ready for deployment
- User says "deploy this model", "set up model serving", "check for drift"
- User needs to manage model versions in production
- User wants to A/B test models or implement canary deployments
- Monitoring detects model performance degradation or data drift

## Workflow

### Step 1: Model Readiness Assessment

Before deploying, verify the model is production-ready:

```
MODEL READINESS CHECKLIST:
Model: <model name and version>
Source experiment: EXP-<ID>

Functional readiness:
  [ ] Model evaluation complete (test set metrics documented)
  [ ] Bias/fairness check passed
  [ ] Model artifacts saved (weights, config, tokenizer/preprocessor)
  [ ] Input/output schema documented
  [ ] Inference latency benchmarked (<target>ms p99)
  [ ] Model size acceptable for target infrastructure (<N> MB)
  [ ] Reproducibility verified (can retrain from config + data)
  ...
```
### Step 2: Model Serving Infrastructure

Select and configure the serving infrastructure:

#### Option A: TensorFlow Serving
```yaml
# tensorflow_serving config
model_config_list:
  config:
    - name: "<model_name>"
      base_path: "/models/<model_name>"
      model_platform: "tensorflow"
```

#### Option B: NVIDIA Triton Inference Server
```
# Triton model repository structure
model_repository/
  <model_name>/
    config.pbtxt
    1/
      model.onnx       # or model.plan (TensorRT)
    2/
      model.onnx

# config.pbtxt
name: "<model_name>"
platform: "onnxruntime_onnx"
  ...
```

#### Option C: AWS SageMaker
```python
# SageMaker deployment
import sagemaker
from sagemaker.model import Model

model = Model(
    image_uri=sagemaker.image_uris.retrieve("pytorch", region, version="2.0"),
```

#### Option D: Custom Serving (FastAPI / Ray Serve)
```python
# FastAPI model server
from fastapi import FastAPI
import torch

app = FastAPI()
model = None
```

### Step 3: Inference Optimization

Optimize model for production inference:

```
INFERENCE OPTIMIZATION:
| Optimization | Latency | Throughput | Size | Accuracy |
|--|--|--|--|--|
| Baseline (FP32) | <ms> | <req/s> | <MB> | <metric> |
| FP16 quantization | <ms> | <req/s> | <MB> | <metric> |
| INT8 quantization | <ms> | <req/s> | <MB> | <metric> |
| ONNX conversion | <ms> | <req/s> | <MB> | <metric> |
| TensorRT | <ms> | <req/s> | <MB> | <metric> |
| Pruning (50%) | <ms> | <req/s> | <MB> | <metric> |
| Distillation | <ms> | <req/s> | <MB> | <metric> |

Selected: <optimization> — <rationale>
  ...
```
#### Batching Strategies
```
BATCHING CONFIGURATION:
Strategy: <static | dynamic | adaptive>

Static batching:
  batch_size: <N>
  Use when: fixed workload, predictable traffic

Dynamic batching:
  max_batch_size: <N>
  max_queue_delay_ms: <N>
  preferred_batch_sizes: [<sizes>]
  Use when: variable traffic, latency-sensitive
  ...
```

### Step 4: Model Versioning

Manage model versions with structured lifecycle:

```
MODEL VERSION REGISTRY:
| Version | Experiment | Metric | Status | Traffic | Deployed |
|--|--|--|--|--|---|
| v3.1 | EXP-042 | F1=0.891 | CHAMPION | 90% | 2025-03 |
| v3.2 | EXP-047 | F1=0.903 | CANARY | 10% | 2025-03 |
| v3.0 | EXP-038 | F1=0.879 | ARCHIVED | 0% | 2025-02 |
| v2.9 | EXP-031 | F1=0.862 | ARCHIVED | 0% | 2025-01 |

Version lifecycle:
  STAGED    → Model uploaded, not yet serving
  CANARY    → Serving small percentage of traffic
  CHAMPION  → Serving majority of production traffic
  ...
```
### Step 5: A/B Testing for Models

Run controlled experiments comparing model versions:

```
A/B TEST CONFIGURATION:
Test name: <descriptive name>
Champion: v<N> (current production model)
Challenger: v<N> (new model to evaluate)
Traffic split: <champion%> / <challenger%>
Routing: <random | user-hash | feature-flag>
Duration: <minimum test duration>
Sample size: <minimum samples per variant for significance>

Success criteria:
  Primary metric: <metric name> improvement >= <threshold>
  Guardrail metrics:
  ...
```
#### A/B Test Monitoring
```
A/B TEST RESULTS:
Status: <RUNNING | SIGNIFICANT | NOT SIGNIFICANT | STOPPED>
Duration: <elapsed> / <planned>
Samples: champion=<N>, challenger=<N>

Metrics:
| Metric | Champion | Challenger | Delta | p-value |
|--|--:|--:|--|--:|
| <primary> | <value> | <value> | <change> | <p> |
| <guardrail 1> | <value> | <value> | <change> | <p> |
| <guardrail 2> | <value> | <value> | <change> | <p> |
| Latency p99 | <value> | <value> | <change> | <p> |
  ...
```

### Step 6: Drift Detection

Monitor for data drift and model performance degradation:

```
DRIFT DETECTION:
Monitoring window: <time range>
Reference: <training data distribution or baseline period>

Data drift (input features):
| Feature | Test | Statistic | p-value | Status |
|--|--|--:|--:|--|
| <feature 1> | KS test | <val> | <p> | <status> |
| <feature 2> | chi-sq | <val> | <p> | <status> |
| <feature 3> | PSI | <val> | — | <status> |
| <feature 4> | KS test | <val> | <p> | <status> |

  ...
```
#### Drift Alert Thresholds
```
DRIFT THRESHOLDS:
Feature drift (PSI):
  < 0.1:  No drift
  0.1-0.2: Moderate drift — monitor closely
  > 0.2:  Significant drift — investigate and trigger retraining

Performance degradation:
  < 2% drop:  Normal variance
  2-5% drop:  Warning — schedule review
  > 5% drop:  Alert — trigger retraining pipeline

Prediction distribution:
  ...
```

### Step 7: Retraining Triggers and Automation

Define when and how to retrain:

```
RETRAINING CONFIGURATION:
Trigger strategy: <scheduled | drift-based | performance-based | hybrid>

Scheduled retraining:
  frequency: <daily | weekly | monthly>
  data window: <last N days of data>
  auto_deploy: <true | false — requires A/B test first>

Drift-based retraining:
  monitor: <list of features and metrics>
  threshold: <drift severity level to trigger>
  cooldown: <minimum time between retraining runs>
  ...
```
#### Retraining Pipeline Status
```
RETRAINING STATUS:
Last retrain: <timestamp>
Trigger: <reason — scheduled | drift | performance>
New model version: v<N>
Training data: <N samples, date range>
Result: <metric value> vs champion <metric value>
Status: <PROMOTED | STAGED | REJECTED>
Next scheduled retrain: <timestamp>
```

### Step 8: Production Monitoring Dashboard

```
MODEL MONITORING DASHBOARD:
  MODEL: <name> v<version>
  Status: SERVING
  Traffic:
  Requests/sec:   <current>  (avg: <avg>, peak: <peak>)
  Latency p50:    <ms>
  Latency p95:    <ms>
  Latency p99:    <ms>
  Error rate:     <percentage>
  Model Performance:
  Primary metric (7d rolling): <value> (baseline: <value>)
  Drift status:               <NONE | LOW | MODERATE | HIGH>
```
### Step 9: Commit and Transition
1. Save deployment config as `configs/mlops/<model>-serving.yaml`
2. Save monitoring config as `configs/mlops/<model>-monitoring.yaml`
3. Commit: `"mlops: <model> v<version> — <action> (<serving platform>)"`
4. If deployed: "Model deployed. Monitoring active. Run `/godmode:mlops --status` to check health."
5. If drift detected: "Drift detected. Retraining triggered. Run `/godmode:ml` to review training results."
6. If A/B test complete: "A/B test concluded. <Recommendation>. Run `/godmode:mlops --promote` or `--rollback`."

## Key Behaviors

1. **Never deploy without a readiness check.** A model that passes evaluation can still fail in production. Check latency, resource usage, error handling, and fallback behavior.
2. **Shadow mode before live traffic.** When possible, run new models in shadow mode first — they receive real traffic but their responses are not returned to users. Compare against champion silently.
3. **Canary before full rollout.** Start with 1-5% traffic. Watch error rates and latency. Only increase if stable.
4. **Monitor continuously, not at deploy time.** Drift happens gradually. Set up alerts for degradation, not outages.
5. **Automate retraining, but gate deployment.** Automate retraining freely. Require a validation gate (A/B test or human review) for deployment.
6. **Keep rollback instant.** Always maintain the previous champion model ready to serve. Rollback should take seconds, not minutes.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive model deployment workflow |
| `--status` | Show production monitoring dashboard |
| `--deploy <model>` | Deploy a specific model version |

## Auto-Detection

```
IF directory contains model files (*.pt, *.onnx, *.savedmodel, *.pkl, *.h5):
  SUGGEST "Trained model artifacts detected. Activate /godmode:mlops for deployment?"

IF directory contains Dockerfile AND (model loading code OR serving framework):
  SUGGEST "Model serving container detected. Activate /godmode:mlops?"

IF directory contains configs/ with serving configs (triton, tf-serving, sagemaker):
  SUGGEST "Model serving configuration detected. Activate /godmode:mlops?"

IF code imports fastapi OR flask AND loads model:
  SUGGEST "Custom model serving endpoint detected. Activate /godmode:mlops?"

  ...
```
## HARD RULES

```
1. NEVER deploy a model without completing the readiness checklist.
   VERIFY latency, bias, input validation, and fallback.

2. NEVER send 100% of traffic to a new model on day one.
   Start with shadow mode, then 5% canary, then ramp.

3. ALWAYS maintain the previous champion model ready for instant rollback.
   Rollback must take seconds, not minutes.

4. NEVER automate model promotion without a validation gate.
   Automate retraining freely; deployment requires A/B test or human review.

  ...
```
## Output Format

After each MLOps skill invocation, emit a structured report:

```
MLOPS DEPLOYMENT REPORT:
| Model | <name> v<version> |
|--|--|
| Serving framework | <TorchServe | TFServing | Triton | custom> |
| Deployment method | <canary | blue-green | shadow> |
| Latency (p50/p99) | <N>ms / <N>ms |
| Throughput | <N> req/s |
| Model size | <N> MB |
| Drift monitoring | CONFIGURED / NOT CONFIGURED |
| Fallback strategy | <description> |
| A/B test | RUNNING / NOT APPLICABLE |
| Verdict | DEPLOYED | NEEDS WORK |
```
## TSV Logging

Log every deployment action for tracking:

```
timestamp	skill	model	version	action	latency_p99_ms	throughput_rps	status
2026-03-20T14:00:00Z	mlops	fraud_detector	v3.2	canary_5pct	45	1200	deployed
2026-03-20T14:30:00Z	mlops	fraud_detector	v3.2	canary_25pct	48	1180	deployed
```
## Success Criteria

The MLOps skill is complete when ALL of the following are true:
1. Model is deployed with a gradual rollout strategy (canary, blue-green, or shadow)
2. Latency meets SLA targets at p50 and p99 (benchmarked under production-like load)
3. Fallback strategy is defined and tested (what happens when the model fails)
4. Drift monitoring is configured for input features and prediction distribution
5. Model version and serving code version are tracked independently
6. Rollback procedure is tested and takes < 5 minutes
7. A/B test (if applicable) has sufficient sample size before making decisions
8. All deployment artifacts are versioned and reproducible

## Stop Conditions
```
STOP when ANY of these are true:
  - Model deployed with canary and stable at 100% traffic for 24h
  - Drift monitoring configured with alerting thresholds
  - Rollback tested and completes in < 5 minutes
  - User explicitly requests stop

DO NOT STOP just because:
  - A/B test is still running (wait for minimum sample size)
  - Retraining pipeline is not yet automated (manual retraining is acceptable initially)
```
## Error Recovery
| Failure | Action |
|--|--|
| Model training fails midway | Check GPU memory (OOM). Verify data pipeline integrity. Resume from last checkpoint if available. Reduce batch size. |
| Model performance degrades in production | Check for data drift using statistical tests. Compare feature distributions. Trigger retraining if drift exceeds threshold. |
| Feature store returns stale features | Verify feature freshness SLAs. Check pipeline scheduling. Add monitoring for feature age. |
| A/B test shows no significant difference | Verify sample size was sufficient. Check for implementation bugs. Document null result. Do not extend test indefinitely. |

## Keep/Discard Discipline
```
After EACH model or pipeline change:
  KEEP if: evaluation metrics improve AND no regression on guardrail metrics AND pipeline runs end-to-end
  DISCARD if: metrics regress OR pipeline fails OR data quality checks fail
  On discard: revert model artifact and pipeline config. Log reason in experiment tracker.
```
