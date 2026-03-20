---
name: predict
description: 5-persona evaluation. Independent assessment then consensus.
---

## Activate When
- `/godmode:predict`, "will this work?", "evaluate this approach"

## Workflow
### 1. Define What's Being Evaluated
Read `.godmode/spec.md` or user-provided proposal. If no spec exists, ask user to run `/godmode:think` first.
### 2. Run 5 Personas
| Persona | Focus |
|---------|-------|
| Backend Architect (15yr) | Scalability, data model, API contracts, error handling |
| Frontend Lead (12yr) | UX, performance, component design |
| SRE (10yr) | Reliability, monitoring, failure modes |
| Security Researcher (11yr) | Attack surface, data exposure, auth, supply chain |
| Product Manager (13yr) | User value, scope, timeline |
Each outputs: `VERDICT: YES|REVISE|NO`, `CONFIDENCE: 1-10`, `RISK: {sentence} @ {file:line}`, `MITIGATION: {concrete change}`.
### 3. Synthesize Consensus
Print: `Confidence: {avg}/10. Blockers: {list}. Split votes: {list}. Gate: PROCEED (≥7) / REVISE (4-6) / RETHINK (<4).`
### 4. Gate
IF avg < 7 → `/godmode:think` with all risks as constraints. IF any persona says NO → `/godmode:think` regardless of avg.

## Output Format
Print: `Predict: Confidence {avg}/10. Blockers: {count}. Gate: PROCEED|REVISE|RETHINK. Verdicts: {YES_count}Y {REVISE_count}R {NO_count}N.`

## TSV Logging
Append `.godmode/predict-log.tsv`: timestamp, feature, persona, verdict, confidence, risk_summary, mitigation, gate_result.

## Rules
1. Every finding: file:line + specific risk. 'Add more tests' or 'consider error handling' = rejected. Must name the exact failure.
2. Disagreements are signal. Report them as-is — don't average conflicting views.
3. Gate: avg < 7 → `/godmode:think` (attach all risks). avg ≥ 7 + no NO votes → `/godmode:plan`. This gate is mandatory.
