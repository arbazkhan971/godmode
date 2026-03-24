---
name: eval
description: |
  AI/LLM evaluation skill. Activates when users need to evaluate, benchmark, or test AI systems. Covers evaluation framework design, benchmark creation, human evaluation protocols, automated evaluation (LLM-as-judge), regression testing for AI outputs, statistical significance, and evaluation pipelines. Every AI system gets a structured evaluation suite, baseline metrics, and regression test set. Triggers on: /godmode:eval, "evaluate my model", "benchmark this", "is my AI getting worse", or when the orchestrator detects evaluation needs.
---

# Eval — AI/LLM Evaluation

## When to Activate
- User invokes `/godmode:eval`
- User says "evaluate my model", "benchmark this", "test my AI"
- User says "is my LLM getting worse", "compare models", "run evals"
- User says "set up evaluation", "create a benchmark", "LLM-as-judge"
- When `/godmode:prompt` needs evaluation of prompt quality
- When `/godmode:rag` needs retrieval or generation evaluation
- When `/godmode:agent` needs trajectory and task completion evaluation
- When deploying or updating any AI/LLM component
- When the orchestrator detects AI outputs that need quality measurement

## Workflow

### Step 1: Evaluation Discovery
Understand what needs to be evaluated and why:

```
EVALUATION DISCOVERY:
System under test: <which AI system to evaluate>
  Type: <LLM prompt | RAG pipeline | AI agent | fine-tuned model | full application>
  Model: <underlying model(s)>
  Current version: <version or commit>

Evaluation trigger:
  - New system: establishing baseline metrics
  - Model change: upgrading or switching models
  - Prompt change: modified system prompt or few-shot examples
  - Pipeline change: new retrieval strategy, chunking, reranking
  - Regression check: periodic quality verification
  ...
```
If the user hasn't specified, ask: "What AI system should I evaluate, and what quality dimensions matter most?"

### Step 2: Evaluation Dataset Design
Create or curate the evaluation dataset:

```
EVALUATION DATASET DESIGN:

Dataset sources:
| Source | Examples | Description |
|--|--|--|
| Hand-curated golden | <N> | Expert-written input/output pairs |
| set |  | (highest quality, expensive to create) |
| Production logs | <N> | Real user queries with human ratings |
| (sampled) |  | (realistic, may contain PII) |
| Synthetic generation | <N> | LLM-generated test cases |
|  |  | (scalable, may miss real patterns) |
| Adversarial set | <N> | Deliberately tricky or edge-case inputs |
  ...
```
### Step 3: Evaluation Framework Selection
Choose or build the evaluation framework:

```
EVALUATION FRAMEWORK:

Framework options:
| Framework | Best for |
|--|--|
| RAGAS | RAG evaluation: faithfulness, relevance, context metrics |
| DeepEval | General LLM evaluation: 14+ metrics, CI integration |
| Promptfoo | Prompt testing: comparison, assertions, CI/CD |
| LangSmith | LangChain apps: tracing, evaluation, datasets |
| Braintrust | Production evals: scoring, experiments, logging |
| Arize Phoenix | Observability + evaluation: traces, spans, evals |
| Humanloop | Prompt management + evaluation: versioning, A/B tests |
  ...
```
### Step 4: Automated Evaluation — LLM-as-Judge
Design automated scoring using LLM judges:

```
LLM-AS-JUDGE DESIGN:

Judge model: <strong model — e.g., Claude 3.5 Sonnet, GPT-4>
  Rationale: Pick a judge model stronger than the system under test.
  Never judge a model with itself.

Scoring rubrics:
| Dimension | Scale | Rubric |
|--|--|--|
| Correctness | 1-5 | 1: Completely wrong |
|  |  | 2: Partially correct, major errors |
|  |  | 3: Mostly correct, minor errors |
  ...
```
### Step 5: Human Evaluation Protocol
Design the human evaluation process for high-stakes evaluation:

```
HUMAN EVALUATION PROTOCOL:

When to use human evaluation:
  - Establishing initial ground truth for a new task
  - Calibrating and validating automated judges
  - Evaluating subjective quality (tone, style, helpfulness)
  - Final sign-off before production deployment
  - Resolving disagreements between automated metrics

Evaluator selection:
  - Pool size: <N evaluators> (minimum 3 for inter-annotator agreement)
  - Expertise: <domain experts | trained annotators | target users>
  ...
```
BENCHMARK DESIGN:

Benchmark name: <name>
Version: <semver>
Purpose: <what this benchmark measures>

Structure:
  BENCHMARK: <name> v<version>
  Categories: | Category | Examples | Weight | Description |
  Scoring: primary metric (weighted avg), threshold, per-category breakdown
  Baseline: | System | Overall | Cat 1 | Cat 2 | Cat 3 |

Benchmark maintenance:
  - Add new examples quarterly (at least <N> per quarter)
  - Add regression examples whenever a bug is found and fixed
  - Re-baseline when major version changes occur
  - Never modify existing examples (append only)
  - Track benchmark saturation (if all systems score >95%, benchmark is too easy)
