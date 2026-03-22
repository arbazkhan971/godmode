---
name: rag
description: |
  RAG (Retrieval-Augmented Generation) skill. Activates when users need to build, optimize, or evaluate RAG systems. Covers embedding model selection, vector store design (Pinecone, Weaviate, Chroma, pgvector), chunking strategies, retrieval optimization (hybrid search, reranking), context window management, and evaluation metrics (faithfulness, relevance, completeness). Every RAG pipeline gets a structured design, retrieval test suite, and quality baseline. Triggers on: /godmode:rag, "build a RAG system", "improve retrieval", "add knowledge base", or when the orchestrator detects RAG-related work.
---

# RAG — Retrieval-Augmented Generation

## When to Activate
- User invokes `/godmode:rag`
- User says "build a RAG system", "add a knowledge base", "search over documents"
- User says "improve retrieval quality", "my RAG is hallucinating", "context is wrong"
- When building a Q&A system, chatbot, or search-augmented feature
- When `/godmode:prompt` identifies a need for external context
- When `/godmode:agent` requires a knowledge retrieval tool
- When the orchestrator detects embedding models, vector stores, or document loaders in code

## Workflow

### Step 1: RAG Requirements & Data Discovery
Understand the knowledge domain and retrieval needs:

```
RAG DISCOVERY:
Use case: <what questions the system must answer>
Data sources:
  - Source 1: <type — docs, wiki, DB, API, PDFs, code> (<size — N docs, N MB>)
  - Source 2: <type> (<size>)
  - Source 3: <type> (<size>)
Total corpus size: <N documents, N tokens, N MB>
Update frequency: <static | daily | real-time>

Query patterns:
  - Factual lookup: "What is the refund policy?" (single-hop retrieval)
  - Analytical: "Compare product A vs product B" (multi-document retrieval)
  - Conversational: Multi-turn Q&A with follow-up questions
  - Structured: "List all products under $50" (metadata filtering + retrieval)

```

If the user hasn't specified, ask: "What documents do you want to search over, and what questions will users ask?"

### Step 2: Embedding Model Selection
Choose the embedding model based on quality, cost, and latency tradeoffs:

```
EMBEDDING MODEL SELECTION:

Candidates:
| Model | Dims | MTEB Avg | Latency | Cost | Context |
|--|--|--|--|--|--|
| OpenAI text-embedding-3 | 3072 | 64.6 | ~80ms | $0.13/1M | 8191 |
| -large |  |  |  |  |  |
| OpenAI text-embedding-3 | 1536 | 62.3 | ~50ms | $0.02/1M | 8191 |
| -small |  |  |  |  |  |
| Cohere embed-v3 | 1024 | 64.5 | ~60ms | $0.10/1M | 512 |
| Voyage voyage-3 | 1024 | 67.1 | ~70ms | $0.06/1M | 32000 |
| BGE-large-en-v1.5 | 1024 | 64.2 | ~20ms* | Free* | 512 |
| GTE-large | 1024 | 63.1 | ~15ms* | Free* | 512 |
| E5-mistral-7b | 4096 | 66.6 | ~100ms* | Free* | 32768 |
```

### Step 3: Chunking Strategy
Design how documents are split into retrievable units:

```
CHUNKING STRATEGY:

Strategy candidates:
| Strategy | Best for |
|--|--|
| Fixed-size (token) | Uniform docs, simple implementation, baseline |
| Recursive character | General-purpose, respects paragraph/section breaks |
| Semantic chunking | Documents with varying topic density |
| Sentence-based | Short documents, high-precision retrieval |
| Document-level | Short documents (emails, tickets, FAQs) |
| Hierarchical | Long docs needing both summary and detail retrieval |
| Code-aware (AST) | Source code repositories |
| Markdown/HTML headers | Structured docs with clear section hierarchy |
| Sliding window | When context at chunk boundaries is critical |
```

### Step 4: Vector Store Design
Select and configure the vector database:

```
VECTOR STORE SELECTION:

Candidates:
| Store | Type | Scale | Filtering | Cost | Best for |
|--|--|--|--|--|--|
| Pinecone | Managed | Billions | Advanced | $70+/mo | Production, |
|  |  |  |  |  | serverless |
| Weaviate | Managed/ | Millions | Advanced | Free-$ | Hybrid search |
|  | Self-host |  |  |  | multi-tenant |
| Chroma | Embedded | Millions | Basic | Free | Prototyping, |
|  |  |  |  |  | local dev |
| pgvector | Extension | Millions | SQL | Free* | Existing |
|  |  |  |  |  | Postgres |
| Qdrant | Managed/ | Billions | Advanced | Free-$ | High perf, |
```

### Step 5: Ingestion Pipeline Design
Design the document processing and indexing pipeline:

```
INGESTION PIPELINE:

┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
| Document | -> | Parse/ | -> | Clean/ | -> | Chunk | -> | Embed |
|--|--|--|--|--|--|--|--|--|
| Sources |  | Extract |  | Transform |  |  |  | & Index |
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

Stage 1 — Document loading:
  Loaders:
    - PDF: <PyMuPDF | pdfplumber | Unstructured — handles tables, images>
    - HTML: <BeautifulSoup | Unstructured — strips nav, ads, boilerplate>
    - Markdown: <native parser>
    - Docx/PPTX: <python-docx | python-pptx | Unstructured>
    - Code: <tree-sitter AST parser>
    - Database: <SQL query -> document format>
```

### Step 6: Retrieval Optimization
Design the retrieval strategy for maximum relevance:

```
RETRIEVAL STRATEGY:

Base retrieval:
  Method: <dense (vector) | sparse (BM25) | hybrid>
  Top-K: <number of chunks to retrieve — typically 5-20>

Hybrid search (RECOMMENDED for production):
  Dense weight: <0.0-1.0> (semantic similarity)
  Sparse weight: <0.0-1.0> (keyword/BM25 matching)
  Fusion method: <Reciprocal Rank Fusion (RRF) | weighted linear combination>

  Why hybrid: Dense search catches semantic matches ("vehicle" matches "car").
  Sparse search catches exact matches (product IDs, proper nouns, acronyms).
  Hybrid gets both.

```

### Step 7: Context Assembly & Prompt Integration
Design how retrieved context is assembled into the LLM prompt:

```
CONTEXT ASSEMBLY:

Context window budget:
  Model context window: <N tokens>
  System prompt: <N tokens>
  Retrieved context: <N tokens> (allocated)
  Conversation history: <N tokens> (if multi-turn)
  Output reservation: <N tokens>
  Total: <N tokens> (must not exceed model limit)

Assembly strategy:
  1. Rank retrieved chunks by relevance score
  2. Include chunks until context budget is exhausted
  3. Format each chunk with source attribution:
     [Source: <document name>, Section: <section title>]
```

### Step 8: RAG Evaluation
Evaluate the RAG pipeline end-to-end:

```
RAG EVALUATION:

Evaluation dataset:
  - <N> question-answer-context triples
  - Sources: hand-curated, user logs, synthetic generation
  - Covers: common questions, edge cases, out-of-scope queries

Retrieval metrics:
| Metric | Score | Description |
|--|--|--|
| Hit rate @ K | <val> | % of queries where answer is in top-K |
| MRR (Mean Reciprocal | <val> | Average 1/rank of first relevant result |
| Rank) |  |  |
| NDCG @ K | <val> | Ranking quality considering relevance |
```

### Step 9: RAG Artifacts & Commit
Generate the deliverables:

1. **RAG config**: `config/rag/<pipeline>-config.yaml`
2. **Ingestion pipeline**: `src/rag/<pipeline>/ingest.py`
3. **Retrieval module**: `src/rag/<pipeline>/retrieve.py`
4. **Evaluation suite**: `tests/rag/<pipeline>/eval.py`
5. **Evaluation results**: `docs/rag/<pipeline>-eval-results.md`

