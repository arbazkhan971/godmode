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

Operational readiness:
  [ ] Model serialized in serving format (SavedModel, ONNX, TorchScript, etc.)
  [ ] Preprocessing pipeline packaged with model
  [ ] Health check endpoint defined
  [ ] Input validation logic defined
  [ ] Error handling for malformed inputs
  [ ] Graceful degradation / fallback strategy defined
  [ ] Logging and monitoring instrumented
  [ ] Load testing completed

Compliance:
  [ ] Model card written (purpose, limitations, ethical considerations)
  [ ] Data provenance documented
  [ ] License compliance for training data and model weights
  [ ] Privacy review complete (no PII memorization, GDPR compliance)

Verdict: <READY | NOT READY — list blockers>
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
      model_version_policy:
        specific:
          versions: [1, 2]  # serve multiple versions for A/B

# Deployment
docker run -p 8501:8501 \
  --mount type=bind,source=/models,target=/models \
  -t tensorflow/serving \
  --model_config_file=/config/models.config \
  --enable_batching=true \
  --batching_parameters_file=/config/batching.config
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
max_batch_size: 64
input [
  { name: "input_ids"      dims: [-1] data_type: TYPE_INT64 }
  { name: "attention_mask"  dims: [-1] data_type: TYPE_INT64 }
]
output [
  { name: "logits"          dims: [-1] data_type: TYPE_FP32 }
]
instance_group [
  { count: 2  kind: KIND_GPU  gpus: [0] }
]
dynamic_batching {
  preferred_batch_size: [8, 16, 32]
  max_queue_delay_microseconds: 100
}
```

#### Option C: AWS SageMaker
```python
# SageMaker deployment
import sagemaker
from sagemaker.model import Model

model = Model(
    image_uri=sagemaker.image_uris.retrieve("pytorch", region, version="2.0"),
    model_data="s3://bucket/models/model.tar.gz",
    role=role,
    env={
        "MODEL_NAME": "<model_name>",
        "MODEL_VERSION": "<version>",
    }
)

predictor = model.deploy(
    initial_instance_count=2,
    instance_type="ml.g5.xlarge",
    endpoint_name="<endpoint_name>",
    data_capture_config=DataCaptureConfig(
        enable_capture=True,
        sampling_percentage=10,
        destination_s3_uri="s3://bucket/data-capture"
    )
)
```

#### Option D: Custom Serving (FastAPI / Ray Serve)
```python
# FastAPI model server
from fastapi import FastAPI
import torch

app = FastAPI()
model = None

@app.on_event("startup")
async def load_model():
    global model
    model = torch.jit.load("model.pt")
    model.eval()

@app.post("/predict")
async def predict(request: PredictRequest):
    with torch.no_grad():
        inputs = preprocess(request.data)
        outputs = model(inputs)
        return {"predictions": postprocess(outputs)}

@app.get("/health")
async def health():
    return {"status": "healthy", "model_version": MODEL_VERSION}
```

### Step 3: Inference Optimization

Optimize model for production inference:

```
INFERENCE OPTIMIZATION:
┌─────────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Optimization        │ Latency  │ Throughput│ Size     │ Accuracy │
├─────────────────────┼──────────┼──────────┼──────────┼──────────┤
│ Baseline (FP32)     │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ FP16 quantization   │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ INT8 quantization   │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ ONNX conversion     │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ TensorRT            │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ Pruning (50%)       │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
│ Distillation        │ <ms>     │ <req/s>  │ <MB>     │ <metric> │
└─────────────────────┴──────────┴──────────┴──────────┴──────────┘

Selected: <optimization> — <rationale>
Accuracy drop: <acceptable | too high — threshold>
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

Adaptive batching:
  min_batch_size: <N>
  max_batch_size: <N>
  target_latency_ms: <N>
  scale_factor: <N>
  Use when: highly variable traffic, SLA-driven

Benchmark results:
  Batch size 1:   latency=<ms>, throughput=<req/s>
  Batch size 8:   latency=<ms>, throughput=<req/s>
  Batch size 32:  latency=<ms>, throughput=<req/s>
  Batch size 128: latency=<ms>, throughput=<req/s>
  Optimal: batch_size=<N> (best throughput within latency SLA)
