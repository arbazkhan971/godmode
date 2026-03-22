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
  Quality dimensions:
    - Correctness: <does the output contain the right information?>
    - Relevance: <does the output address the question/task?>
    - Completeness: <does the output cover all aspects?>
    - Faithfulness: <is the output grounded in provided context?>
    - Safety: <does the output avoid harmful content?>
    - Format: <does the output match the required structure?>
    - Consistency: <same input produces similar outputs?>
    - Latency: <how fast is the response?>
    - Cost: <how much does each call cost?>

  Domain-specific dimensions:
    - <dimension>: <what it measures in this domain>
    - <dimension>: <what it measures in this domain>

Evaluation budget:
  - Evaluation dataset size: <N examples>
  - Human evaluation budget: <hours available>
  - LLM judge budget: <$ for running judge evaluations>
  - Timeline: <when results are needed>
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
│                       │          │ (comparable to published results)         │
│ Regression set        │ <N>      │ Previously-failed cases that were fixed   │
│                       │          │ (prevents reintroduction of bugs)         │
└───────────────────────┴──────────┴────────────────────────────────────────────┘

Total evaluation examples: <N>

Dataset schema:
  - id: unique identifier
  - input: the query/prompt/task given to the system
  - reference_output: expected correct output (gold standard)
  - context: relevant context (for RAG evaluation)
  - metadata:
      - difficulty: easy | medium | hard
      - category: <task category>
      - source: <where this example came from>
      - tags: [<relevant tags>]

Dataset quality checks:
  [ ] No duplicate inputs
  [ ] Reference outputs reviewed by domain expert
  [ ] Balanced across categories and difficulty levels
  [ ] No data leakage (eval examples not in training data)
  [ ] PII redacted or synthetic
  [ ] Adversarial examples included

Dataset versioning:
  Version: <semver>
  Location: <path or artifact store>
  Changelog: <what changed from previous version>
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

SELECTED: <Framework> — <justification>

Evaluation pipeline architecture:
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Dataset  │ -> │  System  │ -> │  Judge   │ -> │ Aggregate│ -> │  Report  │
│ Loading  │    │  Under   │    │ (auto +  │    │  Metrics │    │ & Store  │
│          │    │  Test    │    │  human)  │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

Pipeline steps:
  1. Load evaluation dataset (versioned, immutable)
  2. Run system under test on each example (record output + metadata)
  3. Score each output using automated judges and/or human review
  4. Aggregate scores into summary metrics
  5. Compare against baseline and previous versions
  6. Generate report with pass/fail verdict
  7. Store results for historical tracking
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
├──────────────────┼───────┼──────────────────────────────────────────────────┤
│ Relevance        │ 1-5   │ 1: Completely off-topic                          │
│                  │       │ 2: Tangentially related                           │
│                  │       │ 3: Addresses question partially                   │
│                  │       │ 4: Addresses question well                        │
│                  │       │ 5: Directly and fully addresses question          │
├──────────────────┼───────┼──────────────────────────────────────────────────┤
│ Faithfulness     │ 1-5   │ 1: Entirely fabricated                           │
│ (RAG)            │       │ 2: Mostly unsupported by context                 │
│                  │       │ 3: Mix of supported and unsupported claims        │
│                  │       │ 4: Mostly grounded in context                     │
│                  │       │ 5: Fully grounded, every claim traceable          │
├──────────────────┼───────┼──────────────────────────────────────────────────┤
│ Safety           │ 0-1   │ 0: Contains harmful, biased, or inappropriate    │
│                  │       │    content                                        │
│                  │       │ 1: Safe and appropriate                           │
├──────────────────┼───────┼──────────────────────────────────────────────────┤
│ Format           │ 0-1   │ 0: Does not match required output format         │
│ compliance       │       │ 1: Matches required format exactly               │
└──────────────────┴───────┴──────────────────────────────────────────────────┘

Judge prompt template:
  "You are an expert evaluator. Given:
   - The QUESTION asked
   - The REFERENCE ANSWER (gold standard)
   - The SYSTEM OUTPUT (to evaluate)
   - The CONTEXT provided (if RAG)

   Score the SYSTEM OUTPUT on <dimension> using this rubric:
   <rubric>

   Respond with:
   {
     'score': <1-5>,
     'reasoning': '<1-2 sentences explaining the score>'
   }

   Be strict. A score of 5 means perfection."

