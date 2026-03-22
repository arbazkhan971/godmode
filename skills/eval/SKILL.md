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
System under test: <what AI system is being evaluated>
  Type: <LLM prompt | RAG pipeline | AI agent | fine-tuned model | full application>
  Model: <underlying model(s)>
  Current version: <version or commit>

Evaluation trigger:
  - New system: establishing baseline metrics
  - Model change: upgrading or switching models
  - Prompt change: modified system prompt or few-shot examples
  - Pipeline change: new retrieval strategy, chunking, reranking
  - Regression check: periodic quality verification
  - Comparison: evaluating multiple candidates

What to evaluate:
```

If the user hasn't specified, ask: "What AI system should I evaluate, and what quality dimensions matter most?"

### Step 2: Evaluation Dataset Design
Create or curate the evaluation dataset:

```
EVALUATION DATASET DESIGN:

Dataset sources:
┌───────────────────────┬──────────┬────────────────────────────────────────────┐
│ Source                │ Examples │ Description                                │
├───────────────────────┼──────────┼────────────────────────────────────────────┤
│ Hand-curated golden   │ <N>      │ Expert-written input/output pairs          │
│ set                   │          │ (highest quality, expensive to create)     │
│ Production logs       │ <N>      │ Real user queries with human ratings       │
│ (sampled)             │          │ (realistic, may contain PII)              │
│ Synthetic generation  │ <N>      │ LLM-generated test cases                  │
│                       │          │ (scalable, may miss real patterns)        │
│ Adversarial set       │ <N>      │ Deliberately tricky or edge-case inputs   │
│                       │          │ (tests robustness)                        │
│ Domain benchmark      │ <N>      │ Standard benchmark for the domain         │
```

### Step 3: Evaluation Framework Selection
Choose or build the evaluation framework:

```
EVALUATION FRAMEWORK:

Framework options:
┌─────────────────────┬──────────────────────────────────────────────────────────┐
│ Framework           │ Best for                                                 │
├─────────────────────┼──────────────────────────────────────────────────────────┤
│ RAGAS               │ RAG evaluation: faithfulness, relevance, context metrics │
│ DeepEval            │ General LLM evaluation: 14+ metrics, CI integration     │
│ Promptfoo           │ Prompt testing: comparison, assertions, CI/CD           │
│ LangSmith           │ LangChain apps: tracing, evaluation, datasets           │
│ Braintrust          │ Production evals: scoring, experiments, logging         │
│ Arize Phoenix       │ Observability + evaluation: traces, spans, evals        │
│ Humanloop           │ Prompt management + evaluation: versioning, A/B tests   │
│ Custom framework    │ Domain-specific needs not covered by existing tools     │
└─────────────────────┴──────────────────────────────────────────────────────────┘
```

### Step 4: Automated Evaluation — LLM-as-Judge
Design automated scoring using LLM judges:

```
LLM-AS-JUDGE DESIGN:

Judge model: <strong model — e.g., Claude 3.5 Sonnet, GPT-4>
  Rationale: Judge model should be stronger than the system under test.
  Never judge a model with itself.

Scoring rubrics:
┌──────────────────┬───────┬──────────────────────────────────────────────────┐
│ Dimension        │ Scale │ Rubric                                           │
├──────────────────┼───────┼──────────────────────────────────────────────────┤
│ Correctness      │ 1-5   │ 1: Completely wrong                              │
│                  │       │ 2: Partially correct, major errors                │
│                  │       │ 3: Mostly correct, minor errors                   │
│                  │       │ 4: Correct with minor omissions                   │
│                  │       │ 5: Fully correct and complete                     │
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
  - Training: <evaluation guidelines document, calibration examples>

