# /godmode:prompt

Engineer, test, version, and optimize prompts for LLMs. Covers prompt design patterns (few-shot, chain-of-thought, ReAct, tree-of-thought), structured output, system prompt design, prompt injection prevention, A/B testing, and evaluation.

## Usage

```
/godmode:prompt                            # Full prompt engineering workflow
/godmode:prompt --pattern few-shot         # Design with specific pattern
/godmode:prompt --pattern cot              # Chain-of-thought prompt
/godmode:prompt --pattern react            # ReAct agent prompt
/godmode:prompt --pattern tot              # Tree-of-thought prompt
/godmode:prompt --model claude             # Target specific model
/godmode:prompt --optimize                 # Analyze and improve existing prompt
/godmode:prompt --test                     # Run prompt test suite
/godmode:prompt --compare v1 v2            # A/B compare prompt versions
/godmode:prompt --harden                   # Audit and fix injection defenses
/godmode:prompt --json                     # Design for structured JSON output
/godmode:prompt --eval                     # Full evaluation suite
/godmode:prompt --version                  # Show prompt version registry
/godmode:prompt --export                   # Export prompt spec as YAML
```

## What It Does

1. Discovers task requirements, target model, input/output formats, and constraints
2. Selects optimal prompt pattern (few-shot, chain-of-thought, ReAct, tree-of-thought, self-consistency)
3. Designs system prompt with role, task, format, constraints, and examples
4. Creates few-shot examples covering common cases and edge cases
5. Designs reasoning structure (CoT, ReAct, ToT) if task requires multi-step reasoning
6. Configures structured output with JSON schema, function calling, or constrained decoding
7. Builds prompt injection defenses (input sanitization, delimiters, output validation, monitoring)
8. Creates test suite with golden set, edge cases, safety tests, and injection resistance tests
9. Versions prompts and supports A/B testing with statistical significance
10. Generates prompt spec, test suite, and evaluation artifacts

## Output
- Prompt spec at `prompts/<task>/prompt-spec.yaml`
- System prompt at `prompts/<task>/system-prompt.md`
- Few-shot examples at `prompts/<task>/examples.yaml`
- Test suite at `prompts/<task>/tests.yaml`
- Evaluation results with accuracy, safety, and format compliance metrics
- Commit: `"prompt: <task> — v<version>, <pattern>, accuracy=<val>, <N> test cases"`

## Next Step
After prompt engineering: `/godmode:eval` to run comprehensive evaluation, `/godmode:rag` to add retrieval context, or `/godmode:agent` to build an agent around the prompt.

## Examples

```
/godmode:prompt Design a prompt to classify support tickets
/godmode:prompt --pattern cot Design a prompt for multi-step reasoning
/godmode:prompt --optimize Our extraction prompt is only 72% accurate
/godmode:prompt --harden Audit our chatbot for injection vulnerabilities
/godmode:prompt --compare v1.1 v1.2 Which prompt version is better?
/godmode:prompt --json Design a prompt that outputs structured JSON
```
