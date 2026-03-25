---
name: rag
description: RAG (Retrieval-Augmented Generation) systems.
---

## Activate When
- `/godmode:rag`, "build RAG system", "knowledge base"
- "improve retrieval", "RAG hallucinating"
- Building Q&A, chatbot, or search-augmented features

## Workflow

### 1. Requirements
```
Use case: <questions the system must answer>
Data sources: <docs, wiki, DB, PDFs, code>
Corpus: <N documents, N tokens, N MB>
Update frequency: static|daily|real-time
Query patterns:
  Factual lookup (single-hop retrieval)
  Analytical (multi-document retrieval)
  Conversational (multi-turn Q&A)
  Structured (metadata filtering + retrieval)
```

### 2. Embedding Model Selection
```
| Model | Dims | MTEB | Cost |
| text-embedding-3-large | 3072 | 64.6 | $0.13/1M |
| text-embedding-3-small | 1536 | 62.3 | $0.02/1M |
| Cohere embed-v3 | 1024 | 64.5 | $0.10/1M |
| Voyage voyage-3 | 1024 | 67.1 | $0.06/1M |
| BGE-large-en-v1.5 | 1024 | 64.2 | Free* |
```
IF budget-constrained: text-embedding-3-small.
IF quality-critical: Voyage or BGE fine-tuned.
IF multi-language: Cohere embed-v3.

### 3. Chunking Strategy
```
| Strategy | Best For |
| Fixed-size (token) | Baseline, uniform docs |
| Recursive character | General-purpose |
| Semantic | Varying topic density |
| Code-aware (AST) | Source code repos |
| Markdown headers | Structured docs |
| Sliding window | Boundary context critical |
```
ALWAYS set overlap >= 10% of chunk size.
IF chunk_size > 1000 tokens: information dilution risk.
IF chunk_size < 100 tokens: context too fragmented.
Default: 500 tokens, 50 token overlap.

### 4. Vector Store
```
| Store | Type | Scale | Best For |
| Pinecone | Managed | Billions | Production |
| Weaviate | Managed/Self | Millions | Hybrid search |
| Chroma | Embedded | Millions | Prototyping |
| pgvector | Extension | Millions | Existing PG |
| Qdrant | Managed/Self | Billions | High perf |
```
IF already using PostgreSQL: start with pgvector.
IF < 100K chunks: Chroma for development.
IF > 10M chunks: Pinecone or Qdrant.

### 5. Ingestion Pipeline
```
Document -> Parse/Extract -> Clean/Transform
  -> Chunk -> Embed -> Index
Loaders:
  PDF: PyMuPDF, pdfplumber, Unstructured
  HTML: BeautifulSoup, Unstructured
  Code: tree-sitter AST parser
```
```bash
# Verify indexing
python -c "from chromadb import Client; \
  c=Client(); print(c.list_collections())"
```

### 6. Retrieval Optimization
```
Hybrid search (RECOMMENDED for production):
  Dense (vector): semantic similarity
  Sparse (BM25): keyword/exact matching
  Fusion: Reciprocal Rank Fusion (RRF)
Top-K: 5-20 chunks (start with 10)
Reranker: cross-encoder on top-20 results
  (highest-impact single optimization)
```
IF recall < 70%: increase overlap, add BM25, try
  domain-specific embeddings.
IF recall > 90% but bad answers: generation problem.

### 7. Context Assembly
```
Context window budget:
  System prompt: <N tokens>
  Retrieved context: <N tokens>
  Conversation history: <N tokens>
  Output reservation: <N tokens>
  Total < model context limit
Assembly: rank by relevance, include until budget.
  Format with source attribution.
```

### 8. Evaluation
```
Retrieval metrics:
  Hit rate @ K: % queries with answer in top-K
  MRR: average 1/rank of first correct result
Generation metrics:
  Faithfulness: grounded in retrieved context
  Hallucination rate: answers without evidence
Targets:
  Recall@10 >= 80%, MRR >= 0.7
  Faithfulness >= 90%, Hallucination < 5%
```

## Hard Rules
1. NEVER ship without measuring hallucination rate.
2. NEVER vector search alone — always hybrid (+ BM25).
3. NEVER skip reranking in production.
4. NEVER stuff full context window (less + relevant).
5. NEVER default chunking (500 chars, no overlap).
6. ALWAYS evaluate retrieval + generation separately.
7. ALWAYS include source citations in answers.
8. ALWAYS set chunk overlap >= 10% of chunk size.
9. ALWAYS have "I don't know" fallback.

## TSV Logging
Append `.godmode/rag.tsv`:
```
timestamp	action	chunks	recall_at_10	faithfulness	hallucination	status
```

## Keep/Discard
```
KEEP if: target metric improved AND hallucination
  did not increase.
DISCARD if: hallucination increased OR no improvement.
Never keep a change that increases hallucination.
```

## Stop Conditions
```
STOP when FIRST of:
  - Recall@10 >= 80%, faithfulness >= 90%,
    hallucination < 5%
  - Two iterations < 2% improvement
  - Latency meets requirements
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Low recall < 70% | Increase overlap, add BM25, reranker |
| High hallucination | Add "only use context", reduce chunks |
| High latency | Cache frequent queries, reduce top-K |
