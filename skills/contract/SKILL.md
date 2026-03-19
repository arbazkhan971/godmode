---
name: contract
description: |
  Contract testing skill. Activates when user needs to verify API compatibility between producers and consumers. Implements consumer-driven contract testing using Pact and similar frameworks, generates mock servers from contracts, verifies provider compliance, and detects breaking changes between API versions. Triggers on: /godmode:contract, "test API contracts", "verify API compatibility", "check for breaking changes", or when invoked after /godmode:api completes.
---

# Contract — API Contract Testing

## When to Activate
- User invokes `/godmode:contract`
- User says "test API contracts", "verify compatibility", "check for breaking changes"
- After `/godmode:api` completes and contracts need verification
- When a provider API changes and consumers need validation
- When onboarding a new API consumer
- When migrating between API versions

## Workflow

### Step 1: Contract Discovery
Identify the APIs, producers, and consumers involved:

```
CONTRACT SCOPE:
┌───────────────────────────────────────────────────────────────┐
│  Producer: <service name> (<API type: REST/GraphQL/gRPC>)     │
│  Base URL: <endpoint URL>                                     │
│  Spec: <path to OpenAPI/proto/SDL file, if any>               │
│                                                               │
│  Consumers:                                                   │
│  1. <consumer name> — uses: <list of endpoints/operations>    │
│  2. <consumer name> — uses: <list of endpoints/operations>    │
│  3. <consumer name> — uses: <list of endpoints/operations>    │
│                                                               │
│  Contract Framework: Pact | Spring Cloud Contract | Custom    │
│  Contract Storage: Pact Broker | Git | Local                  │
└───────────────────────────────────────────────────────────────┘
```

If no contracts exist yet: "No existing contracts found. Starting consumer-driven contract definition."

### Step 2: Consumer Contract Definition
For each consumer, define what they expect from the producer:

```
CONSUMER CONTRACT: <Consumer Name> -> <Producer Name>

Interaction 1: <descriptive name>
┌───────────────────────────────────────────────────────────────┐
│  Description: <what the consumer expects>                     │
│  Given: <provider state / precondition>                       │
│                                                               │
│  Request:                                                     │
│    Method: <GET|POST|PUT|PATCH|DELETE>                        │
│    Path: <endpoint path>                                      │
│    Headers:                                                   │
│      Authorization: Bearer <token>                            │
│      Content-Type: application/json                           │
│    Body (if applicable):                                      │
│      { <request payload with matchers> }                      │
│                                                               │
│  Expected Response:                                           │
│    Status: <HTTP status code>                                 │
│    Headers:                                                   │
│      Content-Type: application/json                           │
│    Body:                                                      │
│      {                                                        │
│        "id": "<any string matching UUID>",                    │
│        "name": "<any non-empty string>",                      │
│        "status": "<one of: active, inactive>",                │
│        "created_at": "<any ISO 8601 datetime>"                │
│      }                                                        │
│    Matching rules:                                            │
│      - $.id: type match (string)                              │
│      - $.name: type match (string, min length 1)              │
│      - $.status: regex match (active|inactive)                │
│      - $.created_at: type match (datetime)                    │
└───────────────────────────────────────────────────────────────┘
```

#### Pact Contract (JavaScript/TypeScript):
```typescript
// <consumer>-<provider>.pact.spec.ts
import { PactV4 } from '@pact-foundation/pact';

const provider = new PactV4({
  consumer: '<ConsumerName>',
  provider: '<ProviderName>',
});

describe('<Consumer> -> <Provider> contract', () => {
  it('<interaction description>', async () => {
    await provider
      .addInteraction()
      .given('<provider state>')
      .uponReceiving('<interaction description>')
      .withRequest('<METHOD>', '<path>', (builder) => {
        builder.headers({ Authorization: 'Bearer <token>' });
      })
      .willRespondWith(<status>, (builder) => {
        builder.headers({ 'Content-Type': 'application/json' });
        builder.jsonBody({
          id: like('<uuid>'),
          name: like('<name>'),
          status: regex('active|inactive', 'active'),
          created_at: like('<datetime>'),
        });
      })
      .executeTest(async (mockServer) => {
        const response = await fetch(`${mockServer.url}<path>`, {
          headers: { Authorization: 'Bearer <token>' },
        });
        expect(response.status).toBe(<status>);
        const body = await response.json();
        expect(body.id).toBeDefined();
      });
  });
});
```

