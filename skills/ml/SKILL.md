---
name: ml
description: ML development and experimentation.
---

## Activate When
- `/godmode:ml`, "train a model", "compare experiments"
- "evaluate model", "check for bias", "dataset quality"
- ML-related code detected (training loops, features)

## Workflow

### 1. Experiment Definition
```
ID: EXP-<YYYY-MM-DD>-<NNN>
Hypothesis: <what you expect and why>
Objective: <metric to optimize>
Baseline: <current best or naive baseline>
Task: classification|regression|ranking|generation
Framework: PyTorch|TensorFlow|scikit-learn|JAX|XGBoost
```
```bash
# Check for ML frameworks
pip list 2>/dev/null | grep -iE "torch|tensorflow|sklearn"
cat requirements.txt 2>/dev/null | grep -iE "torch|tf"
```

### 2. Hyperparameter Management
```yaml
search:
  strategy: grid|random|bayesian|hyperband
  space:
    learning_rate: [1e-5, 1e-4, 1e-3, 1e-2]
    batch_size: [16, 32, 64, 128]
    dropout: uniform(0.1, 0.5)
    hidden_size: [128, 256, 512, 1024]
  trials: <total>
```
IF trials > 50: use Bayesian or Hyperband (not grid).
IF search space > 4 dimensions: use random search minimum.

### 3. Dataset Validation
```
Total samples: <N>
Split: train=<N>(<pct>%) / val=<N>(<pct>%) / test=<N>
Quality checks:
  Missing values: <count per feature>
  Duplicates: <count exact duplicates>
  Outliers: <count, method used>
  Class balance: <ratio of majority/minority>
```
IF class imbalance > 10:1: use stratified sampling
  + class weights or oversampling.
IF missing > 5% for any feature: investigate before
  imputing.

### 4. Bias Detection
```
Protected attributes: <gender, race, age, geography>
Per-attribute:
| Attribute | Group | Samples | Accuracy | FPR | FNR |
IF max_group_accuracy - min_group_accuracy > 5%:
  FLAG bias. Investigate feature correlations.
IF FNR disparity > 10% across groups:
  BLOCK deployment until mitigated.
```

### 5. Training and Tracking
```
Epoch: <current>/<total>
Training loss: <value> (trend: decreasing|plateau)
Validation loss: <value> (trend)
Primary metric: <value> (best: <val> at epoch <N>)
```
IF val_loss increases 3 consecutive epochs: early stop.
IF train_loss << val_loss (gap > 2x): overfitting.

### 6. Model Evaluation
```
Test set: <N samples> (used ONCE for final eval)
Accuracy: <val>  Precision: <val>  Recall: <val>
F1: <val>  AUC-ROC: <val>  AUC-PR: <val>
Statistical significance vs baseline:
  p=<val> (paired bootstrap, 10K iterations)
```
IF p > 0.05: improvement not significant, iterate.
IF improvement < 1% absolute: likely noise.

### 7. Experiment Comparison
```
| Experiment | F1 | AUC | Latency | Size | Params |
Winner selection: best accuracy/latency tradeoff.
```

### 8. Commit and Transition
Commit: `"ml: EXP-<ID> — <metric>=<value> (<delta>)"`
IF best found: -> /godmode:mlops to deploy.
IF bias detected: address before deployment.

## Hard Rules
1. NEVER evaluate on test set during development.
2. EVERY experiment: git SHA, data version, params, seeds.
3. NEVER report without comparing to baseline.
4. NEVER deploy model failing bias checks.
5. ALWAYS test significance (bootstrap, p < 0.05).

## TSV Logging
Append `.godmode/ml-results.tsv`:
```
timestamp	experiment_id	model	metric	baseline	result	status
```

## Keep/Discard
```
KEEP if: significant improvement AND bias passes
  AND no data leakage.
DISCARD if: no significance OR bias violation
  OR leakage found. Log both.
```

## Stop Conditions
```
STOP when FIRST of:
  - Best model beats baseline significantly
  - Bias check passes all attributes
  - 3 consecutive experiments show no improvement
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Worse than baseline | Check leakage, preprocessing, balance |
| Training diverges | Reduce LR 10x, check NaN, normalize |
| Fails in production | Compare data distributions, check drift |
