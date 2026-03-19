---
name: aiops
description: |
  AI Operations and safety skill. Activates when users need to operate, monitor, secure, and optimize AI/LLM applications in production. Covers guardrails and content filtering, hallucination detection and mitigation, token cost optimization, latency optimization (caching, streaming, batching), AI safety testing (red-teaming, adversarial inputs), and monitoring LLM applications (latency, quality, cost). Every AI system gets a structured operations plan, guardrail config, monitoring dashboard, and cost analysis. Triggers on: /godmode:aiops, "add guardrails", "reduce LLM costs", "monitor AI", "AI safety", or when the orchestrator detects LLM application operational needs.
---

# AIOps — AI Operations & Safety

## When to Activate
- User invokes `/godmode:aiops`
- User says "add guardrails", "content filtering", "block harmful outputs"
- User says "reduce LLM costs", "optimize token usage", "my AI is too expensive"
- User says "reduce latency", "speed up my LLM", "cache responses"
- User says "AI safety", "red-team my AI", "test for jailbreaks"
- User says "monitor my AI", "track LLM quality", "hallucination detection"
- When deploying AI applications to production and need operational controls
- When `/godmode:agent` or `/godmode:rag` systems need production hardening
- When the orchestrator detects LLM API calls, guardrail libraries (NeMo Guardrails, Guardrails AI), or monitoring tools (LangSmith, Langfuse, Helicone) in code

## Workflow

### Step 1: AI Operations Discovery
Understand the AI system and its operational requirements:

```
AIOPS DISCOVERY:
System: <description of the AI application>
Architecture:
  - LLM provider: <OpenAI | Anthropic | Google | self-hosted | multiple>
  - Model(s): <model names and versions>
  - Components: <RAG | agent | chatbot | pipeline | batch processing>
  - Traffic: <requests/day, peak requests/min>
  - Users: <internal | customer-facing | both>

Current pain points:
  - [ ] Cost too high ($<current monthly> target: $<target monthly>)
  - [ ] Latency too slow (<current p95> target: <target p95>)
  - [ ] Quality issues (hallucinations, wrong answers, format errors)
  - [ ] Safety gaps (jailbreaks, harmful outputs, data leakage)
  - [ ] No monitoring (blind to quality, cost, and failures)
  - [ ] No guardrails (no input/output validation)

Priority: <cost | latency | quality | safety | monitoring>
```

If the user hasn't specified, ask: "What AI system are you operating, and what is your biggest operational challenge?"

### Step 2: Guardrails & Content Filtering
Design input and output guardrails:

```
GUARDRAILS DESIGN:

Layer 1 -- Input Guardrails:
+-----------------------------+------------------+------------------+------------------------+
| Guard                       | Method           | Latency Impact   | Action on Trigger      |
+-----------------------------+------------------+------------------+------------------------+
| Prompt injection detection  | Classifier +     | +20-50ms         | Block request, log,    |
|                             | heuristic rules  |                  | return safe response   |
|                             |                  |                  |                        |
| PII detection               | NER model +      | +30-80ms         | Redact PII before      |
|                             | regex patterns   |                  | sending to LLM         |
|                             |                  |                  |                        |
| Topic restriction           | Classifier       | +15-30ms         | Redirect to allowed    |
|                             |                  |                  | topics or refuse       |
|                             |                  |                  |                        |
| Input length limit          | Token counter    | +1ms             | Truncate with warning  |
|                             |                  |                  |                        |
| Rate limiting (per user)    | Token bucket     | +1ms             | 429 with retry-after   |
|                             |                  |                  |                        |
| Language detection          | fasttext/langid  | +5ms             | Route or refuse        |
|                             |                  |                  |                        |
| Jailbreak detection         | Classifier +     | +20-50ms         | Block, log, alert      |
|                             | pattern matching |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

Layer 2 -- Output Guardrails:
+-----------------------------+------------------+------------------+------------------------+
| Guard                       | Method           | Latency Impact   | Action on Trigger      |
+-----------------------------+------------------+------------------+------------------------+
| PII in output               | NER + regex      | +30-80ms         | Redact before return   |
|                             |                  |                  |                        |
| Harmful content             | Safety classifier| +20-50ms         | Block, return fallback |
|                             | (Llama Guard,    |                  | response               |
|                             | OpenAI moderation|                  |                        |
|                             |                  |                  |                        |
| Factual grounding check     | NLI model        | +50-200ms        | Flag ungrounded claims |
|                             |                  |                  | or require citation    |
|                             |                  |                  |                        |
| Format validation           | Schema validator | +1-5ms           | Retry with format      |
|                             | / regex          |                  | instructions           |
|                             |                  |                  |                        |
| Confidential data leakage   | Pattern matcher  | +10-30ms         | Block, log, alert      |
|                             | + classifier     |                  |                        |
|                             |                  |                  |                        |
| Toxicity / bias             | Toxicity model   | +20-50ms         | Block or soften        |
|                             |                  |                  |                        |
| Hallucination detection     | Source comparison | +50-200ms        | Flag or refuse         |
|                             | + NLI            |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

Guardrail framework:
  Option A: NeMo Guardrails (NVIDIA) -- config-driven, multi-rail, production-ready
  Option B: Guardrails AI -- Python-based, structured output validation
  Option C: Custom middleware -- maximum flexibility, more engineering effort
  Option D: LLM provider built-in (OpenAI moderation, Anthropic constitutional AI)
  SELECTED: <option> -- <justification>

Guardrail configuration:
  Blocking mode: <strict (block on any trigger) | permissive (log, warn, allow) | adaptive>
  Fallback response: <canned response when blocked>
  Human escalation: <conditions for routing to human>
  Bypass: <admin override capability with audit log>
```

### Step 3: Hallucination Detection & Mitigation
Detect and reduce hallucinations:

```
HALLUCINATION MANAGEMENT:

Detection methods:
+-----------------------------+------------------+------------------+------------------------+
| Method                      | Accuracy         | Latency          | Best For               |
+-----------------------------+------------------+------------------+------------------------+
| Source comparison (NLI)     | High             | +50-200ms        | RAG systems with       |
| (check output against       |                  |                  | retrieved sources      |
| retrieved context)          |                  |                  |                        |
|                             |                  |                  |                        |
| Self-consistency            | Medium-High      | 2-3x LLM calls   | General generation     |
| (generate multiple times,   |                  |                  | (no sources needed)    |
| check agreement)            |                  |                  |                        |
|                             |                  |                  |                        |
| Confidence calibration      | Medium           | Minimal           | Classification, QA     |
| (use token probabilities    |                  |                  | with multiple choice   |
| as confidence signal)       |                  |                  |                        |
|                             |                  |                  |                        |
| Knowledge grounding         | High             | +100-500ms       | Factual claims that    |
| (verify claims against       |                  |                  | can be fact-checked    |
| external knowledge)         |                  |                  |                        |
|                             |                  |                  |                        |
| LLM-as-judge               | Medium-High      | +200-1000ms      | Complex outputs        |
| (second LLM evaluates       |                  |                  | (summaries, analysis)  |
| faithfulness)               |                  |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

SELECTED: <method(s)> -- <justification>

Mitigation strategies:
  1. Improve retrieval quality (better context = fewer hallucinations)
  2. Add explicit grounding instructions ("Only answer based on the provided context")
  3. Require citations (force model to reference sources)
  4. Lower temperature (reduce randomness)
  5. Implement "I don't know" behavior (train model to refuse when unsure)
  6. Chain-of-thought with verification (think step by step, then verify each claim)
  7. Source attribution scoring (score each claim against retrieved sources)

Hallucination monitoring:
  Metric: hallucination rate (% of responses with unsupported claims)
  Baseline: <current val>
  Target: <target val>
  Measurement: <automated NLI scoring on N% of responses>
  Alert threshold: hallucination rate > <val>
```

### Step 4: Token Cost Optimization
Reduce LLM costs without sacrificing quality:

```
TOKEN COST OPTIMIZATION:

Current spend analysis:
  Monthly LLM cost: $<val>
  Cost breakdown by component:
  +--------------------+------------------+------------------+------------------+
  | Component          | Model            | Tokens/month     | Cost/month       |
  +--------------------+------------------+------------------+------------------+
  | <component 1>      | <model>          | <N>M             | $<val>           |
  | <component 2>      | <model>          | <N>M             | $<val>           |
  | <component 3>      | <model>          | <N>M             | $<val>           |
  | TOTAL              |                  | <N>M             | $<val>           |
  +--------------------+------------------+------------------+------------------+

Optimization strategies:
+-----------------------------+------------------+------------------+------------------------+
| Strategy                    | Savings          | Quality Impact   | Implementation Effort  |
+-----------------------------+------------------+------------------+------------------------+
| Model routing               | 40-70%           | Minimal          | Medium                 |
| (use cheaper model for      |                  | (route by        |                        |
| simple queries, expensive   |                  | complexity)      |                        |
| model for complex ones)     |                  |                  |                        |
|                             |                  |                  |                        |
| Prompt compression          | 20-50%           | Low              | Low                    |
| (shorten system prompts,    |                  | (test carefully) |                        |
| remove redundant context)   |                  |                  |                        |
|                             |                  |                  |                        |
| Response caching            | 30-80%           | None             | Low                    |
| (cache identical or similar |                  | (exact match)    |                        |
| queries)                    |                  |                  |                        |
|                             |                  |                  |                        |
| Batch processing            | 20-40%           | None             | Medium                 |
| (batch API for non-real-    |                  | (same output)    |                        |
| time workloads)             |                  |                  |                        |
|                             |                  |                  |                        |
| Fine-tuned smaller model    | 50-90%           | Variable         | High                   |
| (replace large model with   |                  | (must evaluate)  |                        |
| fine-tuned smaller one)     |                  |                  |                        |
|                             |                  |                  |                        |
| Context window management   | 10-30%           | Minimal          | Low                    |
| (fewer retrieved chunks,    |                  | (with reranking) |                        |
| shorter conversation hist.) |                  |                  |                        |
|                             |                  |                  |                        |
| Output length control       | 10-30%           | Low              | Low                    |
| (max_tokens, stop sequences |                  |                  |                        |
| structured output)          |                  |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

Model routing design:
  Simple queries (60% of traffic): <cheap model — e.g., Haiku, GPT-4o-mini, Gemini Flash>
  Complex queries (30% of traffic): <standard model — e.g., Sonnet, GPT-4o>
  Expert queries (10% of traffic): <best model — e.g., Opus, o1>
  Router: <classifier | keyword rules | LLM-based routing | complexity score>

Projected savings:
  Strategy 1 (<name>): -$<val>/month (<percentage> reduction)
  Strategy 2 (<name>): -$<val>/month (<percentage> reduction)
  Strategy 3 (<name>): -$<val>/month (<percentage> reduction)
  Combined: -$<val>/month (<percentage> total reduction)
  New monthly cost: $<val>
```

### Step 5: Latency Optimization
Reduce response latency:

```
LATENCY OPTIMIZATION:

Current latency profile:
  End-to-end p50: <ms>
  End-to-end p95: <ms>
  End-to-end p99: <ms>

  Latency breakdown:
  +--------------------+----------+----------+----------------------------------------+
  | Component          | p50      | p95      | Bottleneck?                            |
  +--------------------+----------+----------+----------------------------------------+
  | Input guardrails   | <ms>     | <ms>     | <yes/no>                               |
  | Embedding          | <ms>     | <ms>     | <yes/no>                               |
  | Retrieval          | <ms>     | <ms>     | <yes/no>                               |
  | LLM inference      | <ms>     | <ms>     | <yes/no -- usually dominant>           |
  | Output guardrails  | <ms>     | <ms>     | <yes/no>                               |
  | Network overhead   | <ms>     | <ms>     | <yes/no>                               |
  +--------------------+----------+----------+----------------------------------------+

Optimization strategies:
+-----------------------------+------------------+------------------+------------------------+
| Strategy                    | Latency Reduction| Complexity       | Tradeoff               |
+-----------------------------+------------------+------------------+------------------------+
| Streaming responses         | Perceived: 80%+  | Low              | No full-response       |
|                             | (TTFT matters)   |                  | guardrails             |
|                             |                  |                  |                        |
| Response caching            | 95%+ (cache hit) | Low-Medium       | Stale responses,       |
| (exact + semantic caching)  |                  |                  | cache invalidation     |
|                             |                  |                  |                        |
| Parallel processing         | 30-60%           | Medium           | More concurrent        |
| (run retrieval + guardrails |                  |                  | resources              |
| in parallel)                |                  |                  |                        |
|                             |                  |                  |                        |
| Smaller/faster model        | 40-70%           | Low              | Quality tradeoff       |
|                             |                  |                  |                        |
| Speculative decoding        | 20-40%           | High             | Draft model overhead   |
|                             |                  |                  |                        |
| KV-cache optimization       | 20-50%           | Medium           | Memory usage           |
|                             |                  |                  |                        |
| Request batching            | Throughput: 2-5x | Medium           | Individual latency     |
| (batch similar requests)    |                  |                  | may increase           |
|                             |                  |                  |                        |
| Edge deployment             | 30-60%           | High             | Model size constraints |
| (run model closer to user)  |                  |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

Caching design:
  Exact match cache:
    Key: hash(system_prompt + user_message)
    TTL: <seconds>
    Hit rate estimate: <percentage>

  Semantic cache:
    Key: embedding similarity > <threshold>
    TTL: <seconds>
    Hit rate estimate: <percentage>
    Risk: returning wrong cached response (set threshold high: 0.98+)

  Cache storage: <Redis | in-memory | CDN | dedicated cache service>
  Cache size: <N entries / N MB>
  Invalidation: <TTL | on data update | manual>

Streaming configuration:
  TTFT (Time to First Token) target: <ms>
  Enable streaming: <server-sent events | WebSocket>
  Guardrail integration: run output guardrails on accumulated tokens at <N> token intervals
```

### Step 6: AI Safety Testing
Systematically test for safety vulnerabilities:

```
AI SAFETY TESTING:

Red-team framework:
+-----------------------------+------------------+------------------+------------------------+
| Attack Category             | Tests            | Severity         | Mitigation             |
+-----------------------------+------------------+------------------+------------------------+
| Prompt injection            | <N> tests        | CRITICAL         | Input classifier,      |
| (direct and indirect)       |                  |                  | instruction hierarchy   |
|                             |                  |                  |                        |
| Jailbreaking                | <N> tests        | CRITICAL         | Constitutional AI,     |
| (bypass safety via          |                  |                  | multi-layer guardrails |
| creative prompting)         |                  |                  |                        |
|                             |                  |                  |                        |
| Data extraction             | <N> tests        | HIGH             | Output filtering,      |
| (extract training data,     |                  |                  | PII detection          |
| system prompt, or PII)      |                  |                  |                        |
|                             |                  |                  |                        |
| Harmful content generation  | <N> tests        | HIGH             | Safety classifier,     |
|                             |                  |                  | topic restrictions     |
|                             |                  |                  |                        |
| Bias amplification          | <N> tests        | MEDIUM           | Bias detection,        |
| (model produces biased      |                  |                  | fairness monitoring    |
| or discriminatory output)   |                  |                  |                        |
|                             |                  |                  |                        |
| Denial of service           | <N> tests        | MEDIUM           | Rate limiting, input   |
| (resource exhaustion via     |                  |                  | length limits          |
| adversarial inputs)         |                  |                  |                        |
|                             |                  |                  |                        |
| Multi-turn manipulation     | <N> tests        | HIGH             | Conversation-level     |
| (gradually steer model      |                  |                  | monitoring, reset      |
| across multiple turns)      |                  |                  | thresholds             |
|                             |                  |                  |                        |
| Tool misuse (agents)        | <N> tests        | CRITICAL         | Tool-level guardrails, |
| (trick agent into calling   |                  |                  | confirmation gates     |
| dangerous tools)            |                  |                  |                        |
+-----------------------------+------------------+------------------+------------------------+

Test execution:
  Automated adversarial suite:
    Tool: <Garak | custom red-team suite | manual>
    Prompts tested: <N>
    Attack success rate: <percentage> (target: <1%)
    Categories passed: <N>/<total>
    Categories failed: <list>

  Human red-teaming:
    Red-teamers: <N people with diverse backgrounds>
    Duration: <hours>
    Findings: <N critical, N high, N medium, N low>
    Novel attacks found: <description>

Safety scorecard:
+-----------------------------+----------+----------+
| Category                    | Score    | Status   |
+-----------------------------+----------+----------+
| Prompt injection resistance | <val>/10 | <P/F>    |
| Jailbreak resistance        | <val>/10 | <P/F>    |
| PII protection              | <val>/10 | <P/F>    |
| Harmful content blocking    | <val>/10 | <P/F>    |
| Bias and fairness           | <val>/10 | <P/F>    |
| Data leakage prevention     | <val>/10 | <P/F>    |
| Tool safety (if agent)      | <val>/10 | <P/F>    |
| OVERALL                     | <val>/10 | <P/F>    |
+-----------------------------+----------+----------+

VERDICT: <PASS | FAIL -- list blocking issues>
```