Judge calibration:
  - Run judge on <N> examples with known human scores
  - Measure agreement: Cohen's kappa >= 0.7 (substantial agreement)
  - If agreement is low, refine rubric and re-calibrate
  - Use majority vote across 3 judge runs for critical evaluations

Judge biases to mitigate:
  - Position bias: randomize order of candidates in comparison tasks
  - Verbosity bias: longer answers are not always better
  - Self-preference: never judge a model with itself
  - Anchoring: present rubric before examples, not after
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
  - Randomized example order (prevent ordering effects)
  - Blind evaluation (evaluator does not know which version produced output)
  - Side-by-side comparison (when comparing two systems)
  - Required justification for extreme scores (1 or 5)

Protocol:
  1. Evaluator training (15 min):
     - Review evaluation guidelines
     - Score 5 calibration examples together
     - Discuss scoring disagreements
     - Align on rubric interpretation

  2. Independent evaluation:
     - Each evaluator scores <N> examples independently
     - Overlap: <N> examples scored by all evaluators (for agreement)
     - Unique: remaining examples distributed evenly

  3. Agreement measurement:
     - Cohen's kappa (pairwise) or Fleiss' kappa (multi-rater)
     - Target: kappa >= 0.7 (substantial agreement)
     - If kappa < 0.6: re-calibrate, refine guidelines, adjudicate

  4. Adjudication:
     - For examples with >1 point disagreement: discussion and consensus
     - Final score: majority vote or adjudicator decision

Output:
  - Per-example scores with evaluator IDs
  - Inter-annotator agreement statistics
  - Aggregated scores per dimension
  - Qualitative findings and failure patterns
```

### Step 6: Benchmark Creation
Create a reusable benchmark for ongoing evaluation:

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

## Example Usage

### Evaluating a RAG System
```
User: /godmode:eval Evaluate our customer support RAG chatbot

Eval: Starting evaluation...

EVALUATION DISCOVERY:
System: Customer support RAG chatbot v2.3
Type: RAG pipeline (embedding + retrieval + generation)
Model: Claude 3.5 Sonnet
Trigger: Monthly quality check

DATASET: 200 examples
  Golden set: 80 hand-curated Q&A pairs
  Production logs: 70 sampled with human ratings
  Adversarial: 30 edge cases and injection attempts
  Regression: 20 previously-fixed failures

EVALUATION:
  Retrieval:
    Hit rate @ 5: 91.2%
    MRR: 0.83
  Generation:
    Correctness: 4.1/5
    Faithfulness: 4.3/5
    Relevance: 4.4/5
    Safety: 100%
  Regression: 20/20 passing
  vs Baseline (v2.0): +3.2% correctness, +5.1% faithfulness

VERDICT: PASS — All metrics above targets. No regressions.
```

### Running LLM-as-Judge Evaluation
```
User: /godmode:eval --judge Compare GPT-4 vs Claude on our summarization task

Eval: Setting up LLM-as-judge comparison...

Judge: Claude 3.5 Sonnet (calibrated against 30 human-scored examples)
Judge agreement: Cohen's kappa = 0.78 (substantial)

Running on 150 examples...

RESULTS:
┌──────────────┬──────────┬──────────┬──────────┬──────────┐
│ Metric       │ GPT-4    │ Claude   │ Diff     │ Sig?     │
├──────────────┼──────────┼──────────┼──────────┼──────────┤
│ Correctness  │ 4.12     │ 4.28     │ +0.16    │ YES p=.02│
│ Conciseness  │ 3.89     │ 4.15     │ +0.26    │ YES p=.01│
│ Faithfulness │ 4.31     │ 4.35     │ +0.04    │ NO p=.41 │
│ Latency p95  │ 2.1s     │ 1.8s     │ -0.3s    │ YES      │
│ Cost/call    │ $0.018   │ $0.015   │ -$0.003  │ —        │
└──────────────┴──────────┴──────────┴──────────┴──────────┘

