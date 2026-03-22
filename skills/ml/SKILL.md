---
name: ml
description: |
  ML development and experimentation skill. Activates when teams need to manage machine learning experiments, track hyperparameters, validate datasets, detect bias, and evaluate models systematically. Provides structured experiment tracking, reproducible training pipelines, and rigorous model evaluation. Triggers on: /godmode:ml, "train a model", "compare experiments", "evaluate model", "check for bias", or when ML workflow needs structure.
---

# ML — ML Development & Experimentation

## When to Activate
- User invokes `/godmode:ml`
- User is training, evaluating, or comparing ML models
- User says "run an experiment", "compare models", "check dataset quality"
- User needs to track hyperparameters or reproduce results
- User asks about model fairness, bias, or data quality
- Godmode orchestrator detects ML-related code (model definitions, training loops, feature engineering)

## Workflow

### Step 1: Experiment Definition

Define the experiment with full reproducibility metadata:

```
EXPERIMENT DEFINITION:
ID: EXP-<YYYY-MM-DD>-<NNN>
Name: <descriptive experiment name>
Hypothesis: <what you expect to happen and why>
Objective: <metric to optimize — e.g., minimize validation loss>
Baseline: <current best model or naive baseline to beat>

Task type: <classification | regression | ranking | generation | clustering | detection>
Dataset: <dataset name and version>
Framework: <PyTorch | TensorFlow | scikit-learn | JAX | XGBoost | custom>
Compute: <local | GPU type | cloud instance type>
Estimated training time: <duration>
```

#### Experiment Registry
```
EXPERIMENT REGISTRY:
┌──────────────────┬────────────┬───────────┬──────────┬──────────┬──────────┐
│ ID               │ Name       │ Status    │ Metric   │ Score    │ vs Base  │
├──────────────────┼────────────┼───────────┼──────────┼──────────┼──────────┤
│ EXP-2025-03-15-1 │ baseline   │ COMPLETE  │ F1       │ 0.847    │ —        │
│ EXP-2025-03-15-2 │ larger-lr  │ COMPLETE  │ F1       │ 0.862    │ +1.8%    │
│ EXP-2025-03-15-3 │ dropout-05 │ RUNNING   │ F1       │ (pending)│ —        │
│ EXP-2025-03-16-1 │ aug-data   │ QUEUED    │ F1       │ —        │ —        │
└──────────────────┴────────────┴───────────┴──────────┴──────────┴──────────┘
```

### Step 2: Hyperparameter Management

Track all hyperparameters with structured configuration:

```yaml
HYPERPARAMETERS:
# Model architecture
model:
  type: <architecture name>
  layers: <layer configuration>
  hidden_size: <N>
  num_heads: <N>          # if transformer
  dropout: <rate>
  activation: <function>

# Training
training:
  optimizer: <Adam | SGD | AdamW | custom>
  learning_rate: <rate>
  lr_schedule: <cosine | linear | step | warmup+decay>
  warmup_steps: <N>
  batch_size: <N>
  epochs: <N>
  max_steps: <N>
  gradient_clipping: <max_norm>
  weight_decay: <rate>
  mixed_precision: <fp16 | bf16 | fp32>

# Regularization
regularization:
  dropout: <rate>
  label_smoothing: <rate>
  data_augmentation: <list of transforms>
  early_stopping:
    patience: <epochs>
    metric: <monitored metric>
    min_delta: <minimum improvement>

# Data
data:
  train_size: <N samples>
  val_size: <N samples>
  test_size: <N samples>
  preprocessing: <list of steps>
  feature_engineering: <list of features>
```

#### Hyperparameter Search
```
HYPERPARAMETER SEARCH:
Strategy: <grid | random | bayesian | hyperband | population-based>
Search space:
  learning_rate: [1e-5, 1e-4, 1e-3, 1e-2]
  batch_size: [16, 32, 64, 128]
  dropout: uniform(0.1, 0.5)
  hidden_size: [128, 256, 512, 1024]

Trials: <total trials>
Completed: <N>
Best trial: <trial ID>
Best params: <parameter values>
Best score: <metric value>

Search visualization:
  learning_rate vs score: <trend description>
  batch_size vs score: <trend description>
  Parameter importance: <ranked list>
```

