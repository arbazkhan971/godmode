# /godmode:eval

Evaluate, benchmark, and regression-test AI/LLM systems. Covers evaluation framework design, benchmark creation, human evaluation protocols, automated evaluation (LLM-as-judge), regression testing, statistical significance, and continuous evaluation pipelines.

## Usage

```
/godmode:eval                              # Full evaluation workflow
/godmode:eval --dataset                    # Create or manage evaluation dataset
/godmode:eval --judge                      # Set up LLM-as-judge evaluation
/godmode:eval --human                      # Set up human evaluation protocol
/godmode:eval --benchmark                  # Create reusable benchmark
/godmode:eval --regression                 # Set up or run regression tests
/godmode:eval --compare <a> <b>            # Compare two systems or versions
/godmode:eval --report                     # Generate report from existing results
/godmode:eval --ci                         # Generate CI/CD integration
/godmode:eval --calibrate                  # Calibrate LLM judge vs human scores
/godmode:eval --significance               # Run statistical significance analysis
/godmode:eval --history                    # Show evaluation trends
/godmode:eval --quick                      # Lightweight eval (golden set only)
/godmode:eval --full                       # Comprehensive eval (all categories)
```

## What It Does

1. Discovers what AI system needs evaluation, quality dimensions, and evaluation budget
2. Designs evaluation dataset from golden sets, production logs, synthetic, adversarial, and regression examples
3. Selects evaluation framework (RAGAS, DeepEval, Promptfoo, LangSmith, Braintrust, custom)
4. Designs LLM-as-judge with scoring rubrics, calibration, and bias mitigation
5. Designs human evaluation protocol with annotator training, agreement measurement, and adjudication
6. Creates reusable benchmarks with categories, weighting, and baseline scores
7. Builds regression test suite from production failures that runs in CI/CD
8. Runs statistical significance tests (bootstrap, McNemar, Wilcoxon) with confidence intervals
9. Generates evaluation config, dataset, judge prompts, regression tests, and report

## Output
- Evaluation config at `evals/<system>/eval-config.yaml`
- Dataset at `evals/<system>/dataset/`
- Judge prompts at `evals/<system>/judges/`
- Regression tests at `evals/<system>/regression/`
- Results at `evals/<system>/results/`
- Report at `docs/evals/<system>-eval-report.md`
- Commit: `"eval: <system> — v<version>, <N> examples, correctness=<val>, faithfulness=<val>"`

## Next Step
After evaluation: `/godmode:prompt` to fix prompt issues, `/godmode:rag` to improve retrieval, `/godmode:agent` to fix agent issues, or `/godmode:ship` to deploy if metrics pass.

## Examples

```
/godmode:eval Evaluate our customer support RAG chatbot
/godmode:eval --judge Compare GPT-4 vs Claude on summarization
/godmode:eval --regression Set up regression tests for our AI pipeline
/godmode:eval --benchmark Create a benchmark for our classification task
/godmode:eval --compare v2.0 v2.1 Is the new version better?
/godmode:eval --calibrate Calibrate our LLM judge against human ratings
```