```

### Step 7: Regression Testing for AI Outputs
Design regression testing to catch quality degradation:

```
REGRESSION TESTING:

Regression test set:
  Source: Failures found in production, evaluation, or user feedback
  Size: <N> examples (grows over time, never shrinks)
  Format: { input, expected_output, failure_description, fix_date, ticket_id }

Regression pipeline:
  Trigger: <on every prompt change | model update | deployment | nightly>

  Load Reg. Set → Run System → Compare vs Gold → Alert on Fail

Comparison strategies:
  Exact match: output must exactly match reference (for structured/JSON outputs)
  Semantic match: output matches semantically (cosine similarity > threshold)
  LLM judge: judge model determines if output is acceptable
  Assertion-based: output must satisfy a set of assertions (contains X, does not contain Y)
  Rubric-based: output must score >= threshold on scoring rubric

SELECTED: <Strategy per test category>

Regression dashboard:
  REGRESSION STATUS: <date>
  Total tests: <N>
  Passing: <N> (<pct>%)
  Failing: <N> (<pct>%)
  New failures: <N> (introduced since last run)
  Fixed: <N> (previously failing, now passing)
  Failing tests:
  | ID | Description | Since | Severity |
  | REG-042 | Misclassifies refund query | 2025-03-10 | HIGH |
|  | REG-087 | Wrong date format in output | 2025-03-15 | MEDIUM |  |
  └──────────┴─────────────────────────────┴────────────┴────────────┘
  VERDICT: <PASS — all tests pass | BLOCK — regressions detected>

CI/CD integration:
  - Run regression suite on every PR that touches prompts, models, or AI pipeline
  - Block merge if regression tests fail (configurable by severity)
  - Auto-add new test when a production bug is fixed
  - Report regression results as PR comment
```

### Step 8: Statistical Significance & Comparison
Verify evaluation results are statistically meaningful:

```
STATISTICAL ANALYSIS:

Comparison: <System A> vs <System B>

Per-metric comparison:
| Metric | System A | System B | Diff | p-value | Sig? |
|--|--|--|--|--|--|
| Correctness | <val> | <val> | <delta> | <p> | YES | NO |
| Relevance | <val> | <val> | <delta> | <p> | YES | NO |
| Faithfulness | <val> | <val> | <delta> | <p> | YES | NO |
| Safety | <val> | <val> | <delta> | <p> | YES | NO |
| Latency p95 | <ms> | <ms> | <delta> | <p> | YES | NO |
| Cost per call | <$> | <$> | <delta> | — | — |

Statistical tests:
  Paired: bootstrap (recommended), McNemar's (binary), Wilcoxon (ordinal)
  Independent: Mann-Whitney U, permutation test
  Alpha: 0.05. Multiple correction: Bonferroni (if >3 metrics).
  Sample size: calculate for target MDE with 80% power.
  Report 95% confidence intervals for all metrics.

VERDICT:
  <System B is significantly better on X, Y metrics>
  <No significant difference on Z metric>
  <System A is better on W metric>
  Recommendation: <deploy B | keep A | need more data>
```

### Step 9: Evaluation Report & Artifacts
Generate the evaluation deliverables:

1. **Evaluation config**: `evals/<system>/eval-config.yaml`
2. **Evaluation dataset**: `evals/<system>/dataset/`
3. **Judge prompts**: `evals/<system>/judges/`
4. **Regression tests**: `evals/<system>/regression/`
5. **Results**: `evals/<system>/results/`
6. **Report**: `docs/evals/<system>-eval-report.md`

```
EVALUATION COMPLETE:

System: <name and version>
Dataset: <N examples> across <N categories>
Methods: <automated (LLM judge) | human | hybrid>

Results summary:
| Metric | Score | Target | Status |
|--|--|--|--|
| Correctness | <val> | <val> | PASS|FAIL |
| Relevance | <val> | <val> | PASS|FAIL |
| Faithfulness | <val> | <val> | PASS|FAIL |
| Safety | <val> | 100% | PASS|FAIL |
| Format compliance | <val> | 100% | PASS|FAIL |
| Latency p95 | <ms> | <ms> | PASS|FAIL |
| Cost per call | $<val> | $<val> | PASS|FAIL |

Regression tests: <N>/<N> passing
vs Baseline: <+X% correctness, +Y% relevance, -Z% latency>
Statistical significance: <yes | no | insufficient data>

VERDICT: <PASS — ready for deployment | FAIL — N metrics below target>

Artifacts:
- Config: evals/<system>/eval-config.yaml
- Dataset: evals/<system>/dataset/ (<N> examples)
- Judges: evals/<system>/judges/ (<N> judge prompts)
- Regression: evals/<system>/regression/ (<N> tests)
- Results: evals/<system>/results/<run-id>.json
- Report: docs/evals/<system>-eval-report.md

