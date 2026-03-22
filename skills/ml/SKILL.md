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
# ... (condensed)
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive experiment setup and tracking |
| `--track` | Track a running experiment (attach to training process) |
| `--compare <ids>` | Compare multiple experiments side by side |

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
```

## Keep/Discard Discipline
```
After EACH experiment run:
  1. MEASURE: Evaluate on validation set — primary metric, secondary metrics, bias check.
  2. COMPARE: Is the improvement over baseline statistically significant (paired bootstrap, p < 0.05)?
  3. DECIDE:
     - KEEP if: significant improvement AND bias check passes AND no data leakage detected
     - DISCARD if: no significant improvement OR bias violation OR data leakage found
  4. LOG both kept and discarded experiments with full hyperparameters and metrics.

Never promote a model that fails bias checks, regardless of primary metric improvement.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Best model beats baseline by a meaningful, statistically significant margin
  - Bias check passes for all protected attributes
  - User explicitly requests stop
  - 3 consecutive experiments show no improvement (suggest new approach)

DO NOT STOP just because:
  - A single metric plateaued (check other metrics and error analysis first)
  - Training takes a long time (schedule it, do not skip it)
```

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
```

### ML Pipeline Audit Loop

```
categories = [data_validation, model_metrics, experiment_tracking, pipeline_reliability]

FOR each category:
  1. SCAN pipeline for all checks in category
  2. RECORD status (PASS/FAIL) with evidence
  3. PRIORITIZE fixes: data issues > metric gaps > tracking gaps
  4. IF > 3 FAIL items: fix top 3 before moving to next category

SCORING:
  audit_score = total_pass / total_checks * 100
  < 80%: NOT production-ready
  80-95%: conditionally ready (fix critical items)
  >= 95%: production-ready (next audit in 30 days)
```