### Step 3: Dataset Validation

Validate dataset quality before training:

```
DATASET VALIDATION:
Dataset: <name and version>
Total samples: <N>
Split: train=<N> (<pct>%) / val=<N> (<pct>%) / test=<N> (<pct>%)

Schema validation:
  [ ] All required features present
  [ ] Feature types match expected schema
  [ ] No unexpected null/NaN values
  [ ] Value ranges within expected bounds

Quality checks:
  Missing values: <count per feature, percentage>
  Duplicates: <count of exact duplicate rows>
  Outliers: <count per feature, method used>
  Class distribution:
    <class 1>: <N> (<pct>%)
    <class 2>: <N> (<pct>%)
    Imbalance ratio: <ratio>
    Recommendation: <none | oversample | undersample | SMOTE | class weights>

Data leakage checks:
  [ ] No target leakage (features derived from label)
  [ ] No train/test leakage (same entity in both splits)
  [ ] Temporal consistency (no future data in training set)
  [ ] No proxy features that indirectly encode the label

Drift check (vs previous version):
  Feature distributions: <STABLE | DRIFTED — list of drifted features>
  Label distribution: <STABLE | SHIFTED>
  Schema changes: <NONE | ADDED | REMOVED — list>
```

### Step 4: Bias Detection

Systematically check for bias across protected attributes:

```
BIAS DETECTION:
Protected attributes analyzed: <list — e.g., gender, race, age, geography>

Per-attribute analysis:
┌────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ Attribute      │ Group    │ Samples  │ Accuracy │ FPR      │ FNR      │
├────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Gender         │ Male     │ <N>      │ <val>    │ <val>    │ <val>    │
│                │ Female   │ <N>      │ <val>    │ <val>    │ <val>    │
│                │ Non-bin. │ <N>      │ <val>    │ <val>    │ <val>    │
├────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Age group      │ 18-30    │ <N>      │ <val>    │ <val>    │ <val>    │
│                │ 31-50    │ <N>      │ <val>    │ <val>    │ <val>    │
│                │ 51+      │ <N>      │ <val>    │ <val>    │ <val>    │
└────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

Fairness metrics:
  Demographic parity: <value> (threshold: < 0.1 difference)
  Equalized odds: <value> (threshold: < 0.1 difference)
  Predictive parity: <value> (threshold: < 0.1 difference)
  Individual fairness: <value>

Verdict: <PASS | REVIEW REQUIRED | FAIL>
Findings:
  - <bias finding 1 with evidence>
  - <bias finding 2 with evidence>

Mitigation recommendations:
  - <technique 1 — e.g., resampling underrepresented groups>
  - <technique 2 — e.g., adversarial debiasing>
  - <technique 3 — e.g., calibrated equalized odds post-processing>
```

### Step 5: Model Training and Tracking

Execute training with full observability:

```
TRAINING RUN:
Experiment: EXP-<ID>
Started: <timestamp>
Status: <RUNNING | COMPLETE | FAILED | STOPPED>

Progress:
  Epoch: <current>/<total>
  Step: <current>/<total>
  Elapsed: <duration>
  ETA: <estimated remaining>

Live metrics:
  Training loss:    <value> (trend: <decreasing | plateauing | diverging>)
  Validation loss:  <value> (trend: <decreasing | plateauing | increasing>)
  Primary metric:   <value> (best: <value> at epoch <N>)
  Learning rate:    <current LR>
  GPU utilization:  <percentage>
  GPU memory:       <used>/<total>

Checkpoints saved:
  - checkpoint-epoch-<N>: <metric value> <BEST>
  - checkpoint-epoch-<N>: <metric value>
  - checkpoint-latest: <metric value>

Early stopping:
  Patience: <remaining>/<total>
  Best epoch: <N>
  Best metric: <value>
```