```
RAG PIPELINE COMPLETE:

Architecture:
- Embedding model: <model name> (<dimensions>d)
- Vector store: <store name> (<N> chunks indexed)
- Chunking: <strategy> (<chunk_size> tokens, <overlap> overlap)
- Retrieval: <strategy> (top-<K>, reranker: <name>)
- LLM: <model> for generation

Evaluation:
- Hit rate @ 5: <val>
- Faithfulness: <val>
- Hallucination rate: <val>
- E2E latency p95: <ms>

```

Commit: `"rag: <pipeline> — <embedding model>, <vector store>, <N> chunks, faithfulness=<val>"`

## Explicit Loop Protocol

For iterative RAG quality improvement:

```
RAG IMPROVEMENT LOOP:
current_iteration = 0
max_iterations = 5
baseline = evaluate_rag_pipeline(golden_set)  # hit_rate, faithfulness, hallucination_rate

WHILE current_iteration < max_iterations AND quality < target:
  current_iteration += 1

  1. DIAGNOSE failure mode:
     - Sample failed queries from evaluation
     - Categorize: retrieval_failure | generation_failure | out_of_scope
     - Retrieval failures: vocabulary mismatch, chunk boundary, missing doc
     - Generation failures: context overload, contradicting chunks, ambiguity

  2. APPLY single fix targeting top failure category:
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER ship a RAG system without measuring hallucination rate.
2. NEVER use vector search alone — always combine with BM25 (hybrid search).
3. NEVER skip the reranking step for production systems.
4. NEVER stuff the full context window — less context with higher relevance beats more.
5. NEVER use default chunking (500 chars, no overlap) — design the strategy deliberately.
6. ALWAYS evaluate retrieval and generation SEPARATELY to diagnose bottlenecks.
7. ALWAYS include source attribution/citations in generated answers.
8. ALWAYS test with real user queries, not just synthetic ones.
9. NEVER assume one embedding model works for all content types.
10. ALWAYS set chunk overlap >= 10% of chunk size to prevent boundary splits.
11. ALWAYS have a fallback response for "I don't know" when context is insufficient.
12. NEVER evaluate only end-to-end — measure retrieval metrics (hit rate, MRR) independently.
```

## Key Behaviors

1. **Chunking is the foundation.** Bad chunks produce bad retrieval. Spend more time on chunking strategy than on fancy retrieval algorithms. Garbage in, garbage out.
2. **Hybrid search beats pure vector search.** Dense retrieval misses exact keyword matches. Sparse search misses semantic matches. Combine both with reciprocal rank fusion.
3. **Reranking is the highest-leverage optimization.** A cross-encoder reranker applied to the top-20 results dramatically improves precision at minimal latency cost.
4. **Evaluate retrieval and generation separately.** If retrieval is bad, fixing the prompt will not help. If retrieval is good but generation is bad, fixing retrieval will not help. Diagnose the bottleneck.
5. **Hallucination is the critical metric.** A RAG system that makes things up is worse than one that says "I don't know." Measure and minimize hallucination rate.
6. **Context window is a budget.** Every token of context competes with the model's ability to reason. More context is not always better. Retrieve less, rerank more.
7. **Test with real user queries.** Synthetic test queries are a start. Real user queries reveal failure modes you did not anticipate.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full RAG pipeline design workflow |
| `--ingest <source>` | Run document ingestion pipeline |
| `--chunk <strategy>` | Force chunking strategy: `fixed`, `recursive`, `semantic`, `sentence`, `code`, `markdown` |

## Output Format

After each RAG skill invocation, emit a structured report:

```
RAG PIPELINE REPORT:
| Corpus | <N> documents / <N> chunks |
|--|--|
| Embedding model | <model name> (<N> dimensions) |
| Vector store | <store name> |
| Chunk strategy | <method> (<N> tokens, <N>% overlap) |
| Retrieval method | <dense | hybrid | dense+rerank> |
| Reranker | <model name> / NONE |
| Retrieval quality | Recall@10: <N>%  MRR: <N> |
| Generation quality | Faithfulness: <N>%  Relevance: <N>% |
| Hallucination rate | <N>% |
| Latency (p50/p99) | <N>ms / <N>ms |
| Verdict | PASS | NEEDS TUNING |
```

