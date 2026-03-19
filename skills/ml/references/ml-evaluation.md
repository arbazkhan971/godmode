# ML Evaluation Reference

> Metric selection guide by problem type, cross-validation strategies, statistical significance testing, and bias and fairness metrics.

---

## Metric Selection by Problem Type

### Binary Classification

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  When to Use                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  Accuracy            │  Balanced classes only. Misleading when classes are       │
│                      │  imbalanced (99% accuracy by always predicting majority). │
│                      │  Formula: (TP + TN) / (TP + TN + FP + FN)               │
│                      │                                                          │
│  Precision           │  When false positives are costly.                         │
│                      │  "Of all predicted positive, how many are truly positive?"│
│                      │  Example: Spam filter (don't mark real email as spam).    │
│                      │  Formula: TP / (TP + FP)                                 │
│                      │                                                          │
│  Recall (Sensitivity)│  When false negatives are costly.                         │
│                      │  "Of all actual positive, how many did we catch?"         │
│                      │  Example: Cancer screening (don't miss real cancer).      │
│                      │  Formula: TP / (TP + FN)                                 │
│                      │                                                          │
│  F1 Score            │  When you need a balance between precision and recall.    │
│                      │  Harmonic mean; punishes extreme imbalance between P/R.   │
│                      │  Formula: 2 * (P * R) / (P + R)                          │
│                      │                                                          │
│  F-beta Score        │  When you want to weight precision vs. recall.            │
│                      │  beta < 1: weight precision more.                         │
│                      │  beta > 1: weight recall more.                            │
│                      │  F2: recall twice as important. F0.5: precision twice.    │
│                      │                                                          │
│  AUC-ROC             │  When you need a threshold-independent measure.           │
│                      │  Probability that model ranks a random positive higher    │
│                      │  than a random negative. Robust to class imbalance.       │
│                      │  Range: 0.5 (random) to 1.0 (perfect).                   │
│                      │                                                          │
│  AUC-PR              │  Imbalanced datasets where positives are rare.            │
│                      │  More informative than AUC-ROC when negative class        │
│                      │  dominates. Precision-Recall curve area.                  │
│                      │                                                          │
│  Log Loss            │  When calibrated probabilities matter (not just ranking). │
│                      │  Penalizes confident wrong predictions heavily.           │
│                      │  Used in: betting, risk scoring, decision systems.        │
│                      │  Formula: -1/N * sum(y*log(p) + (1-y)*log(1-p))          │
│                      │                                                          │
│  MCC                 │  Most informative single metric for binary classification.│
│  (Matthews           │  Uses all four confusion matrix values. Works well even   │
│   Correlation Coeff) │  with imbalanced datasets. Range: -1 to 1.               │
│                      │  Formula: (TP*TN - FP*FN) /                              │
│                      │           sqrt((TP+FP)(TP+FN)(TN+FP)(TN+FN))             │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

**Decision guide:**

```
What matters most?
├── Balanced classes, simple requirement → Accuracy
├── False positives are expensive → Precision (or F0.5)
├── False negatives are expensive → Recall (or F2)
├── Need balance of P and R → F1
├── Need threshold-independent ranking → AUC-ROC
├── Rare positive class → AUC-PR or MCC
├── Need calibrated probabilities → Log Loss
└── Single best overall metric → MCC
```

### Multi-Class Classification

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  Description                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  Macro-Average       │  Compute metric per class, then average. Treats all       │
│  (Precision, Recall, │  classes equally regardless of size.                      │
│   F1)                │  Use when: All classes are equally important.              │
│                      │                                                          │
│  Weighted-Average    │  Compute metric per class, average weighted by class      │
│                      │  support (number of samples). Accounts for imbalance.     │
│                      │  Use when: Class sizes differ and larger classes matter.   │
│                      │                                                          │
│  Micro-Average       │  Aggregate TP, FP, FN globally, then compute.             │
│                      │  Equivalent to accuracy for multi-class.                  │
│                      │  Use when: Per-sample accuracy matters most.              │
│                      │                                                          │
│  Confusion Matrix    │  Full NxN matrix showing predicted vs. actual per class.  │
│                      │  Essential for understanding per-class errors.             │
│                      │                                                          │
│  Cohen's Kappa       │  Agreement beyond chance. Adjusts for random agreement.   │
│                      │  Range: -1 to 1. >0.8 is excellent.                       │
│                      │  Use when: Comparing to random or baseline classifier.     │
│                      │                                                          │
│  Top-K Accuracy      │  Correct if true class is in top K predictions.           │
│                      │  Use when: Multiple valid answers (image classification).  │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

### Regression

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  When to Use                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  MSE                 │  When large errors are disproportionately bad.            │
│  (Mean Squared Error)│  Penalizes outliers heavily (squared term).               │
│                      │  Formula: 1/N * sum((y - y_hat)^2)                       │
│                      │                                                          │
│  RMSE                │  Same as MSE but in original units (interpretable).       │
│  (Root MSE)          │  "Average prediction is off by RMSE units."               │
│                      │  Formula: sqrt(MSE)                                       │
│                      │                                                          │
│  MAE                 │  When all errors are equally bad (not just large ones).   │
│  (Mean Abs. Error)   │  More robust to outliers than MSE/RMSE.                  │
│                      │  Formula: 1/N * sum(|y - y_hat|)                         │
│                      │                                                          │
│  MAPE               │  When relative error matters (percentage-based).           │
│  (Mean Abs. % Error) │  Caution: undefined when y=0, biased toward              │
│                      │  under-prediction.                                        │
│                      │  Formula: 1/N * sum(|y - y_hat| / |y|) * 100             │
│                      │                                                          │
│  R-squared           │  Proportion of variance explained by the model.           │
│  (Coeff. of Determ.) │  Range: -inf to 1. 1 = perfect, 0 = predicts mean,       │
│                      │  <0 = worse than predicting mean.                         │
│                      │  Formula: 1 - SS_res / SS_tot                             │
│                      │                                                          │
│  Adjusted R-squared  │  R-squared penalized for number of features.              │
│                      │  Use when comparing models with different feature counts. │
│                      │                                                          │
│  Huber Loss          │  Hybrid: MSE for small errors, MAE for large errors.      │
│                      │  Robust to outliers while still differentiable.            │
│                      │  Controlled by delta parameter.                            │
│                      │                                                          │
│  Quantile Loss       │  When you care about specific percentiles of prediction.  │
│                      │  Asymmetric penalty: weight over/under-prediction          │
│                      │  differently. Used in demand forecasting.                  │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

### Ranking / Recommendation

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  When to Use                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  NDCG                │  When position in ranking matters (top results more       │
│  (Normalized         │  important). Standard for search and recommendation.      │
│   Discounted         │  Range: 0 to 1. Logarithmic discount for lower positions.│
│   Cumulative Gain)   │                                                          │
│                      │                                                          │
│  MAP                 │  Mean of average precision across queries.                │
│  (Mean Average       │  Good for information retrieval with binary relevance.    │
│   Precision)         │  Emphasizes ranking relevant items higher.                │
│                      │                                                          │
│  MRR                 │  Mean of reciprocal rank of first relevant result.        │
│  (Mean Reciprocal    │  Use when only the top result matters.                    │
│   Rank)              │  Example: question answering, "I'm feeling lucky" search. │
│                      │                                                          │
│  Hit Rate @ K        │  Fraction of queries with at least one relevant item      │
│                      │  in top K. Simple but useful for recommendations.         │
│                      │                                                          │
│  Precision @ K       │  Fraction of top K results that are relevant.             │
│  Recall @ K          │  Fraction of all relevant items in top K.                 │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

### Object Detection / Segmentation

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  When to Use                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  mAP                 │  Standard for object detection (COCO, VOC).               │
│  (mean Average       │  Average precision across all classes and IoU thresholds. │
│   Precision)         │  mAP@0.5: IoU threshold 0.5. mAP@[.5:.95]: COCO style.  │
│                      │                                                          │
│  IoU                 │  Overlap between predicted and ground truth bounding box. │
│  (Intersection over  │  Range: 0 (no overlap) to 1 (perfect overlap).           │
│   Union)             │  Threshold for "correct" detection: usually 0.5 or 0.75. │
│                      │                                                          │
│  Dice Coefficient    │  Segmentation overlap metric. Similar to F1.              │
│                      │  Formula: 2 * |A ∩ B| / (|A| + |B|)                      │
│                      │  Commonly used in medical image segmentation.             │
│                      │                                                          │
│  Pixel Accuracy      │  Fraction of correctly classified pixels.                 │
│                      │  Misleading with imbalanced classes (large background).   │
│                      │                                                          │
│  Mean IoU            │  Average IoU across all classes. Standard for semantic    │
│                      │  segmentation (Cityscapes, ADE20K benchmarks).            │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

### NLP / Generation

```
┌──────────────────────┬──────────────────────────────────────────────────────────┐
│  Metric              │  When to Use                                              │
├──────────────────────┼──────────────────────────────────────────────────────────┤
│  Perplexity          │  Language model quality. Lower = better.                  │
│                      │  Measures how "surprised" the model is by the test set.   │
│                      │                                                          │
│  BLEU                │  Machine translation. N-gram overlap with reference.      │
│                      │  Range: 0-1 (often 0-100). Focuses on precision.          │
│                      │  Limitation: does not capture fluency or meaning.         │
│                      │                                                          │
│  ROUGE               │  Summarization. Measures recall of reference n-grams.     │
│                      │  ROUGE-1 (unigrams), ROUGE-2 (bigrams), ROUGE-L (LCS).   │
│                      │                                                          │
│  BERTScore           │  Semantic similarity using contextual embeddings.          │
│                      │  Better than BLEU/ROUGE for capturing meaning.             │
│                      │                                                          │
│  Human evaluation    │  The gold standard for generation quality.                 │
│                      │  Measures fluency, relevance, faithfulness, etc.           │
│                      │  Expensive but essential for production systems.            │
│                      │                                                          │
│  Exact Match (EM)    │  Question answering. Binary: predicted answer matches     │
│                      │  ground truth exactly (after normalization).               │
│                      │                                                          │
│  Token-level F1      │  QA and NER. Overlap between predicted and gold tokens.   │
└──────────────────────┴──────────────────────────────────────────────────────────┘
```

---

## Cross-Validation Strategies

### K-Fold Cross-Validation

```
K-FOLD (K=5):
┌───────────────────────────────────────────────────────────────┐
│  Fold 1: [TEST] [Train] [Train] [Train] [Train]              │
│  Fold 2: [Train] [TEST] [Train] [Train] [Train]              │
│  Fold 3: [Train] [Train] [TEST] [Train] [Train]              │
│  Fold 4: [Train] [Train] [Train] [TEST] [Train]              │
│  Fold 5: [Train] [Train] [Train] [Train] [TEST]              │
│                                                                │
│  Final score = mean(fold_scores)                               │
│  Uncertainty = std(fold_scores)                                │
└───────────────────────────────────────────────────────────────┘

When to use: General-purpose, sufficient data (>1000 samples).
K=5 or K=10 is standard.
```

### Stratified K-Fold

```
STRATIFIED K-FOLD:
  Same as K-Fold, but each fold preserves the class distribution.

  Dataset: 90% negative, 10% positive
  Each fold: 90% negative, 10% positive (preserved)

  When to use: ALWAYS for classification tasks, especially imbalanced.
  Standard K-Fold can create folds with zero positive samples.
```

### Leave-One-Out (LOO)

```
LOO:
  K = N (one fold per sample).

  When to use: Very small datasets (<100 samples).
  Warning: Computationally expensive (N model trainings).
  High variance in estimate.
```

### Time-Series Split

```
TIME-SERIES SPLIT (expanding window):
┌───────────────────────────────────────────────────────────────┐
│  Fold 1: [Train]           [TEST]                             │
│  Fold 2: [Train    Train]  [TEST]                             │
│  Fold 3: [Train    Train    Train]  [TEST]                    │
│  Fold 4: [Train    Train    Train    Train]  [TEST]           │
│                                                                │
│  NEVER use future data to predict the past.                   │
│  Training window expands; test window slides forward.          │
└───────────────────────────────────────────────────────────────┘

SLIDING WINDOW VARIANT:
┌───────────────────────────────────────────────────────────────┐
│  Fold 1: [Train    Train]  [TEST]                             │
│  Fold 2:           [Train    Train]  [TEST]                   │
│  Fold 3:                    [Train    Train]  [TEST]          │
│                                                                │
│  Fixed-size training window slides forward.                    │
│  Better when older data becomes less relevant.                 │
└───────────────────────────────────────────────────────────────┘

When to use: ANY time-series or temporal data. Violating temporal
order causes data leakage and inflated metrics.
```

### Group K-Fold

```
GROUP K-FOLD:
  Ensures all samples from the same group are in the same fold.

  Example: Medical data — all images from Patient A in one fold.
  Prevents data leakage from correlated samples.

  When to use:
  - Multiple samples per user/patient/entity
  - Geographic data (all readings from same sensor in one fold)
  - Document-level splits for sentence-level tasks
```

### Nested Cross-Validation

```
NESTED CV (for hyperparameter tuning + evaluation):
┌──────────────────────────────────────────────────────────────────┐
│  Outer Loop (K=5): Evaluate final model performance              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │  Inner Loop (K=3): Hyperparameter tuning                   │  │
│  │                                                             │  │
│  │  For each outer fold:                                       │  │
│  │    Split outer-train into inner folds                       │  │
│  │    Grid/random search across inner folds                    │  │
│  │    Select best hyperparameters                              │  │
│  │    Train on full outer-train with best params               │  │
│  │    Evaluate on outer-test fold                              │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  Result: Unbiased estimate of generalization performance          │
│  with tuned hyperparameters.                                      │
└──────────────────────────────────────────────────────────────────┘

When to use: When you need an honest performance estimate AND
hyperparameter tuning. Prevents optimistic bias from tuning on test set.
```

### CV Strategy Selection Guide

```
┌──────────────────────────┬──────────────────────────────────────────────┐
│  Situation               │  Recommended Strategy                         │
├──────────────────────────┼──────────────────────────────────────────────┤
│  Classification          │  Stratified K-Fold (K=5 or 10)               │
│  Regression              │  K-Fold (K=5 or 10)                          │
│  Time series             │  Time-Series Split (NEVER shuffle)           │
│  Small dataset (<200)    │  Leave-One-Out or Repeated Stratified K-Fold │
│  Grouped data            │  Group K-Fold                                 │
│  Hyperparameter tuning   │  Nested CV (outer=5, inner=3)                │
│  Large dataset (>100K)   │  Single train/val/test split (60/20/20)      │
│  Imbalanced classes      │  Stratified K-Fold + class-weighted metrics   │
└──────────────────────────┴──────────────────────────────────────────────┘
```

---

## Statistical Significance Testing

### When to Test

```
ALWAYS test statistical significance when:
- Comparing two models (is Model B actually better than Model A?)
- Reporting performance improvements (is the improvement real or noise?)
- A/B testing model deployments (does the new model help users?)
- Publishing results (reviewers will ask)

SIGNIFICANCE ≠ PRACTICAL IMPORTANCE:
- A model may be statistically significantly better (p < 0.05)
  but the improvement is 0.1% accuracy — practically meaningless.
- Always report effect size alongside significance.
```

### McNemar's Test (Classification)

```
McNEMAR'S TEST:
  Compares two classifiers on the SAME test set.
  Tests whether they make different types of errors.

  Contingency table:
  ┌───────────────────┬──────────────┬──────────────┐
  │                   │ Model B      │ Model B      │
  │                   │ Correct      │ Wrong        │
  ├───────────────────┼──────────────┼──────────────┤
  │ Model A Correct   │     a        │     b        │
  │ Model A Wrong     │     c        │     d        │
  └───────────────────┴──────────────┴──────────────┘

  H0: b = c (models make the same errors)
  chi2 = (|b - c| - 1)^2 / (b + c)
  df = 1

  If p < 0.05: models are significantly different.

  When to use: Comparing two classifiers on the same data.
  Better than comparing accuracy values directly.
```

### Paired t-Test (Cross-Validation Results)

```
PAIRED t-TEST:
  Compares mean performance across K-Fold CV.

  d_i = score_A_i - score_B_i  (difference per fold)
  t = mean(d) / (std(d) / sqrt(K))
  df = K - 1

  If p < 0.05: one model is significantly better.

  WARNING: K-Fold scores are NOT independent (overlapping training data).
  The test may be anti-conservative (too many false positives).

  BETTER ALTERNATIVE: Corrected resampled t-test or 5x2cv paired t-test.
```

### Bootstrap Confidence Intervals

```
BOOTSTRAP CI:
  1. Sample N items with replacement from test set (N = test set size)
  2. Compute metric on bootstrap sample
  3. Repeat B times (B = 1000-10000)
  4. Sort the B metric values
  5. 95% CI = [2.5th percentile, 97.5th percentile]

  Model A: Accuracy = 0.87 [0.84, 0.90]
  Model B: Accuracy = 0.89 [0.86, 0.92]

  If CIs overlap significantly: difference may not be significant.
  If CIs do not overlap: strong evidence of a real difference.

  When to use: Any metric, any model comparison. Non-parametric,
  no distribution assumptions. Works with any metric.
```

### Permutation Test

```
PERMUTATION TEST:
  1. Compute observed difference: d_obs = metric_A - metric_B
  2. For i = 1 to N_perm (e.g., 10000):
     a. Randomly swap predictions between Model A and B
     b. Compute metric difference: d_i
  3. p-value = fraction of d_i >= d_obs

  Advantage: No distributional assumptions. Exact test.
  Disadvantage: Computationally expensive.

  When to use: Gold standard for comparing two models.
  Works when other test assumptions are violated.
```

### Bonferroni Correction (Multiple Comparisons)

```
MULTIPLE COMPARISONS:
  When comparing K models, the chance of at least one false positive:
    1 - (1 - 0.05)^K

  For K=10 comparisons: 1 - 0.95^10 = 40% chance of false positive!

  BONFERRONI CORRECTION:
    Adjusted alpha = 0.05 / K

  For K=10: use alpha = 0.005 per comparison.

  More powerful alternatives:
  - Holm-Bonferroni (less conservative, sequential)
  - Benjamini-Hochberg (controls false discovery rate, not FWER)
  - Nemenyi test (post-hoc after Friedman test for K models)
```

### Effect Size

```
EFFECT SIZES (report alongside p-values):
┌──────────────────────┬────────────────────────────────────────────────┐
│  Metric              │  Interpretation                                 │
├──────────────────────┼────────────────────────────────────────────────┤
│  Cohen's d           │  Standardized mean difference.                  │
│                      │  Small: 0.2, Medium: 0.5, Large: 0.8          │
│                      │  d = (mean_A - mean_B) / pooled_std            │
│                      │                                                │
│  Absolute improvement│  Direct metric difference.                      │
│                      │  "Model B is 2.3% more accurate than Model A." │
│                      │                                                │
│  Relative improvement│  Percentage change.                             │
│                      │  "Model B reduces error by 15% vs. Model A."   │
│                      │  Better for communicating practical impact.     │
└──────────────────────┴────────────────────────────────────────────────┘
```

---

## Bias and Fairness Metrics

### Definitions

```
PROTECTED ATTRIBUTES:
  Characteristics that should not affect model decisions.
  Examples: race, gender, age, disability, religion, national origin.

PRIVILEGED GROUP:
  The group historically or currently advantaged.

UNPRIVILEGED GROUP:
  The group historically or currently disadvantaged.

FAVORABLE OUTCOME:
  The outcome that benefits the individual (loan approved, hired, etc.).
```

### Group Fairness Metrics

```
┌──────────────────────────┬───────────────────────────────────────────────────┐
│  Metric                  │  Definition & Interpretation                       │
├──────────────────────────┼───────────────────────────────────────────────────┤
│  Demographic Parity      │  P(Y_hat=1 | A=0) = P(Y_hat=1 | A=1)             │
│  (Statistical Parity)    │  Approval rate should be equal across groups.      │
│                          │  "Equal proportion of each group gets positive     │
│                          │   outcome."                                        │
│                          │  Limitation: ignores actual qualification rates.   │
│                          │                                                   │
│  Equalized Odds          │  P(Y_hat=1 | Y=1, A=0) = P(Y_hat=1 | Y=1, A=1)  │
│                          │  AND                                               │
│                          │  P(Y_hat=1 | Y=0, A=0) = P(Y_hat=1 | Y=0, A=1)  │
│                          │  Equal TPR AND FPR across groups.                  │
│                          │  "Equally good at identifying positives and not    │
│                          │   making false positive errors across groups."     │
│                          │                                                   │
│  Equal Opportunity       │  P(Y_hat=1 | Y=1, A=0) = P(Y_hat=1 | Y=1, A=1)  │
│                          │  Equal TPR across groups (relaxed equalized odds). │
│                          │  "Equally good at identifying qualified people     │
│                          │   across groups."                                  │
│                          │                                                   │
│  Predictive Parity       │  P(Y=1 | Y_hat=1, A=0) = P(Y=1 | Y_hat=1, A=1)  │
│                          │  Equal precision across groups.                    │
│                          │  "When the model says yes, it's equally likely     │
│                          │   to be correct for all groups."                   │
│                          │                                                   │
│  Calibration             │  P(Y=1 | S=s, A=0) = P(Y=1 | S=s, A=1) for all s│
│                          │  Equal calibration curves across groups.           │
│                          │  "A score of 0.8 means 80% probability for all    │
│                          │   groups."                                         │
│                          │                                                   │
│  Treatment Equality      │  FN/FP ratio is equal across groups.              │
│                          │  "The ratio of types of errors is the same."       │
└──────────────────────────┴───────────────────────────────────────────────────┘

IMPOSSIBILITY THEOREM:
  It is mathematically impossible to satisfy Demographic Parity,
  Equalized Odds, AND Predictive Parity simultaneously
  (except when base rates are equal across groups or the model is perfect).
  You MUST choose which fairness definition matters most for your context.
```

### Individual Fairness Metrics

```
┌──────────────────────────┬───────────────────────────────────────────────────┐
│  Metric                  │  Definition                                        │
├──────────────────────────┼───────────────────────────────────────────────────┤
│  Individual Fairness     │  Similar individuals should receive similar         │
│                          │  predictions.                                      │
│                          │  D(f(x_i), f(x_j)) <= L * d(x_i, x_j)            │
│                          │  Requires defining a meaningful similarity metric. │
│                          │                                                   │
│  Counterfactual Fairness │  Prediction should not change if the protected     │
│                          │  attribute were different (holding everything else │
│                          │  constant via causal model).                       │
│                          │  Requires a causal graph.                          │
└──────────────────────────┴───────────────────────────────────────────────────┘
```

### Disparity Metrics

```
DISPARITY MEASURES:
┌──────────────────────────┬───────────────────────────────────────────────────┐
│  Measure                 │  Formula & Threshold                               │
├──────────────────────────┼───────────────────────────────────────────────────┤
│  Disparate Impact Ratio  │  P(Y_hat=1 | unprivileged) /                      │
│                          │  P(Y_hat=1 | privileged)                           │
│                          │                                                   │
│                          │  Four-fifths rule: ratio should be >= 0.8          │
│                          │  (U.S. EEOC guideline for employment).             │
│                          │                                                   │
│  Statistical Parity      │  P(Y_hat=1 | unprivileged) -                      │
│  Difference              │  P(Y_hat=1 | privileged)                           │
│                          │                                                   │
│                          │  Fair if close to 0. Range: -1 to 1.              │
│                          │                                                   │
│  Average Odds Difference │  0.5 * [(FPR_unpriv - FPR_priv) +                 │
│                          │         (TPR_unpriv - TPR_priv)]                   │
│                          │                                                   │
│                          │  Fair if close to 0.                               │
└──────────────────────────┴───────────────────────────────────────────────────┘
```

### Bias Detection Workflow

```
BIAS AUDIT WORKFLOW:
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  1. DEFINE                                                                  │
│     ├── Identify protected attributes in the data                          │
│     ├── Define favorable/unfavorable outcomes                              │
│     ├── Choose fairness metrics appropriate to the context                 │
│     └── Set acceptable thresholds (e.g., DI ratio >= 0.8)                  │
│                                                                             │
│  2. MEASURE                                                                 │
│     ├── Compute all fairness metrics across all protected groups            │
│     ├── Disaggregate performance metrics by group                           │
│     │   (accuracy, FPR, FNR, precision, recall per group)                  │
│     ├── Check intersectional groups (e.g., race x gender)                  │
│     └── Visualize metric distributions across groups                        │
│                                                                             │
│  3. MITIGATE (if bias detected)                                             │
│     ├── Pre-processing:                                                     │
│     │   ├── Reweighting: adjust sample weights to balance outcomes          │
│     │   ├── Resampling: over/undersample to equalize representation        │
│     │   └── Disparate impact remover: transform features                    │
│     ├── In-processing:                                                      │
│     │   ├── Adversarial debiasing: add fairness constraint to loss         │
│     │   ├── Prejudice remover: add regularization term for fairness        │
│     │   └── Constrained optimization: optimize with fairness constraints   │
│     └── Post-processing:                                                    │
│         ├── Threshold adjustment: different thresholds per group            │
│         ├── Reject option classification: defer uncertain predictions       │
│         └── Calibrated equalized odds: adjust scores post-hoc              │
│                                                                             │
│  4. VALIDATE                                                                │
│     ├── Re-measure all fairness metrics after mitigation                    │
│     ├── Check that overall performance did not degrade unacceptably         │
│     ├── Document trade-offs between fairness and performance                │
│     └── Establish ongoing monitoring in production                          │
│                                                                             │
│  5. MONITOR (production)                                                    │
│     ├── Track fairness metrics continuously                                 │
│     ├── Alert on metric drift by group                                     │
│     ├── Regular bias audits on new data                                    │
│     └── Feedback loops: monitor for disparate real-world outcomes           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Fairness Metric Selection Guide

```
CHOOSING THE RIGHT FAIRNESS METRIC:
┌──────────────────────────┬──────────────────────────────────────────────┐
│  Context                 │  Recommended Metric                           │
├──────────────────────────┼──────────────────────────────────────────────┤
│  Loan approval           │  Equal Opportunity + Disparate Impact Ratio   │
│                          │  (qualified people should be approved equally)│
│                          │                                               │
│  Criminal risk assess.   │  Equalized Odds                               │
│                          │  (equal TPR and FPR across groups is critical)│
│                          │                                               │
│  Hiring                  │  Demographic Parity + 4/5ths rule             │
│                          │  (legal compliance, EEOC guidelines)          │
│                          │                                               │
│  Medical diagnosis       │  Equal Opportunity (sensitivity)              │
│                          │  (must catch disease equally across groups)   │
│                          │                                               │
│  Ad targeting            │  Demographic Parity                           │
│                          │  (opportunities shown equally)                │
│                          │                                               │
│  Credit scoring          │  Calibration                                  │
│                          │  (scores should mean the same for all groups) │
│                          │                                               │
│  Content moderation      │  Equalized Odds                               │
│                          │  (false positive rates equal across groups)   │
└──────────────────────────┴──────────────────────────────────────────────┘
```

---

## Common Evaluation Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Test set leakage | Model sees test data during training (inflated metrics) | Strict train/val/test split before any preprocessing |
| Reporting accuracy on imbalanced data | 99% accuracy by predicting majority class | Use F1, AUC-PR, MCC for imbalanced problems |
| No confidence intervals | Cannot tell if improvement is real | Bootstrap CI or cross-validation standard deviation |
| Comparing single-run results | Random seeds affect results | Average over multiple runs, report std |
| Tuning on test set | Overfitting to test set | Nested CV or separate holdout for tuning |
| Ignoring class distribution in CV | Folds with no positive samples | Always use stratified K-Fold for classification |
| Shuffling time series data | Future data leaks into training | Use time-series split, never shuffle temporal data |
| Using BLEU/ROUGE as sole NLP metric | Misses semantic quality | Combine with BERTScore and human evaluation |
| Fairness as afterthought | Bias discovered in production | Include fairness metrics in initial evaluation |
| Single fairness metric | Different biases are hidden | Report multiple fairness metrics, disaggregate by group |
