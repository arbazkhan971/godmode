# /godmode:embeddings

Embeddings and semantic search workflow. Guides the full lifecycle of creating, managing, and optimizing embeddings for similarity search, clustering, classification, and retrieval -- from model selection through dimensionality reduction, hybrid search, and versioning.

## Usage

```
/godmode:embeddings                        # Full embedding pipeline design
/godmode:embeddings --model <name>         # Force a specific embedding model
/godmode:embeddings --dims <N>             # Force dimensionality
/godmode:embeddings --eval                 # Run evaluation suite on current embeddings
/godmode:embeddings --benchmark            # Benchmark embedding models on your data
/godmode:embeddings --cluster              # Run clustering analysis
/godmode:embeddings --optimize             # Diagnose and optimize existing pipeline
/godmode:embeddings --hybrid               # Design hybrid search (dense + sparse)
/godmode:embeddings --refresh              # Trigger embedding refresh / re-indexing
/godmode:embeddings --version              # Show embedding version registry
/godmode:embeddings --visualize            # Generate 2D/3D visualization
/godmode:embeddings --compare <models>     # Compare embedding models side by side
```

## What It Does

1. Discovers embedding requirements (use case, data type, volume, latency, cost)
2. Selects embedding model (OpenAI, Cohere, Voyage, Jina, open-source) with benchmarks
3. Optimizes dimensionality (Matryoshka truncation, PCA, quantization)
4. Analyzes embedding space (clustering, isotropy, hubness, quality diagnostics)
5. Optimizes similarity search (HNSW/IVF config, distance metrics, pre/post filtering, caching)
6. Designs hybrid search (dense + sparse with RRF or weighted fusion + reranking)
7. Manages embedding versioning and refresh strategies (incremental, full re-embed, migration)

## Output
- Embedding config at `configs/embeddings/<pipeline>-config.yaml`
- Benchmark results at `docs/embeddings/<pipeline>-benchmarks.md`
- Commit: `"embeddings: <pipeline> -- <model>, <N> items, <dims>d, hit_rate@10=<val>"`

## Key Principles

1. **Benchmark on your data** -- general benchmarks (MTEB) do not predict domain-specific performance
2. **Hybrid search is the default** -- combine dense and sparse search for production systems
3. **Dimensions are a tradeoff** -- test reduced dimensions before using maximum
4. **Version your indexes** -- embedding model changes require complete re-indexing
5. **Reranking is high leverage** -- cross-encoder reranker on top-N results improves precision significantly
6. **Monitor quality** -- embeddings degrade as data changes; run periodic evaluations

## Next Step
If embeddings ready: `/godmode:rag` to build full RAG pipeline.
If quality insufficient: try different model or increase dimensions.
If search slow: `/godmode:embeddings --optimize` to tune index configuration.

## Examples

```
/godmode:embeddings                        # Design a new embedding pipeline
/godmode:embeddings --benchmark            # Compare models on your data
/godmode:embeddings --optimize             # Speed up slow search or fix quality drop
/godmode:embeddings --hybrid               # Add keyword search alongside semantic
/godmode:embeddings --cluster              # Explore data structure via clustering
```