### Step 6: Model Evaluation

Rigorous evaluation on held-out test set:

```
MODEL EVALUATION:
Model: <experiment ID and checkpoint>
Test set: <dataset name, N samples>

Classification metrics:
  Accuracy:  <value>
  Precision: <value> (macro | weighted)
  Recall:    <value> (macro | weighted)
  F1 Score:  <value> (macro | weighted)
  AUC-ROC:   <value>
  AUC-PR:    <value>

Per-class metrics:
┌────────────┬───────────┬────────┬──────┬──────────┐
│ Class      │ Precision │ Recall │ F1   │ Support  │
├────────────┼───────────┼────────┼──────┼──────────┤
│ <class 1>  │ <val>     │ <val>  │ <val>│ <N>      │
│ <class 2>  │ <val>     │ <val>  │ <val>│ <N>      │
│ <class 3>  │ <val>     │ <val>  │ <val>│ <N>      │
└────────────┴───────────┴────────┴──────┴──────────┘

Regression metrics (if applicable):
  MAE:   <value>
  RMSE:  <value>
  R2:    <value>
  MAPE:  <value>

Confidence analysis:
  Calibration error (ECE): <value>
  Confidence histogram: <distribution description>
  Prediction entropy: mean=<value>, std=<value>

Error analysis:
  Most confused classes: <class A> <-> <class B> (<N> misclassifications)
  Hardest samples: <description of samples with highest loss>
  Failure modes: <categorized list of error patterns>
```

### Step 7: Experiment Comparison

Compare experiments to select the best model:

```
EXPERIMENT COMPARISON:
┌──────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ Experiment       │ F1       │ AUC-ROC  │ Latency  │ Size     │ Params   │
├──────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ EXP-001 (base)   │ 0.847    │ 0.912    │ 45ms     │ 120MB    │ 12M      │
│ EXP-002 (lr=3e4) │ 0.862    │ 0.928    │ 45ms     │ 120MB    │ 12M      │
│ EXP-003 (large)  │ 0.879    │ 0.941    │ 120ms    │ 450MB    │ 48M      │
│ EXP-004 (dist)   │ 0.871    │ 0.935    │ 38ms     │ 85MB     │ 8M       │
└──────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

Winner: EXP-004 (distilled)
Rationale: Best accuracy/latency tradeoff. 2.8% F1 improvement over baseline
           with 16% lower latency and 30% smaller model size.

Statistical significance:
  EXP-004 vs baseline: p=0.003 (significant at alpha=0.01)
  Method: paired bootstrap test, 10000 iterations
```

### Step 8: Commit and Transition
1. Save experiment results as `docs/ml/EXP-<ID>-results.md`
2. Save best hyperparameters as `configs/ml/EXP-<ID>-params.yaml`
3. Commit: `"ml: EXP-<ID> — <model name> — <primary metric>=<value> (<vs baseline>)"`
4. If best model found: "Experiment complete. Best model: EXP-<ID>. Run `/godmode:mlops` to deploy."
5. If more experiments needed: "Results inconclusive. Recommend trying <suggestion>. Run `/godmode:ml` to continue."
6. If bias detected: "Bias detected in <attribute>. Address before deployment. See mitigation recommendations."

## Key Behaviors

1. **Reproducibility is non-negotiable.** Every experiment must record: code version (git SHA), data version, hyperparameters, random seeds, and environment. Anyone should be able to reproduce the result.
2. **Baselines first.** Never evaluate a model without a baseline. Even a naive baseline (majority class, mean prediction) provides essential context.
3. **Statistical significance matters.** A 0.2% improvement could be noise. Test significance before claiming improvement.
4. **Evaluation on held-out test set.** Never tune hyperparameters on the test set. That is the final, one-time evaluation. Validation set is for tuning.
5. **Bias is a blocker.** A model that performs well on average but poorly for a protected group is not ready to deploy. Check before shipping.
6. **Track negative results.** Failed experiments are valuable. They tell you what does not work and prevent others from repeating dead ends.

