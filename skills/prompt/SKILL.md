---
name: prompt
description: Prompt engineering -- design, test, version,
  and optimize prompts for LLMs.
---

## Activate When
- `/godmode:prompt`, "design a prompt", "test prompt"
- "optimize my prompt", "prevent prompt injection"
- Building LLM-powered features

## Workflow

### 1. Requirements
```
Task: <what the prompt must accomplish>
Model: <target model>
Input/Output: <format and constraints>
Quality: accuracy target, safety, consistency
Budget: max tokens, latency, cost per call
```

### 2. Pattern Selection
| Pattern | Best for |
|--|--|
| Zero-shot | Simple tasks model handles well |
| Few-shot | Tasks needing format/style examples |
| Chain-of-thought | Reasoning, math, multi-step |
| ReAct | Tool-using agents, search+reason |
| Tree-of-thought | Exploring alternatives |
| Self-consistency | High-stakes, multiple paths |
| Structured output | JSON, XML, typed schema |

IF simple classification: zero-shot.
IF format matters: few-shot with 2-5 examples.

### 3. System Prompt Design
Structure: 1) Role, 2) Task, 3) Input Format,
4) Output Format, 5) Constraints, 6) Examples,
7) Edge Cases.

Most important instructions at beginning and end
(primacy/recency effect). Examples > instructions.

### 4. Few-Shot Examples
Cover: common case, edge case, output format.
2-5 examples typical. Track token overhead.

### 5. Reasoning Design
- CoT: "Think step by step: 1. Identify, 2. Analyze"
- ReAct: Thought -> Action -> Observation -> Answer
- ToT: generate 3 approaches, evaluate, select
- Self-consistency: N generations -> majority vote

### 6. Structured Output
Options: JSON mode, function calling, prompt-based,
constrained decoding. Validate against schema.
Retry on failure (max 2-3 attempts).

### 7. Injection Prevention
1. Input sanitization: strip patterns, max length
2. Prompt structure: delimiters, `<user_input>` tags
3. Output validation: format check, leak detection
4. Monitoring: log prompts/completions, alert anomalies

IF user input enters prompt: injection defense required.
IF output contains system prompt text: leak detected.

### 8. Testing & Evaluation
Categories: golden set, edge cases, format compliance,
safety, injection resistance, consistency.
Metrics: accuracy (target), format (100%), safety (>99%),
injection resistance (>95%), latency, cost.

### 9. Versioning & A/B Testing
Track: version, accuracy, latency, cost, status.
A/B test with traffic split, significance testing
(alpha=0.05). Minimum 100 samples per variant.

### 10. Artifacts
`prompts/<task>/`: prompt-spec.yaml, system-prompt.md,
examples.yaml, tests.yaml, eval-results.md.


```bash
# Test prompt templates
curl -X POST http://localhost:8080/api/chat -d '{"prompt":"test"}'
pytest tests/test_prompts.py -v
```

## Optimization Loop
```
WHILE iteration < 5 AND accuracy < target:
  1. DIAGNOSE failures (format, wrong, hallucination)
  2. GENERATE ONE change targeting top failure
  3. EVALUATE on same golden set
  4. COMPARE: accept if improved + no regression
```

## Hard Rules
1. NEVER ship without golden set evaluation.
2. NEVER hardcode prompts inline -- externalize.
3. NEVER change >1 variable per iteration.
4. NEVER ignore injection if user input in prompt.
5. ALWAYS version prompts with semver.
6. ALWAYS include 2+ few-shot examples for non-trivial.
7. ALWAYS validate structured output against schema.
8. ALWAYS test on the TARGET model.
9. ALWAYS critical instructions at START and END.
10. NEVER trust user input as instructions.

## TSV Logging
Append `.godmode/prompt-results.tsv`:
```
timestamp	version	model	accuracy_pct	latency_ms	injection_safe	status
```

## Keep/Discard
```
KEEP if: accuracy improved/maintained AND injection
  tests pass AND output parseable.
DISCARD if: accuracy dropped OR injection bypass
  OR format breaks.
```

## Stop Conditions
```
STOP when ALL of:
  - Accuracy meets target on test suite
  - Injection hardening passes all cases
  - Output format consistent and parseable
  - Latency within budget
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Inconsistent output | JSON mode, temperature=0, examples |
| Injection bypasses | Sanitize input, isolate system prompt |
| Model refuses valid | Rephrase, explicit context setting |
| Scores drop after edit | Compare diffs, A/B test old vs new |
