---
name: search
description: |
  Search implementation skill. Activates when teams need to design, build, or optimize search functionality. Covers full-text search engine selection and configuration (Elasticsearch, Algolia, Meilisearch, Typesense, PostgreSQL FTS), relevance tuning and ranking algorithms (BM25, TF-IDF, vector embeddings), faceted search, autocomplete, fuzzy matching, synonym handling, and index design. Provides structured workflows for building production search from zero to deployed. Triggers on: /godmode:search, "add search", "search is slow", "improve relevance", "build autocomplete", "faceted search", or when the application needs full-text search capability.
---

# Search — Search Implementation & Relevance Engineering

## When to Activate
- User invokes `/godmode:search`
- User says "add search", "build search", "implement full-text search"
- User says "search results are bad", "improve relevance", "results are not relevant"
- User says "build autocomplete", "add typeahead", "search suggestions"
- User says "add faceted search", "add filters to search"
- User needs fuzzy matching, synonym handling, or multilingual search
- Application requires full-text search and no search infrastructure exists
- Existing search is slow, irrelevant, or missing features
- Godmode orchestrator detects search-related code (indices, analyzers, search queries)

## Workflow

### Step 1: Search Requirements Assessment

Evaluate the search use case, data characteristics, and constraints:

```
SEARCH REQUIREMENTS ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│  Dimension          │ Value                               │
│  ─────────────────────────────────────────────────────── │
│  Use case           │ <site search | product search |     │
│                     │  document search | log search |     │
│                     │  autocomplete | geo search>         │
│  Data volume        │ <N documents>                       │
│  Document size      │ <avg size per document>             │
│  Index frequency    │ <real-time | near-real-time |       │
│                     │  batch hourly | batch daily>        │
│  Query volume       │ <queries per second>                │
│  Latency target     │ <P95 latency requirement>           │
│  Languages          │ <list of languages>                 │
│  Structured fields  │ <filterable attributes>             │
│  Existing infra     │ <PostgreSQL | MongoDB | none>       │
│  Budget             │ <self-hosted OK | managed only>     │
│  Team expertise     │ <none | basic | advanced>           │
├──────────────────────────────────────────────────────────┤
│  Recommendation: <engine selection with rationale>        │
└──────────────────────────────────────────────────────────┘
```

#### Engine Selection Matrix
```
ENGINE SELECTION:
┌───────────────────┬────────────┬───────────┬──────────┬───────────┬──────────────┐
│ Engine            │ Best for   │ Scale     │ Ops cost │ Relevance │ Realtime idx │
├───────────────────┼────────────┼───────────┼──────────┼───────────┼──────────────┤
│ Elasticsearch     │ Large-scale│ Billions  │ High     │ Excellent │ Near-RT      │
│                   │ complex    │ of docs   │          │           │              │
│ Algolia           │ E-commerce │ Millions  │ None     │ Great     │ Real-time    │
│                   │ instant UX │           │ (hosted) │ (tunable) │              │
│ Meilisearch       │ Small-med  │ 10M docs  │ Low      │ Good      │ Near-RT      │
│                   │ typo-toler │           │          │           │              │
│ Typesense         │ Speed-     │ Millions  │ Low      │ Good      │ Real-time    │
│                   │ critical   │           │          │           │              │
│ PostgreSQL FTS    │ Already    │ Millions  │ None     │ Adequate  │ Real-time    │
│                   │ using PG   │ (with idx)│ (no new) │           │              │
│ OpenSearch        │ AWS-native │ Billions  │ Medium   │ Excellent │ Near-RT      │
│                   │ log/search │           │          │           │              │
│ Solr              │ Enterprise │ Billions  │ High     │ Excellent │ Near-RT      │
│                   │ faceting   │           │          │           │              │
└───────────────────┴────────────┴───────────┴──────────┴───────────┴──────────────┘

Decision tree:
  Already on PostgreSQL + < 1M docs + basic search? → PostgreSQL FTS
  Need instant typo-tolerant search + < 10M docs?   → Meilisearch or Typesense
  E-commerce with facets + managed preferred?        → Algolia
  Large scale + complex queries + analytics?         → Elasticsearch
  AWS-native + logging + search?                     → OpenSearch
```

