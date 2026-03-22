---
name: search
description: |
  Search implementation skill. Activates when teams need to design, build, or optimize search functionality. Covers full-text search engine selection and configuration (Elasticsearch, Algolia, Meilisearch, Typesense, PostgreSQL FTS), relevance tuning and ranking algorithms (BM25, TF-IDF, vector embeddings), faceted search, autocomplete, fuzzy matching, synonym handling, and index design. Provides structured workflows for building production search from zero to deployed. Triggers on: /godmode:search, "add search", "search is slow", "improve relevance", "build autocomplete", "faceted search", or when the application needs full-text search capability.
---

# Search — Search Implementation & Relevance Engineering

## When to Activate
- User invokes `/godmode:search`
- User says "add search", "build search", "improve relevance", "search results are bad"
- User says "build autocomplete", "add typeahead", "faceted search", "add filters"
- User needs fuzzy matching, synonyms, or multilingual search
- Existing search is slow, irrelevant, or missing features

## Workflow

### Step 1: Requirements Assessment

```
SEARCH REQUIREMENTS:
Use case: <site|product|document|log|autocomplete|geo search>
Data volume: <N documents>, Document size: <avg>, Index frequency: <real-time|batch>
Query volume: <QPS>, Latency target: <P95>, Languages: <list>
Existing infra: <PostgreSQL|MongoDB|none>, Budget: <self-hosted|managed>

ENGINE SELECTION:
  PostgreSQL FTS: Already on PG + < 1M docs + basic search
  Meilisearch/Typesense: < 10M docs + typo tolerance needed + low ops
  Algolia: E-commerce with facets + managed preferred
  Elasticsearch/OpenSearch: Large scale + complex queries + analytics
```

### Step 2: Index Design

```
FIELD MAPPINGS:
  text fields → searchable (with weight boosting: title 3x > tags 2x > description 1x)
  keyword fields → filter, sort, facet
  numeric → filter, sort, facet (range)
  datetime → filter, sort
  geo_point → location-based filter/sort

ANALYZERS:
  search_analyzer: standard + lowercase + stop + stemmer + synonyms
  autocomplete_analyzer: standard + lowercase + edge_ngram(1,20)
  exact_analyzer: keyword + lowercase

MAPPING RULES:
  Multi-fields (text + keyword + autocomplete sub-field)
  scaled_float for prices, date for timestamps, geo_point for locations
  Start with 1 shard, 1 replica. Scale shards at 10M+ docs.
```

PostgreSQL FTS: Add tsvector column with weighted fields (A/B/C), GIN index, auto-update trigger, ts_rank for ranking.

### Step 3: Relevance Tuning

```
RANKING COMPONENTS:
  Text relevance (BM25): 60% — query matching against fields with boosting
  Field boosting: title 3x, exact match 5x
  Recency signal: 15% — newer docs via decay function (30-day half-life)
  Popularity signal: 15% — view count, CTR, purchases (log1p modifier)
  Personalization: 10% — user preference history
  Penalties: out of stock -50%, flagged -100%

RELEVANCE TESTING:
  Build test suite: query → expected top 3 → pass/fail (including fuzzy, synonym tests)
  Metrics: Precision@10, Recall@10, NDCG@10, MRR, zero-result rate, CTR
```

### Step 4: Autocomplete & Suggestions

```
TYPES:
  Query suggest (typeahead): prefix match on popular past queries, < 50ms
  Result suggest (instant search): edge_ngram on doc fields, < 100ms
  Completion suggest: completion suggester with category context, < 30ms
  Did you mean: phrase suggester on indexed terms, < 100ms

CLIENT RULES:
  Debounce 200-300ms, min 2 chars, cancel previous with AbortController,
  max 5-8 suggestions, highlight matched prefix
```

### Step 5: Faceted Search

```
FACET TYPES:
  Terms (checkbox list): category, brand, color — OR within, AND across facets
  Range (slider/buckets): price, rating
  Boolean (toggle): availability

Show counts per facet value. Hide facets with 0 results. Encode in URL for shareable links.
```

### Step 6: Fuzzy Matching & Synonyms

```
FUZZY: fuzziness=AUTO (0 edits 1-2 chars, 1 edit 3-5, 2 edits 6+), prefix_length=2, max_expansions=50, transpositions=true

SYNONYMS:
  Two-directional: laptop, notebook, portable computer
  One-directional: js => javascript, k8s => kubernetes
  Store in external file (update without reindex), review monthly, add from zero-result queries
```

### Step 7: Performance Optimization