Next steps:
-> /godmode:prompt — Optimize prompts based on failure analysis
-> /godmode:rag — Improve retrieval based on faithfulness scores
-> /godmode:agent — Fix agent trajectory issues identified in eval
-> /godmode:ship — Deploy if all metrics pass
```

Commit: `"eval: <system> — v<version>, <N> examples, correctness=<val>, faithfulness=<val>"`

## Key Behaviors

1. **Evaluate before shipping.** No AI system goes to production without evaluation. "It works on my examples" is not evidence. Run the full eval suite.
2. **Baseline everything.** Every metric is meaningless without a baseline. Compare against the previous version, a naive baseline, or a published benchmark. Never report absolute numbers alone.
3. **Separate retrieval from generation.** In RAG systems, evaluate retrieval quality and generation quality independently. A bad answer from good retrieval is a different problem than a bad answer from bad retrieval.
4. **LLM judges need calibration.** An uncalibrated LLM judge performs worse than no evaluation. Calibrate against human judgments. Measure agreement. Refine rubrics.
5. **Statistical significance is not optional.** A 2% improvement is often noise. Run significance tests. Report confidence intervals. Do not deploy based on noise.
## HARD RULES

1. **Never evaluate without a baseline.** "Our model scores 4.2/5" is meaningless without comparison. Always report relative to a previous version, a naive baseline, or a published benchmark.
2. **Never use the same model as judge and subject.** Self-evaluation is biased. Use a different, preferably stronger model as the judge. Never judge GPT-4 with GPT-4.
3. **Never skip calibration of LLM judges.** An uncalibrated judge may consistently over-score or under-score. Validate against human ratings (Cohen's kappa >= 0.7) before trusting automated evaluation.
4. **Never deploy AI changes without running the regression suite.** Every production bug becomes a regression test. The suite blocks deployment if regressions are detected.
5. **Never delete regression tests.** Once a bug is caught and tested, that test stays forever. The regression set is the immune system of your AI system.

## Output Format
After each eval skill invocation, emit a structured report:
```
EVALUATION REPORT:
| System evaluated | <name and version> |
|--|--|
| Eval framework | <DeepEval | RAGAS | Promptfoo | custom> |
| Test cases | <N> total (<N> golden, <N> regression) |
| Primary metric | <metric>: <value> (baseline: <value>) |
| Secondary metrics | <metric>: <value>, <metric>: <value> |
| Improvement | +<N>% over baseline |
| Statistical sig. | p=<value> (significant: YES/NO) |
| Regressions found | <N> |
| Judge model | <model name> (calibrated: YES/NO) |
| Verdict | PASS | REGRESSED | NEEDS MORE DATA |
```

## TSV Logging

Log every evaluation run for tracking:

```
timestamp	skill	system	version	metric	baseline	result	improvement	p_value	status
2026-03-20T14:00:00Z	eval	rag_pipeline	v2.1	faithfulness	0.85	0.92	+8.2%	0.003	pass
2026-03-20T14:30:00Z	eval	rag_pipeline	v2.1	hallucination	0.08	0.03	-62.5%	0.001	pass
```

## Success Criteria

The eval skill is complete when ALL of the following are true:
1. Baseline evaluation is established and logged (never skip baseline)
2. Golden test set covers happy paths, edge cases, and adversarial inputs
3. Regression test set captures all previously identified bugs
4. LLM judge (if used) is calibrated against human ratings
5. Statistical significance is computed for all metric comparisons
6. Results are relative to baseline (never report absolute scores alone)
7. Evaluation runs in CI and blocks merges on regression
8. All evaluation artifacts (datasets, judge prompts, results) are versioned
  ...
```
After EACH evaluation dimension scored:
  1. MEASURE: Compare metric to baseline with confidence interval.
  2. VERIFY: Statistical significance test run (paired bootstrap).
  3. DECIDE:
     - KEEP if: metric meets threshold AND comparison to baseline is statistically significant
     - DISCARD if: metric below threshold OR result is not significant OR judge disagreement > 30%
  4. Log kept results. Re-run discarded dimensions with refined judge prompts.

Never report an evaluation result without a baseline comparison and significance test.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
On failure: git reset --hard HEAD~1.

STOP when ANY of these are true:
  - All quality dimensions evaluated with baseline comparison
  - Regression tests pass and are integrated into CI
  - Statistical significance computed for all comparisons
  - User explicitly requests stop

DO NOT STOP when:
  - One dimension shows no significant difference (report it as-is)
  - Human evaluation budget is exhausted (use automated judges for remaining)
```
## Error Recovery
| Failure | Action |
|--|--|
| Noisy/inconsistent scores | Increase sample size. Multiple judges, take median. Add calibration examples. |
| Judge disagrees with humans | Calibrate with labeled examples. Check position bias. Use structured rubrics. |
| Test set too small | Calculate minimum sample size. Expand test set or reduce dimensions. |
| Unclear regression cause | Bisect recent changes. Run eval per commit. Check for prompt/data drift. |