Recommendation: Claude is significantly better on correctness and conciseness,
with no significant difference on faithfulness. Lower cost and latency.
Recommend switching to Claude.
```

### Setting Up Regression Testing
```
User: /godmode:eval --regression Set up regression tests for our AI pipeline

Eval: Collecting failure cases...

Found 15 production incidents in the last 90 days:
  - 6 incorrect answers (wrong facts)
  - 4 format violations (invalid JSON)
  - 3 hallucinations (unsupported claims)
  - 2 safety issues (PII leakage)

Creating regression test set:
  15 tests created from production incidents
  5 tests from edge cases found during evaluation
  Total: 20 regression tests

CI/CD integration:
  - Added to GitHub Actions pipeline
  - Runs on every PR touching prompts/ or src/ai/
  - Blocks merge if any regression test fails

Regression baseline: 20/20 PASSING
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full evaluation workflow |
| `--dataset` | Create or manage evaluation dataset |
| `--judge` | Set up LLM-as-judge evaluation |
| `--human` | Set up human evaluation protocol |
| `--benchmark` | Create reusable benchmark |
| `--regression` | Set up or run regression tests |
| `--compare <a> <b>` | Compare two systems or versions |
| `--report` | Generate evaluation report from existing results |
| `--ci` | Generate CI/CD integration for eval pipeline |
| `--calibrate` | Calibrate LLM judge against human scores |
| `--significance` | Run statistical significance analysis |
| `--history` | Show evaluation history and trend charts |
| `--quick` | Run lightweight evaluation (golden set only) |
| `--full` | Run comprehensive evaluation (all categories) |

## HARD RULES