### Step 7: LLM Application Monitoring
Design the monitoring stack:

```
LLM MONITORING:

Metrics to track:
+-----------------------------+------------------+------------------+------------------------+
| Metric                      | Collection       | Alert Threshold  | Dashboard              |
+-----------------------------+------------------+------------------+------------------------+
| Request volume              | Counter          | >2x baseline     | Traffic panel          |
| Latency (p50, p95, p99)    | Histogram        | p95 > <ms>       | Latency panel          |
| TTFT (streaming)            | Histogram        | > <ms>           | Latency panel          |
| Error rate                  | Counter/rate     | > <percentage>   | Errors panel           |
| Token usage (in/out)        | Counter          | > <N>/hour       | Cost panel             |
| Cost per request            | Gauge            | > $<val>         | Cost panel             |
| Daily/monthly cost          | Counter          | > $<val>         | Cost panel             |
| Cache hit rate              | Counter/rate     | < <percentage>   | Performance panel      |
| Guardrail trigger rate      | Counter/rate     | > <percentage>   | Safety panel           |
| Hallucination rate          | Gauge            | > <percentage>   | Quality panel          |
| User satisfaction           | Gauge            | < <score>        | Quality panel          |
| Model version distribution  | Gauge            | --               | Deployment panel       |
+-----------------------------+------------------+------------------+------------------------+

Quality monitoring:
  Automated quality scoring:
    Method: <LLM-as-judge on N% sample | NLI scoring | user feedback>
    Sample rate: <percentage of responses evaluated>
    Metrics:
      - Relevance score: <0-1, how well response addresses query>
      - Faithfulness score: <0-1, how grounded in provided context>
      - Helpfulness score: <0-1, how useful to the user>
      - Format compliance: <0-1, follows expected format>

  User feedback integration:
    Signals: <thumbs up/down | 1-5 rating | free-text feedback | implicit (copy, share)>
    Feedback rate: <percentage of interactions with feedback>
    Negative feedback analysis: <cluster negative feedback to identify patterns>

Monitoring stack:
  Option A: LangSmith (LangChain ecosystem, traces + evals)
  Option B: Langfuse (open-source, traces + scoring + cost)
  Option C: Helicone (API proxy, cost + latency + caching)
  Option D: Arize Phoenix (open-source, traces + evals + embeddings)
  Option E: Custom (OpenTelemetry + Prometheus + Grafana)
  SELECTED: <option> -- <justification>

Tracing:
  Trace every request:
    - Input (sanitized -- no PII)
    - Retrieved context (if RAG)
    - LLM prompt (full prompt sent to model)
    - LLM response
    - Guardrail triggers
    - Latency per component
    - Token count and cost
    - User feedback (if available)

  Retention: <N days>
  Sampling: <100% for first N days, then N% for cost>

Alerting:
  Channel: <Slack | PagerDuty | email | webhook>
  Severity levels:
    CRITICAL: safety violation, data leakage -> immediate page
    HIGH: error rate spike, latency degradation -> alert within 5 min
    MEDIUM: cost increase, quality drop -> daily digest
    LOW: anomalous patterns -> weekly review
```