```

### Step 4: Model Versioning

Manage model versions with structured lifecycle:

```
MODEL VERSION REGISTRY:
┌─────────┬────────────┬──────────┬──────────┬──────────┬──────────┐
│ Version │ Experiment │ Metric   │ Status   │ Traffic  │ Deployed │
├─────────┼────────────┼──────────┼──────────┼──────────┼──────────┤
│ v3.1    │ EXP-042    │ F1=0.891 │ CHAMPION │ 90%      │ 2025-03  │
│ v3.2    │ EXP-047    │ F1=0.903 │ CANARY   │ 10%      │ 2025-03  │
│ v3.0    │ EXP-038    │ F1=0.879 │ ARCHIVED │ 0%       │ 2025-02  │
│ v2.9    │ EXP-031    │ F1=0.862 │ ARCHIVED │ 0%       │ 2025-01  │
└─────────┴────────────┴──────────┴──────────┴──────────┴──────────┘

Version lifecycle:
  STAGED    → Model uploaded, not yet serving
  CANARY    → Serving small percentage of traffic
  CHAMPION  → Serving majority of production traffic
  SHADOW    → Receiving traffic but responses not returned to users
  ARCHIVED  → Removed from serving, artifacts retained
  RETIRED   → Artifacts deleted after retention period
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
    - <metric 1>: must not degrade by more than <threshold>
    - <metric 2>: must not degrade by more than <threshold>
  Statistical test: <t-test | chi-squared | mann-whitney>
  Significance level: alpha = <value>
  Minimum detectable effect: <value>
```

#### A/B Test Monitoring
```
A/B TEST RESULTS:
Status: <RUNNING | SIGNIFICANT | NOT SIGNIFICANT | STOPPED>
Duration: <elapsed> / <planned>
Samples: champion=<N>, challenger=<N>

Metrics:
┌────────────────┬───────────┬────────────┬──────────┬──────────┐
│ Metric         │ Champion  │ Challenger │ Delta    │ p-value  │
├────────────────┼───────────┼────────────┼──────────┼──────────┤
│ <primary>      │ <value>   │ <value>    │ <change> │ <p>      │
│ <guardrail 1>  │ <value>   │ <value>    │ <change> │ <p>      │
│ <guardrail 2>  │ <value>   │ <value>    │ <change> │ <p>      │
│ Latency p99    │ <value>   │ <value>    │ <change> │ <p>      │
│ Error rate     │ <value>   │ <value>    │ <change> │ <p>      │
└────────────────┴───────────┴────────────┴──────────┴──────────┘

Decision: <PROMOTE challenger | KEEP champion | EXTEND test>
Rationale: <explanation based on metrics and significance>
```

### Step 6: Drift Detection

Monitor for data drift and model performance degradation:

```
DRIFT DETECTION:
Monitoring window: <time range>
Reference: <training data distribution or baseline period>

Data drift (input features):
┌────────────────┬────────────┬──────────┬──────────┬──────────┐
│ Feature        │ Test       │ Statistic│ p-value  │ Status   │
├────────────────┼────────────┼──────────┼──────────┼──────────┤
│ <feature 1>    │ KS test    │ <val>    │ <p>      │ <status> │
│ <feature 2>    │ chi-sq     │ <val>    │ <p>      │ <status> │
│ <feature 3>    │ PSI        │ <val>    │ —        │ <status> │
│ <feature 4>    │ KS test    │ <val>    │ <p>      │ <status> │
└────────────────┴────────────┴──────────┴──────────┴──────────┘

Concept drift (model performance):
  Accuracy (rolling 7d): <current> vs <baseline> (delta: <change>)
  Prediction distribution shift: <PSI value> (<status>)
  Confidence calibration drift: <ECE change>

Drift severity:
  NONE:     All features stable, performance nominal
  LOW:      Minor feature drift, performance within SLA
  MODERATE: Significant feature drift OR minor performance drop
  HIGH:     Major feature drift AND performance degradation
  CRITICAL: Model predictions unreliable, immediate action required
```

#### Drift Alert Thresholds
```
DRIFT THRESHOLDS:
Feature drift (PSI):
  < 0.1:  No drift
  0.1-0.2: Moderate drift — monitor closely
  > 0.2:  Significant drift — investigate and consider retraining

Performance degradation:
  < 2% drop:  Normal variance
  2-5% drop:  Warning — schedule review
  > 5% drop:  Alert — trigger retraining pipeline

Prediction distribution:
  < 0.1 PSI:  Stable
  0.1-0.25:   Shift detected — investigate
  > 0.25:     Major shift — retrain
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

Performance-based retraining:
  metric: <monitored metric>
  threshold: <minimum acceptable value>
  evaluation_window: <rolling window size>
  min_samples: <minimum samples before evaluating>

