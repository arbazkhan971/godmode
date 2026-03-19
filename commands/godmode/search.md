# /godmode:search

Design, build, and optimize full-text search functionality. Covers engine selection (Elasticsearch, Algolia, Meilisearch, PostgreSQL FTS), index design, relevance tuning, faceted search, autocomplete, fuzzy matching, and synonym handling.

## Usage

```
/godmode:search                            # Full search implementation workflow
/godmode:search --engine elasticsearch     # Target Elasticsearch specifically
/godmode:search --engine postgres          # Use PostgreSQL full-text search
/godmode:search --tune                     # Tune relevance on existing search
/godmode:search --autocomplete             # Design autocomplete/typeahead only
/godmode:search --facets                   # Design faceted search only
/godmode:search --analyze                  # Analyze search quality metrics
/godmode:search --synonyms                 # Manage synonym configuration
/godmode:search --benchmark                # Run search performance benchmarks
/godmode:search --migrate                  # Migrate between search engines
```

## What It Does

1. Assesses search requirements (use case, data volume, latency, languages)
2. Selects the appropriate search engine based on constraints
3. Designs index schema with field mappings, analyzers, and weights
4. Configures text analysis pipeline (tokenizer, stemmer, synonyms, n-grams)
5. Implements relevance scoring with BM25, field boosting, and custom signals
6. Builds autocomplete with edge n-grams and completion suggesters
7. Designs faceted search with aggregations and dynamic filters
8. Sets up fuzzy matching and synonym handling for typo tolerance
9. Optimizes index performance (sharding, caching, refresh intervals)
10. Establishes search analytics and quality monitoring

## Output
- Index mapping at `search/mappings/<index>-mapping.json`
- Analyzer config at `search/analyzers/<index>-analyzers.json`
- Synonym file at `search/synonyms/synonyms.txt`
- Relevance test suite at `search/tests/relevance-tests.json`
- Commit: `"search: <index> — <engine>, <N> fields, <N> facets, relevance NDCG=<value>"`

## Next Step
After search implementation: `/godmode:observe` to add search monitoring, or `/godmode:optimize` to performance-tune queries.

## Examples

```
/godmode:search Build product search for our e-commerce catalog
/godmode:search --engine postgres Add full-text search to our PostgreSQL app
/godmode:search --tune Users say search results are not relevant
/godmode:search --autocomplete Add typeahead to the search bar
/godmode:search --facets Add category and price filters to search
```
