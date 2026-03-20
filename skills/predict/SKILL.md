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
Each outputs: Verdict (YES/REVISE/NO), Confidence (1-10), Risk (one sentence + file:line), Mitigation (code change or architecture suggestion).
### 3. Synthesize Consensus
Print: `Confidence: {avg}/10. Blockers: {list}. Split votes: {list}. Gate: PROCEED (≥7) / REVISE (4-6) / RETHINK (<4).`
### 4. Gate
IF avg < 7 → `/godmode:think` with all risks as constraints. IF any persona says NO → `/godmode:think` regardless of avg.

## Rules
1. Every persona cites file:line. No finding without code evidence. Generic advice like 'add more tests' is not a finding.
2. Disagreements are signal. Report them as-is — don't average conflicting views.
3. Confidence < 7 → `/godmode:think` with risks. Confidence ≥ 7 → `/godmode:plan`. Never skip this gate.
