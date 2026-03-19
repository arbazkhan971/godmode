# /godmode:unittest

Unit testing mastery with proper structure, mocking strategies, property-based testing, and mutation testing. Produces high-confidence tests that verify behavior, not implementation.

## Usage

```
/godmode:unittest                          # Analyze and write comprehensive unit tests
/godmode:unittest --for <file>             # Write unit tests for a specific file
/godmode:unittest --mock-strategy          # Analyze dependencies and recommend mocking approach
/godmode:unittest --property               # Focus on property-based tests
/godmode:unittest --mutation               # Run mutation testing and fill gaps
/godmode:unittest --coverage               # Focus on increasing branch coverage
/godmode:unittest --framework jest         # Target a specific framework
/godmode:unittest --refactor               # Refactor existing tests for better structure
```

## What It Does

1. Analyzes the unit under test and maps its dependency graph
2. Chooses test structure (Arrange-Act-Assert or Given-When-Then)
3. Applies the mocking decision framework:
   - **Stubs** for dependencies that return values
   - **Mocks** for dependencies where interactions matter
   - **Fakes** for dependencies needing realistic behavior
   - **Spies** for observing real implementations
   - **Real implementations** for pure internal collaborators
4. Writes example-based tests (happy path, edge cases, errors)
5. Writes property-based tests for invariants (fast-check, Hypothesis)
6. Optionally runs mutation testing to find gaps in test quality
7. Reports coverage and confidence metrics

## Output
- Test files following project structure conventions
- Mocking strategy rationale for each dependency
- Coverage report with before/after comparison
- Mutation score (if mutation testing enabled)
- Commit: `"test(unit): <module> — <N> tests, <coverage>% branch coverage"`

## Next Step
If mocking is heavy: `/godmode:integration` to test with real dependencies.
If property tests find edge cases: `/godmode:fix` to handle them.

## Examples

```
/godmode:unittest --for src/services/payment.ts
/godmode:unittest --property                      # Property-based tests
/godmode:unittest --mutation                       # Find test gaps via mutation
/godmode:unittest --mock-strategy                  # Get mocking recommendations
/godmode:unittest --framework pytest               # Target pytest
```