## TSV Logging

Log every RAG pipeline run for tracking:

```
timestamp	skill	action	corpus_chunks	recall_at_10	faithfulness	hallucination_rate	status
2026-03-20T14:00:00Z	rag	index	4200	0.82	0.91	0.04	pass
2026-03-20T14:30:00Z	rag	eval	4200	0.87	0.93	0.02	improved
```

## Success Criteria

The RAG skill is complete when ALL of the following are true:
1. Chunking strategy is designed for the content type (not default 500-char splits)
2. Hybrid search is configured (dense + sparse/BM25) or justified as unnecessary
3. Reranker is applied to top-N retrieved results (or justified as unnecessary)
4. Retrieval quality meets targets: Recall@10 >= 80%, MRR >= 0.7
5. Generation faithfulness >= 90% (answers are grounded in retrieved context)
6. Hallucination rate < 5% (measured with a hallucination detection eval)
7. End-to-end latency is within application requirements
8. Evaluation suite covers retrieval quality, generation quality, and hallucination separately

## Error Recovery

```
IF retrieval quality is low (Recall@10 < 70%):
  1. Check chunking: are relevant passages being split across chunks?
  2. Increase chunk overlap to 15-20%
  3. Try hybrid search (add BM25 alongside dense retrieval)
  4. Test a domain-specific embedding model instead of a general-purpose one
  5. Increase top-K retrieval count and add a reranker

IF hallucination rate is high (> 5%):
  1. Verify the prompt explicitly instructs the model to only use retrieved context
  2. Add "If the answer is not in the context, say so" instruction
  3. Reduce the number of retrieved chunks to avoid noise diluting the signal
  4. Add a reranker to improve precision of retrieved chunks
  5. Add a hallucination detection step as a post-processing guard

IF latency is too high:
```

## Keep/Discard Discipline
```
After EACH RAG pipeline change:
  1. MEASURE: Run the golden set evaluation (hit_rate, faithfulness, hallucination_rate).
  2. COMPARE: Did the target metric improve? Did hallucination rate increase?
  3. DECIDE:
     - KEEP if: target metric improved AND hallucination rate did not increase
     - DISCARD if: hallucination rate increased OR no metric improved
  4. COMMIT kept changes. Revert discarded changes before the next iteration.

Never keep a change that increases hallucination rate, even if retrieval metrics improve.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Recall@10 >= 80%, faithfulness >= 90%, hallucination rate < 5%
  - Two consecutive iterations produce < 2% improvement on any metric
  - End-to-end latency meets application requirements
  - User explicitly requests stop

DO NOT STOP just because:
  - One data source has lower quality (fix that source separately)
  - Embedding cost seems high (optimize cost after quality targets are met)
```

## RAG Optimization Loop

Structured iterative loop for systematically improving retrieval precision, recall, chunk quality, and embedding effectiveness:

```
RAG OPTIMIZATION LOOP:
Pipeline: <pipeline name>
Optimization target: <metric to improve — e.g., hit_rate, faithfulness, hallucination_rate>
Golden set: <N evaluation queries with ground-truth relevant passages>

RETRIEVAL PRECISION/RECALL TUNING:
| Metric | Current | Target | Gap | Priority |
|--|--|--|--|--|
| Precision @ 5 | <val> | <val> | <delta> | <H/M/L> |
| Recall @ 10 | <val> | <val> | <delta> | <H/M/L> |
| MRR | <val> | <val> | <delta> | <H/M/L> |
| NDCG @ 10 | <val> | <val> | <delta> | <H/M/L> |
| Retrieval latency | <ms> | <ms> | <delta> | <H/M/L> |
```

