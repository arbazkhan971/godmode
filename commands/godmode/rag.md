# /godmode:rag

Build, optimize, and evaluate RAG (Retrieval-Augmented Generation) systems. Covers embedding model selection, vector store design, chunking strategies, retrieval optimization (hybrid search, reranking), context assembly, and evaluation metrics (faithfulness, relevance, hallucination rate).

## Usage

```
/godmode:rag                               # Full RAG pipeline design workflow
/godmode:rag --ingest ./docs               # Run document ingestion pipeline
/godmode:rag --chunk semantic              # Force semantic chunking strategy
/godmode:rag --store pgvector              # Force vector store selection
/godmode:rag --embed text-embedding-3-small # Force embedding model
/godmode:rag --hybrid                      # Enable hybrid search (dense + BM25)
/godmode:rag --rerank cohere               # Add reranking stage
/godmode:rag --eval                        # Evaluate RAG pipeline quality
/godmode:rag --diagnose                    # Debug retrieval quality issues
/godmode:rag --compare                     # Compare pipeline configurations
/godmode:rag --reindex                     # Force full corpus reindexing
/godmode:rag --stats                       # Show pipeline statistics
```

## What It Does

1. Discovers data sources, query patterns, quality requirements, and infrastructure
2. Selects embedding model based on quality, cost, latency, and domain fit
3. Designs chunking strategy (fixed, recursive, semantic, sentence, code-aware, hierarchical)
4. Selects and configures vector store (Pinecone, Weaviate, Chroma, pgvector, Qdrant, Milvus)
5. Designs ingestion pipeline (load, clean, chunk, embed, index, verify)
6. Optimizes retrieval with hybrid search (dense + BM25), query expansion, and reranking
7. Designs context assembly with token budgeting and citation strategy
8. Evaluates retrieval (hit rate, MRR, NDCG) and generation (faithfulness, relevance, hallucination)
9. Generates config, pipeline code, evaluation suite, and results report

## Output
- RAG config at `config/rag/<pipeline>-config.yaml`
- Pipeline code at `src/rag/<pipeline>/`
- Evaluation suite at `tests/rag/<pipeline>/eval.py`
- Results report at `docs/rag/<pipeline>-eval-results.md`
- Commit: `"rag: <pipeline> — <embedding model>, <vector store>, <N> chunks, faithfulness=<val>"`

## Next Step
After RAG pipeline: `/godmode:prompt` to optimize the generation prompt, `/godmode:eval` for comprehensive evaluation, or `/godmode:agent` to wrap RAG in an agent loop.

## Examples

```
/godmode:rag Build a knowledge base for internal documentation
/godmode:rag --store pinecone --embed voyage-3 Build a production RAG pipeline
/godmode:rag --diagnose Users say the chatbot gives wrong answers
/godmode:rag --eval Run evaluation on our RAG pipeline
/godmode:rag --hybrid --rerank cohere Upgrade retrieval to hybrid + reranking
```