## Example Usage

### Running an ML Experiment
```
User: /godmode:ml Train a text classifier for support ticket routing

ML: Setting up experiment...

EXPERIMENT DEFINITION:
ID: EXP-2025-03-15-001
Name: support-ticket-classifier-v1
Hypothesis: Fine-tuned DistilBERT will achieve >0.85 F1 on 12-class ticket routing
Objective: maximize macro F1
Baseline: TF-IDF + LogisticRegression (F1=0.72)
Task: multi-class classification (12 categories)
Dataset: support-tickets-v3 (45,000 labeled tickets)
Framework: PyTorch + HuggingFace Transformers

Validating dataset...
  Schema: OK
  Missing values: 0
  Class distribution: moderate imbalance (ratio 1:8)
  Recommendation: apply class weights
  Leakage check: PASS
  Bias check: analyzing by customer_region and account_tier...

Training with hyperparameters:
  model: distilbert-base-uncased
  learning_rate: 2e-5
  batch_size: 32
  epochs: 10
  early_stopping: patience=3

Training complete. Results:
  F1: 0.873 (+21.3% vs baseline)
  AUC-ROC: 0.952
  Bias check: PASS (all regions within 0.05 F1)

Recommendation: Model exceeds target. Run /godmode:mlops to deploy.
```

### Comparing Experiments
```
User: /godmode:ml --compare EXP-001,EXP-002,EXP-003

ML: Loading experiment results...

<comparison table with metrics, significance tests, and recommendation>
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive experiment setup and tracking |
| `--track` | Track a running experiment (attach to training process) |
| `--compare <ids>` | Compare multiple experiments side by side |
| `--validate <dataset>` | Run dataset validation checks |
| `--bias <dataset>` | Run bias detection on dataset or model predictions |
| `--evaluate <checkpoint>` | Evaluate a model checkpoint on test set |
| `--search <config>` | Run hyperparameter search |
| `--registry` | Show experiment registry |
| `--export <id>` | Export experiment artifacts (model, config, results) |

## Auto-Detection

```
IF directory contains requirements.txt OR setup.py OR pyproject.toml:
  IF contains "torch" OR "tensorflow" OR "scikit-learn" OR "xgboost" OR "jax":
    SUGGEST "ML framework detected. Activate /godmode:ml?"

IF directory contains *.ipynb files:
  notebook_count = count(*.ipynb)
  IF notebook_count > 0:
    SCAN notebooks for model training code (model.fit, trainer.train, etc.)
    IF found:
      SUGGEST "ML training notebooks detected ({notebook_count}). Activate /godmode:ml?"

IF directory contains mlflow/ OR wandb/ OR .dvc/ OR experiments/:
  SUGGEST "ML experiment tracking detected. Activate /godmode:ml?"

IF directory contains data/ AND models/:
  SUGGEST "ML project structure detected (data/ + models/). Activate /godmode:ml?"

IF directory contains configs/ with *.yaml containing "learning_rate" OR "batch_size":
  SUGGEST "ML hyperparameter configs detected. Activate /godmode:ml?"
```

## Iterative Experiment Protocol

```
WHEN running a series of ML experiments:

current_experiment = 0
total_experiments = len(experiment_configs)
results = []
best_score = baseline_score
best_experiment = "baseline"

WHILE current_experiment < total_experiments:
  config = experiment_configs[current_experiment]

  1. VALIDATE dataset (schema, quality, leakage checks)
  2. CONFIGURE hyperparameters from config
  3. TRAIN model with checkpointing
  4. EVALUATE on validation set
  5. CHECK for bias across protected attributes
  6. LOG results to experiment registry

  score = evaluation_result.primary_metric
  IF score > best_score:
    best_score = score
    best_experiment = config.id
    SAVE best checkpoint

  results.append({id: config.id, score: score, vs_baseline: score - baseline_score})
  current_experiment += 1

  IF current_experiment % 5 == 0:
    REPORT "Progress: {current_experiment}/{total_experiments}, best so far: {best_experiment} ({best_score})"

  # Early termination: if last 3 experiments show no improvement
  IF len(results) >= 3 AND all(r.score <= best_score for r in results[-3:]):
    SUGGEST "Last 3 experiments showed no improvement. Consider new approach."

