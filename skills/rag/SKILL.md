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

Quality requirements:
  - Answer accuracy target: <percentage>
  - Retrieval relevance target: <percentage — relevant docs in top-K>
  - Latency budget: <ms for retrieval + generation>
  - Hallucination tolerance: <zero | low | moderate>
  - Citation requirement: <must cite sources | optional | none>

Infrastructure:
  - Cloud: <AWS | GCP | Azure | self-hosted>
  - Existing stack: <databases, search engines, LLM providers>
  - Budget: <vector DB cost, embedding API cost, LLM API cost>
```

If the user hasn't specified, ask: "What documents do you want to search over, and what questions will users ask?"

### Step 2: Embedding Model Selection
Choose the embedding model based on quality, cost, and latency tradeoffs:

```
EMBEDDING MODEL SELECTION:

Candidates:
┌─────────────────────────┬────────┬──────────┬──────────┬──────────┬──────────┐
│ Model                   │ Dims   │ MTEB Avg │ Latency  │ Cost     │ Context  │
├─────────────────────────┼────────┼──────────┼──────────┼──────────┼──────────┤
│ OpenAI text-embedding-3 │ 3072   │ 64.6     │ ~80ms    │ $0.13/1M │ 8191    │
│   -large                │        │          │          │          │          │
│ OpenAI text-embedding-3 │ 1536   │ 62.3     │ ~50ms    │ $0.02/1M │ 8191    │
│   -small                │        │          │          │          │          │
│ Cohere embed-v3         │ 1024   │ 64.5     │ ~60ms    │ $0.10/1M │ 512     │
│ Voyage voyage-3         │ 1024   │ 67.1     │ ~70ms    │ $0.06/1M │ 32000   │
│ BGE-large-en-v1.5       │ 1024   │ 64.2     │ ~20ms*  │ Free*    │ 512     │
│ GTE-large               │ 1024   │ 63.1     │ ~15ms*  │ Free*    │ 512     │
│ E5-mistral-7b           │ 4096   │ 66.6     │ ~100ms* │ Free*    │ 32768   │
│ Nomic embed-text-v1.5   │ 768    │ 62.3     │ ~15ms*  │ Free*    │ 8192    │
└─────────────────────────┴────────┴──────────┴──────────┴──────────┴──────────┘
* Self-hosted latency and cost

Selection criteria:
  1. Quality: MTEB score on domain-relevant benchmarks
  2. Context window: must handle document chunk size
  3. Latency: must fit within retrieval latency budget
  4. Cost: embedding entire corpus + ongoing query volume
  5. Matryoshka support: can reduce dimensions without reindexing
  6. Multilingual: required if corpus has multiple languages

SELECTED: <Model> — <justification>

Dimensionality: <full | reduced to N dims via Matryoshka>
Estimated indexing cost: $<cost> for <N> documents
Estimated query cost: $<cost>/month at <N> queries/day
```

### Step 3: Chunking Strategy
Design how documents are split into retrievable units:

```
CHUNKING STRATEGY:

Strategy candidates:
┌────────────────────────┬──────────────────────────────────────────────────────┐
│ Strategy               │ Best for                                             │
├────────────────────────┼──────────────────────────────────────────────────────┤
│ Fixed-size (token)     │ Uniform docs, simple implementation, baseline        │
│ Recursive character    │ General-purpose, respects paragraph/section breaks   │
│ Semantic chunking      │ Documents with varying topic density                 │
│ Sentence-based         │ Short documents, high-precision retrieval            │
│ Document-level         │ Short documents (emails, tickets, FAQs)              │
│ Hierarchical           │ Long docs needing both summary and detail retrieval  │
│ Code-aware (AST)       │ Source code repositories                             │
│ Markdown/HTML headers  │ Structured docs with clear section hierarchy         │
│ Sliding window         │ When context at chunk boundaries is critical         │
│ Parent-child           │ Retrieve small chunks, return parent for context     │
└────────────────────────┴──────────────────────────────────────────────────────┘

SELECTED: <Strategy> — <justification>

Parameters:
  Chunk size: <N tokens> (typical: 256-1024)
  Chunk overlap: <N tokens> (typical: 50-200, or 10-20% of chunk size)
  Separator hierarchy: <e.g., \n\n -> \n -> . -> space>
  Minimum chunk size: <N tokens> (discard smaller chunks)

