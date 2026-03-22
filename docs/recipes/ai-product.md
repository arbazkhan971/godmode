# Recipe: Building an AI-Powered Product

> From concept to deployed AI product. A complete Godmode workflow covering RAG pipelines, agent design, prompt engineering, evaluation, and ML operations.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `think → architect → prompt → rag → build → eval → mlops → observe → ship` |
| **Timeline** | 2-4 weeks from concept to production |
| **Team size** | 1-3 engineers |
| **Example project** | "DocuBot" — an AI-powered customer support agent that answers questions from your documentation |

---

## The Scenario

You are building DocuBot for a developer tools company:
- 500+ pages of documentation (API reference, guides, tutorials, changelog)
- 2,000 support tickets per month (60% are answered in the docs)
- Goal: AI agent that answers documentation questions accurately, reducing support volume by 50%
- Requirements: must cite sources, must know when it does not know, must handle follow-up questions

---

## Phase 1: Design the AI System (Day 1-2)

### Step 1: Think — Define the AI Product

```
> /godmode:think I want to build DocuBot, an AI support agent that answers
  customer questions using our documentation. It needs to be accurate,
  cite sources, handle follow-ups, and know when to escalate to a human.

Godmode: Researching the problem space...

Three questions:
1. What format is the documentation in? (Markdown, HTML, PDF?)
2. Do you need real-time doc updates (answer from latest docs) or is
   a nightly index refresh acceptable?
3. What LLM provider? (OpenAI, Anthropic, self-hosted?)

> Markdown in a Git repo. Nightly refresh is fine. Anthropic Claude.

Godmode: Writing spec...

SPEC: DocuBot — AI Documentation Assistant

User flows:
  1. Customer asks a question in chat widget
  2. DocuBot searches documentation for relevant sections
  3. DocuBot generates an answer citing specific doc pages
  4. If confidence is low, DocuBot says "I'm not sure" and offers
     to create a support ticket
  5. Customer can ask follow-up questions (conversation context maintained)

Architecture approach: RAG (Retrieval-Augmented Generation)
  - Index: Documentation chunked and embedded in vector database
  - Retrieval: Semantic search + keyword search (hybrid)
  - Generation: Claude with retrieved context + system prompt
  - Evaluation: Automated accuracy testing against known Q&A pairs

Non-functional requirements:
  - Response time: < 3 seconds end-to-end
  - Accuracy: > 90% on test question set
  - Hallucination rate: < 5% (must be verifiable from docs)
  - Availability: 99.9% uptime

Saved: docs/specs/docubot.md
Commit: "spec: DocuBot — AI documentation assistant with RAG"
```

### Step 2: Architect — Design the AI Architecture

```
> /godmode:architect

Godmode: Designing AI system architecture...

ARCHITECTURE: DocuBot

  Chat Interface
  (Web widget / API)
┌────────────────────────▼─────────────────────────────┐
  Agent Orchestrator
  (conversation management,
  intent classification,
  escalation logic)
└───────┬──────────────────────────────┬───────────────┘
┌───────▼──────────┐          ┌───────▼──────────┐
| RAG Pipeline |  | Tool Executor |
│                  │          │                  │
| 1. Query rewrite |  | - Create ticket |
| 2. Hybrid search |  | - Check status |
| 3. Rerank |  | - Search issues |
| 4. Context build |  |  |
└───────┬──────────┘          └──────────────────┘
┌───────▼──────────┐    ┌─────────────────────┐
| Vector Database |  | Document Index |
| (Pinecone / | ◄─── | Pipeline (nightly) |
| pgvector) |  |  |
└──────────────────┘    │ 1. Fetch from Git   │
  2. Chunk documents
  3. Generate embeds
  4. Upsert to vector

TECHNOLOGY CHOICES:
  LLM: Claude 3.5 Sonnet (accuracy + speed balance)
  Embeddings: Voyage AI (optimized for code/docs)
  Vector DB: pgvector (PostgreSQL extension — no new infra)
  Chunking: Semantic chunking (by heading sections, 500-1000 tokens)
  Search: Hybrid (vector similarity + BM25 keyword search)
  Reranking: Cohere Rerank (improves retrieval precision)
  Framework: LangChain / LlamaIndex (or custom — see ADR)

Saved: docs/architecture/docubot-architecture.md
Saved: docs/adr/001-rag-over-fine-tuning.md
Saved: docs/adr/002-pgvector-over-pinecone.md
```