### Step 8: Artifacts & Commit
Generate deliverables:

1. **Guardrail config**: `configs/aiops/<system>-guardrails.yaml`
2. **Monitoring config**: `configs/aiops/<system>-monitoring.yaml`
3. **Safety test suite**: `tests/aiops/<system>/safety_tests.py`
4. **Cost analysis**: `docs/aiops/<system>-cost-analysis.md`
5. **Runbook**: `docs/aiops/<system>-runbook.md`

```
AIOPS COMPLETE:

Guardrails:
- Input guards: <N> (injection, PII, topic, rate limit)
- Output guards: <N> (PII, harmful, hallucination, format)
- Framework: <guardrail framework>
- Blocking mode: <strict | permissive | adaptive>

Safety:
- Red-team tests: <N> (attack success rate: <val>%)
- Safety score: <val>/10
- Blocking issues: <none | list>

Cost:
- Current monthly: $<val>
- Optimized monthly: $<val> (<percentage> reduction)
- Key savings: <top 3 optimizations>

Latency:
- Current p95: <ms>
- Optimized p95: <ms>
- Key improvements: <top 3 optimizations>

Monitoring:
- Stack: <monitoring tool>
- Metrics tracked: <N>
- Alerts configured: <N>
- Quality scoring: <method>

Artifacts:
- Guardrails: configs/aiops/<system>-guardrails.yaml
- Monitoring: configs/aiops/<system>-monitoring.yaml
- Safety tests: tests/aiops/<system>/safety_tests.py
- Cost analysis: docs/aiops/<system>-cost-analysis.md
- Runbook: docs/aiops/<system>-runbook.md

Next steps:
-> /godmode:secure -- Deep security audit of the AI system
-> /godmode:observe -- Integrate with broader observability stack
-> /godmode:loadtest -- Load test the AI system
-> /godmode:incident -- Set up incident response for AI failures
```

Commit: `"aiops: <system> -- guardrails=<N>, safety=<score>/10, cost=-<percentage>%, latency_p95=<ms>"`

## Key Behaviors

1. **Guardrails before launch.** No AI system goes to production without input and output guardrails. This is non-negotiable. Even internal tools need basic safety controls.
2. **Cost is a feature.** Token costs are not an afterthought. Model routing, caching, and prompt compression are as important as the AI logic itself. Track cost per request from day one.
3. **Latency is perceived quality.** A slow AI response feels broken. Streaming, caching, and parallel processing are not optimizations -- they are requirements for user experience.
4. **Hallucinations are the primary risk.** For RAG and knowledge systems, hallucination rate is the most critical metric. Measure it, monitor it, and never deploy without it.
5. **Red-team before deploy, continuously after.** Safety is not a one-time check. Adversarial techniques evolve. Re-test regularly and monitor for novel attacks.
6. **Monitor quality, not just availability.** Traditional uptime monitoring is necessary but insufficient. An AI that returns fast, confident, wrong answers is worse than one that is down.
7. **Trace everything.** Every LLM call should be traceable: input, output, latency, cost, guardrail triggers. You cannot debug, optimize, or improve what you cannot observe.

## Example Usage