Metadata per chunk:
  - source_document: <file path or URL>
  - section_title: <heading hierarchy>
  - chunk_index: <position in document>
  - total_chunks: <chunks in source document>
  - document_type: <type — pdf, markdown, html, code>
  - last_updated: <timestamp>
  - custom: <domain-specific metadata for filtering>

Estimated chunks: <N total chunks> from <N documents>
Avg tokens per chunk: <N>
```

### Step 4: Vector Store Design
Select and configure the vector database:

```
VECTOR STORE SELECTION:

Candidates:
┌─────────────────┬──────────┬──────────┬──────────┬──────────┬──────────────┐
│ Store           │ Type     │ Scale    │ Filtering│ Cost     │ Best for     │
├─────────────────┼──────────┼──────────┼──────────┼──────────┼──────────────┤
│ Pinecone        │ Managed  │ Billions │ Advanced │ $70+/mo  │ Production,  │
│                 │          │          │          │          │ serverless   │
│ Weaviate        │ Managed/ │ Millions │ Advanced │ Free-$   │ Hybrid search│
│                 │ Self-host│          │          │          │ multi-tenant │
│ Chroma          │ Embedded │ Millions │ Basic    │ Free     │ Prototyping, │
│                 │          │          │          │          │ local dev    │
│ pgvector        │ Extension│ Millions │ SQL      │ Free*    │ Existing     │
│                 │          │          │          │          │ Postgres     │
│ Qdrant          │ Managed/ │ Billions │ Advanced │ Free-$   │ High perf,   │
│                 │ Self-host│          │          │          │ filtering    │
│ Milvus          │ Managed/ │ Billions │ Advanced │ Free-$   │ Large scale, │
│                 │ Self-host│          │          │          │ GPU accel    │
│ LanceDB        │ Embedded │ Millions │ SQL      │ Free     │ Serverless,  │
│                 │          │          │          │          │ multimodal   │
│ Elasticsearch   │ Managed/ │ Billions │ Full-text│ $$       │ Hybrid with  │
│                 │ Self-host│          │ + vector │          │ existing ES  │
└─────────────────┴──────────┴──────────┴──────────┴──────────┴──────────────┘

Selection criteria:
  1. Scale: <N vectors>, growth rate
  2. Query latency: <target p95 ms>
  3. Filtering: <metadata filtering requirements>
  4. Multi-tenancy: <shared index vs tenant isolation>
  5. Existing infrastructure: <leverage existing DBs>
  6. Cost: <monthly budget>
  7. Operational complexity: <managed vs self-hosted>

SELECTED: <Store> — <justification>

Index configuration:
  Index type: <HNSW | IVF | FLAT | PQ>
  Distance metric: <cosine | dot product | euclidean>
  HNSW parameters:
    M: <connections per layer — default 16>
    ef_construction: <build quality — default 200>
    ef_search: <query quality — default 100>

  Namespace/collection strategy:
    <one collection per tenant | one collection with metadata filtering | sharded>

  Replication: <single | replicated for HA>
  Backup: <strategy and frequency>
```

### Step 5: Ingestion Pipeline Design
Design the document processing and indexing pipeline:

```
INGESTION PIPELINE:

┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Document │ -> │  Parse/  │ -> │  Clean/  │ -> │  Chunk   │ -> │  Embed   │
│ Sources  │    │  Extract │    │ Transform│    │          │    │  & Index │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

Stage 1 — Document loading:
  Loaders:
    - PDF: <PyMuPDF | pdfplumber | Unstructured — handles tables, images>
    - HTML: <BeautifulSoup | Unstructured — strips nav, ads, boilerplate>
    - Markdown: <native parser>
    - Docx/PPTX: <python-docx | python-pptx | Unstructured>
    - Code: <tree-sitter AST parser>
    - Database: <SQL query -> document format>
    - API: <connector with pagination and rate limiting>

Stage 2 — Cleaning & transformation:
  - Remove boilerplate (headers, footers, navigation)
  - Normalize whitespace and encoding
  - Extract and preserve tables as structured text
  - Extract image descriptions (OCR or vision model)
  - Resolve cross-references and links
  - Detect and handle duplicates (exact + near-duplicate)

