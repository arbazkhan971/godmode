---
name: prompt
description: |
  Prompt engineering skill. Activates when users need to design, test, version, or optimize prompts for LLMs. Covers prompt design patterns (few-shot, chain-of-thought, ReAct, tree-of-thought), structured output (JSON mode, function calling), system prompt design, prompt injection prevention, A/B testing, and evaluation. Triggers on: /godmode:prompt, "design a prompt", "test this prompt", "optimize my prompt", or when the orchestrator detects prompt engineering work.
---

# Prompt — Prompt Engineering

## When to Activate
- User invokes `/godmode:prompt`
- User says "design a prompt", "write a system prompt", "optimize this prompt"
- User says "test my prompt", "prevent prompt injection"
- When building an LLM-powered feature requiring prompt design

## Workflow

### Step 1: Requirements
```
PROMPT DISCOVERY:
Task: <what the prompt must accomplish>
Model: <target model>
Input/Output: <format and constraints>
Quality: accuracy target, safety, consistency
Budget: max tokens, latency, cost per call
```

### Step 2: Pattern Selection

| Pattern | Best for |
|--|--|
| Zero-shot | Simple tasks the model handles well |
| Few-shot | Tasks needing examples for format/style |
| Chain-of-thought | Reasoning, math, multi-step analysis |
| ReAct | Tool-using agents, search + reason loops |
| Tree-of-thought | Problems needing exploration of alternatives |
| Self-consistency | High-stakes answers needing multiple paths |
| Structured output | Output requires JSON, XML, or typed schema |

### Step 3: System Prompt Design
Structure: 1) Role, 2) Task, 3) Input Format, 4) Output Format, 5) Constraints, 6) Examples, 7) Edge Cases.

- Specificity over brevity. Examples > instructions. Constraints are critical.
- Most important instructions at beginning and end (primacy/recency).

### Step 4: Few-Shot Examples
Cover common case, edge case, output format. 2-5 examples typical. Track token overhead.

### Step 5: Reasoning Design
- **CoT:** "Think step by step: 1. Identify, 2. Analyze, 3. Conclude, 4. Answer"
- **ReAct:** Thought -> Action -> Observation -> ... -> Answer
- **ToT:** Generate 3 approaches, evaluate, select best
- **Self-consistency:** N generations -> majority vote

### Step 6: Structured Output
Options: JSON mode, function calling, prompt-based, constrained decoding. Validate against schema. Retry on failure (max 2-3).

### Step 7: Injection Prevention
1. **Input sanitization:** Strip patterns, detect suspicious input, max length
2. **Prompt structure:** Delimiters, `<user_input>` tags treated as DATA
3. **Output validation:** Validate format, check for leaks
4. **Monitoring:** Log prompts/completions, alert on anomalies

### Step 8: Testing & Evaluation
Categories: golden set, edge cases, format compliance, safety, injection resistance, consistency.
Metrics: accuracy, format compliance (100%), safety (>99%), injection resistance (>95%), latency, cost.

### Step 9: Versioning
Track: version, accuracy, latency, cost, status. A/B test with traffic split and significance testing (alpha=0.05).

### Step 10: Artifacts
`prompts/<task>/`: prompt-spec.yaml, system-prompt.md, examples.yaml, tests.yaml, eval-results.md.

## Optimization Loop
```
WHILE iteration < 5 AND accuracy < target:
  1. DIAGNOSE: categorize failures (format, wrong answer, hallucination, refusal)
  2. GENERATE: ONE change targeting top failure category
  3. EVALUATE: same golden set
  4. COMPARE: accept if improved + no regression. Stop if plateau 2 iterations.
```

## Autonomous Operation
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors

1. **Test before shipping.** Golden set evaluation required.
2. **Version everything.** Prompts are code.
3. **Measure, do not guess.** Run evaluation, check significance.
4. **Defense in depth.** Layer sanitization, structure, validation.
5. **Less is more.** Shortest prompt achieving target is best.
6. **Examples beat instructions.**
7. **Model-specific optimization.** Test on the target model.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full workflow |
| `--pattern <name>` | Force pattern |
| `--optimize` | Improve existing prompt |
| `--test` | Run test suite |
| `--harden` | Audit injection defenses |
| `--json` | Design for structured output |
| `--eval` | Full evaluation suite |

## HARD RULES

1. NEVER ship without golden set evaluation.
2. NEVER hardcode prompts inline — externalize to versioned files.
3. NEVER change more than ONE variable per iteration.
4. NEVER ignore injection if user input enters prompt.
5. ALWAYS version prompts with semver.
6. ALWAYS include 2+ few-shot examples for non-trivial tasks.
7. ALWAYS validate structured output against schema.
8. ALWAYS test on the TARGET model.
9. ALWAYS place critical instructions at START and END.
10. NEVER trust user input as instructions — delimit with tags.

## Output Format

```
PROMPT REPORT:
Task: <description> | Pattern: <selected> | Model: <target>
Version: v<N> | Accuracy: <N>% | Latency: <N>ms
Injection hardened: YES/NO | Structured: YES/NO
Verdict: PASS | NEEDS ITERATION
```

## Platform Fallback
Run sequentially: design, test suite, evaluation, security hardening.

## Error Recovery
| Failure | Action |
|--|--|
| Prompt produces inconsistent output | Add structured output format (JSON mode). Increase temperature to 0 for deterministic tasks. Add few-shot examples. |
| Prompt injection bypasses guardrails | Add input sanitization. Use system prompt isolation. Test with known injection payloads. Add output validation. |
| Model refuses valid requests | Rephrase to avoid false-positive safety triggers. Use explicit context setting. Test with alternative phrasing. |
| Evaluation scores drop after edit | Compare diffs between prompt versions. Check if examples were accidentally removed. A/B test old vs new. |

## Success Criteria
1. Prompt produces correct output on all test cases (accuracy target met).
2. Prompt injection test suite passes (zero bypasses).
3. Output format is consistent and parseable.
4. Latency within budget for target model.

## TSV Logging
Append to `.godmode/prompt-results.tsv`:
```
timestamp	prompt_version	model	accuracy_pct	latency_ms	injection_safe	status
```
One row per evaluation run. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH prompt iteration:
  KEEP if: accuracy improved or maintained AND injection tests pass AND output parseable
  DISCARD if: accuracy dropped OR injection bypass found OR output format breaks
  On discard: revert to previous version. Analyze which test cases regressed.
```

## Stop Conditions
```
STOP when ALL of:
  - Accuracy meets target on test suite
  - Injection hardening passes all test cases
  - Output format consistent and parseable
  - Latency within budget
```