#### Pact Contract (Python):
```python
# test_<consumer>_<provider>_contract.py
import pytest
from pact import Consumer, Provider

pact = Consumer('<ConsumerName>').has_pact_with(
    Provider('<ProviderName>'),
    pact_dir='./pacts'
)

def test_<interaction_name>():
    expected = {
        'id': Term(r'[a-f0-9-]{36}', '<sample-uuid>'),
        'name': Like('<sample-name>'),
        'status': Term(r'active|inactive', 'active'),
    }

    pact.given('<provider state>')
    pact.upon_receiving('<interaction description>')
    pact.with_request('<METHOD>', '<path>')
    pact.will_respond_with(<status>, body=expected)

    with pact:
        result = consumer_client.get_<resource>('<id>')
        assert result.id is not None
```

### Step 3: Mock Server Generation
Generate a mock server from the contracts for consumer-side testing:

```
MOCK SERVER CONFIGURATION:
┌───────────────────────────────────────────────────────────────┐
│  Source: <contract files / Pact Broker / OpenAPI spec>        │
│  Port: <port number>                                          │
│  Stubs:                                                       │
│                                                               │
│  GET /api/v1/resources                                        │
│    -> 200: { data: [...], pagination: {...} }                 │
│                                                               │
│  GET /api/v1/resources/:id                                    │
│    -> 200: { id: "...", name: "...", ... }   (resource exists)│
│    -> 404: { error: { code: "RESOURCE_NOT_FOUND" } }         │
│                                                               │
│  POST /api/v1/resources                                       │
│    -> 201: { id: "...", ... }                (valid input)    │
│    -> 400: { error: { code: "VALIDATION_ERROR" } }           │
│    -> 422: { error: { code: "..." } }        (semantic error) │
│                                                               │
│  Scenarios:                                                   │
│    default — happy path responses                             │
│    error — error responses for all endpoints                  │
│    empty — empty collections, null optional fields            │
│    slow — adds 2s delay to simulate latency                   │
└───────────────────────────────────────────────────────────────┘
```

Start the mock server:
```bash
# Pact mock server
npx @pact-foundation/pact-core mock-service \
  --pact-dir ./pacts \
  --port 8080

# Prism (from OpenAPI spec)
npx @stoplight/prism-cli mock openapi.yaml --port 8080

# WireMock (JVM-based)
java -jar wiremock.jar --port 8080 --root-dir ./stubs
```

### Step 4: Provider Verification
Verify that the producer satisfies all consumer contracts:

```
PROVIDER VERIFICATION:
┌───────────────────────────────────────────────────────────────┐
│  Provider: <service name>                                     │
│  Provider URL: <running instance URL>                         │
│  Contracts to verify:                                         │
│    1. <Consumer A> — <N interactions>                         │
│    2. <Consumer B> — <N interactions>                         │
│    3. <Consumer C> — <N interactions>                         │
│                                                               │
│  Provider states setup:                                       │
│    "resource exists": POST /setup { state: "resource_exists" }│
│    "no resources": POST /setup { state: "empty" }             │
│    "user is admin": POST /setup { state: "admin_user" }       │
└───────────────────────────────────────────────────────────────┘
```

Run provider verification:
```bash
# Pact provider verification (JS/TS)
npx jest --testPathPattern='pact/provider'

# Pact provider verification (CLI)
npx @pact-foundation/pact-provider-verifier \
  --provider-base-url=http://localhost:3000 \
  --pact-broker-base-url=https://pact-broker.example.com \
  --provider=<ProviderName> \
  --provider-version=$(git rev-parse HEAD) \
  --publish-verification-results

# Pact provider verification (Python)
pytest tests/pact/test_provider.py -v
```

Provider verification test:
```typescript
// pact/provider/provider.pact.spec.ts
import { Verifier } from '@pact-foundation/pact';

describe('Provider verification', () => {
  it('validates all consumer contracts', async () => {
    const verifier = new Verifier({
      providerBaseUrl: 'http://localhost:3000',
      provider: '<ProviderName>',
      pactBrokerUrl: process.env.PACT_BROKER_URL,
      publishVerificationResult: true,
      providerVersion: process.env.GIT_SHA,
      stateHandlers: {
        '<provider state>': async () => {
          // Set up the required state in the database/service
          await seedDatabase({ /* test data */ });
        },
        'no resources exist': async () => {
          await clearDatabase();
        },
      },
    });
    await verifier.verifyProvider();
  });
});
```