---

## Phase 2: Build the RAG Pipeline (Day 3-5)

### Step 3: Prompt — Design the Prompts

```
> /godmode:prompt

Godmode: Designing prompt architecture...

PROMPT ARCHITECTURE:

System Prompt (agent identity and behavior):
  Role: You are DocuBot, an AI assistant for [Company] documentation.
  Behavior rules:
    - Answer ONLY from the provided documentation context
    - Always cite the source document with a link
    - If the answer is not in the context, say "I don't have information
      about that in the documentation" and offer to create a support ticket
    - Never make up information or hallucinate features
    - Be concise — prefer short, accurate answers over long ones
    - For code examples, use the language from the documentation
    - Handle follow-up questions using conversation history

Query Rewrite Prompt:
  Given the conversation history and the user's latest question,
  rewrite the question to be self-contained (resolve pronouns,
  add context from conversation history).
  Example:
    History: "How do I authenticate?" → "Use API keys in the header"
    User: "What about OAuth?"
    Rewritten: "How do I authenticate using OAuth instead of API keys?"

Answer Generation Prompt:
  Given the following documentation excerpts and conversation history,
  answer the user's question.
  Context: {retrieved_chunks}
  Conversation: {history}
  Question: {question}
  Rules:
    - Cite sources as [Doc Title](url)
    - If multiple docs are relevant, synthesize the answer
    - If context is insufficient, say so explicitly

Confidence Assessment Prompt:
  Rate your confidence in the answer from 0-100:
    90-100: Answer is directly stated in the docs
    70-89: Answer is strongly implied by the docs
    50-69: Answer is partially covered, some inference needed
    0-49: Answer is not well-supported by the docs
  If confidence < 70, add disclaimer and offer ticket creation.

Files created:
  src/prompts/system.ts
  src/prompts/query-rewrite.ts
  src/prompts/answer-generation.ts
  src/prompts/confidence.ts
  tests/prompts/prompt-injection.test.ts   — 8 injection tests

Commit: "feat: prompt architecture — system, query rewrite, answer, confidence"
```

### Step 4: RAG — Build the Retrieval Pipeline

```
> /godmode:rag

Godmode: Building RAG pipeline...

RAG PIPELINE IMPLEMENTATION:

Step 1: Document Ingestion
  File: src/ingestion/doc-loader.ts
  - Fetch markdown files from Git repo
  - Parse frontmatter (title, url, category)
  - Track document versions (only re-embed changed docs)

Step 2: Chunking Strategy
  File: src/ingestion/chunker.ts
  - Semantic chunking: split by heading (H2/H3 boundaries)
  - Chunk size: 500-1000 tokens (overlap: 100 tokens)
  - Metadata preserved: title, url, heading hierarchy, category
  - Code blocks kept intact (never split mid-code)

  Statistics:
    Documents: 523
    Chunks: 2,847
    Average chunk size: 680 tokens

Step 3: Embedding Generation
  File: src/ingestion/embedder.ts
  - Model: Voyage AI voyage-code-2
  - Dimension: 1536
  - Batch processing: 100 chunks per API call
  - Cost: ~$0.12 for full corpus

Step 4: Vector Storage
  File: src/ingestion/vector-store.ts
  - pgvector extension on existing PostgreSQL
  - HNSW index for approximate nearest neighbor
  - Table: doc_embeddings (id, chunk_text, embedding, metadata)

Step 5: Hybrid Search
  File: src/retrieval/search.ts
  - Vector search: top 20 by cosine similarity
  - BM25 keyword search: top 20 by term frequency
  - Reciprocal Rank Fusion: merge and rerank
  - Cohere Rerank: final top 5 chunks

Step 6: Context Building
  File: src/retrieval/context-builder.ts
  - Assemble top 5 chunks into a coherent context block
  - Add source metadata for citations
  - Ensure total context < 8000 tokens (leave room for answer)

Pipeline execution:
  Full index: 523 docs → 2,847 chunks → 2,847 embeddings
  Time: 4 minutes 23 seconds
  Incremental update (10 changed docs): 12 seconds

Commit: "feat: RAG pipeline — ingestion, chunking, embedding, hybrid search"
```

### Step 5: Build — Implement the Agent