### Step 2: Index Design

Design the search index schema, analyzers, and mappings:

```
INDEX DESIGN:
Index name: <index_name>
Primary key: <document ID field>

Field mappings:
┌──────────────────┬────────────┬──────────┬──────────┬──────────┬────────────┐
│ Field            │ Type       │ Search   │ Filter   │ Sort     │ Facet      │
├──────────────────┼────────────┼──────────┼──────────┼──────────┼────────────┤
│ title            │ text       │ YES (3x) │ —        │ —        │ —          │
│ description      │ text       │ YES (1x) │ —        │ —        │ —          │
│ category         │ keyword    │ —        │ YES      │ YES      │ YES        │
│ price            │ float      │ —        │ YES      │ YES      │ YES (range)│
│ tags             │ keyword[]  │ —        │ YES      │ —        │ YES        │
│ created_at       │ datetime   │ —        │ YES      │ YES      │ —          │
│ location         │ geo_point  │ —        │ YES      │ YES      │ —          │
│ status           │ keyword    │ —        │ YES      │ —        │ YES        │
└──────────────────┴────────────┴──────────┴──────────┴──────────┴────────────┘

Weight boosting: title (3x) > tags (2x) > description (1x)
```

#### Analyzer Configuration
```
TEXT ANALYSIS PIPELINE:
┌──────────────────────────────────────────────────────────┐
│  Stage            │ Component         │ Purpose           │
│  ─────────────────────────────────────────────────────── │
│  Char filter      │ html_strip        │ Remove HTML tags  │
│  Tokenizer        │ standard          │ Split on words    │
│  Token filter 1   │ lowercase         │ Case-insensitive  │
│  Token filter 2   │ stop words        │ Remove "the", etc │
│  Token filter 3   │ stemmer           │ "running" → "run" │
│  Token filter 4   │ synonym           │ "laptop" = "notebook" │
│  Token filter 5   │ asciifolding      │ "café" → "cafe"   │
│  Token filter 6   │ edge_ngram (auto) │ Prefix matching   │
└──────────────────────────────────────────────────────────┘

Custom analyzers:
  search_analyzer:    standard + lowercase + stop + stemmer + synonyms
  autocomplete_analyzer: standard + lowercase + edge_ngram(1,20)
  exact_analyzer:     keyword + lowercase (for exact match filters)
```

#### Elasticsearch Mapping Example
```json
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "search_analyzer",
        "fields": {
          "autocomplete": {
            "type": "text",
            "analyzer": "autocomplete_analyzer",
            "search_analyzer": "standard"
          },
          "exact": {
            "type": "keyword",
            "normalizer": "lowercase_normalizer"
          }
        }
      },
      "description": {
        "type": "text",
        "analyzer": "search_analyzer"
      },
      "category": {
        "type": "keyword"
      },
      "price": {
        "type": "scaled_float",
        "scaling_factor": 100
      },
      "tags": {
        "type": "keyword"
      },
      "created_at": {
        "type": "date"
      },
      "location": {
        "type": "geo_point"
      }
    }
  },
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "search_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "stemmer", "synonym_filter"]
        },
        "autocomplete_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "edge_ngram_filter"]
        }
      },
      "filter": {
        "edge_ngram_filter": {
          "type": "edge_ngram",
          "min_gram": 1,
          "max_gram": 20
        },
        "synonym_filter": {
          "type": "synonym",
          "synonyms_path": "analysis/synonyms.txt"
        }
      }
    }
  }
}
```