### Step 5: Breaking Change Detection
Compare API versions to detect breaking changes:

```
BREAKING CHANGE ANALYSIS: v1 -> v2
┌───────────────────────────────────────────────────────────────┐
│  Status: <N> breaking changes detected                        │
│                                                               │
│  BREAKING:                                                    │
│  1. REMOVED endpoint: DELETE /api/v1/resources/:id/archive    │
│     Impact: Consumer A uses this in 3 places                  │
│     Migration: Use PATCH /api/v2/resources/:id { archived: t }│
│                                                               │
│  2. RENAMED field: "userName" -> "username"                   │
│     Impact: All consumers parsing this field                  │
│     Migration: Update all references to use "username"        │
│                                                               │
│  3. CHANGED type: "count" integer -> string                   │
│     Impact: Consumers expecting numeric type                  │
│     Migration: Parse string to int on consumer side           │
│                                                               │
│  NON-BREAKING:                                                │
│  4. ADDED endpoint: GET /api/v2/resources/:id/history         │
│  5. ADDED field: "metadata" (optional object)                 │
│  6. ADDED query param: "sort_by" on list endpoint             │
│                                                               │
│  DEPRECATIONS:                                                │
│  7. DEPRECATED: GET /api/v1/resources/:id/legacy-detail       │
│     Sunset: 2026-06-01                                        │
│     Replacement: GET /api/v2/resources/:id                    │
└───────────────────────────────────────────────────────────────┘
```

Run breaking change detection:
```bash
# OpenAPI diff
npx openapi-diff old-spec.yaml new-spec.yaml

# Optic (API change management)
npx @useoptic/optic diff openapi-v1.yaml openapi-v2.yaml

# Proto (gRPC)
buf breaking --against .git#branch=main

# GraphQL
npx graphql-inspector diff old-schema.graphql new-schema.graphql
```

### Step 6: Compatibility Matrix
Generate a compatibility matrix across all consumers and provider versions:

```
COMPATIBILITY MATRIX:
┌─────────────────┬────────────┬────────────┬────────────┐
│  Consumer       │  v1.0      │  v1.1      │  v2.0      │
├─────────────────┼────────────┼────────────┼────────────┤
│  Frontend App   │  PASS      │  PASS      │  FAIL (2)  │
│  Mobile App     │  PASS      │  PASS      │  PASS      │
│  Partner API    │  PASS      │  PASS      │  FAIL (1)  │
│  Internal Svc   │  N/A       │  PASS      │  PASS      │
└─────────────────┴────────────┴────────────┴────────────┘

Deployment safety:
- v1.1: SAFE to deploy (all consumers pass)
- v2.0: BLOCKED (Frontend App and Partner API have failures)

Required actions before v2.0 deployment:
1. Frontend App: Update field name "userName" -> "username" (2 references)
2. Partner API: Add handling for removed /archive endpoint
```

### Step 7: Contract Test Report

```
┌────────────────────────────────────────────────────────────────┐
│  CONTRACT TEST REPORT                                          │
├────────────────────────────────────────────────────────────────┤
│  Provider: <service name> (v<version>)                         │
│  Consumers tested: <N>                                         │
│  Total interactions: <N>                                       │
│  Passed: <N>                                                   │
│  Failed: <N>                                                   │
│  Pending: <N> (new interactions not yet verified)               │
│                                                                │
│  Breaking changes: <N>                                         │
│  Non-breaking changes: <N>                                     │
│  Deprecations: <N>                                             │
│                                                                │
│  Verdict: <COMPATIBLE | INCOMPATIBLE | REQUIRES MIGRATION>     │
├────────────────────────────────────────────────────────────────┤
│  Failures:                                                     │
│  1. <Consumer A> / <interaction>: <reason>                     │
│  2. <Consumer B> / <interaction>: <reason>                     │
│                                                                │
│  Artifacts:                                                    │
│  - Contracts: tests/contracts/<consumer>-<provider>.pact.json  │
│  - Mock stubs: tests/mocks/<provider>-stubs/                   │
│  - Compatibility matrix: docs/api/compatibility-matrix.md      │
│  - Report: docs/api/<provider>-contract-report.md              │
└────────────────────────────────────────────────────────────────┘
```