### Adding Guardrails to a RAG System
```
User: /godmode:aiops Add guardrails to our customer support chatbot

AIOps: Starting discovery...

AIOPS DISCOVERY:
System: Customer support chatbot (RAG + Claude Sonnet)
Traffic: 5,000 queries/day, peak 500/hour
Users: Customer-facing
Priority: Safety (customer-facing) + Cost

GUARDRAILS:
Input:
  - Prompt injection detection (classifier, +25ms)
  - PII redaction (NER + regex, +40ms)
  - Topic restriction (support topics only, +15ms)
  - Rate limit (10 queries/min per user)

Output:
  - PII detection (block customer data in responses, +40ms)
  - Hallucination check (NLI against retrieved context, +100ms)
  - Format validation (JSON schema, +2ms)
  - Toxicity filter (Llama Guard, +30ms)

Framework: NeMo Guardrails (config-driven, multi-rail)
Blocking mode: Strict (customer-facing)

SAFETY TESTING:
  120 adversarial prompts tested
  Attack success rate: 0.8% (1 partial injection)
  Action: patched injection pattern, retested at 0%

COST OPTIMIZATION:
  Model routing: simple FAQs -> Haiku (60% of traffic)
  Caching: exact match + semantic cache (cache hit: 35%)
  Savings: $2,400/month -> $890/month (63% reduction)

Verdict: PASS -- guardrails active, safety tested, cost optimized.
```

### Reducing LLM Costs
```
User: /godmode:aiops --cost Our AI spend is $15K/month, need to cut to $5K

AIOps: Analyzing cost breakdown...

COST ANALYSIS:
  Total: $15,200/month
  - RAG generation (GPT-4): $8,100 (53%)
  - Embedding (text-embedding-3-large): $2,300 (15%)
  - Agent tool calls (GPT-4): $3,100 (20%)
  - Guardrail classifiers: $1,700 (12%)

OPTIMIZATION PLAN:
  1. Model routing: 65% of RAG queries -> GPT-4o-mini (-$4,800)
  2. Semantic caching (40% hit rate): (-$2,100)
  3. Smaller embeddings (3072d -> 1024d Matryoshka): (-$1,500)
  4. Batch guardrails (non-real-time): (-$800)
  5. Prompt compression (remove redundant context): (-$600)

  Total savings: -$9,800/month
  New monthly cost: $5,400

  Quality impact:
  - RAG accuracy: 94.1% -> 93.2% (routing to smaller model)
  - All other metrics: unchanged

Recommendation: implement strategies 1-3 first ($8,400 savings, minimal quality impact).
Strategy 4-5 if further reduction needed.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full AI operations workflow |
| `--guardrails` | Design and configure guardrails |
| `--safety` | Run AI safety testing (red-team) |
| `--cost` | Analyze and optimize token costs |
| `--latency` | Analyze and optimize latency |
| `--monitor` | Set up LLM monitoring |
| `--hallucination` | Detect and mitigate hallucinations |
| `--audit` | Full operational audit (guardrails + safety + cost + monitoring) |
| `--cache` | Design and configure caching strategy |
| `--route` | Design model routing strategy |
| `--trace <request_id>` | Debug a specific request trace |
| `--dashboard` | Generate monitoring dashboard configuration |

## Auto-Detection

Before prompting the user, automatically detect the AI system context:

```
AUTO-DETECT SEQUENCE:
1. Scan for LLM provider SDKs:
   - grep for 'openai', 'anthropic', '@google/generative-ai', 'replicate'
   - Check API keys in .env.example (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc.)
2. Detect AI frameworks:
   - LangChain: grep for 'langchain', '@langchain'
   - LlamaIndex: grep for 'llama_index', 'llama-index'
   - Custom: grep for 'chat.completions', 'messages.create'
3. Detect existing guardrails:
   - grep for 'nemo-guardrails', 'guardrails-ai', 'llama-guard'
   - Check for content filtering middleware
4. Detect monitoring:
   - grep for 'langsmith', 'langfuse', 'helicone', 'phoenix'
   - Check for OpenTelemetry tracing on LLM calls
5. Detect RAG components:
   - grep for 'pinecone', 'weaviate', 'chromadb', 'qdrant', 'pgvector'