#### PostgreSQL FTS Setup
```sql
-- Add tsvector column for full-text search
ALTER TABLE products ADD COLUMN search_vector tsvector;

-- Populate with weighted fields
UPDATE products SET search_vector =
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(tags::text, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'C');

-- Create GIN index for fast lookup
CREATE INDEX idx_products_search ON products USING GIN(search_vector);

-- Auto-update trigger
CREATE OR REPLACE FUNCTION products_search_trigger() RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.tags::text, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'C');
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_products_search
  BEFORE INSERT OR UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION products_search_trigger();

-- Search query with ranking
SELECT id, title, ts_rank(search_vector, query) AS rank
FROM products, plainto_tsquery('english', 'wireless keyboard') AS query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 20;
```

### Step 3: Relevance Tuning

Design and tune the ranking algorithm:

```
RELEVANCE STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Component          │ Weight  │ Purpose                   │
│  ─────────────────────────────────────────────────────── │
│  Text relevance     │ 60%     │ BM25 score from query     │
│  (BM25/TF-IDF)      │         │ matching against fields   │
│                     │         │                           │
│  Field boosting     │ —       │ title (3x) > body (1x)   │
│                     │         │ exact match (5x boost)    │
│                     │         │                           │
│  Recency signal     │ 15%     │ Newer documents score     │
│                     │         │ higher via decay function  │
│                     │         │                           │
│  Popularity signal  │ 15%     │ View count, click-through │
│                     │         │ rate, purchase count       │
│                     │         │                           │
│  Personalization    │ 10%     │ User preference history,  │
│                     │         │ category affinity          │
│                     │         │                           │
│  Penalties          │ —       │ Out of stock (-50%),      │
│                     │         │ flagged content (-100%)    │
└──────────────────────────────────────────────────────────┘
```

#### Elasticsearch Relevance Query
```json
{
  "query": {
    "function_score": {
      "query": {
        "bool": {
          "must": [
            {
              "multi_match": {
                "query": "wireless keyboard",
                "fields": ["title^3", "title.exact^5", "description", "tags^2"],
                "type": "best_fields",
                "fuzziness": "AUTO",
                "prefix_length": 2
              }
            }
          ],
          "filter": [
            { "term": { "status": "active" } },
            { "range": { "price": { "gte": 10, "lte": 200 } } }
          ]
        }
      },
      "functions": [
        {
          "gauss": {
            "created_at": {
              "origin": "now",
              "scale": "30d",
              "decay": 0.5
            }
          },
          "weight": 15
        },
        {
          "field_value_factor": {
            "field": "popularity_score",
            "modifier": "log1p",
            "missing": 1
          },
          "weight": 15
        }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

#### Relevance Testing Framework
```
RELEVANCE TEST SUITE:
┌────────────────────────────────────────────────────────────────────────┐
│  Test ID │ Query              │ Expected top 3           │ Pass/Fail   │
├──────────┼────────────────────┼──────────────────────────┼─────────────┤
│  REL-001 │ "wireless keyboard"│ [KB-100, KB-203, KB-045] │ PASS        │
│  REL-002 │ "wireles keybord"  │ [KB-100, KB-203, KB-045] │ PASS (fuzzy)│
│  REL-003 │ "laptop"           │ [LT-001, LT-019, LT-042]│ PASS        │
│  REL-004 │ "notebook"         │ [LT-001, LT-019, LT-042]│ PASS (syn)  │
│  REL-005 │ "cheap headphones" │ [HP-033, HP-012, HP-091] │ FAIL — HP-  │
│          │                    │                          │ 091 missing │
│  REL-006 │ "" (empty)         │ [trending/popular items] │ PASS        │
└──────────┴────────────────────┴──────────────────────────┴─────────────┘

Metrics:
  Precision@10:        0.82
  Recall@10:           0.75
  NDCG@10:             0.88
  Mean Reciprocal Rank: 0.91
  Zero-result rate:    2.3%
  Click-through rate:  34%
