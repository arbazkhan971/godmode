---
name: predict
description: |
  Multi-persona evaluation. 5 expert personas independently assess a proposal, then consensus is synthesized.
---

# Predict — Multi-Persona Evaluation

## Activate When
- `/godmode:predict`, "will this work?", "evaluate this approach"
- Invoked by `/godmode:think` for design validation

## Workflow

### 1. Define What's Being Evaluated
Read the spec/proposal. Summarize in one sentence.

### 2. Run 5 Personas

| Persona | Focus |
|---------|-------|
| Backend Architect (15yr) | Scalability, data model, API design |
| Frontend Lead (12yr) | UX, performance, component design |
| SRE (10yr) | Reliability, monitoring, failure modes |
| Security Researcher (11yr) | Attack surface, data exposure, auth |
| Product Manager (13yr) | User value, scope, timeline |

Each persona outputs: Verdict (YES / YES WITH CHANGES / NO), Confidence (1-10 with justification), Biggest risk (one sentence), Evidence (file:line — mandatory), One thing I'd change.

### 3. Synthesize Consensus
Average confidence, unanimous concerns (raised by 3+), disagreements (with reasons), recommendation: PROCEED / REVISE / RETHINK.

### 4. Gate
IF average confidence < 7 → loop back to `/godmode:think` with all risks attached.

## Rules
1. Every persona cites code evidence. No generic advice.
2. Disagreements are valuable. Don't smooth them over.
3. Confidence < 7 = go back to think. Don't build on shaky designs.