### Step 8: CI/CD Integration
Set up contract testing in the deployment pipeline:

```
CONTRACT TESTING IN CI/CD:

Consumer pipeline (runs on consumer changes):
┌─────────────────────────────────────────────────────────────┐
│  1. Run consumer contract tests (generate pact files)       │
│  2. Publish pacts to broker: pact-broker publish            │
│  3. Can-i-deploy check: pact-broker can-i-deploy            │
│     --pacticipant <Consumer> --version $(git rev-parse HEAD)│
│  4. If can-i-deploy passes -> deploy consumer               │
│  5. Record deployment: pact-broker record-deployment        │
└─────────────────────────────────────────────────────────────┘

Provider pipeline (runs on provider changes):
┌─────────────────────────────────────────────────────────────┐
│  1. Run provider verification against all consumer pacts    │
│  2. Publish results: --publish-verification-results         │
│  3. Can-i-deploy check: pact-broker can-i-deploy            │
│     --pacticipant <Provider> --version $(git rev-parse HEAD)│
│  4. If can-i-deploy passes -> deploy provider               │
│  5. Record deployment: pact-broker record-deployment        │
└─────────────────────────────────────────────────────────────┘

Webhook triggers:
- When consumer publishes new pact -> trigger provider verification
- When provider verification fails -> notify consumer team
- When contract changes -> trigger compatibility matrix rebuild
```

### Step 9: Commit and Transition

```
CONTRACT TESTING COMPLETE:

Artifacts:
- Consumer contracts: <N> contracts for <M> consumers
- Mock server config: tests/mocks/<provider>-stubs/
- Compatibility matrix: docs/api/compatibility-matrix.md
- Contract report: docs/api/<provider>-contract-report.md

Verdict: <COMPATIBLE | INCOMPATIBLE | REQUIRES MIGRATION>

Next steps:
-> /godmode:api — Revise API design if incompatible
-> /godmode:build — Implement missing provider states
-> /godmode:ship — Deploy if all contracts pass
```

Commit: `"contract: <provider> — <N> consumers verified, <verdict>"`

## Key Behaviors

1. **Consumer-driven, always.** The consumer defines what it needs. The provider proves it delivers. Never the other way around.
2. **Contracts are tests, not documentation.** Contracts run in CI. They fail builds. They block deployments. They are not optional.
3. **Use matchers, not exact values.** A contract should say "id is a UUID string" not "id is abc-123." Exact values make contracts brittle.
4. **Provider states are essential.** The provider must be able to set up the preconditions each contract expects. Without provider states, verification is meaningless.
5. **Can-i-deploy before every deployment.** Never deploy a consumer or provider without checking contract compatibility first.
6. **Detect breaking changes early.** Run breaking change detection on every PR that modifies API routes, schemas, or protobuf definitions.
7. **Mock servers match contracts.** The mock server a consumer uses in testing must be generated from the same contracts the provider verifies against. No hand-written mocks.

## Example Usage

### Setting up contract tests for a new consumer
```
User: /godmode:contract Set up contract tests between our frontend and the user service API

Contract: Starting discovery...

CONTRACT SCOPE:
Producer: UserService (REST, OpenAPI 3.1)
Base URL: https://api.example.com/v1
Spec: docs/api/user-service-openapi.yaml

Consumers:
1. Frontend App — uses: GET /users, GET /users/:id, PATCH /users/:id

Generating consumer contracts...

CONSUMER CONTRACT: Frontend -> UserService

Interaction 1: "get user by ID"
  Given: "user with ID abc-123 exists"
  GET /api/v1/users/abc-123
  -> 200: { id: like("abc-123"), email: like("user@example.com"), name: like("Jane") }

Interaction 2: "list users with pagination"
  Given: "multiple users exist"
  GET /api/v1/users?limit=20
  -> 200: { data: eachLike({...}), pagination: { has_more: like(true) } }

Interaction 3: "update user name"
  Given: "user with ID abc-123 exists"
  PATCH /api/v1/users/abc-123 { name: "Updated Name" }
  -> 200: { id: "abc-123", name: "Updated Name", ... }

Generated: tests/contracts/frontend-userservice.pact.spec.ts
Mock server ready on port 8080
```