```
> /godmode:plan

PLAN: 12 tasks
  Task 1: Agent orchestrator (conversation management)
  Task 2: Intent classifier (question vs. action vs. chitchat)
  Task 3: Query rewriting (conversation-aware)
  Task 4: RAG retrieval integration
  Task 5: Answer generation with citations
  Task 6: Confidence scoring and escalation
  Task 7: Tool integration (create ticket, check status)
  Task 8: Conversation memory (sliding window + summary)
  Task 9: Chat API endpoint (WebSocket + REST fallback)
  Task 10: Rate limiting and abuse prevention
  Task 11: Analytics and feedback collection
  Task 12: Nightly index refresh cron job

> /godmode:build

[builds all 12 tasks with TDD]

BUILD COMPLETE: 12 tasks, 64 tests, all passing.

Key files:
  src/agent/orchestrator.ts      — main agent loop
  src/agent/intent-classifier.ts — route user messages
  src/agent/tools.ts             — ticket creation, status check
  src/agent/memory.ts            — conversation history management
  src/api/chat.controller.ts     — WebSocket + REST API
  src/jobs/index-refresh.ts      — nightly documentation re-indexing
```

---

## Phase 3: Evaluate and Improve (Day 6-10)

### Step 6: Eval — Build the Evaluation Suite

```
> /godmode:eval

Godmode: Building AI evaluation framework...

EVALUATION FRAMEWORK:

Dataset creation:
  Source: 200 real support tickets with known answers
  Format: (question, expected_answer, source_doc_url, category)

  Categories:
    - API reference (60 questions)
    - Getting started (40 questions)
    - Troubleshooting (35 questions)
    - Configuration (30 questions)
    - Edge cases / unanswerable (20 questions)
    - Adversarial / prompt injection (15 questions)

Evaluation metrics:
  1. Answer accuracy (LLM-as-judge: does answer match expected?)
  2. Source citation accuracy (did it cite the correct doc?)
  3. Hallucination rate (does answer contain info NOT in docs?)
  4. Unanswerable detection (does it correctly say "I don't know"?)
  5. Response latency (end-to-end time)
  6. Prompt injection resistance (does it stay in character?)

BASELINE EVALUATION (first run):

  Metric                          Score     Target    Status
  Answer accuracy                 78.5%     > 90%     ✗
  Citation accuracy               71.0%     > 85%     ✗
  Hallucination rate              8.2%      < 5%      ✗
  Unanswerable detection          65.0%     > 90%     ✗
  Avg response latency            2.8s      < 3s      ✓
  Prompt injection resistance     93.3%     > 95%     ✗

ANALYSIS:
  Weaknesses:
  1. Retrieval recall is low — correct doc not in top 5 for 22% of queries
  2. Hallucination when context is partially relevant
  3. "I don't know" threshold too low — answers when it should not
  4. Follow-up questions lose context after 3 turns

Saved: docs/eval/docubot-baseline-eval.md
Commit: "eval: baseline evaluation — 200 test cases, 6 metrics"
```

### Step 7: Optimize — Improve AI Performance

```
> /godmode:optimize \
    --goal "DocuBot answer accuracy" \
    --verify "python eval/run_eval.py --metric accuracy" \
    --target "> 90" \
    --iterations 30

Godmode: Starting AI optimization loop...

Baseline: 78.5% accuracy

ITER  CHANGE                                    ACCURACY  CHANGE   VERDICT
 1    Increase retrieval from top-5 to top-8    78.5%→83.0%  +4.5%  KEEP
 2    Add query rewriting for follow-ups        83.0%→85.5%  +2.5%  KEEP
 3    Add Cohere reranking after hybrid search  85.5%→88.0%  +2.5%  KEEP
 4    Reduce chunk size from 1000 to 600 tokens 88.0%→89.5%  +1.5%  KEEP
 5    Add "answer not found" few-shot examples  89.5%→91.0%  +1.5%  KEEP
      to system prompt
 6    Increase chunk overlap from 100 to 200    91.0%→91.5%  +0.5%  KEEP
 7    Add section heading context to each chunk 91.5%→92.5%  +1.0%  KEEP
 8    Use Claude 3.5 Opus instead of Sonnet     92.5%→93.0%  +0.5%  REVERT
      (4x cost for 0.5% gain — not worth it)
 9    Add parent-document retrieval (fetch       92.5%→93.5%  +1.0%  KEEP
      surrounding sections for context)
10    Fine-tune confidence threshold (70→75)     93.5%→94.0%  +0.5%  KEEP

TARGET ACHIEVED at iteration 10

FULL METRICS (post-optimization):

  Metric                          Before    After     Target    Status
  Answer accuracy                 78.5%     94.0%     > 90%     ✓
  Citation accuracy               71.0%     91.5%     > 85%     ✓
  Hallucination rate              8.2%      3.1%      < 5%      ✓
  Unanswerable detection          65.0%     92.0%     > 90%     ✓
  Avg response latency            2.8s      2.4s      < 3s      ✓
  Prompt injection resistance     93.3%     96.7%     > 95%     ✓

All targets met.
Commit: "optimize: AI accuracy 78.5% → 94.0% in 10 iterations"
```