FINAL:
  REPORT experiment comparison table
  RECOMMEND best_experiment with statistical significance test
  IF bias_detected: BLOCK deployment until addressed
```

## Multi-Agent Dispatch

```
WHEN running hyperparameter search OR comparing architectures:

DISPATCH parallel agents in worktrees:

  Agent 1 (experiment-A):
    - Train model with config A (e.g., learning_rate=1e-3, model=base)
    - Full evaluation + bias check
    - Output: results/exp-A.json

  Agent 2 (experiment-B):
    - Train model with config B (e.g., learning_rate=3e-4, model=large)
    - Full evaluation + bias check
    - Output: results/exp-B.json

  Agent 3 (experiment-C):
    - Train model with config C (e.g., distilled model, augmented data)
    - Full evaluation + bias check
    - Output: results/exp-C.json

  Agent 4 (dataset-validation):
    - Run comprehensive dataset quality checks
    - Run bias detection across all protected attributes
    - Output: reports/dataset-quality.md

MERGE:
  - Compare all experiment results side by side
  - Run statistical significance tests between top results
  - Select winner based on metric + latency + size tradeoff
  - Verify winner passes bias checks from Agent 4
```

## HARD RULES

```
1. NEVER evaluate on the test set during development.
   Test set is touched ONCE for final evaluation. Use validation set for tuning.

2. EVERY experiment MUST record: git SHA, data version, hyperparameters,
   random seeds, and environment. Reproducibility is non-negotiable.

3. NEVER report a result without comparing to a baseline.
   Even a majority-class baseline provides essential context.

4. NEVER deploy a model that fails bias checks on any protected attribute.
   Bias is a deployment blocker, not a nice-to-have.

5. ALWAYS test statistical significance before claiming improvement.
   A 0.2% improvement could be noise. Use paired bootstrap (10K iterations).

6. NEVER hardcode hyperparameters in training scripts.
   Use configuration files (YAML/JSON) that are version-controlled.

7. EVERY failed experiment MUST be logged with explanation of why it failed.
   Negative results prevent duplicate wasted effort.

8. ALWAYS check for data leakage before training:
   no target leakage, no train/test overlap, no future data in training.
```

## Output Format

After each ML skill invocation, emit a structured report:

```
ML EXPERIMENT REPORT:
┌──────────────────────────────────────────────────────┐
│  Task type          │  <classification | regression | etc> │
│  Dataset            │  <name> (<N> train / <N> val / <N> test) │
│  Baseline           │  <model> — <metric>: <value>    │
│  Best model         │  <model> — <metric>: <value>    │
│  Improvement        │  +<N>% over baseline             │
│  Experiments run    │  <N>                             │
│  Compute used       │  <N> GPU-hours                   │
│  Bias check         │  PASS / <N> fairness violations  │
│  Data leakage check │  PASS / FAIL                     │
│  Verdict            │  SHIP | ITERATE | INSUFFICIENT DATA │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every experiment for tracking:

```
timestamp	skill	experiment_id	model	metric	baseline	result	improvement	status
2026-03-20T14:00:00Z	ml	exp-001	random_forest	f1	0.72	0.72	0%	baseline
2026-03-20T14:30:00Z	ml	exp-002	xgboost	f1	0.72	0.84	+16.7%	improvement
```

## Success Criteria

The ML skill is complete when ALL of the following are true:
1. Baseline model is established and logged (never skip baseline)
2. Best model beats baseline by a meaningful margin on the primary metric
3. Test set is used exactly once for final evaluation (no tuning on test data)
4. No data leakage detected (no target leakage, no train/test overlap, no future data)
5. Bias/fairness check passes for all relevant subgroups
6. All experiments are logged with hyperparameters, metrics, and outcomes
7. Failed experiments are documented with reasons for failure
8. Model artifacts are versioned and reproducible from logged configuration