Stage 3 — Chunking:
  <Apply strategy from Step 3>
  - Attach metadata to each chunk
  - Generate chunk summaries (optional, for hierarchical retrieval)

Stage 4 — Embedding & indexing:
  - Batch embed chunks (<batch_size> per API call)
  - Rate limit embedding API calls (<requests/min>)
  - Upsert to vector store with metadata
  - Verify index count matches expected chunks

Stage 5 — Quality verification:
  - Sample <N> random chunks and verify content integrity
  - Run <N> test queries and verify retrieval quality
  - Log ingestion stats: documents, chunks, failures, duration

Pipeline schedule:
  Full reindex: <frequency — weekly | on-demand>
  Incremental: <frequency — daily | real-time via webhook>
  Staleness detection: <max age before re-ingestion>
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

Query preprocessing:
  - Query expansion: <rephrase query for better retrieval — HyDE, multi-query>
  - Query decomposition: <split complex queries into sub-queries>
  - Query routing: <route to different indexes based on query type>
  - Metadata filtering: <pre-filter by date, source, category before vector search>

Reranking (RECOMMENDED for high-quality retrieval):
  Stage 1: Vector search retrieves top-<N> candidates (fast, broad)
  Stage 2: Cross-encoder reranker scores top-<N> for relevance (slow, precise)

  Reranker options:
  ┌──────────────────────┬──────────┬──────────┬──────────────────────────┐
  │ Reranker             │ Latency  │ Cost     │ Notes                    │
  ├──────────────────────┼──────────┼──────────┼──────────────────────────┤
  │ Cohere rerank-v3     │ ~200ms   │ $1/1K    │ Best quality, managed    │
  │ Voyage rerank-2      │ ~150ms   │ $0.05/1K │ Cost-effective           │
  │ BGE-reranker-v2-m3   │ ~100ms*  │ Free*    │ Self-hosted, multilingual│
  │ ColBERT v2           │ ~50ms*   │ Free*    │ Self-hosted, fast        │
  │ LLM-based reranking  │ ~500ms   │ $$       │ Most flexible, expensive │
  └──────────────────────┴──────────┴──────────┴──────────────────────────┘

  SELECTED: <Reranker> — <justification>
  Retrieve top-<N>, rerank to top-<K> (e.g., retrieve 20, rerank to 5)

Advanced retrieval patterns:
  - Parent-child retrieval: retrieve small chunks, return parent section
  - Contextual compression: LLM extracts only relevant sentences from chunks
  - Multi-index routing: route query to domain-specific indexes
  - Self-RAG: model decides whether retrieval is needed for each query
  - Agentic RAG: agent iteratively retrieves, evaluates, and re-queries
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
     <chunk content>
  4. Add retrieval metadata for citation:
     Sources used: <list of source documents with chunk IDs>

Context formatting:
  "Use the following context to answer the user's question.
   If the answer is not in the context, say 'I don't have enough
   information to answer this question.'

   Context:
   ---
   [Source: <doc1>] <chunk 1 content>
   ---
   [Source: <doc2>] <chunk 2 content>
   ---

   Question: <user query>
   Answer:"

Citation strategy:
  Option A — Inline citations: "The refund policy allows returns within 30 days [Source: refund-policy.md]"
  Option B — Footnote citations: "Answer text [1][2]" with sources listed at end
  Option C — No citations (internal use only)
  SELECTED: <Option>

Conversation memory (multi-turn):
  - Store last <N> turns of conversation
  - Summarize older turns to save context
  - Re-retrieve on follow-up questions with conversation context
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
┌────────────────────────┬──────────┬──────────────────────────────────────────┐
│ Metric                 │ Score    │ Description                              │
├────────────────────────┼──────────┼──────────────────────────────────────────┤
│ Hit rate @ K           │ <val>    │ % of queries where answer is in top-K    │
│ MRR (Mean Reciprocal   │ <val>    │ Average 1/rank of first relevant result  │
│   Rank)                │          │                                          │
│ NDCG @ K              │ <val>    │ Ranking quality considering relevance     │
│ Precision @ K          │ <val>    │ % of top-K results that are relevant     │
│ Recall @ K             │ <val>    │ % of all relevant results in top-K       │
│ Retrieval latency p95  │ <ms>     │ 95th percentile retrieval time           │
└────────────────────────┴──────────┴──────────────────────────────────────────┘

