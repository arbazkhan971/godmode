---
name: embeddings
description: |
  Embeddings and semantic search skill. Activates when users need to generate, manage, or optimize embeddings for similarity search, clustering, classification, or retrieval. Covers embedding model selection (OpenAI, Cohere, Voyage, open-source), dimensionality reduction, clustering, similarity search optimization, hybrid search (keyword + semantic), embedding versioning, and refresh strategies. Every embedding pipeline gets a structured design, benchmark suite, and optimization plan. Triggers on: /godmode:embeddings, "create embeddings", "semantic search", "similarity search", "vector search", or when the orchestrator detects embedding-related work.
---

# Embeddings — Embeddings & Semantic Search

## When to Activate
- User invokes `/godmode:embeddings`
- User says "create embeddings", "semantic search", "similarity search", "vector search"
- User says "find similar items", "cluster documents", "embed my data"
- When building or optimizing similarity-based features (recommendations, dedup, search)
- When `/godmode:rag` requires embedding model selection or optimization
- When `/godmode:finetune` produces a model that needs embedding capabilities
- When the orchestrator detects embedding libraries (sentence-transformers, openai.embeddings, cohere.embed) in code

## Workflow

### Step 1: Embedding Discovery & Requirements
Understand what must be embedded and why:

```
EMBEDDING DISCOVERY:
Use case: <what the embeddings will be used for>
  - Semantic search: find documents relevant to a query
  - Similarity matching: find items similar to a given item
  - Clustering: group similar items together
  - Classification: embed + classifier for categorization
  - Recommendation: find items similar to user preferences
  - Deduplication: find near-duplicate content
  - Anomaly detection: find outliers in embedding space

Data to embed:
  Type: <text | code | images | audio | multi-modal>
  Volume: <N items to embed>
  Avg item size: <N tokens / pixels / seconds>
  Languages: <list of languages in corpus>
  Update frequency: <static | daily | real-time>
  Growth rate: <N new items per day/week/month>

Quality requirements:
  Retrieval accuracy target: <hit rate @ K>
  Latency budget: <ms for embedding generation + search>
  Embedding dimensionality preference: <minimize | maximize quality | balanced>
  Cost budget: <monthly embedding generation + storage + search cost>

Infrastructure:
  Existing vector store: <none | Pinecone | Weaviate | Chroma | pgvector | Qdrant | other>
  Compute: <API-based | GPU self-hosted | CPU only>
  Cloud: <AWS | GCP | Azure | self-hosted>
```

If the user hasn't specified, ask: "What data do you want to embed, and what will you do with the embeddings?"

### Step 2: Embedding Model Selection
Choose the embedding model based on quality, cost, and operational requirements:

```
EMBEDDING MODEL SELECTION:

Text Embedding Models:
+----------------------------+------+----------+----------+----------+----------+-----------+
| Model                      | Dims | MTEB Avg | Latency  | Cost     | Context  | Matryoshka|
+----------------------------+------+----------+----------+----------+----------+-----------+
| OpenAI text-embedding-3    | 3072 | 64.6     | ~80ms    | $0.13/1M | 8191     | Yes       |
|   -large                   |      |          |          |          |          |           |
| OpenAI text-embedding-3    | 1536 | 62.3     | ~50ms    | $0.02/1M | 8191     | Yes       |
|   -small                   |      |          |          |          |          |           |
| Cohere embed-v3            | 1024 | 64.5     | ~60ms    | $0.10/1M | 512      | No        |
| Voyage voyage-3-large      | 1024 | 67.1     | ~70ms    | $0.18/1M | 32000    | No        |
| Voyage voyage-3-lite       | 512  | 62.3     | ~40ms    | $0.02/1M | 32000    | No        |
| Jina jina-embeddings-v3    | 1024 | 66.0     | ~50ms    | $0.02/1M | 8192     | Yes       |
| BGE-large-en-v1.5          | 1024 | 64.2     | ~20ms*   | Free*    | 512      | No        |
| GTE-Qwen2-7B-instruct      | 3584 | 70.2     | ~80ms*   | Free*    | 32768    | No        |
| E5-mistral-7b-instruct     | 4096 | 66.6     | ~100ms*  | Free*    | 32768    | No        |
| Nomic embed-text-v1.5      | 768  | 62.3     | ~15ms*   | Free*    | 8192     | Yes       |
| all-MiniLM-L6-v2           | 384  | 56.3     | ~5ms*    | Free*    | 256      | No        |
+----------------------------+------+----------+----------+----------+----------+-----------+
* Self-hosted latency and cost (requires GPU)

Code Embedding Models:
+----------------------------+------+----------+---------------------------------------------+
| Model                      | Dims | Quality  | Notes                                       |
+----------------------------+------+----------+---------------------------------------------+
| Voyage code-3              | 1024 | Best     | Purpose-built for code, 16K context         |
| OpenAI text-embedding-3    | 3072 | Good     | General-purpose, works well for code         |
| CodeBERT                   | 768  | Moderate | Free, self-hosted, older                     |
| StarEncoder                | 768  | Good     | Free, self-hosted, multi-language code       |
+----------------------------+------+----------+---------------------------------------------+

Selection criteria:
  1. Quality: benchmark scores on domain-relevant tasks (MTEB, domain-specific eval)
  2. Context window: must handle item size (short text: 256 OK; docs: need 8K+)
  3. Latency: embedding generation + search must fit latency budget
  4. Cost: initial embedding + ongoing query volume + re-embedding on updates
  5. Matryoshka support: can reduce dimensions post-hoc without reindexing
  6. Multilingual: required if data spans multiple languages
  7. Operational: API vs self-hosted tradeoff (API = simpler, self-hosted = cheaper at scale)

SELECTED: <Model> -- <justification>

Dimensionality decision:
  Full dimensions: <N> (maximum quality)
  Reduced dimensions: <N> (via Matryoshka or PCA)
  Reduction quality impact: <percentage of quality retained>
  Storage savings: <percentage reduction>

Estimated costs:
  Initial embedding: $<val> for <N> items
  Monthly query cost: $<val> at <N> queries/day
  Monthly storage: $<val> for <N> vectors at <N> dimensions
```

### Step 3: Dimensionality Reduction & Optimization
Optimize embedding dimensions for storage, speed, and quality:

```
DIMENSIONALITY REDUCTION:

Techniques:
+----------------------------+------------------+------------------+---------------------------+
| Technique                  | Quality Retained | Speed Gain       | Best For                  |
+----------------------------+------------------+------------------+---------------------------+
| Matryoshka (truncation)    | 95-99%           | Proportional to  | Models that support it    |
|                            | (at 50% dims)    | dim reduction     | (OpenAI, Nomic, Jina)     |
|                            |                  |                  |                           |
| PCA (Principal Component   | 90-98%           | Proportional to  | Any model, offline        |
|   Analysis)                | (at 50% dims)    | dim reduction     | compression               |
|                            |                  |                  |                           |
| UMAP                       | N/A (for viz)    | N/A              | Visualization,            |
|                            |                  |                  | 2D/3D projection          |
|                            |                  |                  |                           |
| Random Projection          | 85-95%           | Fast to compute  | Very high-dim inputs,     |
|                            |                  |                  | approximate reduction     |
|                            |                  |                  |                           |
| Quantization               | 95-99%           | 2-4x memory      | Reducing memory for       |
| (scalar / binary)          |                  | reduction         | vector store              |
+----------------------------+------------------+------------------+---------------------------+

SELECTED: <Technique> -- <justification>

Reduction plan:
  Original dimensions: <N>
  Target dimensions: <N>
  Method: <technique>
  Quality retention: <percentage> (measured on eval set)
  Storage reduction: <percentage>
  Search speed improvement: <percentage>

Binary quantization (if applicable):
  Full precision: <float32 | float16>
  Quantized: <int8 | binary>
  Memory reduction: <4x for int8, 32x for binary>
  Quality impact: <measured on eval set>
  Use case: <first-pass retrieval with reranking | final retrieval>
```

