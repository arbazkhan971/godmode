# /godmode:micro

Design and manage microservice architectures. Decomposes monoliths into bounded contexts, designs inter-service communication (REST, gRPC, events), configures service mesh (Istio, Linkerd), implements service discovery and load balancing, and manages distributed transactions with the Saga pattern.

## Usage

```
/godmode:micro                          # Full microservice design workflow
/godmode:micro --decompose              # Analyze and propose service decomposition
/godmode:micro --communication          # Design inter-service communication only
/godmode:micro --saga <name>            # Design a specific saga workflow
/godmode:micro --mesh istio             # Generate Istio service mesh configuration
/godmode:micro --mesh linkerd           # Generate Linkerd service mesh configuration
/godmode:micro --topology               # Generate service topology diagram
/godmode:micro --validate               # Validate existing microservice architecture
/godmode:micro --resilience             # Design resilience patterns
/godmode:micro --migrate                # Plan monolith-to-microservices migration
```

## What It Does

1. Assesses current system architecture and team structure
2. Identifies bounded contexts using domain-driven decomposition
3. Designs inter-service communication (sync: REST/gRPC, async: events/messages)
4. Configures service mesh for mTLS, traffic management, and observability
5. Sets up service discovery and load balancing strategies
6. Designs Saga patterns for distributed transactions (choreography or orchestration)
7. Generates service topology diagram and registry
8. Configures resilience patterns (circuit breaker, retry, bulkhead, timeout)
9. Validates architecture against 14 best-practice checks

## Output
- Architecture diagram at `docs/architecture/<system>-topology.md`
- Service catalog at `docs/architecture/<system>-services.md`
- Communication contracts at `docs/architecture/<system>-communication.md`
- Saga definitions at `docs/architecture/<system>-sagas.md`
- Service mesh config at `k8s/mesh/` or `infra/mesh/`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"micro: <system> -- <N> services, <communication pattern>, <saga type>"`

## Next Step
After microservice design: `/godmode:api` to design APIs for each service, `/godmode:event` to design the event layer, or `/godmode:k8s` to deploy services.

## Examples

```
/godmode:micro Decompose our e-commerce monolith
/godmode:micro --saga order-processing     # Design order saga
/godmode:micro --mesh istio                # Generate Istio config
/godmode:micro --validate                  # Validate existing architecture
/godmode:micro --migrate                   # Plan monolith migration
```