## Error Recovery

```
IF model performance is worse than baseline:
  1. Check for data leakage (target leakage, train/test overlap)
  2. Verify data preprocessing is consistent between train and evaluation
  3. Check for class imbalance — switch to stratified sampling and appropriate metrics
  4. Simplify the model (reduce complexity) and verify it can at least match baseline

IF training diverges or loss increases:
  1. Reduce learning rate by 10x
  2. Check for NaN/Inf values in features (missing value handling)
  3. Normalize/standardize features if not already done
  4. Reduce model complexity and verify on a smaller data subset

IF model passes validation but fails in production:
  1. Compare production data distribution with training data distribution
  2. Check for feature drift (features computed differently in production)
  3. Verify feature engineering pipeline is identical between training and serving
  4. Add monitoring for input distribution and prediction distribution

IF bias check reveals fairness violations:
  1. Analyze which subgroups are affected and by how much
  2. Check training data representation for the affected subgroups
  3. Apply mitigation: resampling, reweighting, or fairness-constrained training
  4. Re-evaluate and document the trade-off between overall accuracy and fairness
```

## Anti-Patterns

- **Do NOT skip the baseline.** "Our model has 0.92 F1" means nothing without knowing what a trivial baseline achieves. Always compare.
- **Do NOT tune on test data.** The test set is sacred. Touch it once, for final evaluation. Use validation set for all tuning.
- **Do NOT ignore class imbalance.** Accuracy on imbalanced data is misleading. 95% accuracy is trivial when 95% of samples are one class. Use F1, AUC-PR, or balanced accuracy.
- **Do NOT ship without bias check.** A model that works for most users but fails for a subgroup is a liability. Check fairness metrics.
- **Do NOT hardcode hyperparameters.** Use configuration files. Hardcoded values are not reproducible, searchable, or comparable.
- **Do NOT discard failed experiments.** Log them. Tag them as failed. Explain why. They prevent duplicate wasted effort.


## ML Pipeline Audit

Systematically audit the end-to-end ML pipeline for production readiness:

```
ML PIPELINE AUDIT:
Pipeline: <pipeline name and version>
Audit date: <date>
Auditor: <team or individual>

DATA VALIDATION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Evidence        │
├──────────────────────────────────────────────────────────────────┤
│  Schema enforcement on input data   │ PASS|FAIL│ <schema tool>   │
│  Missing value thresholds defined   │ PASS|FAIL│ <max % allowed> │
│  Feature distribution monitoring    │ PASS|FAIL│ <drift tool>    │
│  Label quality verification         │ PASS|FAIL│ <QA process>    │
│  Data versioning (DVC, LakeFS, etc) │ PASS|FAIL│ <tool + version>│
│  Train/val/test split reproducible  │ PASS|FAIL│ <seed + method> │
│  Data pipeline idempotency tested   │ PASS|FAIL│ <test evidence> │
│  Outlier detection and handling     │ PASS|FAIL│ <method + thresh>│
│  Feature correlation analysis done  │ PASS|FAIL│ <report link>   │
│  Target leakage scan completed      │ PASS|FAIL│ <scan results>  │
└──────────────────────────────────────────────────────────────────┘

MODEL METRICS AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Metric Category    │ Tracked │ Threshold │ Alerting │ Dashboard │
├──────────────────────────────────────────────────────────────────┤
│  Primary metric     │ YES|NO  │ <value>   │ YES|NO   │ YES|NO    │
│  Secondary metrics  │ YES|NO  │ <values>  │ YES|NO   │ YES|NO    │
│  Per-class metrics  │ YES|NO  │ <values>  │ YES|NO   │ YES|NO    │
│  Calibration (ECE)  │ YES|NO  │ <value>   │ YES|NO   │ YES|NO    │
│  Inference latency  │ YES|NO  │ <p99 ms>  │ YES|NO   │ YES|NO    │
│  Prediction distrib │ YES|NO  │ <PSI>     │ YES|NO   │ YES|NO    │
│  Feature importance │ YES|NO  │ N/A       │ NO       │ YES|NO    │
│  Slice-based evals  │ YES|NO  │ <per-grp> │ YES|NO   │ YES|NO    │
│  Cost per prediction│ YES|NO  │ <budget>  │ YES|NO   │ YES|NO    │
└──────────────────────────────────────────────────────────────────┘

EXPERIMENT TRACKING AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Requirement                        │ Status   │ Tool            │
├──────────────────────────────────────────────────────────────────┤
│  All experiments logged centrally   │ PASS|FAIL│ <MLflow|W&B|etc>│
│  Hyperparams recorded per run       │ PASS|FAIL│ <auto or manual>│
│  Git SHA linked to each experiment  │ PASS|FAIL│ <integration>   │
│  Data version linked to each run    │ PASS|FAIL│ <DVC|hash|tag>  │
│  Random seeds stored and replayable │ PASS|FAIL│ <seed strategy> │
│  Environment captured (pip freeze)  │ PASS|FAIL│ <conda|docker>  │
│  Artifact storage (model checkpts)  │ PASS|FAIL│ <S3|GCS|local>  │
│  Comparison dashboards available    │ PASS|FAIL│ <tool URL>      │
│  Failed experiments documented      │ PASS|FAIL│ <log evidence>  │
│  Model lineage traceable end-to-end │ PASS|FAIL│ <from data->prod│
└──────────────────────────────────────────────────────────────────┘

PIPELINE RELIABILITY AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Details         │
├──────────────────────────────────────────────────────────────────┤
│  Pipeline runs on schedule          │ PASS|FAIL│ <cron/trigger>  │
│  Pipeline failures trigger alerts   │ PASS|FAIL│ <alert channel> │
│  Retry logic for transient failures │ PASS|FAIL│ <retry policy>  │
│  Resource limits set (GPU/mem/time) │ PASS|FAIL│ <limits>        │
│  Pipeline DAG is version-controlled │ PASS|FAIL│ <Airflow|Kubeflow│
│  Intermediate outputs cached        │ PASS|FAIL│ <cache strategy>│
│  End-to-end pipeline test exists    │ PASS|FAIL│ <test details>  │
│  Pipeline runs are idempotent       │ PASS|FAIL│ <verified how>  │
└──────────────────────────────────────────────────────────────────┘

AUDIT VERDICT: <PASS — pipeline production-ready | FAIL — <N> items to fix>
Priority fixes:
  1. <highest priority issue>
  2. <second priority issue>
  3. <third priority issue>
```

### ML Pipeline Audit Loop

```
ML AUDIT ITERATION:
current_category = 0
categories = [data_validation, model_metrics, experiment_tracking, pipeline_reliability]
findings = []

WHILE current_category < len(categories):
  category = categories[current_category]

  1. SCAN pipeline for all checks in category
  2. RECORD status (PASS/FAIL) with evidence for each check
  3. IDENTIFY root cause for each FAIL
  4. PRIORITIZE fixes by blast radius (data issues > metric gaps > tracking gaps)

  IF category has > 3 FAIL items:
    HALT "Category {category} has critical gaps. Fix before proceeding."
    FIX top 3 issues
    RE-AUDIT category before moving to next

  findings.append({category, pass_count, fail_count, critical_items})
  current_category += 1

FINAL:
  GENERATE audit report with all findings
  CALCULATE audit score: total_pass / total_checks * 100
  IF audit_score < 80%: "Pipeline NOT production-ready. Address {fail_count} issues."
  IF audit_score >= 80% AND audit_score < 95%: "Pipeline conditionally ready. Address {critical_count} critical items."
  IF audit_score >= 95%: "Pipeline production-ready. Schedule next audit in 30 days."
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run ML experiments sequentially: experiment A, then experiment B, then experiment C. Compare results after all complete.
- Use branch isolation per task: `git checkout -b godmode-ml-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
