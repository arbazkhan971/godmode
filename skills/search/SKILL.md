---
name: search
description: >
  Search implementation. Full-text search, relevance
  tuning, facets, autocomplete, fuzzy matching.
---

# Search -- Search Implementation

## Activate When
- `/godmode:search`, "add search", "improve relevance"
- "build autocomplete", "faceted search", "add filters"
- Fuzzy matching, synonyms, multilingual search
- Existing search is slow, irrelevant, or missing

## Workflow

### Step 1: Requirements Assessment
```
SEARCH REQUIREMENTS:
Use case: site | product | document | log | autocomplete
Data volume: <N docs>, Avg size: <N KB>
Query volume: <QPS>, Latency target: <P95 ms>
Existing infra: PostgreSQL | MongoDB | none

ENGINE SELECTION:
  IF already on PG + <1M docs: PostgreSQL FTS
  IF <10M docs + typo tolerance: Meilisearch/Typesense
  IF e-commerce + managed preferred: Algolia
  IF large scale + complex queries: Elasticsearch
```
```bash
# Check existing search setup
grep -r "elasticsearch\|meilisearch\|algolia\|typesense" \
  package.json 2>/dev/null
grep -r "tsvector\|ts_rank\|to_tsquery" \
  --include="*.sql" --include="*.ts" -l 2>/dev/null
```

### Step 2: Index Design
```
FIELD MAPPINGS:
  text -> searchable (weight: title 3x > tags 2x > body 1x)
  keyword -> filter, sort, facet
  numeric -> filter, sort, facet (range)
  datetime -> filter, sort
  geo_point -> location filter/sort

ANALYZERS:
  search: standard + lowercase + stop + stemmer + synonyms
  autocomplete: standard + lowercase + edge_ngram(1,20)
  exact: keyword + lowercase

SHARD SIZING:
  Start 1 shard, 1 replica
  Scale shards at 10M+ docs (10-50GB per shard)
```

### Step 3: Relevance Tuning
```
RANKING COMPONENTS:
  Text relevance (BM25): 60% weight
  Field boosting: title 3x, exact match 5x
  Recency signal: 15% (30-day half-life decay)
  Popularity signal: 15% (views, CTR, log1p)
  Personalization: 10% (user history)
  Penalties: out of stock -50%, flagged -100%

RELEVANCE TESTING:
  Build suite: query -> expected top 3 -> pass/fail
  Metrics: Precision@10, Recall@10, NDCG@10, MRR
  Target: NDCG@10 >= 0.85, zero-result rate <3%
```

### Step 4: Autocomplete & Suggestions
```
TYPES:
  Query suggest: prefix on popular queries, <50ms
  Result suggest: edge_ngram on fields, <100ms
  Completion suggest: with category context, <30ms
  Did you mean: phrase suggester, <100ms

CLIENT RULES:
  Debounce 200-300ms, min 2 chars
  Cancel previous with AbortController
  Max 5-8 suggestions, highlight matched prefix
```

### Step 5: Faceted Search
```
FACET TYPES:
  Terms (checkbox): category, brand, color
    OR within facet, AND across facets
  Range (slider): price, rating
  Boolean (toggle): availability
Show counts per value. Hide facets with 0 results.
Encode in URL for shareable links.
```

### Step 6: Fuzzy Matching & Synonyms
```
FUZZY: fuzziness=AUTO
  0 edits for 1-2 chars
  1 edit for 3-5 chars
  2 edits for 6+ chars
  prefix_length=2, max_expansions=50

SYNONYMS:
  Two-directional: laptop, notebook, portable
  One-directional: js => javascript, k8s => kubernetes
  External file (update without reindex)
  Review monthly, add from zero-result queries
```

### Step 7: Performance
```
Refresh interval: 1s default, 30s batch, -1 bulk
Bulk indexing: batch 500-5000, 2-4 threads
  Disable replicas + refresh during bulk load
Index lifecycle: hot-warm-cold
  Rollover at 50GB or 30 days

TARGETS:
  Index throughput: >5000 docs/sec
  Search P50: <50ms, P95: <200ms
  Autocomplete P95: <50ms
```

### Step 8: Search Analytics
```
TRACK:
  Zero-result rate: target <3%
  CTR: target >30%
  Click position: target <3
  Search exit rate: target <15%
  Autocomplete accept: target >40%
ACTION: top zero-result queries ->
  add synonyms, fix data, add content
```

### Step 9: Commit
Commit: `"search: <index> -- <engine>, <N> fields, NDCG <score>"`

## Key Behaviors
1. **Simplest tool first.** PostgreSQL FTS for millions.
2. **Relevance is measurable.** NDCG, precision, CTR.
3. **Analyzers are the foundation.**
4. **Monitor zero-result queries.**
5. **Autocomplete latency is sacred.** Sub-50ms.
6. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER add Elasticsearch for <100K docs.
2. EVERY search must have a relevance test suite.
3. NEVER high fuzziness without prefix_length >= 2.
4. ALWAYS track zero-result queries.
5. NEVER reindex in place. Use aliases + swap.
6. SANITIZE every search input.
7. ALWAYS use index aliases, never raw names.
8. Autocomplete must respond <100ms.

## Auto-Detection
```bash
grep -r "elasticsearch\|meilisearch\|algolia" \
  package.json 2>/dev/null
grep -r "tsvector" --include="*.sql" -l 2>/dev/null
```

## TSV Logging
Append to `.godmode/search-results.tsv`:
`timestamp\tengine\tindexes\tfacets\tautocomplete\tndcg\tstatus`

## Output Format
```
SEARCH: Engine: {name}. Indexes: {N}. Facets: {N}.
NDCG@10: {score}. Zero-result: {N}%.
P50: {N}ms. P95: {N}ms. Status: {DONE|PARTIAL}.
```

## Keep/Discard Discipline
```
KEEP if: NDCG >= previous AND Precision >= previous
DISCARD if: either metric regressed
Never deploy without full relevance test suite.
```

## Stop Conditions
```
STOP when:
  - NDCG@10 >= 0.85 AND zero-result <3% AND P95 <200ms
  - Improvement <0.01 per iteration
  - User requests stop OR max 10 iterations
```
