# /godmode:mlops

MLOps and model deployment management. Handles model serving infrastructure, inference optimization, model versioning, A/B testing, drift detection, and automated retraining. Supports TensorFlow Serving, Triton Inference Server, SageMaker, and custom serving solutions.

## Usage

```
/godmode:mlops                             # Interactive model deployment workflow
/godmode:mlops --status                    # Production monitoring dashboard
/godmode:mlops --deploy <model>            # Deploy a specific model version
/godmode:mlops --promote                   # Promote canary to champion
/godmode:mlops --rollback                  # Rollback to previous champion
/godmode:mlops --drift                     # Run drift detection analysis
/godmode:mlops --retrain                   # Trigger retraining pipeline
/godmode:mlops --ab-test                   # Configure or check A/B test
/godmode:mlops --optimize                  # Run inference optimization benchmarks
/godmode:mlops --scale <replicas>          # Scale serving infrastructure
/godmode:mlops --versions                  # Show model version registry
```

## What It Does

1. Assesses model readiness (evaluation, bias, latency, size, error handling, compliance)
2. Configures serving infrastructure (TensorFlow Serving, Triton, SageMaker, FastAPI/Ray Serve)
3. Optimizes inference (FP16/INT8 quantization, ONNX, TensorRT, pruning, distillation, batching)
4. Manages model versions with lifecycle (STAGED, CANARY, CHAMPION, SHADOW, ARCHIVED, RETIRED)
5. Runs A/B tests between champion and challenger models with statistical significance
6. Detects data drift (KS test, PSI, chi-squared) and concept drift (performance degradation)
7. Automates retraining with configurable triggers (scheduled, drift-based, performance-based)
8. Provides production monitoring dashboard (traffic, latency, error rate, drift, infrastructure)

## Output
- Deployment config at `configs/mlops/<model>-serving.yaml`
- Monitoring config at `configs/mlops/<model>-monitoring.yaml`
- Commit: `"mlops: <model> v<version> — <action> (<platform>)"`

## Deployment Flow

```
Train (ml) → Readiness Check → Deploy Canary (5%) → A/B Test → Promote Champion
                                                          ↓
                                              Monitor → Drift Detection → Retrain
```

## Key Principles

1. **Shadow before canary, canary before full rollout** — validate at every stage
2. **Monitor continuously** — drift happens gradually, catch it early
3. **Automate retraining, gate deployment** — retraining can be automated but promotion requires validation
4. **Keep rollback instant** — always maintain the previous champion ready to serve
5. **Model version is not code version** — track both independently

## Next Step
If deployed: `/godmode:mlops --status` to monitor health.
If drift detected: `/godmode:ml` to review retraining results.
If A/B test done: `/godmode:mlops --promote` or `--rollback`.

## Examples

```
/godmode:mlops --deploy ticket-classifier-v3.2     # Deploy a model
/godmode:mlops --status                            # Check production health
/godmode:mlops --drift                             # Run drift analysis
/godmode:mlops --rollback                          # Emergency rollback
```