### Step 4: Clustering & Analysis
Analyze the embedding space for structure and quality:

```
EMBEDDING SPACE ANALYSIS:

Clustering:
  Algorithm: <K-Means | HDBSCAN | Agglomerative | Spectral>
  Number of clusters: <N> (determined by: <silhouette score | elbow method | domain knowledge>)

  Cluster summary:
  +----------+--------+---------------------+---------------------------------------------+
  | Cluster  | Size   | Cohesion Score      | Top Terms / Description                     |
  +----------+--------+---------------------+---------------------------------------------+
  | 0        | <N>    | <silhouette>        | <representative terms or description>       |
  | 1        | <N>    | <silhouette>        | <representative terms or description>       |
  | 2        | <N>    | <silhouette>        | <representative terms or description>       |
  | ...      |        |                     |                                             |
  | Outliers | <N>    | --                  | <items not fitting any cluster>             |
  +----------+--------+---------------------+---------------------------------------------+

  Overall silhouette score: <val> (>0.5 = good, >0.7 = strong clusters)

Quality diagnostics:
  Embedding isotropy: <val> (how uniformly embeddings fill the space; higher = better)
  Average cosine similarity: <val> (too high = embeddings collapsed; too low = no structure)
  Nearest-neighbor consistency: <val> (do known-similar items have high similarity?)

  Diagnostic flags:
  - [ ] ANISOTROPY: embeddings clustered in narrow cone (common with some models)
  - [ ] HUBNESS: some items are nearest neighbors of too many others
  - [ ] COLLAPSE: many items have near-identical embeddings (data or model issue)
  - [ ] SEPARATION: known-different items are too close in embedding space

Visualization:
  Project to 2D using: <UMAP | t-SNE | PCA>
  Color by: <cluster | label | metadata attribute>
  Save to: <path to visualization>
```

### Step 5: Similarity Search Optimization
Optimize search for speed and accuracy:

```
SIMILARITY SEARCH OPTIMIZATION:

Distance metric selection:
  Cosine similarity: <RECOMMENDED for normalized embeddings>
  Dot product: <fast, use when embeddings are normalized>
  Euclidean (L2): <use when magnitude matters>
  SELECTED: <metric> -- <justification>

Index configuration:
  Index type: <HNSW | IVF-Flat | IVF-PQ | SCANN | Flat (brute force)>

  HNSW (recommended for most use cases):
    M: <16 | 32 | 48> (connections per node; higher = better recall, more memory)
    ef_construction: <128 | 200 | 400> (build quality; higher = better index, slower build)
    ef_search: <64 | 100 | 200 | 400> (query quality; higher = better recall, slower query)

  IVF (for very large datasets > 10M vectors):
    nlist: <N centroids> (sqrt(N_vectors) is a good starting point)
    nprobe: <N clusters to search> (higher = better recall, slower query)
    Quantizer: <Flat | PQ | SQ>

  Performance benchmark:
  +------------------+----------+----------+----------+----------+
  | Configuration    | Recall@10| QPS      | Memory   | Build    |
  +------------------+----------+----------+----------+----------+
  | Flat (baseline)  | 100%     | <val>    | <val>    | <val>    |
  | HNSW (M=16)      | <val>%   | <val>    | <val>    | <val>    |
  | HNSW (M=32)      | <val>%   | <val>    | <val>    | <val>    |
  | IVF-PQ           | <val>%   | <val>    | <val>    | <val>    |
  +------------------+----------+----------+----------+----------+

  SELECTED: <configuration> -- <justification>

Pre-filtering and post-filtering:
  Pre-filter: apply metadata filters before vector search (reduces search space)
  Post-filter: apply metadata filters after vector search (simpler, may miss results)
  SELECTED: <pre-filter | post-filter> -- <justification>

Caching strategy:
  Cache frequent queries: <LRU cache with TTL>
  Cache size: <N entries>
  Cache hit rate target: <percentage>
  Invalidation: <on data update | TTL-based | manual>
```