---

## Phase 4: Production Deployment (Day 10-14)

### Step 8: MLOps — Prepare for Production

```
> /godmode:mlops

Godmode: Configuring ML operations...

MLOPS CONFIGURATION:

Model versioning:
  - Prompt versions tracked in Git (src/prompts/)
  - Embedding model version pinned (voyage-code-2 v1.3)
  - LLM version pinned (claude-3-5-sonnet-20241022)
  - Evaluation results stored per version

Deployment:
  - Blue-green deployment for prompt/retrieval changes
  - A/B testing framework for comparing prompt variants
  - Canary rollout: new prompts serve 10% traffic, compare metrics

Monitoring:
  - Real-time accuracy tracking (sample 5% of conversations for LLM-judge eval)
  - Hallucination detection (compare answer claims against retrieved docs)
  - Retrieval quality (log search queries and retrieved chunk relevance)
  - Latency tracking per pipeline stage
  - Cost tracking per conversation (token usage)

Drift detection:
  - Weekly automated eval run against 200-question test set
  - Alert if accuracy drops below 88% (2% below target)
  - Alert if hallucination rate exceeds 5%
  - Alert if new question categories appear (distribution shift)

Feedback loop:
  - Thumbs up/down on every answer
  - "Was this helpful?" after conversation ends
  - Human review queue for low-confidence answers
  - Monthly eval dataset refresh with new questions from support tickets

Guardrails:
  - Max tokens per response: 2000 (prevent runaway generation)
  - Max conversation length: 20 turns (suggest ticket for long convos)
  - Content filter: reject harmful/off-topic queries
  - PII detection: mask any PII in logs

Files created:
  src/monitoring/accuracy-tracker.ts
  src/monitoring/hallucination-detector.ts
  src/monitoring/drift-detector.ts
  src/monitoring/cost-tracker.ts
  src/feedback/collector.ts
  src/guardrails/content-filter.ts
  src/guardrails/pii-detector.ts

Commit: "mlops: monitoring, drift detection, guardrails, feedback loop"
```

### Step 9: Observe — Set Up AI-Specific Monitoring

```
> /godmode:observe

Godmode: Setting up AI observability...

AI OBSERVABILITY DASHBOARD:

Conversation metrics:
  - Conversations/hour (volume)
  - Avg turns per conversation (engagement)
  - Resolution rate (answered without escalation)
  - Escalation rate (handed off to human)
  - Thumbs up/down ratio (satisfaction)

Quality metrics:
  - Real-time accuracy (sampled, LLM-as-judge)
  - Hallucination rate (automated detection)
  - Citation accuracy (source verification)
  - "I don't know" rate (should be 5-15%)

Performance metrics:
  - End-to-end latency (p50, p95, p99)
  - Retrieval latency
  - LLM generation latency
  - Embedding generation latency

Cost metrics:
  - Cost per conversation (LLM tokens + embedding lookups)
  - Daily/weekly/monthly LLM spend
  - Cost per resolution (conversations that resolved without human)

Alerts:
  - Accuracy < 88%: Slack notification
  - Hallucination rate > 5%: PagerDuty
  - Latency p95 > 5s: Slack notification
  - Daily cost > $50: Slack notification
  - Escalation rate > 50%: Review queue alert

Saved: docs/runbooks/docubot-observability.md
Commit: "observe: AI-specific monitoring — quality, cost, performance dashboards"
```

### Step 10: Ship — Deploy to Production