Retraining pipeline:
  1. Fetch latest labeled data from <data source>
  2. Validate dataset (schema, quality, bias)
  3. Train with best known hyperparameters from EXP-<ID>
  4. Evaluate on held-out test set
  5. Compare against current champion
  6. If improved: stage as canary, run A/B test
  7. If not improved: log results, alert team
  8. Retain artifacts for <retention period>
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
┌────────────────────────────────────────────────────────────┐
│  MODEL: <name> v<version>                                  │
│  Status: SERVING                                           │
├────────────────────────────────────────────────────────────┤
│  Traffic:                                                  │
│  Requests/sec:   <current>  (avg: <avg>, peak: <peak>)    │
│  Latency p50:    <ms>                                      │
│  Latency p95:    <ms>                                      │
│  Latency p99:    <ms>                                      │
│  Error rate:     <percentage>                              │
│                                                            │
│  Model Performance:                                        │
│  Primary metric (7d rolling): <value> (baseline: <value>) │
│  Drift status:               <NONE | LOW | MODERATE | HIGH>│
│  Data quality:               <HEALTHY | DEGRADED>         │
│                                                            │
│  Infrastructure:                                           │
│  CPU utilization:  <percentage>                            │
│  GPU utilization:  <percentage>                            │
│  Memory usage:     <used>/<total>                          │
│  Replicas:         <current>/<desired>                     │
│  Autoscaler:       <status>                                │
│                                                            │
│  A/B Test:                                                 │
│  Active: <YES/NO>                                          │
│  Champion: v<N> (<traffic%>) | Challenger: v<N> (<traffic%>)│
│  Result: <pending | significant | not significant>        │
└────────────────────────────────────────────────────────────┘
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
4. **Monitor continuously, not just at deploy time.** Drift happens gradually. Set up alerts for degradation, not just outages.
5. **Automate retraining, but gate deployment.** Retraining can be automated. Deployment should require validation gate (A/B test or human review).
6. **Keep rollback instant.** Always maintain the previous champion model ready to serve. Rollback should take seconds, not minutes.

## Example Usage

### Deploying a Model
```
User: /godmode:mlops Deploy the ticket classifier from EXP-047

MLOps: Running readiness assessment...

MODEL READINESS:
Model: ticket-classifier v3.2 (EXP-047)
Evaluation: F1=0.903, AUC=0.961 — PASS
Bias check: PASS
Latency: 23ms p99 (target: <50ms) — PASS
Model size: 85MB (ONNX optimized) — PASS
Input validation: defined — PASS
Fallback strategy: return "uncategorized" + queue for human review — PASS

Verdict: READY

Deploying to Triton Inference Server...
  Model uploaded to repository
  Config generated (dynamic batching, max_batch=32)
  Health check: PASSING
  Traffic routing: CANARY (5%)

Monitoring dashboard active.
Champion (v3.1): 95% traffic | Challenger (v3.2): 5% traffic
A/B test running — minimum 48 hours, need 10,000 samples per variant.

Run /godmode:mlops --status to monitor.
```

### Checking for Drift
```
User: /godmode:mlops --drift

MLOps: Running drift detection...

DRIFT DETECTION:
Model: ticket-classifier v3.1
Window: last 7 days vs training data

Data drift: MODERATE
  - "ticket_length" feature: PSI=0.18 (shifted toward longer tickets)
  - "category_distribution": chi-sq p=0.02 (new category emerging)

Performance: STABLE
  - F1 (7d rolling): 0.887 vs baseline 0.891 (delta: -0.4%)

Recommendation: Monitor for 1 more week. If ticket_length drift continues,
schedule retraining with recent data. No immediate action required.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive model deployment workflow |
| `--status` | Show production monitoring dashboard |
| `--deploy <model>` | Deploy a specific model version |
| `--promote` | Promote canary/challenger to champion |
| `--rollback` | Rollback to previous champion |
| `--drift` | Run drift detection analysis |
| `--retrain` | Trigger retraining pipeline |
| `--ab-test` | Configure or check A/B test |
| `--optimize` | Run inference optimization benchmarks |
| `--scale <replicas>` | Scale serving infrastructure |
| `--versions` | Show model version registry |

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

IF directory contains drift/ OR monitoring/ with ML monitoring code:
  SUGGEST "ML monitoring infrastructure detected. Activate /godmode:mlops?"

ON experiment completion (from /godmode:ml):
  IF experiment.primary_metric > baseline:
    SUGGEST "Experiment {experiment.id} beat baseline. Deploy with /godmode:mlops?"
```