```

### Step 4: Autocomplete & Suggestions

Design typeahead and search-as-you-type functionality:

```
AUTOCOMPLETE ARCHITECTURE:
┌──────────────────────────────────────────────────────────┐
│  Type             │ Implementation          │ Latency     │
│  ─────────────────────────────────────────────────────── │
│  Query suggest    │ Prefix matching on      │ < 50ms      │
│  (typeahead)      │ popular past queries    │             │
│                   │ with frequency ranking  │             │
│                   │                         │             │
│  Result suggest   │ Search-as-you-type on   │ < 100ms     │
│  (instant search) │ edge_ngram indexed      │             │
│                   │ document fields         │             │
│                   │                         │             │
│  Completion       │ Completion suggester    │ < 30ms      │
│  suggest          │ with context (category) │             │
│                   │                         │             │
│  Did you mean     │ Phrase suggester on     │ < 100ms     │
│  (spell correct)  │ indexed terms           │             │
└──────────────────────────────────────────────────────────┘

Debounce: 200-300ms on client side
Min chars: 2 characters before triggering
Max suggestions: 5-8 results
Highlight: Bold matched prefix in suggestions
```

#### Autocomplete Implementation (Elasticsearch)
```json
{
  "suggest": {
    "query-suggest": {
      "prefix": "wire",
      "completion": {
        "field": "title.autocomplete",
        "size": 5,
        "fuzzy": {
          "fuzziness": 1
        },
        "contexts": {
          "category": ["electronics"]
        }
      }
    },
    "did-you-mean": {
      "text": "wireles keybord",
      "phrase": {
        "field": "title",
        "size": 1,
        "gram_size": 3,
        "direct_generator": [{
          "field": "title",
          "suggest_mode": "popular"
        }]
      }
    }
  }
}
```

#### Client-Side Autocomplete Pattern
```typescript
// Debounced autocomplete with abort controller
class SearchAutocomplete {
  private controller: AbortController | null = null;
  private debounceTimer: ReturnType<typeof setTimeout> | null = null;

  async suggest(query: string): Promise<Suggestion[]> {
    // Cancel previous in-flight request
    if (this.controller) {
      this.controller.abort();
    }

    // Minimum character threshold
    if (query.length < 2) {
      return [];
    }

    // Debounce
    return new Promise((resolve) => {
      if (this.debounceTimer) clearTimeout(this.debounceTimer);
      this.debounceTimer = setTimeout(async () => {
        this.controller = new AbortController();
        try {
          const response = await fetch(`/api/search/suggest?q=${encodeURIComponent(query)}`, {
            signal: this.controller.signal,
          });
          const data = await response.json();
          resolve(data.suggestions);
        } catch (err) {
          if (err instanceof DOMException && err.name === 'AbortError') {
            resolve([]); // Request was cancelled, ignore
          }
          throw err;
        }
      }, 250);
    });
  }
}
```

### Step 5: Faceted Search & Filtering

Design faceted navigation for search results:

```
FACET DESIGN:
┌──────────────────────────────────────────────────────────┐
│  Facet            │ Type       │ Display     │ Logic      │
│  ─────────────────────────────────────────────────────── │
│  Category         │ Terms      │ Checkbox    │ OR within, │
│                   │            │ list        │ AND across │
│                   │            │             │            │
│  Price            │ Range      │ Slider or   │ Single     │
│                   │            │ predefined  │ range      │
│                   │            │ buckets     │            │
│                   │            │             │            │
│  Brand            │ Terms      │ Checkbox    │ OR within  │
│                   │            │ with search │            │
│                   │            │             │            │
│  Rating           │ Range      │ Star rating │ >= value   │
│                   │            │ buttons     │            │
│                   │            │             │            │
│  Color            │ Terms      │ Color       │ OR within  │
│                   │            │ swatches    │            │
│                   │            │             │            │
│  Availability     │ Terms      │ Toggle      │ Boolean    │
│                   │            │             │ filter     │
└──────────────────────────────────────────────────────────┘

Facet counts: Show count of results per facet value
Dynamic facets: Only show facets with > 0 results
Facet ordering: By count (descending) or alphabetical
URL encoding: Facets encoded in URL for shareable links
  e.g., /search?q=keyboard&category=electronics&price=10-200&brand=logitech,corsair