### Checking for breaking changes
```
User: /godmode:contract Check if our API v2 changes break any consumers

Contract: Analyzing changes between v1 and v2...

BREAKING CHANGE ANALYSIS: v1.3 -> v2.0
3 breaking changes detected:
1. REMOVED: "legacy_id" field from User response
2. CHANGED: "role" from string to enum
3. RENAMED: "createdAt" to "created_at"

COMPATIBILITY MATRIX:
Frontend App:  FAIL (uses legacy_id, uses createdAt)
Mobile App:    FAIL (uses createdAt)
Admin Panel:   PASS

Verdict: INCOMPATIBLE — 2 of 3 consumers affected

Run /godmode:api --diff v1 v2 to see full migration guide.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full contract testing workflow |
| `--consumer <name>` | Generate contract for a specific consumer |
| `--provider <name>` | Verify contracts for a specific provider |
| `--breaking` | Run breaking change detection only |
| `--mock` | Start mock server from existing contracts |
| `--matrix` | Generate compatibility matrix only |
| `--publish` | Publish contracts to Pact Broker |
| `--can-i-deploy` | Check deployment safety for a specific version |
| `--framework pact` | Use Pact framework (default) |
| `--framework spring` | Use Spring Cloud Contract |
| `--ci` | Generate CI/CD pipeline configuration for contract testing |

## HARD RULES

1. **NEVER STOP** until all consumer-provider pairs have contracts defined and verified.
2. **Consumer-driven ALWAYS** — the consumer defines expectations, the provider proves compliance.
3. **NEVER use exact value matching** — use type matchers, regex, and structural matchers.
4. **NEVER deploy without can-i-deploy check.** No exceptions.
5. **NEVER hand-write mock servers** — generate from contracts.
6. **git commit BEFORE verify** — commit contracts, then run verification.
7. **Automatic revert on regression** — if provider changes break consumer contracts, block deployment.
8. **TSV logging** — log every contract test run:
   ```
   timestamp	provider	consumer	interactions	passed	failed	breaking_changes	verdict
   ```

## Multi-Agent Dispatch

For systems with multiple consumers and providers, dispatch parallel agents:

```
MULTI-AGENT CONTRACT TESTING:

Agent 1 (worktree: contract-consumer-frontend):
  Scope: Frontend App consumer contracts
  Task: Define/update consumer expectations for all API endpoints used
  Output: pacts/frontend-*.pact.json

Agent 2 (worktree: contract-consumer-mobile):
  Scope: Mobile App consumer contracts
  Task: Define/update consumer expectations for mobile-specific endpoints
  Output: pacts/mobile-*.pact.json

Agent 3 (worktree: contract-provider-verify):
  Scope: Provider verification
  Task: Set up provider states, verify ALL consumer pacts against running provider
  Output: verification-results.md

Agent 4 (worktree: contract-breaking-analysis):
  Scope: Breaking change detection
  Task: Diff current spec vs previous version, identify breaking changes,
        generate compatibility matrix
  Output: compatibility-matrix.md, breaking-changes.md

MERGE: Combine all pacts, verify compatibility matrix,
       produce unified can-i-deploy decision.
```

## Anti-Patterns

- **Do NOT write contracts that match exact values.** Use type matchers, regex matchers, and structural matchers. Exact value matching makes contracts brittle and noisy.
- **Do NOT skip provider states.** A contract that says "given a user exists" must have a corresponding provider state handler that actually creates the user. Stateless verification is meaningless.
- **Do NOT let the provider define the contract.** Consumer-driven means the consumer says what it needs. If the provider writes the contract, it will test what it provides, not what consumers actually use.
- **Do NOT hand-write mock servers.** Mock servers must be generated from contracts. A hand-written mock will drift from the real API and give false confidence.
- **Do NOT treat contract tests as integration tests.** Contract tests verify the shape and structure of interactions, not business logic. Use integration tests for logic.
- **Do NOT deploy without can-i-deploy.** The whole point of contract testing is safe deployment. Bypassing the check defeats the purpose.
- **Do NOT ignore pending pacts.** When a consumer adds a new interaction, the provider must verify it before the consumer deploys. Pending pacts are a time bomb.
- **Do NOT test every field combination.** Test the fields the consumer actually uses. If the consumer only reads `id` and `name`, don't assert on every field in the response.