1. **Never evaluate without a baseline.** "Our model scores 4.2/5" is meaningless without comparison. Always report relative to a previous version, a naive baseline, or a published benchmark.
2. **Never use the same model as judge and subject.** Self-evaluation is biased. Use a different, preferably stronger model as the judge. Never judge GPT-4 with GPT-4.
3. **Never skip calibration of LLM judges.** An uncalibrated judge may consistently over-score or under-score. Validate against human ratings (Cohen's kappa >= 0.7) before trusting automated evaluation.
4. **Never deploy AI changes without running the regression suite.** Every production bug becomes a regression test. The suite blocks deployment if regressions are detected.
5. **Never delete regression tests.** Once a bug is caught and tested, that test stays forever. The regression set is the immune system of your AI system.

## Loop Protocol

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

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "dataset-and-judges":
  EnterWorktree("dataset-and-judges")
  Curate or load evaluation dataset (golden set + production logs + adversarial)
  Design LLM judge prompts with scoring rubrics
  Calibrate judges against human ratings (measure Cohen's kappa)
  ExitWorktree()

Agent 2 — "automated-evaluation":
  EnterWorktree("automated-evaluation")
  Run system under test on all evaluation examples
  Score with automated judges across all quality dimensions
  Compute aggregate metrics, confidence intervals, per-category breakdowns
  Compare against baseline with statistical significance tests
  ExitWorktree()

Agent 3 — "regression-and-reporting":
  EnterWorktree("regression-and-reporting")
  Run full regression test suite (exact match, semantic match, assertion-based)
  Identify new failures and fixed regressions
  Generate evaluation report with verdict (PASS/FAIL)
  Store results for historical tracking
  ExitWorktree()

MERGE: Combine judge calibration, evaluation results, and regression status into unified report.
```

## Auto-Detection

```
AUTO-DETECT AI evaluation context:
  1. Check for existing eval framework: evals/ directory, eval-config.yaml, promptfoo.yaml
  2. Scan for evaluation datasets: evals/dataset/, tests/golden_set/, fixtures/eval/
  3. Detect AI framework: langchain, llamaindex, openai SDK, anthropic SDK
  4. Check for existing judge prompts: evals/judges/, prompts/judge/
  5. Scan for regression tests: evals/regression/, tests/ai_regression/
  6. Detect model config: model name, provider, version in env vars or config
  7. Check CI for existing eval jobs: eval workflow, benchmark step

  USE detected context to:
    - Reuse existing evaluation datasets and judges
    - Match existing eval framework (DeepEval, RAGAS, Promptfoo, custom)
    - Compare against most recent baseline run
    - Add to existing CI pipeline rather than creating new one
```

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

## Error Recovery

```
IF evaluation metrics are inconsistent across runs:
  1. Check for non-determinism in the system under test (set temperature=0 if applicable)
  2. Increase the evaluation dataset size to reduce variance
  3. Run multiple evaluation passes and report mean + confidence interval
  4. Check if the LLM judge is non-deterministic (use same seed/temperature for judge)

IF LLM judge disagrees with human ratings:
  1. Calculate judge-human agreement (Cohen's kappa or Spearman correlation)
  2. If agreement < 0.7: recalibrate the judge prompt with human-labeled examples
  3. Add few-shot examples of correct judgments to the judge prompt
  4. Consider using majority vote from multiple judge runs

IF regression test fails on a new change:
  1. Identify exactly which test cases regressed
  2. Determine if the regression is in retrieval, generation, or both
  3. Do NOT delete the failing regression test — fix the system instead
  4. If the regression is acceptable (trade-off), document the justification

IF evaluation takes too long to run in CI:
  1. Split evaluation into fast (smoke) and full (nightly) suites
  2. Run smoke suite on every PR (< 5 minutes, core test cases only)
  3. Run full suite nightly or on release branches
  4. Cache embedding computations and model responses where safe
```

## Anti-Patterns

- **Do NOT evaluate without a baseline.** "Our model scores 4.2/5" is meaningless. Compared to what? Always report relative to a baseline.
- **Do NOT use the same model as judge and subject.** Self-evaluation is biased. Use a different, preferably stronger model as the judge.
- **Do NOT skip calibration of LLM judges.** An uncalibrated judge may consistently over-score or under-score. Validate against human ratings before trusting automated evaluation.
- **Do NOT treat evaluation as one-time.** AI systems degrade over time (model updates, data drift, prompt rot). Run evaluations continuously, not just at launch.
- **Do NOT ignore statistical significance.** Small differences between systems may be noise. Run significance tests. Report p-values and confidence intervals.
- **Do NOT delete regression tests.** Once a bug is caught and tested, that test stays forever. Regression tests are the memory of past failures.
- **Do NOT use accuracy alone.** Accuracy on imbalanced tasks is misleading. Use precision, recall, F1, or task-specific metrics. Report multiple dimensions.
- **Do NOT evaluate only happy paths.** Adversarial inputs, edge cases, and out-of-scope queries reveal more about system quality than common-case inputs.


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
┌──────────────────────────────────────────────────────────────────┐
│  Dimension               │ Examples │ % of Total │ Adequate?     │
├──────────────────────────────────────────────────────────────────┤
│  Happy path (common)     │ <N>      │ <pct>      │ >= 40%        │
│  Edge cases (unusual)    │ <N>      │ <pct>      │ >= 15%        │
│  Adversarial (attacks)   │ <N>      │ <pct>      │ >= 10%        │
│  Out-of-scope (refuse)   │ <N>      │ <pct>      │ >= 10%        │
│  Regression (prev bugs)  │ <N>      │ <pct>      │ >= 10%        │
│  Cross-category balance  │ <N cats> │ <balance>  │ No cat < 5%   │
│  Difficulty distribution │ <E/M/H>  │ <pcts>     │ Balanced      │
│  Freshness (last update) │ <date>   │ N/A        │ < 90 days     │
│  Size sufficiency        │ <N total>│ N/A        │ >= 100        │
└──────────────────────────────────────────────────────────────────┘

  Benchmark coverage gaps:
    1. SCAN for categories with < 5 examples: these are undertested
    2. SCAN for difficulty levels with 0 examples: add hard cases
    3. SCAN for recently-added features with no eval examples
    4. CHECK: is the benchmark too easy? (if all systems score > 90%, add harder cases)
    5. CHECK: is the benchmark representative? (compare query distribution to production logs)

  Benchmark maintenance protocol:
    - ADD new examples monthly (minimum 10 per month)
    - ADD regression examples for every production bug found
    - NEVER modify existing examples (append only)
    - REVIEW and refresh every quarter (remove stale, add emerging patterns)
    - VERSION the benchmark (semver) — major version when > 20% of examples change
    - TRACK benchmark saturation (if top system scores > 95%, benchmark needs harder cases)

REGRESSION DETECTION AUDIT:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Evidence        │
├──────────────────────────────────────────────────────────────────┤
│  Regression suite exists            │ PASS|FAIL│ <test count>    │
│  Every past production bug has a    │ PASS|FAIL│ <coverage %>    │
│    corresponding regression test    │          │                 │
│  Regression suite runs in CI        │ PASS|FAIL│ <CI job link>   │
│  Regression failures block merges   │ PASS|FAIL│ <branch protect>│
│  Regression tests use exact match   │ PASS|FAIL│ <match strategy>│
│    OR semantic match OR assertions  │          │                 │
│  New failures are auto-detected     │ PASS|FAIL│ <diff detection>│
│    (compare to previous run)        │          │                 │
│  Regression test set only grows     │ PASS|FAIL│ <deletion audit>│
│    (never shrinks)                  │          │                 │
│  Flaky tests identified and fixed   │ PASS|FAIL│ <flake rate %>  │
│  Regression run time < 10 min       │ PASS|FAIL│ <run duration>  │
│    (fast enough for CI)             │          │                 │
│  Historical regression results      │ PASS|FAIL│ <storage>       │
│    stored for trend analysis        │          │                 │
└──────────────────────────────────────────────────────────────────┘

  Regression detection sensitivity test:
    1. Take the current best system
    2. Introduce a known degradation (e.g., remove a few-shot example, increase temperature)
    3. Run regression suite
    4. VERIFY: at least one regression test fails
    5. IF no test fails: the regression suite is too weak — add more sensitive tests

JUDGE QUALITY AUDIT (if using LLM-as-judge):
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Evidence        │
├──────────────────────────────────────────────────────────────────┤
│  Judge model differs from subject   │ PASS|FAIL│ <judge model>   │
│  Judge calibrated vs human ratings  │ PASS|FAIL│ <kappa value>   │
│  Judge rubric is specific (not vague│ PASS|FAIL│ <rubric review> │
│  Position bias tested and mitigated │ PASS|FAIL│ <bias test>     │
│  Verbosity bias tested              │ PASS|FAIL│ <bias test>     │
│  Judge consistency tested (same     │ PASS|FAIL│ <intra-rater r> │
│    input scored similarly)          │          │                 │
│  Judge cost is sustainable          │ PASS|FAIL│ <cost per eval> │
│  Judge latency is acceptable        │ PASS|FAIL│ <ms per eval>   │
└──────────────────────────────────────────────────────────────────┘

AUDIT VERDICT: <ROBUST — framework is sound | GAPS — <N> items to address>
Priority fixes:
  1. <highest priority gap>
  2. <second priority gap>
  3. <third priority gap>
```

### Evaluation Framework Audit Loop

```
EVAL FRAMEWORK AUDIT ITERATION:
audit_areas = [metric_selection, benchmark_coverage, regression_detection, judge_quality]
current_area = 0

WHILE current_area < len(audit_areas):
  area = audit_areas[current_area]

  1. RUN all checks for the area
  2. FOR each FAIL: document root cause and recommended fix
  3. CLASSIFY severity: CRITICAL (evaluation is misleading) | HIGH (gaps in coverage) | MEDIUM (nice to have)
  4. IF any CRITICAL failures in metric_selection or regression_detection:
     HALT "Evaluation framework is unreliable. Fix before trusting eval results."

  current_area += 1

FINAL:
  total_checks = sum(all checks across areas)
  pass_count = sum(all PASS across areas)
  framework_health = pass_count / total_checks * 100

  IF framework_health < 60%: "Evaluation framework needs significant work. Results are unreliable."
  IF framework_health >= 60% AND < 85%: "Evaluation framework is functional but has gaps."
  IF framework_health >= 85%: "Evaluation framework is robust. Schedule re-audit in 90 days."
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run evaluation tasks sequentially: dataset/judges, then automated evaluation, then regression/reporting.
- Use branch isolation per task: `git checkout -b godmode-eval-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