## Iterative Deployment Protocol

```
WHEN deploying a model through canary -> champion pipeline:

current_phase = "readiness_check"
traffic_pct = 0
monitoring_window_hours = 48
samples_needed = 10000

WHILE current_phase != "complete":

  IF current_phase == "readiness_check":
    RUN model readiness checklist
    IF all_checks_pass:
      current_phase = "shadow"
    ELSE:
      HALT "Model not ready: {failing_checks}"

  IF current_phase == "shadow":
    DEPLOY model in shadow mode (receives traffic, responses not returned)
    COMPARE shadow predictions vs champion predictions
    IF match_rate > 99% AND latency_ok:
      current_phase = "canary"
    ELSE:
      INVESTIGATE discrepancies
      CONTINUE

  IF current_phase == "canary":
    traffic_pct = 5
    ROUTE {traffic_pct}% traffic to new model
    MONITOR for {monitoring_window_hours} hours:
      - Error rate vs champion
      - Latency p50/p95/p99
      - Primary metric (if labeled data available)

    IF error_rate > champion_error_rate * 1.1 OR latency_p99 > SLA:
      ROLLBACK to champion
      current_phase = "rolled_back"
    ELSE:
      RAMP traffic: 5% -> 25% -> 50% -> 100%
      AT each ramp step: monitor for 4 hours before next ramp

    IF traffic_pct == 100 AND stable_for(24h):
      current_phase = "promote"

  IF current_phase == "promote":
    PROMOTE new model to champion
    ARCHIVE old champion (keep for rollback)
    current_phase = "complete"

  IF current_phase == "rolled_back":
    REPORT "Deployment failed. Reason: {failure_reason}"
    BREAK

FINAL: Report deployment outcome and monitoring dashboard link
```

## Multi-Agent Dispatch

```
WHEN deploying a model AND setting up monitoring:

DISPATCH parallel agents in worktrees:

  Agent 1 (serving-setup):
    - Configure serving infrastructure (Triton/TF-Serving/SageMaker)
    - Optimize inference (quantization, batching)
    - Output: serving configs + Dockerfile

  Agent 2 (monitoring-setup):
    - Configure drift detection pipeline
    - Set up alerting thresholds
    - Output: monitoring configs + dashboards

  Agent 3 (ab-test-setup):
    - Configure A/B test routing
    - Define success criteria and guardrails
    - Output: traffic routing config + test definition

  Agent 4 (retraining-pipeline):
    - Set up automated retraining triggers
    - Configure data pipeline for fresh training data
    - Output: retraining pipeline config

MERGE:
  - Verify serving config aligns with monitoring expectations
  - Verify A/B test routes match serving endpoints
  - Verify retraining pipeline outputs are compatible with serving format
```

## HARD RULES

```
1. NEVER deploy a model without completing the readiness checklist.
   Latency, bias, input validation, and fallback MUST be verified.

2. NEVER send 100% of traffic to a new model on day one.
   Start with shadow mode, then 5% canary, then ramp.

3. ALWAYS maintain the previous champion model ready for instant rollback.
   Rollback must take seconds, not minutes.

4. NEVER automate model promotion without a validation gate.
   Retraining can be automated; deployment requires A/B test or human review.

5. EVERY model in production MUST have drift monitoring with alerting.
   Check feature drift (PSI) and performance degradation continuously.

6. NEVER serve a model without a fallback strategy.
   When the model fails: simpler model, rules-based fallback, or graceful degradation.

7. Model version and serving code version MUST be tracked independently.
   A model update and a serving code update are separate deployments.

8. EVERY A/B test MUST run for minimum sample size before making decisions.
   Peeking at results early inflates false positive rate.
```

## Anti-Patterns

- **Do NOT deploy without benchmarking latency.** A model that takes 2 seconds per request will destroy your user experience and infrastructure budget. Benchmark first.
- **Do NOT skip canary deployment.** Sending 100% of traffic to a new model on day one is gambling. Start small.
- **Do NOT ignore drift.** A model trained on last year's data will perform poorly on this year's inputs. Monitor and retrain.
- **Do NOT retrain without validation.** Automated retraining is powerful but dangerous. Always validate the new model before promoting it.
- **Do NOT serve without a fallback.** When the model fails (and it will), have a graceful degradation path — a simpler model, a rules-based fallback, or a "we're processing your request" message.
- **Do NOT conflate model version with code version.** Model v3.2 might run on serving code v1.8. Track both independently. A model update and a serving code update should be separate deployments.
