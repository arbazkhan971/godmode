Flaw: main.sh evals the user-supplied test once per line, so "x; touch m" executes.
Fix: validate the test against a strict flat [[ cond (&&/|| cond)* ]] grammar, then
evaluate it with a tokenizer (eval removed entirely); anything else exits 2 with a diagnostic.
Verified: 13/13 hostile shapes rejected rc=2 with no side effects; 4 benign inputs
byte-identical to starter; starter EXIT=1, solution EXIT=0, metric ~0.1s.
