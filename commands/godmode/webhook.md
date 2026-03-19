# /godmode:webhook

Design, implement, and secure webhook systems — inbound handling, outbound delivery, retry strategies, HMAC verification, event subscriptions, and dead letter queues.

## Usage

```
/godmode:webhook                            # Full webhook design workflow
/godmode:webhook --inbound                  # Design inbound webhook handling only
/godmode:webhook --outbound                 # Design outbound webhook delivery only
/godmode:webhook --provider stripe          # Configure for specific provider (stripe, github, twilio)
/godmode:webhook --events                   # Design event catalog and payload format
/godmode:webhook --schema                   # Generate database schema only
/godmode:webhook --security                 # Security audit of existing webhook implementation
/godmode:webhook --test                     # Generate webhook testing tools and simulator
/godmode:webhook --monitor                  # Set up monitoring and alerting
/godmode:webhook --rotate                   # Implement signing secret rotation
/godmode:webhook --debug                    # Investigate delivery issues (DLQ, circuits, retries)
```

## What It Does

1. Discovers project context, direction (inbound/outbound/both), and delivery requirements
2. Designs event catalog with standardized naming (`resource.action`) and payload envelope
3. Implements inbound webhook handling with HMAC-SHA256 verification, replay prevention, and idempotency
4. Designs outbound delivery pipeline with exponential backoff, circuit breaker, and dead letter queue
5. Creates webhook subscription management API (registration, filtering, secret rotation)
6. Hardens security: HTTPS-only, SSRF prevention, constant-time comparison, IP allowlisting
7. Generates database schema for subscriptions, events, deliveries, and DLQ
8. Builds testing tools: ping endpoint, delivery log inspector, replay, URL validator
9. Sets up monitoring: delivery success rates, retry queue depth, circuit breaker state, DLQ growth
10. Validates the design against 18 webhook best-practice checks

## Output
- Database migration: `migrations/<timestamp>_create_webhook_tables.sql`
- Event catalog: `docs/webhooks/event-types.md`
- Integration guide: `docs/webhooks/integration-guide.md`
- OpenAPI spec: `docs/api/<service>-webhooks-openapi.yaml`
- Monitoring config: `infra/monitoring/webhook-dashboard.json`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"webhook: <service> — inbound/outbound pipeline, <M> event types, delivery + retry + DLQ"`

## Next Step
After webhook design: `/godmode:queue` to set up message queues for delivery workers, `/godmode:event` for event sourcing architecture, or `/godmode:monitor` for observability dashboards.

## Examples

```
/godmode:webhook Add webhook support to our e-commerce API
/godmode:webhook --inbound Handle Stripe webhooks in our payment service
/godmode:webhook --provider github Set up GitHub webhook receiver
/godmode:webhook --security Audit our existing webhook implementation
/godmode:webhook --debug Our consumers are reporting missed events
/godmode:webhook --rotate Rotate signing secrets for all subscriptions
```