### Step 6: Hybrid Search (Keyword + Semantic)
Combine keyword and semantic search for best results:

```
HYBRID SEARCH DESIGN:

Why hybrid:
  Dense search (semantic): catches "vehicle" when searching "car" (semantic match)
  Sparse search (keyword): catches "SKU-12345" exactly (lexical match)
  Hybrid: catches both. Strictly better for real-world queries.

Architecture:
  +--------+     +---------+     +-------+     +---------+     +--------+
  | Query  | --> | Dense   | --> |       | --> | Rerank  | --> | Top-K  |
  |        |     | Search  |     | Fusion|     | (opt)   |     | Results|
  |        | --> | Sparse  | --> |       |     |         |     |        |
  +--------+     | Search  |     +-------+     +---------+     +--------+
                 +---------+

Dense component:
  Model: <embedding model from Step 2>
  Top-K retrieved: <N> (e.g., 50)

Sparse component:
  Method: <BM25 | TF-IDF | SPLADE>
  BM25 parameters: k1=<1.2>, b=<0.75> (standard defaults)
  SPLADE: <learned sparse representations, better than BM25>
  Top-K retrieved: <N> (e.g., 50)

Fusion method:
  Reciprocal Rank Fusion (RRF):
    score = sum(1 / (k + rank_in_list)) for each list
    k = 60 (standard)
    Advantage: no tuning needed, robust across queries

  Weighted Linear Combination:
    score = alpha * dense_score + (1 - alpha) * sparse_score
    alpha = <0.5 - 0.8> (tune on evaluation set)
    Advantage: can optimize weights for domain

  SELECTED: <RRF | weighted linear> -- <justification>

  Dense weight: <val>
  Sparse weight: <val>

Reranking (RECOMMENDED):
  Stage 1: Hybrid search retrieves top-<N> (fast, broad)
  Stage 2: Cross-encoder reranker scores top-<N> (slow, precise)
  Reranker: <Cohere rerank-v3 | Voyage rerank-2 | BGE-reranker | ColBERT>
  Final top-K: <N>

Evaluation:
  Dense only:  hit_rate@10 = <val>, MRR = <val>
  Sparse only: hit_rate@10 = <val>, MRR = <val>
  Hybrid:      hit_rate@10 = <val>, MRR = <val>
  + Reranking:  hit_rate@10 = <val>, MRR = <val>

  Improvement: hybrid achieves +<N>% hit rate over dense-only
```

### Step 7: Embedding Versioning & Refresh
Manage embedding lifecycle:

```
EMBEDDING VERSIONING:

Version strategy:
  Version format: <model_name>-<version>-<dims>-<date>
  Example: text-embedding-3-small-v1-1536-2025-03-15

  Version registry:
  +-----------------+------------------+--------+--------+--------+----------+
  | Version         | Model            | Dims   | Items  | Hit@10 | Status   |
  +-----------------+------------------+--------+--------+--------+----------+
  | v1-2025-01-15   | embed-3-small    | 1536   | 50K    | 89.2%  | RETIRED  |
  | v2-2025-02-20   | embed-3-large    | 3072   | 55K    | 93.1%  | ACTIVE   |
  | v3-2025-03-15   | voyage-3         | 1024   | 58K    | 94.5%  | CANARY   |
  +-----------------+------------------+--------+--------+--------+----------+

Refresh triggers:
  - New embedding model release with significant quality improvement
  - Corpus grows beyond <N>% of original size
  - Embedding quality degrades (measured by periodic eval)
  - Model provider deprecation announcement
  - Domain shift detected (new vocabulary, new topics)

Refresh strategy:
  Full re-embed:
    Frequency: <quarterly | on model change>
    Duration: <hours for full corpus>
    Cost: $<val>
    Process: embed all items with new model, run eval, swap index

  Incremental:
    Frequency: <daily | real-time>
    New items: embed and add to index
    Updated items: re-embed and upsert
    Deleted items: remove from index

  Migration (model change):
    1. Embed corpus with new model into shadow index
    2. Run evaluation suite against shadow index
    3. If quality meets bar: atomic swap from active to shadow
    4. Keep old index available for rollback (7 days)
    5. Delete old index after rollback window

Staleness monitoring:
  Track: percentage of items older than <N> days since last embedding
  Alert: when >20% of items are stale
  Auto-refresh: trigger incremental re-embedding for stale items
```

