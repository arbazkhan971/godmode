# /godmode:aiops

AI Operations and safety workflow. Provides structured operational controls for AI/LLM applications in production -- guardrails, hallucination detection, cost optimization, latency optimization, safety testing, and monitoring.

## Usage

```
/godmode:aiops                             # Full AI operations workflow
/godmode:aiops --guardrails                # Design and configure guardrails
/godmode:aiops --safety                    # Run AI safety testing (red-team)
/godmode:aiops --cost                      # Analyze and optimize token costs
/godmode:aiops --latency                   # Analyze and optimize latency
/godmode:aiops --monitor                   # Set up LLM monitoring
/godmode:aiops --hallucination             # Detect and mitigate hallucinations
/godmode:aiops --audit                     # Full operational audit
/godmode:aiops --cache                     # Design caching strategy
/godmode:aiops --route                     # Design model routing strategy
/godmode:aiops --trace <request_id>        # Debug a specific request
/godmode:aiops --dashboard                 # Generate monitoring dashboard config
```

## What It Does

1. Discovers AI system architecture and operational pain points
2. Designs input and output guardrails (injection detection, PII redaction, content filtering, format validation)
3. Implements hallucination detection and mitigation (NLI, self-consistency, grounding checks)
4. Optimizes token costs (model routing, caching, prompt compression, batch processing)
5. Optimizes latency (streaming, caching, parallel processing, smaller models)
6. Runs AI safety testing (prompt injection, jailbreaking, data extraction, bias, adversarial inputs)
7. Designs LLM monitoring stack (latency, quality, cost, traces, alerts)

## Output
- Guardrail config at `configs/aiops/<system>-guardrails.yaml`
- Monitoring config at `configs/aiops/<system>-monitoring.yaml`
- Safety test suite at `tests/aiops/<system>/safety_tests.py`
- Cost analysis at `docs/aiops/<system>-cost-analysis.md`
- Commit: `"aiops: <system> -- guardrails=<N>, safety=<score>/10, cost=-<pct>%, latency_p95=<ms>"`

## Key Principles

1. **Guardrails before launch** -- no AI goes to production without input/output validation
2. **Cost is a feature** -- track cost per request from day one, optimize with model routing and caching
3. **Latency is perceived quality** -- streaming and caching are requirements, not optimizations
4. **Hallucinations are the primary risk** -- measure and monitor hallucination rate continuously
5. **Red-team before deploy, continuously after** -- adversarial techniques evolve monthly
6. **Monitor quality, not just availability** -- fast wrong answers are worse than downtime
7. **Trace everything** -- every LLM call should be traceable

## Next Step
If guardrails active: `/godmode:aiops --safety` to red-team.
If cost too high: `/godmode:aiops --cost` to optimize spend.
If quality issues: `/godmode:aiops --hallucination` to diagnose.

## Examples

```
/godmode:aiops                             # Full operational setup
/godmode:aiops --guardrails                # Add input/output guardrails
/godmode:aiops --cost                      # Cut LLM spend by 50%+
/godmode:aiops --safety                    # Red-team test the AI system
/godmode:aiops --monitor                   # Set up observability
```