```

#### Elasticsearch Aggregation Query
```json
{
  "query": { "match": { "title": "keyboard" } },
  "aggs": {
    "categories": {
      "terms": { "field": "category", "size": 20 }
    },
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "key": "Under $25", "to": 25 },
          { "key": "$25-$50", "from": 25, "to": 50 },
          { "key": "$50-$100", "from": 50, "to": 100 },
          { "key": "$100-$200", "from": 100, "to": 200 },
          { "key": "Over $200", "from": 200 }
        ]
      }
    },
    "brands": {
      "terms": { "field": "brand", "size": 30 }
    },
    "avg_rating": {
      "range": {
        "field": "rating",
        "ranges": [
          { "key": "4+ stars", "from": 4 },
          { "key": "3+ stars", "from": 3 },
          { "key": "2+ stars", "from": 2 }
        ]
      }
    },
    "price_stats": {
      "stats": { "field": "price" }
    }
  }
}
```

### Step 6: Fuzzy Matching & Synonym Handling

Configure typo tolerance and synonym expansion:

```
FUZZY MATCHING CONFIG:
┌──────────────────────────────────────────────────────────┐
│  Setting           │ Value     │ Rationale                │
│  ─────────────────────────────────────────────────────── │
│  Fuzziness         │ AUTO      │ 0 edits for 1-2 chars,  │
│                    │           │ 1 edit for 3-5 chars,    │
│                    │           │ 2 edits for 6+ chars     │
│  Prefix length     │ 2         │ First 2 chars must match │
│                    │           │ exactly (prevents fan-out)│
│  Max expansions    │ 50        │ Limit term variants to   │
│                    │           │ prevent slow queries      │
│  Transpositions    │ true      │ "teh" matches "the"       │
└──────────────────────────────────────────────────────────┘

SYNONYM CONFIGURATION:
Type: Two-directional and one-directional synonyms

synonyms.txt:
  # Two-directional (equivalent)
  laptop, notebook, portable computer
  phone, mobile, cell phone, smartphone
  tv, television, telly
  couch, sofa, settee

  # One-directional (expansion only)
  js => javascript
  ts => typescript
  k8s => kubernetes
  db => database
  NY => New York

Synonym update strategy:
  - Store synonyms in external file or API (not inline in settings)
  - Update synonyms without full reindex (Elasticsearch reload API)
  - Review synonym quality monthly via search analytics
  - Add synonyms based on zero-result queries
```

### Step 7: Index Optimization & Performance

Optimize index performance for production workloads:

```
INDEX OPTIMIZATION:
┌──────────────────────────────────────────────────────────┐
│  Technique          │ When                │ Impact        │
│  ─────────────────────────────────────────────────────── │
│  Shard sizing       │ Initial design      │ High          │
│    Target: 10-50GB per shard                              │
│    Rule: 1 shard per 10M documents                        │
│                                                           │
│  Replica count      │ Initial design      │ Medium        │
│    1 replica for read-heavy workloads                     │
│    0 replicas during bulk indexing                         │
│                                                           │
│  Refresh interval   │ Indexing vs search   │ High          │
│    1s (default) for near-real-time                         │
│    30s for batch indexing workloads                        │
│    -1 to disable during bulk import                       │
│                                                           │
│  Bulk indexing      │ Initial data load    │ High          │
│    Batch size: 500-5000 documents                         │
│    Parallel: 2-4 concurrent bulk threads                  │
│    Disable replicas + refresh during load                 │
│                                                           │
│  Field data         │ Sorting/aggregation  │ Medium        │
│    Use doc_values (default, on-disk)                      │
│    Avoid fielddata on text fields                         │
│                                                           │
│  Query caching      │ Frequent queries     │ Medium        │
│    Node query cache for filtered queries                  │
│    Request cache for aggregation results                  │
│                                                           │
│  Index lifecycle    │ Time-series data     │ High          │
│    Hot-warm-cold architecture                             │
│    Rollover at 50GB or 30 days                            │
│    Force merge old indices to 1 segment                   │
└──────────────────────────────────────────────────────────┘