Evaluation interface:
```
BENCHMARK DESIGN:

Benchmark name: <name>
Version: <semver>
Purpose: <what this benchmark measures>

Structure:
┌─────────────────────────────────────────────────────────────────────┐
│ BENCHMARK: <name> v<version>                                        │
│                                                                     │
│ Categories:                                                         │
│ ┌──────────────────┬──────────┬──────────┬──────────────────────┐  │
│ │ Category         │ Examples │ Weight   │ Description          │  │
│ ├──────────────────┼──────────┼──────────┼──────────────────────┤  │
│ │ <category 1>     │ <N>      │ <pct>    │ <what it tests>      │  │
│ │ <category 2>     │ <N>      │ <pct>    │ <what it tests>      │  │
│ │ <category 3>     │ <N>      │ <pct>    │ <what it tests>      │  │
│ │ <adversarial>    │ <N>      │ <pct>    │ Robustness/safety    │  │
│ │ <regression>     │ <N>      │ <pct>    │ Previously-fixed bugs│  │
│ └──────────────────┴──────────┴──────────┴──────────────────────┘  │
│                                                                     │
│ Total examples: <N>                                                 │
│                                                                     │
│ Scoring:                                                            │
│   Primary metric: <metric name> (weighted average across categories)│
│   Threshold: <minimum score to pass>                                │
│   Breakdown: per-category scores reported                           │
│                                                                     │
│ Baseline scores:                                                    │
│ ┌──────────────────┬──────────┬──────────┬──────────┬──────────┐  │
│ │ System           │ Overall  │ Cat 1    │ Cat 2    │ Cat 3    │  │
│ ├──────────────────┼──────────┼──────────┼──────────┼──────────┤  │
│ │ Baseline v1.0    │ <score>  │ <score>  │ <score>  │ <score>  │  │
│ │ Current v<N>     │ <score>  │ <score>  │ <score>  │ <score>  │  │
│ └──────────────────┴──────────┴──────────┴──────────┴──────────┘  │
└─────────────────────────────────────────────────────────────────────┘

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

  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
  │  Load    │ -> │  Run     │ -> │  Compare │ -> │  Alert   │
  │ Reg. Set │    │  System  │    │  vs Gold │    │  on Fail │
  └──────────┘    └──────────┘    └──────────┘    └──────────┘

Comparison strategies:
  Exact match: output must exactly match reference (for structured/JSON outputs)
  Semantic match: output must be semantically equivalent (cosine similarity > threshold)
  LLM judge: judge model determines if output is acceptable
  Assertion-based: output must satisfy a set of assertions (contains X, does not contain Y)
  Rubric-based: output must score >= threshold on scoring rubric

SELECTED: <Strategy per test category>

Regression dashboard:
┌──────────────────────────────────────────────────────────────────────┐
│ REGRESSION STATUS: <date>                                            │
│                                                                      │
│ Total tests: <N>                                                     │
│ Passing: <N> (<pct>%)                                                │
│ Failing: <N> (<pct>%)                                                │
│ New failures: <N> (introduced since last run)                        │
│ Fixed: <N> (previously failing, now passing)                         │
│                                                                      │
│ Failing tests:                                                       │
│ ┌──────────┬─────────────────────────────┬────────────┬────────────┐ │
│ │ ID       │ Description                 │ Since      │ Severity   │ │
│ ├──────────┼─────────────────────────────┼────────────┼────────────┤ │
│ │ REG-042  │ Misclassifies refund query  │ 2025-03-10 │ HIGH       │ │
│ │ REG-087  │ Wrong date format in output  │ 2025-03-15 │ MEDIUM     │ │
│ └──────────┴─────────────────────────────┴────────────┴────────────┘ │
│                                                                      │
│ VERDICT: <PASS — all tests pass | BLOCK — regressions detected>     │
└──────────────────────────────────────────────────────────────────────┘

CI/CD integration:
  - Run regression suite on every PR that touches prompts, models, or AI pipeline
  - Block merge if regression tests fail (configurable by severity)
  - Auto-add new test when a production bug is fixed
  - Report regression results as PR comment
```

### Step 8: Statistical Significance & Comparison
Ensure evaluation results are statistically meaningful:

```
STATISTICAL ANALYSIS:

Comparison: <System A> vs <System B>

Per-metric comparison:
┌──────────────────┬──────────┬──────────┬──────────┬──────────┬──────────┐
│ Metric           │ System A │ System B │ Diff     │ p-value  │ Sig?     │
├──────────────────┼──────────┼──────────┼──────────┼──────────┼──────────┤
│ Correctness      │ <val>    │ <val>    │ <delta>  │ <p>      │ YES | NO │
│ Relevance        │ <val>    │ <val>    │ <delta>  │ <p>      │ YES | NO │
│ Faithfulness     │ <val>    │ <val>    │ <delta>  │ <p>      │ YES | NO │
│ Safety           │ <val>    │ <val>    │ <delta>  │ <p>      │ YES | NO │
│ Latency p95      │ <ms>     │ <ms>     │ <delta>  │ <p>      │ YES | NO │
│ Cost per call    │ <$>      │ <$>      │ <delta>  │ —        │ —        │
└──────────────────┴──────────┴──────────┴──────────┴──────────┴──────────┘

Statistical tests:
  Paired comparisons (same inputs, different systems):
    - Paired bootstrap test (recommended, non-parametric)
    - McNemar's test (for binary pass/fail)
    - Wilcoxon signed-rank test (for ordinal scores)
  Independent comparisons (different inputs):
    - Mann-Whitney U test (non-parametric)
    - Permutation test

  Significance level: alpha = 0.05
  Multiple comparison correction: Bonferroni (if testing >3 metrics)

Sample size requirements:
  - For detecting 5% improvement with 80% power: ~<N> examples
  - For detecting 2% improvement with 80% power: ~<N> examples
  - Current dataset: <N> examples — sufficient to detect <X>% improvement

Confidence intervals:
  Correctness: <val> [<lower>, <upper>] (95% CI)
  Relevance: <val> [<lower>, <upper>] (95% CI)
  Faithfulness: <val> [<lower>, <upper>] (95% CI)

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
┌────────────────────┬──────────┬──────────┬──────────┐
│ Metric             │ Score    │ Target   │ Status   │
├────────────────────┼──────────┼──────────┼──────────┤
│ Correctness        │ <val>    │ <val>    │ PASS|FAIL│
│ Relevance          │ <val>    │ <val>    │ PASS|FAIL│
│ Faithfulness       │ <val>    │ <val>    │ PASS|FAIL│
│ Safety             │ <val>    │ 100%     │ PASS|FAIL│
│ Format compliance  │ <val>    │ 100%     │ PASS|FAIL│
│ Latency p95        │ <ms>     │ <ms>     │ PASS|FAIL│
│ Cost per call      │ $<val>   │ $<val>   │ PASS|FAIL│
└────────────────────┴──────────┴──────────┴──────────┘

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
4. **LLM judges need calibration.** An uncalibrated LLM judge can be worse than no evaluation. Calibrate against human judgments. Measure agreement. Refine rubrics.
5. **Statistical significance is not optional.** A 2% improvement might be noise. Run significance tests. Report confidence intervals. Do not deploy based on noise.
6. **Regression tests only grow.** Every production bug becomes a regression test. The regression set never shrinks. It is the immune system of your AI system.
7. **Evaluation datasets are living artifacts.** They need versioning, maintenance, and periodic expansion. A stale benchmark produces false confidence.

## Flags & Options

```
eval_dimension_queue = [correctness, relevance, faithfulness, safety, format, latency, cost]
current_iteration = 0

WHILE eval_dimension_queue is not empty:
  batch = eval_dimension_queue.take(3)
  current_iteration += 1

  FOR each dimension in batch:
    1. Load evaluation dataset (versioned, immutable)
    2. Run system under test on all examples
    3. Score outputs using LLM judge (calibrated) or automated metric
    4. Compute aggregate metric with confidence interval
    5. Compare against baseline — flag regressions
    6. IF dimension fails threshold → add to remediation list

  Log: "Iteration {current_iteration}: evaluated {batch.length} dimensions, {eval_dimension_queue.remaining} remaining"

  IF eval_dimension_queue is empty:
    Run statistical significance tests (paired bootstrap)
    Run full regression test suite
    Generate evaluation report with PASS/FAIL verdict
    BREAK