```
> /godmode:ship --deploy production

Godmode: Shipping DocuBot...

Phase 1: INVENTORY
  38 commits, 52 files
  Features: RAG pipeline, agent, chat API, monitoring, guardrails

Phase 2: CHECKLIST
  ✓ Tests: 64 unit + 200 eval tests
  ✓ Accuracy: 94.0% (target > 90%)
  ✓ Hallucination rate: 3.1% (target < 5%)
  ✓ Latency: 2.4s (target < 3s)
  ✓ Prompt injection tests: passing
  ✓ PII detection: active
  ✓ Cost guardrails: configured

Phase 3: PREPARE
  ✓ Documentation index built (2,847 chunks)
  ✓ pgvector index created
  ✓ Nightly refresh cron scheduled

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ 50 sample conversations: all accurate
  ✓ Load test: handles 100 concurrent conversations

Phase 5: DEPLOY
  ✓ Production deployment complete
  ✓ Chat widget embedded on docs site
  ✓ API endpoint live at /api/chat

Phase 6: VERIFY
  ✓ Production smoke test: 10 questions answered correctly
  ✓ WebSocket connection stable
  ✓ Monitoring dashboards receiving data

Phase 7: LOG
  Version: v1.0.0
  Ship log: .godmode/ship-log.tsv

Phase 8: MONITOR
  T+0:   ✓ Deployed, first conversations incoming
  T+15:  ✓ 12 conversations, 10 resolved (83% resolution)
  T+60:  ✓ 47 conversations, accuracy tracking at 93%
  T+120: ✓ Stable. No hallucinations detected. Cost: $2.40
```

---

## Post-Launch: Continuous Improvement

### Weekly Evaluation Cycle

```
# Every Monday: run full eval suite
/godmode:eval --weekly

WEEKLY EVAL (Week 3):
  Accuracy: 94.0% → 93.2% (within tolerance)
  New question types detected: 4 questions about new v3.2 API features
  Action: Add v3.2 release notes to documentation index

# Update the index
/godmode:rag --refresh

Index updated: +12 new chunks from v3.2 docs
```

### Monthly Prompt Optimization

```
# Analyze feedback and optimize
/godmode:optimize \
    --goal "DocuBot resolution rate" \
    --verify "python eval/run_eval.py --metric resolution_rate" \
    --target "> 70" \
    --iterations 10

Month 1 results:
  Resolution rate: 62% → 71%
  Changes: improved few-shot examples, better escalation prompts
```

### Quarterly Model Evaluation

```
# Test against newer LLM versions
/godmode:eval --compare-models

Claude 3.5 Sonnet (current): 94.0% accuracy, $0.08/conversation
Claude 3.6 Sonnet (new):     95.2% accuracy, $0.07/conversation
→ Upgrade recommended: better accuracy at lower cost
```

---

## Architecture Decisions Summary

| Decision | Choice | Why |
|----------|--------|-----|
| RAG vs. fine-tuning | RAG | Docs change frequently; fine-tuning is stale within days |
| Vector DB | pgvector | Already have PostgreSQL; no new infrastructure |
| Chunking | Semantic (by heading) | Preserves document structure, coherent chunks |
| Search | Hybrid (vector + BM25) | Vector catches semantic similarity; BM25 catches exact terms |
| Reranking | Cohere Rerank | +5% retrieval precision for minimal latency cost |
| LLM | Claude 3.5 Sonnet | Best accuracy/cost/speed trade-off for this use case |
| Embeddings | Voyage AI | Optimized for code and documentation |

---

## Cost Analysis

| Component | Monthly Cost (at 2K conversations/month) |
|-----------|------------------------------------------|
| LLM (Claude) | $160 (~80K input tokens/convo avg) |
| Embeddings | $0.12 (nightly re-index) |
| Reranking (Cohere) | $20 (2K queries) |
| pgvector (PostgreSQL) | $0 (existing DB) |
| **Total** | **~$180/month** |
| **Cost per resolution** | **~$0.13** |
| **Human agent cost per ticket** | **~$15** |
| **ROI** | **115x cheaper than human support** |

---

## Custom Chain for AI Products

```yaml
# .godmode/chains.yaml
chains:
  ai-product:
    description: "Build an AI-powered product from scratch"
    steps:
      - think
      - architect
      - prompt
      - rag
      - build
      - eval
      - optimize:
          args: "--goal accuracy --target '> 90'"
      - mlops
      - observe
      - ship

  ai-iterate:
    description: "Weekly AI improvement cycle"
    steps:
      - eval
      - optimize:
          args: "--iterations 10"
      - verify
      - ship
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Greenfield SaaS Recipe](greenfield-saas.md) — Building the non-AI parts of your product
- [Performance Optimization Recipe](performance-optimization.md) — Making the AI pipeline faster
- [Security Hardening Recipe](security-hardening.md) — Securing AI systems (prompt injection, PII)