PERFORMANCE BENCHMARKS:
  Index throughput: <N> docs/sec (target: > 5000 docs/sec)
  Search latency P50: <N>ms (target: < 50ms)
  Search latency P95: <N>ms (target: < 200ms)
  Search latency P99: <N>ms (target: < 500ms)
  Autocomplete P95: <N>ms (target: < 50ms)
```

### Step 8: Search Analytics & Monitoring

Track search quality and user behavior:

```
SEARCH ANALYTICS:
┌──────────────────────────────────────────────────────────┐
│  Metric                    │ Current  │ Target  │ Status  │
│  ─────────────────────────────────────────────────────── │
│  Zero-result rate          │ 4.2%     │ < 3%    │ NEEDS   │
│                            │          │         │ WORK    │
│  Click-through rate        │ 32%      │ > 30%   │ OK      │
│  Click position (mean)     │ 2.4      │ < 3     │ OK      │
│  Search exit rate          │ 18%      │ < 15%   │ NEEDS   │
│                            │          │         │ WORK    │
│  Refinement rate           │ 22%      │ < 25%   │ OK      │
│  Autocomplete accept rate  │ 45%      │ > 40%   │ OK      │
│  Time to first click       │ 3.2s     │ < 4s    │ OK      │
│  Queries per session       │ 1.8      │ < 2     │ OK      │
└──────────────────────────────────────────────────────────┘

Top zero-result queries (action required):
  1. "wireles mouse" (142/day) → Add synonym: wireles → wireless
  2. "usb-c hub" (89/day) → Index product field missing USB-C tag
  3. "gift ideas" (67/day) → Add curated collection

Top queries by volume:
  1. "laptop" (1,240/day)
  2. "headphones" (890/day)
  3. "keyboard" (654/day)
```

### Step 9: Commit and Transition

```
1. Save index configuration as `search/mappings/<index>-mapping.json`
2. Save analyzer config as `search/analyzers/<index>-analyzers.json`
3. Save synonym file as `search/synonyms/synonyms.txt`
4. Save relevance tests as `search/tests/relevance-tests.json`
5. Commit: "search: <index> — <engine>, <N> fields, <N> facets, <N> synonyms, relevance score <NDCG>"
6. If new search: "Search infrastructure configured. Index and verify with test queries."
7. If relevance tuning: "Relevance tuned. NDCG improved from <old> to <new>. Review zero-result queries."
8. If autocomplete: "Autocomplete configured. P95 latency: <N>ms. Test with common queries."
```

## Key Behaviors

1. **Understand the query intent.** Not every search needs Elasticsearch. PostgreSQL FTS handles millions of documents. Choose the simplest tool that meets requirements.
2. **Relevance is measurable.** Never guess whether search is good. Define metrics (NDCG, precision, click-through), build a test suite, and measure before and after every change.
3. **Analyzers are the foundation.** Bad analyzers produce bad results regardless of query tuning. Get tokenization, stemming, and synonyms right first.
4. **Fuzzy matching has limits.** Fuzziness is expensive and can produce false positives. Use prefix length constraints and AUTO fuzziness to balance recall and precision.
5. **Facets must be consistent.** Facet counts must always reflect the current query. A facet showing 0 results is confusing — hide it or grey it out.
6. **Monitor zero-result queries.** Every zero-result query is a missed opportunity. Track them, analyze patterns, and add synonyms, fix data, or improve matching.
7. **Autocomplete latency is sacred.** Users expect sub-50ms typeahead. Optimize aggressively: completion suggesters, prefix queries, edge n-grams.
8. **Index design is hard to change.** Changing analyzers or field types requires reindexing. Design carefully upfront, test with real data.

## Example Usage

### Building product search from scratch
```
User: /godmode:search Build search for our e-commerce product catalog

Search: Assessing search requirements...