```
Shard sizing: 10-50GB per shard, 1 shard per 10M docs
Refresh interval: 1s default, 30s batch, -1 during bulk import
Bulk indexing: batch 500-5000, 2-4 threads, disable replicas+refresh during load
Query caching: node query cache + request cache for aggregations
Index lifecycle: hot-warm-cold, rollover at 50GB/30 days

TARGETS: Index > 5000 docs/sec, Search P50 < 50ms, P95 < 200ms, Autocomplete P95 < 50ms
```

### Step 8: Search Analytics

```
TRACK: Zero-result rate (<3%), CTR (>30%), click position (<3), search exit rate (<15%),
  autocomplete accept rate (>40%), queries per session
ACTION: Top zero-result queries → add synonyms, fix data, add collections
```

### Step 9: Commit and Transition
Save mappings, analyzers, synonyms, relevance tests. Commit: `"search: <index> — <engine>, <N> fields, <N> facets, relevance NDCG <score>"`

## Key Behaviors

1. **Choose the simplest tool.** PostgreSQL FTS handles millions. Not everything needs Elasticsearch.
2. **Relevance is measurable.** Define NDCG, precision, CTR. Measure before and after every change.
3. **Analyzers are the foundation.** Bad analyzers = bad results regardless of query tuning.
4. **Monitor zero-result queries.** Every zero-result is a missed opportunity.
5. **Autocomplete latency is sacred.** Sub-50ms. Optimize aggressively.
6. **Index design is hard to change.** Changing analyzers requires reindexing. Design carefully.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full search implementation |
| `--engine <name>` | Target engine (elasticsearch, meilisearch, algolia, postgres) |
| `--tune` | Tune relevance on existing search |
| `--autocomplete` | Autocomplete/typeahead only |
| `--facets` | Faceted search only |
| `--analyze` | Search quality metrics |
| `--synonyms` | Synonym management |
| `--benchmark` | Performance benchmarks |

## Auto-Detection
```
Detect: search engine in deps, PostgreSQL FTS (tsvector in migrations), data size,
search endpoints, client SDK, autocomplete config, synonyms/stopwords files.
```

## HARD RULES

1. NEVER add Elasticsearch for < 100K documents. Use PostgreSQL FTS or Meilisearch.
2. EVERY search must have a relevance test suite.
3. NEVER high fuzziness without prefix_length >= 2.
4. ALWAYS track zero-result queries.
5. NEVER reindex in place. Use aliases and swap atomically.
6. SANITIZE EVERY search input (escape reserved chars).
7. NEVER couple personalization with query DSL. Use function_score.
8. ALWAYS use index aliases (never raw index names).
9. Autocomplete must respond < 100ms.
10. PAIR EVERY aggregation with a filter.

## Loop Protocol
```
TASKS: index_setup → mapping → ingestion → query_logic → relevance_tuning → autocomplete → facets
FOR EACH: implement, test relevance suite, adjust if below target, commit if passing.
POST-LOOP: Benchmark latency p50/p95/p99, verify < 200ms p95.
```

## Multi-Agent Dispatch
```
Agent 1 — search-engine: index, mappings, analyzers, ingestion
Agent 2 — search-api: endpoint, query building, pagination, facets
Agent 3 — search-relevance: synonyms, boosting, test suite, analytics
MERGE: engine → api → relevance
```

## Output Format
```
SEARCH COMPLETE:
Engine: <name>, Indexes: <N>, Analyzers: <N>, Facets: <N>
Autocomplete: <yes|no>, Synonyms: <N>, Indexing: <real-time|batch>
Relevance: NDCG@10 <score>, Zero-result rate <N>%
Latency: P50 <N>ms, P95 <N>ms
```

## TSV Logging
Append to `.godmode/search-results.tsv`: `timestamp\tproject\tengine\tindexes_count\tdocument_types\tfacets\tautocomplete\tsynonyms_count\tcommit_sha`

## Success Criteria
Index mappings defined (no dynamic), custom analyzers, pagination, facets (if applicable), autocomplete (recommended), relevance tested, indexing handles updates/deletes, P95 < 200ms, zero-result rate monitored, no query injection.

## Error Recovery
```
Irrelevant results → check analyzers, field boosting, use explain API.
Indexing lag → increase batch size, add workers, check refresh_interval.
Mapping conflict → new index + correct mappings + reindex + alias swap.
Autocomplete slow → completion suggester or dedicated index with edge_ngram.
Zero-results high → add synonyms, "did you mean", fallback to broader search.
Cluster yellow/red → check shard allocation, disk space, replicas vs nodes.
```

## Keep/Discard Discipline
```
KEEP if NDCG@10 >= previous AND Precision@10 >= previous.
DISCARD if either metric regressed.
Never deploy without running full relevance test suite.
```

## Stop Conditions
```
STOP when: NDCG@10 >= 0.85 AND zero-result rate < 3% AND P95 < 200ms
  OR improvement < 0.01 per iteration (diminishing returns)
  OR user requests stop OR max 10 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
