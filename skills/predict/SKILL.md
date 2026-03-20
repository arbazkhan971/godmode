---
name: predict
description: 5-persona evaluation. Independent assessment then consensus.
---

## Activate When
- `/godmode:predict`, "will this work?", "evaluate this approach"

## Workflow
### 1. Define What's Being Evaluated
Read `.godmode/spec.md` or user-provided proposal. Summarize: what changes, what's at risk.
### 2. Run 5 Personas
| Persona | Focus |
|---------|-------|
| Backend Architect (15yr) | Scalability, data model, API design |
| Frontend Lead (12yr) | UX, performance, component design |
| SRE (10yr) | Reliability, monitoring, failure modes |
| Security Researcher (11yr) | Attack surface, data exposure, auth |
| Product Manager (13yr) | User value, scope, timeline |
Each outputs: Verdict (YES/REVISE/NO), Confidence (1-10), Risk (one sentence + file:line), Mitigation (code change or architecture suggestion).
### 3. Synthesize Consensus
Avg confidence, concerns raised by 3+ personas, key disagreements, recommendation: PROCEED / REVISE (with specific changes) / RETHINK.
### 4. Gate
IF average confidence < 7 → loop back to `/godmode:think` with all risks attached.

## Rules
1. Every persona cites file:line. No finding without code evidence.
2. Disagreements are signal. Report them as-is — don't average conflicting views.
3. Confidence < 7 = `/godmode:think` with risks attached. Never proceed to `/godmode:plan` on shaky designs.