Generation metrics:
┌────────────────────────┬──────────┬──────────────────────────────────────────┐
│ Metric                 │ Score    │ Description                              │
├────────────────────────┼──────────┼──────────────────────────────────────────┤
│ Faithfulness           │ <val>    │ Answer is grounded in retrieved context   │
│ Relevance              │ <val>    │ Answer addresses the question asked       │
│ Completeness           │ <val>    │ Answer covers all aspects of the question │
│ Correctness            │ <val>    │ Answer is factually correct               │
│ Hallucination rate     │ <val>    │ % of claims not supported by context      │
│ Citation accuracy      │ <val>    │ % of citations pointing to correct source │
│ Answer latency p95     │ <ms>     │ 95th percentile end-to-end time          │
└────────────────────────┴──────────┴──────────────────────────────────────────┘

Failure analysis:
  Retrieval failures: <N> queries where relevant docs not retrieved
    Root causes: <vocabulary mismatch | chunk boundary issues | missing docs>
  Generation failures: <N> queries where answer is wrong despite correct retrieval
    Root causes: <context too long | contradicting chunks | ambiguous question>
  Out-of-scope handling: <N> queries correctly refused when answer not in corpus

Evaluation tools:
  - RAGAS: faithfulness, answer relevancy, context precision/recall
  - DeepEval: hallucination, toxicity, bias metrics
  - LLM-as-judge: custom rubric evaluation using a strong model
  - Human evaluation: expert review of sampled responses

VERDICT: <PASS | NEEDS IMPROVEMENT>
  Strengths: <what works well>
  Weaknesses: <what needs improvement>
  Priority fixes: <ranked list of improvements>
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

Artifacts:
- Config: config/rag/<pipeline>-config.yaml
- Pipeline: src/rag/<pipeline>/
- Tests: tests/rag/<pipeline>/eval.py (<N> test cases)
- Report: docs/rag/<pipeline>-eval-results.md

Next steps:
-> /godmode:prompt — Optimize the generation prompt
-> /godmode:eval — Run comprehensive evaluation
-> /godmode:agent — Build an agent with RAG as a tool
-> /godmode:deploy — Deploy the RAG pipeline
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
     - Retrieval: adjust chunk size/overlap, add reranker, enable hybrid search
     - Generation: reduce top-K, improve prompt, add citation instructions
     - Corpus: add missing documents, update stale content
     - ONE change per iteration

  3. RE-EVALUATE:
     - Run same golden set against updated pipeline
     - Record: { iteration, change, hit_rate, faithfulness, hallucination_rate, latency }

  4. COMPARE:
     - IF primary metric improved AND no regression: ACCEPT change
     - IF hallucination rate increased: REJECT immediately
     - IF plateau for 2 iterations: STOP

  OUTPUT:
  Iteration | Change | Hit@5 | Faithfulness | Hallucination | Latency
  0         | baseline| 78%  | 0.82         | 8.5%          | 2.1s
  1         | +rerank | 89%  | 0.88         | 5.2%          | 2.4s
  ...
```

## Multi-Agent Dispatch

For building complete RAG systems:

```
PARALLEL AGENTS:
Agent 1 — Ingestion Pipeline (worktree: rag-ingest)
  - Build document loaders for all source types
  - Implement chunking strategy with metadata extraction
  - Build embedding and indexing pipeline

Agent 2 — Retrieval & Reranking (worktree: rag-retrieval)
  - Configure vector store with HNSW index
  - Implement hybrid search (dense + BM25)
  - Add cross-encoder reranker
  - Build query preprocessing (expansion, decomposition)

Agent 3 — Generation & Prompting (worktree: rag-generation)
  - Design context assembly strategy
  - Build generation prompt with citation support
  - Implement conversation memory for multi-turn
  - Add hallucination guardrails

Agent 4 — Evaluation Suite (worktree: rag-eval)
  - Create golden set of question-answer-context triples
  - Build evaluation harness (RAGAS metrics)
  - Create failure analysis reports
  - Set up regression testing for pipeline changes

MERGE ORDER: Agent 1 first (data), Agent 2 (retrieval), Agent 3 (generation), Agent 4 (eval).
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

## Example Usage

