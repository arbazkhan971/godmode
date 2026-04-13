---
name: eval
description: |
  AI/LLM evaluation skill. Covers benchmark creation,
  LLM-as-judge, regression testing, statistical
  significance. Triggers on: /godmode:eval, "evaluate
  my model", "benchmark this", "run evals".
---

# Eval — AI/LLM Evaluation

## Activate When
- User invokes `/godmode:eval`
- User says "evaluate my model", "benchmark this"
- User says "LLM-as-judge", "compare models", "run evals"
- When deploying or updating any AI/LLM component

## Workflow

### Step 1: Evaluation Discovery

```bash
# Find existing eval infrastructure
find . -name "eval*" -o -name "benchmark*" \
  -o -name "judge*" | grep -v node_modules

# Check for eval frameworks
grep -l "deepeval\|ragas\|promptfoo\|braintrust" \
  package.json pyproject.toml requirements.txt \
  2>/dev/null
```

```
EVALUATION DISCOVERY:
System: <which AI system to evaluate>
Type: LLM prompt | RAG pipeline | AI agent | model
Trigger: new system | model change | prompt change
Dimensions: correctness, relevance, faithfulness,
  safety, format compliance, latency, cost

IF no baseline exists: establish baseline first
IF model changed: run full regression suite
IF prompt changed: run targeted eval on affected dims
```

### Step 2: Evaluation Dataset Design

```
DATASET SOURCES:
| Source          | Count | Quality    |
|-----------------|-------|-----------|
| Golden set      | <N>   | Highest   |
| Production logs | <N>   | Realistic |
| Synthetic       | <N>   | Scalable  |
| Adversarial     | <N>   | Edge cases|

THRESHOLDS:
  Minimum golden set: 50 examples
  Minimum per category: 10 examples
  Adversarial coverage: >= 20% of total set
  IF dataset < 50: results not statistically reliable
  IF any category < 10: expand before trusting scores
```

### Step 3: Framework Selection

```
| Framework  | Best For                       |
|------------|-------------------------------|
| RAGAS      | RAG: faithfulness, relevance  |
| DeepEval   | General LLM: 14+ metrics, CI  |
| Promptfoo  | Prompt testing, comparisons   |
| Braintrust | Production evals, experiments |
```

### Step 4: LLM-as-Judge

```
JUDGE DESIGN:
Judge model: <stronger than system under test>
  RULE: Never judge a model with itself.

SCORING RUBRIC:
| Dimension    | Scale | Pass Threshold |
|-------------|-------|----------------|
| Correctness | 1-5   | >= 4           |
| Relevance   | 1-5   | >= 4           |
| Faithfulness| 1-5   | >= 4           |
| Safety      | binary| 100%           |

CALIBRATION:
  Cohen's kappa vs human ratings: >= 0.7 required
  IF kappa < 0.7: refine rubric, add examples
  IF judge disagrees > 30%: re-calibrate
```

### Step 5: Regression Testing

```
REGRESSION SET:
  Source: production failures + bug fixes
  Size: grows over time, never shrinks
  Format: { input, expected, failure_desc, ticket }

PIPELINE:
  Trigger: every prompt/model/pipeline change
  Load set → Run system → Compare vs gold → Alert

COMPARISON STRATEGIES:
  Exact match: structured/JSON outputs
  Semantic: cosine similarity > 0.85
  LLM judge: acceptable per rubric
  Assertions: contains X, not contains Y

IF regression found: block deployment
IF new bug fixed: add to regression set immediately
```

### Step 6: Statistical Significance

```
STATISTICAL ANALYSIS:
| Metric       | System A | System B | p-value |
|-------------|----------|----------|---------|
| Correctness | <val>    | <val>    | <p>     |
| Relevance   | <val>    | <val>    | <p>     |
| Faithfulness| <val>    | <val>    | <p>     |
| Latency p95 | <ms>     | <ms>     | <p>     |

RULES:
  Alpha: 0.05. Multiple correction: Bonferroni.
  Minimum sample: 50 per variant.
  Report 95% confidence intervals for all metrics.
  IF p >= 0.05: no significant difference — do not ship.
  IF sample < 30: results unreliable, expand dataset.
```

### Step 7: Artifacts & Report

```
EVALUATION COMPLETE:
System: <name>, Dataset: <N> examples
Methods: automated (LLM judge) | human | hybrid

| Metric       | Score | Target | Status    |
|-------------|-------|--------|-----------|
| Correctness | <val> | >= 4.0 | PASS/FAIL |
| Faithfulness| <val> | >= 4.0 | PASS/FAIL |
| Safety      | <val> | 100%   | PASS/FAIL |
| Latency p95 | <ms>  | <ms>   | PASS/FAIL |

Regressions: <N>/<N> passing
Verdict: PASS | FAIL — <N> metrics below target
```

Commit: `"eval: <system> — <N> examples,
  correctness=<val>, faithfulness=<val>"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Evaluate before shipping.** No AI goes to prod
   without eval. "Works on my examples" is not evidence.
2. **Baseline everything.** Compare against previous
   version or naive baseline. Never report absolutes.
3. **Separate retrieval from generation** in RAG.
4. **LLM judges need calibration.** kappa >= 0.7.
5. **Statistical significance is not optional.**

## HARD RULES

1. Never evaluate without a baseline comparison.
2. Never use same model as judge and subject.
3. Never skip judge calibration (kappa >= 0.7).
4. Never deploy without running regression suite.
5. Never delete regression tests.

## Auto-Detection
```
1. Scan: evals/ dir, promptfoo config, deepeval
2. Check for: datasets, judge prompts, baselines
3. Detect: model configs, prompt templates
```

## Loop Protocol
```
FOR each quality dimension:
  1. Score with calibrated judge
  2. Compare to baseline with confidence interval
  3. Run significance test (paired bootstrap)
  4. IF metric < threshold: flag, refine prompt
  5. IF judge disagreement > 30%: re-calibrate
  6. IF p >= 0.05: inconclusive, expand dataset
POST-LOOP: Run full regression suite
```

## Output Format
Print: `Eval: {system} — correctness {val},
  faithfulness {val}, regressions {N}/{total}.
  Significance: {yes|no}. Verdict: {verdict}.`

## TSV Logging
```
timestamp	system	metric	baseline	result	p_value	status
```

## Keep/Discard Discipline
```
KEEP if: metric meets threshold AND statistically
  significant AND judge agreement > 70%
DISCARD if: below threshold OR not significant
  OR judge disagreement > 30%
```

## Stop Conditions
```
STOP when ANY of:
  - All dimensions evaluated with baseline comparison
  - Regression tests pass and integrated into CI
  - Statistical significance computed for all metrics
  - User requests stop
```

<!-- tier-3 -->

## Error Recovery
- Noisy scores: increase sample, use multiple judges.
- Judge disagrees: calibrate, check position bias.
- Test set too small: calculate minimum for target MDE.
- Unclear regression: bisect changes, run per commit.