6. Detect agent patterns:
   - grep for 'tools', 'function_calling', 'tool_choice'
   - Check for agent loop patterns (while loops with LLM calls)
7. Auto-configure priority based on findings:
   - No guardrails detected → priority: safety
   - No monitoring detected → priority: monitoring
   - High token usage patterns → priority: cost
```

## Explicit Loop Protocol

For iterative optimization of AI systems:

```
AIOPS OPTIMIZATION LOOP:
current_iteration = 0
max_iterations = 15
metrics = { cost: current_cost, latency: current_p95, quality: current_score, safety: current_score }
targets = { cost: target_cost, latency: target_p95, quality: target_score, safety: 10 }

WHILE any(metrics[k] worse than targets[k]) AND current_iteration < max_iterations:
    current_iteration += 1

    1. IDENTIFY highest-impact optimization from gap analysis
    2. IMPLEMENT optimization (guardrail config, model routing, caching, prompt edit)
    3. git commit: "aiops: <optimization> (iter {current_iteration})"
    4. MEASURE all metrics after change (not just the targeted one)
    5. IF quality or safety regressed:
       - git revert
       - Try alternative approach
    6. RECORD in TSV log:
       ITER\tOPTIMIZATION\tCOST\tLATENCY_P95\tQUALITY\tSAFETY

    IF current_iteration % 5 == 0:
        PRINT STATUS:
        "Iteration {current_iteration}/{max_iterations}"
        "Cost: ${metrics.cost}/mo (target: ${targets.cost}/mo)"
        "Latency P95: {metrics.latency}ms (target: {targets.latency}ms)"
        "Quality: {metrics.quality}/10 (target: {targets.quality}/10)"
        "Safety: {metrics.safety}/10 (target: 10/10)"
```

## Multi-Agent Dispatch

For comprehensive AI operations audits, parallelize across concerns:

```
PARALLEL AIOPS AUDIT:
IF system has multiple components (RAG + agent + guardrails):
  Agent 1 (worktree: aiops-safety):
    - Run full red-team test suite
    - Test prompt injection resistance
    - Audit guardrail coverage
    - Verify PII handling

  Agent 2 (worktree: aiops-cost):
    - Analyze token usage per component
    - Identify model routing opportunities
    - Design caching strategy for repeated queries
    - Calculate projected savings

  Agent 3 (worktree: aiops-quality):
    - Run hallucination detection on sample responses
    - Evaluate response quality with LLM-as-judge
    - Test edge cases and failure modes
    - Measure retrieval quality (if RAG)

  Agent 4 (worktree: aiops-monitoring):
    - Set up tracing for all LLM calls
    - Configure cost tracking and alerts
    - Build quality monitoring dashboard
    - Set up guardrail trigger alerting

  COORDINATOR merges all findings into unified operations report
```

## Anti-Patterns

- **Do NOT deploy AI without guardrails.** "We'll add guardrails later" means "we'll add them after the incident." Input and output validation are launch requirements.
- **Do NOT ignore cost until the bill arrives.** Track token usage from day one. Set budgets and alerts. Cost surprises are engineering failures.
- **Do NOT treat latency as an optimization.** For user-facing AI, latency is a core requirement. Streaming and caching should be in the initial design, not bolted on later.
- **Do NOT rely solely on LLM provider safety.** Provider safety filters are a baseline. Customer-facing applications need additional guardrails specific to your use case.
- **Do NOT test safety once and forget.** Adversarial techniques evolve monthly. New jailbreaks, injection patterns, and attack vectors emerge continuously. Re-test regularly.
- **Do NOT monitor availability without quality.** An AI system that is up but returning hallucinated answers is worse than downtime. Monitor quality metrics alongside latency and errors.
- **Do NOT cache without invalidation.** Cached responses can become stale or wrong. Define TTL, invalidation triggers, and quality checks for cached responses.
- **Do NOT use the most expensive model for everything.** Model routing (cheap model for simple queries, expensive model for complex ones) is one of the highest-leverage cost optimizations.