SEARCH REQUIREMENTS:
  Use case: Product search (e-commerce)
  Data volume: 250,000 products
  Query volume: ~50 queries/sec peak
  Latency target: P95 < 100ms
  Languages: English
  Existing infra: PostgreSQL

Recommendation: Meilisearch
  Rationale: < 10M docs, typo tolerance needed, low ops cost,
  instant search UX. PostgreSQL FTS would work but lacks
  built-in typo tolerance and faceting ease.

Setting up Meilisearch index...
  Index: products
  Searchable fields: title (rank 1), description (rank 2), tags (rank 3)
  Filterable: category, brand, price, rating, in_stock
  Sortable: price, rating, created_at
  Synonyms: 24 synonym groups loaded
  Typo tolerance: enabled (2 typos for 6+ chars)

Testing relevance...
  Precision@10: 0.87
  Zero-result rate: 1.8%
  Autocomplete P95: 28ms
  Search P95: 42ms

Search ready. Test at /search or run /godmode:search --tune to improve relevance.
```

### Improving existing search relevance
```
User: /godmode:search --tune Users complain search results are not relevant

Search: Analyzing search quality...

SEARCH ANALYTICS (last 7 days):
  Zero-result rate: 8.4% — HIGH (target: < 3%)
  Click position: 4.1 — HIGH (target: < 3)
  CTR: 18% — LOW (target: > 30%)
  Top zero-result queries: "wireles mouse", "usb-c hub", "gift ideas"

Issues found:
  1. Missing synonyms (32 common misspellings with no results)
  2. Field boosting wrong (description weighted same as title)
  3. No recency signal (old products ranking above new ones)
  4. No popularity signal (bestsellers not prioritized)

Applying fixes...
  Added 32 synonym pairs
  Adjusted boosting: title (3x), tags (2x), description (1x)
  Added recency decay: 30-day half-life
  Added popularity boost: log1p(sales_count)

Re-testing relevance...
  Precision@10: 0.72 → 0.86 (+19%)
  Zero-result rate: 8.4% → 2.1% (-75%)
  NDCG@10: 0.68 → 0.84 (+24%)

Commit: search: relevance-tuning — 32 synonyms, field boosting, recency+popularity signals (NDCG +24%)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full search implementation workflow |
| `--engine <name>` | Target specific engine (elasticsearch, meilisearch, algolia, postgres) |
| `--tune` | Tune relevance on existing search (analyze + improve) |
| `--autocomplete` | Design and implement autocomplete/typeahead only |
| `--facets` | Design faceted search only |
| `--index <name>` | Create or update a specific index |
| `--analyze` | Analyze search analytics and quality metrics |
| `--synonyms` | Manage synonym configuration |
| `--benchmark` | Run search performance benchmarks |
| `--migrate` | Migrate from one search engine to another |

## Anti-Patterns

- **Do NOT add Elasticsearch for 10,000 documents.** PostgreSQL FTS or Meilisearch handles small datasets with far less operational overhead. Elasticsearch is for millions to billions.
- **Do NOT skip relevance testing.** "Search works" is not "search is good." Build a test suite with expected results for common queries and measure precision/recall/NDCG.
- **Do NOT use high fuzziness without prefix length.** Fuzziness 2 with prefix length 0 turns "cat" into every 3-letter word. Always require at least 2 exact prefix characters.
- **Do NOT put user IDs in search queries for personalization.** Personalization happens in the ranking layer (function_score), not in the query DSL. Mixing them kills caching.
- **Do NOT ignore zero-result queries.** They are the single most valuable signal for improving search. Track them, review them weekly, and add synonyms or fix data.
- **Do NOT reindex in production without a plan.** Use index aliases, create the new index alongside the old one, swap the alias atomically. Never reindex in place.
- **Do NOT forget to sanitize search input.** Search queries can contain special characters that break query parsers. Escape or strip reserved characters before sending to the engine.
- **Do NOT use match_all with expensive aggregations.** Aggregations on the entire index are slow. Always pair aggregations with a filtered query to reduce the working set.