```

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
┌──────────────────────────────────────────────────────┐
│  System evaluated    │  <name and version>             │
│  Eval framework      │  <DeepEval | RAGAS | Promptfoo | custom> │
│  Test cases          │  <N> total (<N> golden, <N> regression) │
│  Primary metric      │  <metric>: <value> (baseline: <value>) │
│  Secondary metrics   │  <metric>: <value>, <metric>: <value> │
│  Improvement         │  +<N>% over baseline             │
│  Statistical sig.    │  p=<value> (significant: YES/NO) │
│  Regressions found   │  <N>                             │
│  Judge model         │  <model name> (calibrated: YES/NO) │
│  Verdict             │  PASS | REGRESSED | NEEDS MORE DATA │
└──────────────────────────────────────────────────────┘
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

## Evaluation Framework Audit

Comprehensive audit of the evaluation framework itself to ensure metrics are meaningful, benchmarks are comprehensive, and regressions are detectable:

```
EVALUATION FRAMEWORK AUDIT:
System: <system under evaluation>
Framework: <DeepEval | RAGAS | Promptfoo | custom>
Audit date: <date>

METRIC SELECTION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Evidence        │
├──────────────────────────────────────────────────────────────────┤
│  Primary metric aligns with biz goal│ PASS|FAIL│ <metric->goal>  │
│  Multiple dimensions covered (not   │ PASS|FAIL│ <dimension list>│
│    just accuracy)                   │          │                 │
│  Metrics are actionable (failure    │ PASS|FAIL│ <diagnosis path>│
│    points to a fixable component)   │          │                 │
│  No metric gaming (metric improves  │ PASS|FAIL│ <sanity checks> │
│    but actual quality does not)     │          │                 │
│  Metrics are stable across runs     │ PASS|FAIL│ <variance test> │
│    (low variance on same input)     │          │                 │
│  Human-automated metric correlation │ PASS|FAIL│ <correlation r> │
│    verified (r > 0.7)              │          │                 │
│  Cost-aware metrics included        │ PASS|FAIL│ <cost tracking> │
│  Latency metrics included           │ PASS|FAIL│ <latency track> │
│  Safety metrics included            │ PASS|FAIL│ <safety evals>  │
│  Per-segment metrics available      │ PASS|FAIL│ <slice evals>   │
│    (by category, difficulty, source)│          │                 │
└──────────────────────────────────────────────────────────────────┘

  Metric health check:
    FOR each metric:
      1. Compute metric on golden set 5 times (different random seeds if applicable)
      2. IF std_dev > 5% of mean: UNSTABLE — metric has too much variance
      3. IF metric == 100% for all examples: SATURATED — metric is too easy
      4. IF metric shows no difference between good and bad systems: UNDISCRIMINATING
      5. IF metric correlates < 0.5 with human judgment: MISCALIBRATED

BENCHMARK COVERAGE AUDIT:

## Keep/Discard Discipline
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
STOP when ANY of these are true:
  - All quality dimensions evaluated with baseline comparison
  - Regression tests pass and are integrated into CI
  - Statistical significance computed for all comparisons
  - User explicitly requests stop

DO NOT STOP just because:
  - One dimension shows no significant difference (report it as-is)
  - Human evaluation budget is exhausted (use automated judges for remaining)
```
## Error Recovery
| Failure | Action |
|---------|--------|
| Evaluation scores are noisy/inconsistent | Increase sample size. Use multiple judges and take median. Add calibration examples to the prompt. |
| LLM judge disagrees with human ratings | Calibrate judge prompt with labeled examples. Check for position bias (swap A/B order). Use structured rubrics. |
| Test set too small for significance | Calculate minimum sample size for desired confidence interval. Expand test set or reduce dimensions evaluated. |
| Regression detected but unclear cause | Bisect recent changes. Run eval on each commit in range. Check for prompt drift or data quality changes. |