### Step 8: Artifacts & Commit
Generate deliverables:

1. **Embedding config**: `configs/embeddings/<pipeline>-config.yaml`
2. **Embedding pipeline**: `src/embeddings/<pipeline>/embed.py`
3. **Search module**: `src/embeddings/<pipeline>/search.py`
4. **Evaluation suite**: `tests/embeddings/<pipeline>/eval.py`
5. **Benchmark results**: `docs/embeddings/<pipeline>-benchmarks.md`

```
EMBEDDING PIPELINE COMPLETE:

Architecture:
- Model: <embedding model> (<dims>d)
- Items embedded: <N>
- Index: <index type and configuration>
- Search: <dense | hybrid> (+ reranking: <yes/no>)
- Dimensionality: <full | reduced to N>

Evaluation:
- Hit rate @ 10: <val>
- MRR: <val>
- Search latency p95: <ms>
- Embedding latency: <ms per item>

Cost:
- Initial embedding: $<val>
- Monthly queries: $<val>
- Monthly storage: $<val>

Artifacts:
- Config: configs/embeddings/<pipeline>-config.yaml
- Pipeline: src/embeddings/<pipeline>/
- Tests: tests/embeddings/<pipeline>/eval.py (<N> test cases)
- Benchmarks: docs/embeddings/<pipeline>-benchmarks.md

Next steps:
-> /godmode:rag -- Build a full RAG pipeline with these embeddings
-> /godmode:finetune -- Fine-tune an embedding model for your domain
-> /godmode:aiops -- Monitor embedding quality in production
-> /godmode:multimodal -- Add image/audio embeddings
```

Commit: `"embeddings: <pipeline> -- <model>, <N> items, <dims>d, hit_rate@10=<val>"`

## Key Behaviors

1. **Benchmark before committing.** Never choose an embedding model based on marketing. Run your own evaluation on your data with your queries. Domain-specific performance varies wildly from general benchmarks.
2. **Hybrid search is the default.** Pure semantic search misses exact matches. Pure keyword search misses semantic matches. Always combine both unless you have a strong reason not to.
3. **Dimensions are a tradeoff.** Higher dimensions = better quality but more storage, slower search, higher cost. Use Matryoshka truncation or PCA to find the sweet spot.
4. **Versioning prevents disasters.** When you change embedding models, old and new embeddings are incompatible. Version your indexes, run evaluations before swapping, and keep rollback capability.
5. **Reranking is high leverage.** A cross-encoder reranker on top-N results dramatically improves precision at minimal latency cost. Always consider reranking for production systems.
6. **Monitor embedding quality.** Embeddings degrade as your data changes. Run periodic evaluations and set alerts for quality drops.
7. **Clustering reveals data quality.** Cluster your embeddings early. It reveals duplicates, outliers, missing categories, and data quality issues before they become retrieval problems.

## Example Usage