### Building a RAG System from Scratch
```
User: /godmode:rag Build a knowledge base for our internal documentation

RAG: Starting discovery...

RAG DISCOVERY:
Use case: Internal docs Q&A for engineering team
Data sources:
  - Confluence wiki: 2,400 pages, ~15MB text
  - GitHub READMEs: 180 repos, ~3MB text
  - Notion runbooks: 95 docs, ~2MB text
Total: 2,675 documents, ~20MB text
Update frequency: Daily sync

EMBEDDING: text-embedding-3-small (1536d, $0.02/1M tokens)
  Indexing cost: ~$0.40 for entire corpus
  Query cost: ~$0.60/month at 1000 queries/day

CHUNKING: Markdown headers + recursive character
  Chunk size: 512 tokens, overlap: 64 tokens
  Estimated: ~12,000 chunks

VECTOR STORE: pgvector (existing Postgres infrastructure)
  Index: HNSW, cosine similarity
  Filtering: by source, team, date

RETRIEVAL: Hybrid (dense 0.7 + BM25 0.3) + Cohere rerank-v3
  Retrieve top-20, rerank to top-5

EVALUATION (50 test queries):
  Hit rate @ 5: 94%
  Faithfulness: 0.91
  Hallucination rate: 3.2%
  E2E latency p95: 1.8s

Verdict: PASS — Ready for internal deployment.
```

### Debugging Retrieval Quality
```
User: /godmode:rag --diagnose Users say the chatbot gives wrong answers

RAG: Running retrieval diagnostics...

Sampling 100 recent user queries with thumbs-down feedback...

DIAGNOSIS:
  Retrieval failures: 34/100
    - 18: Vocabulary mismatch (users say "PTO" but docs say "paid time off")
    - 9: Chunk boundary splits relevant content across chunks
    - 7: Document not in corpus (outdated or missing)

  Generation failures: 22/100
    - 12: Too many chunks, relevant info buried in noise
    - 6: Contradicting information from different doc versions
    - 4: Question ambiguous, multiple valid interpretations

Recommended fixes:
  1. Add synonym expansion for domain terms (PTO -> paid time off)
  2. Increase chunk overlap from 50 to 128 tokens
  3. Add 7 missing documents to corpus
  4. Reduce retrieved chunks from 10 to 5 with reranker
  5. Add doc version filtering (prefer latest)

Estimated improvement: +15-20% answer accuracy
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full RAG pipeline design workflow |
| `--ingest <source>` | Run document ingestion pipeline |
| `--chunk <strategy>` | Force chunking strategy: `fixed`, `recursive`, `semantic`, `sentence`, `code`, `markdown` |
| `--store <name>` | Force vector store: `pinecone`, `weaviate`, `chroma`, `pgvector`, `qdrant`, `milvus` |
| `--embed <model>` | Force embedding model |
| `--eval` | Run evaluation suite against current pipeline |
| `--diagnose` | Diagnose retrieval quality issues |
| `--compare` | Compare two pipeline configurations |
| `--reindex` | Force full reindexing of corpus |
| `--hybrid` | Enable hybrid search (dense + sparse) |
| `--rerank <model>` | Add or change reranking model |
| `--stats` | Show pipeline statistics (chunks, queries, latency) |

## Anti-Patterns

- **Do NOT skip chunking design.** Default chunking (500 chars, no overlap) is almost always wrong. Spend time on chunking strategy — it is the highest-impact decision.
- **Do NOT use vector search alone.** Pure dense retrieval misses exact keyword matches. Hybrid search with BM25 catches what embeddings miss.
- **Do NOT retrieve without reranking.** Bi-encoder retrieval (vector search) is fast but imprecise. A cross-encoder reranker on top-N results significantly improves quality.
- **Do NOT stuff the entire context window.** More retrieved chunks is not better. Irrelevant chunks dilute the signal and confuse the model. Retrieve less, rerank more.
- **Do NOT ignore chunk boundaries.** A relevant sentence split across two chunks may never be retrieved. Use overlap and respect natural document boundaries.
- **Do NOT evaluate end-to-end only.** Measure retrieval quality and generation quality separately. You cannot fix generation if the problem is retrieval.
- **Do NOT launch without hallucination measurement.** A RAG system that confidently makes things up is a liability. Measure hallucination rate and set a hard threshold.
- **Do NOT use the same embedding model for everything.** Code, legal text, medical text, and casual conversation have different embedding needs. Test domain-specific models.
