# /godmode:contract

Consumer-driven contract testing for APIs. Defines contracts between consumers and producers, generates mock servers, verifies provider compliance, detects breaking changes, and produces compatibility matrices.

## Usage

```
/godmode:contract                       # Full contract testing workflow
/godmode:contract --consumer <name>     # Generate contract for a specific consumer
/godmode:contract --provider <name>     # Verify contracts for a specific provider
/godmode:contract --breaking            # Run breaking change detection only
/godmode:contract --mock                # Start mock server from existing contracts
/godmode:contract --matrix              # Generate compatibility matrix only
/godmode:contract --publish             # Publish contracts to Pact Broker
/godmode:contract --can-i-deploy        # Check deployment safety for a version
/godmode:contract --framework pact      # Use Pact framework (default)
/godmode:contract --framework spring    # Use Spring Cloud Contract
/godmode:contract --ci                  # Generate CI/CD pipeline config
```

## What It Does

1. Discovers producers, consumers, and existing contracts
2. Defines consumer contracts with request/response expectations and matchers
3. Generates Pact specs (JS/TS/Python) with proper matching rules
4. Creates mock servers from contracts for consumer-side testing
5. Verifies provider compliance against all consumer contracts
6. Detects breaking changes between API versions
7. Generates compatibility matrix across all consumers and provider versions
8. Integrates contract testing into CI/CD pipelines

## Output
- Consumer contracts at `tests/contracts/<consumer>-<provider>.pact.spec.ts`
- Mock server stubs at `tests/mocks/<provider>-stubs/`
- Compatibility matrix at `docs/api/compatibility-matrix.md`
- Contract report at `docs/api/<provider>-contract-report.md`
- Verdict: COMPATIBLE / INCOMPATIBLE / REQUIRES MIGRATION
- Commit: `"contract: <provider> — <N> consumers verified, <verdict>"`

## Next Step
If incompatible: `/godmode:api` to revise the API design.
If compatible: `/godmode:ship` to deploy safely.

## Examples

```
/godmode:contract                                # Full contract testing
/godmode:contract --consumer frontend            # Test frontend contracts
/godmode:contract --breaking                     # Check for breaking changes
/godmode:contract --can-i-deploy                 # Safe to deploy?
/godmode:contract --mock                         # Start mock server for dev
```