### Building a Semantic Search Pipeline
```
User: /godmode:embeddings Build semantic search for our product catalog (50K products)

Embeddings: Starting discovery...

EMBEDDING DISCOVERY:
Use case: Product similarity search + customer query matching
Data: 50,000 product descriptions (avg 120 tokens)
Languages: English only
Update: ~200 new products/week

MODEL: OpenAI text-embedding-3-small (1536d)
  Rationale: Good quality, low cost ($1.00 for full corpus), 8K context
  Matryoshka: reduce to 768d (97% quality retained, 50% storage savings)

INDEX: HNSW on Qdrant
  M=16, ef_construction=200, ef_search=100
  Distance: cosine

HYBRID SEARCH:
  Dense: embedding search (top-50)
  Sparse: BM25 on product titles + descriptions (top-50)
  Fusion: RRF (k=60)
  Reranker: Cohere rerank-v3 (top-50 -> top-10)

EVALUATION (500 test queries):
  Dense only:  hit_rate@10 = 84.2%, MRR = 0.71
  Hybrid:      hit_rate@10 = 91.8%, MRR = 0.82
  + Reranking: hit_rate@10 = 95.4%, MRR = 0.89
  Search latency p95: 85ms

Cost: $1.00 initial + $12/month (queries + storage)

Verdict: PASS -- meets quality and latency targets.
```

### Optimizing an Existing Embedding Pipeline
```
User: /godmode:embeddings --optimize Our search is slow and recall is dropping

Embeddings: Running diagnostics...

DIAGNOSIS:
  Current: 2M vectors at 3072d, HNSW M=64, flat search
  Latency p95: 450ms (target: 100ms)
  Hit rate@10: 82% (was 91% three months ago)

ROOT CAUSES:
  1. Dimensions too high for dataset size (3072d for 2M vectors is overkill)
  2. HNSW M=64 is oversized (M=16-32 sufficient for 2M vectors)
  3. 15% of corpus not re-embedded after model update (mixed embedding versions)

FIXES:
  1. Reduce to 1024d via Matryoshka (quality: 96.5% retained)
  2. Rebuild index with M=24, ef_search=128
  3. Re-embed stale 15% of corpus

RESULTS:
  Latency p95: 62ms (was 450ms)
  Hit rate@10: 93.2% (was 82%)
  Storage: -67% (3072d -> 1024d)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full embedding pipeline design workflow |
| `--model <name>` | Force embedding model |
| `--dims <N>` | Force dimensionality |
| `--eval` | Run evaluation suite on current embeddings |
| `--benchmark` | Benchmark embedding models on your data |
| `--cluster` | Run clustering analysis on embeddings |
| `--optimize` | Diagnose and optimize existing embedding pipeline |
| `--hybrid` | Design hybrid search (dense + sparse) |
| `--refresh` | Trigger embedding refresh / re-indexing |
| `--version` | Show embedding version registry |
| `--visualize` | Generate 2D/3D visualization of embedding space |
| `--compare <models>` | Compare embedding models side by side |

## Anti-Patterns

- **Do NOT choose an embedding model without benchmarking on your data.** MTEB scores are general. Your domain may have very different results. Always run your own evaluation.
- **Do NOT use maximum dimensions by default.** Higher dimensions cost more storage, slower search, and may not improve quality. Test reduced dimensions first.
- **Do NOT mix embedding model versions in the same index.** Embeddings from different models are not comparable. This silently degrades search quality.
- **Do NOT skip hybrid search.** Pure dense search fails on exact matches (product IDs, proper nouns, acronyms). Hybrid search with BM25 catches what embeddings miss.
- **Do NOT forget to re-embed when data changes significantly.** Embeddings are a snapshot. As your data evolves, embeddings become stale. Set up refresh schedules.
- **Do NOT embed without preprocessing.** Clean text before embedding. HTML tags, boilerplate, and noise degrade embedding quality. Garbage in, garbage out.
- **Do NOT use brute-force search at scale.** Flat/brute-force search is fine for <10K vectors. Beyond that, use approximate nearest neighbor indexes (HNSW, IVF).
- **Do NOT ignore the cost of re-embedding.** Changing embedding models means re-embedding your entire corpus. Factor this into model selection decisions.
