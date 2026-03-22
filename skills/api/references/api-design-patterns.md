# API Design Patterns Reference

> Comprehensive catalog of API design patterns across REST, GraphQL, and gRPC paradigms. Each pattern includes when to use it, trade-offs, and concrete examples.

---

## Pattern Catalog

### 1. Resource-Based (CRUD)

The foundational REST pattern. Every entity is a resource with a stable URL and standard operations.

```
GET    /api/v1/orders          → List orders
POST   /api/v1/orders          → Create order
GET    /api/v1/orders/:id      → Get order
PUT    /api/v1/orders/:id      → Replace order
PATCH  /api/v1/orders/:id      → Partial update
DELETE /api/v1/orders/:id      → Delete order
```

**When to use:** Most CRUD applications. The default starting point for any REST API.

**Trade-offs:**
- Simple, well-understood, tooling support everywhere
- Does not fit well for complex workflows or non-entity operations
- Can lead to chatty APIs when clients need data from multiple resources

---

### 2. Sub-Resource (Nested Resources)

Express parent-child relationships through URL hierarchy.

```
GET    /api/v1/projects/:pid/tasks          → Tasks within a project
POST   /api/v1/projects/:pid/tasks          → Create task in project
GET    /api/v1/projects/:pid/tasks/:tid     → Specific task in project
```

**When to use:** When a child resource only makes sense in the context of a parent. When you need to scope access control by parent.

**Trade-offs:**
- Clear ownership semantics
- Deep nesting (3+ levels) becomes unwieldy — flatten after 2 levels
- Clients must know the parent ID to access children

---

### 3. Composite / Aggregate

Return a pre-composed view that combines multiple resources in a single response.

```
GET /api/v1/dashboard
→ {
    "user": { ... },
    "recent_orders": [ ... ],
    "notifications": [ ... ],
    "stats": { "total_spent": 1234.56, "order_count": 42 }
  }
```

**When to use:** Mobile clients with limited bandwidth. Dashboards or summary views. When eliminating N+1 API calls matters.

**Trade-offs:**
- Reduces round trips significantly
- Harder to cache (composite invalidation)
- Tightly couples the API to a specific UI view
- Use GraphQL if you need many composite endpoints

---

### 4. Backend for Frontend (BFF)

Separate API layer per client type, each tailored to that client's needs.

```
Mobile BFF:   /api/mobile/v1/feed       → Compact payload, image thumbnails
Web BFF:      /api/web/v1/feed          → Full payload, high-res images
Partner BFF:  /api/partner/v1/feed      → Structured data, webhook registration
```

**When to use:** Multiple client types with divergent data needs. When mobile and web teams move at different cadences. When third-party API contracts differ from internal needs.

**Trade-offs:**
- Each client gets an optimized API
- Duplication of logic across BFFs
- More services to deploy and maintain
- Risk of business logic leaking into BFF layer

---

### 5. Gateway Aggregation

A single API gateway that fans out to multiple backend services and aggregates responses.

```
Client → API Gateway → [ Service A, Service B, Service C ] → Aggregated Response

GET /api/v1/order-summary/:id
Gateway calls:
  - Order Service:    GET /orders/:id
  - Payment Service:  GET /payments?order_id=:id
  - Shipping Service: GET /shipments?order_id=:id
Returns combined response.
```

**When to use:** Microservices architectures where clients should not call services directly. When you want to reduce client-side orchestration.

**Trade-offs:**
- Single entry point simplifies client logic
- Gateway becomes a potential bottleneck and single point of failure
- Response time is bounded by the slowest backend call
- Error handling for partial failures is complex

---

### 6. CQRS (Command Query Responsibility Segregation)

Separate the read model from the write model at the API level.

```
COMMANDS (writes):
  POST   /api/v1/commands/place-order       → { "product_id": "...", "qty": 2 }
  POST   /api/v1/commands/cancel-order      → { "order_id": "..." }

QUERIES (reads):
  GET    /api/v1/queries/order-history      → Denormalized read model
  GET    /api/v1/queries/order-summary/:id  → Optimized projection
```

**When to use:** Read and write workloads differ drastically. Complex domain logic on writes but simple lookups on reads. Event-sourced systems.

**Trade-offs:**
- Each side scales independently
- Read models can be denormalized for performance
- Eventual consistency between write and read sides
- More complex infrastructure (two data stores, sync mechanism)

---

### 7. Event-Carried State Transfer

APIs communicate changes through events that carry enough state for consumers to act without callbacks.

```
Event published:
{
  "event_type": "order.completed",
  "timestamp": "2025-03-15T10:30:00Z",
  "data": {
    "order_id": "ord_123",
    "customer_id": "cust_456",
    "total": 99.99,
    "items": [ { "sku": "ABC", "qty": 2 } ],
    "shipping_address": { ... }
  }
}
```

**When to use:** Loose coupling between services. When downstream services need data but should not call back to the source. Audit trail requirements.

**Trade-offs:**
- Extreme decoupling between producer and consumer
- Consumers have local copies of data they need (no synchronous dependency)
- Events can grow large if carrying too much state
- Schema evolution must be managed carefully (backward/forward compatibility)

---

### 8. Webhook (Reverse API)

The server calls the client when events occur, inverting the typical request flow.

```
Register:
  POST /api/v1/webhooks
  {
    "url": "https://client.example.com/hooks/orders",
    "events": ["order.created", "order.shipped"],
    "secret": "whsec_..."
  }

Delivery:
  POST https://client.example.com/hooks/orders
  Headers:
    X-Webhook-Signature: sha256=<HMAC of body using secret>
    X-Webhook-ID: wh_evt_789
  Body:
    { "event": "order.created", "data": { ... } }
```

**When to use:** Third-party integrations that need real-time notifications. Replacing polling patterns. When the consumer cannot maintain a persistent connection.

**Trade-offs:**
- Eliminates polling, reduces API load
- Consumer must expose a public endpoint
- Delivery reliability requires retry logic, dead-letter queues
- Signature verification is essential for security

---

### 9. Polling with ETags

Client polls for changes efficiently using conditional requests and ETags.

```
First request:
  GET /api/v1/orders?status=pending
  Response:
    ETag: "abc123"
    Body: [...]

Subsequent requests:
  GET /api/v1/orders?status=pending
  If-None-Match: "abc123"
  Response:
    304 Not Modified (no bandwidth wasted)
    — or —
    200 OK, ETag: "def456", Body: [updated data]
```

**When to use:** When webhooks are not feasible. When the client needs fresh data but changes are infrequent. Static or slowly changing resources.

**Trade-offs:**
- Simple to implement on both sides
- Wastes requests when data does not change
- ETags require server-side computation
- Not suitable for real-time requirements (latency equals polling interval)

---

### 10. Long Polling

Client sends a request that the server holds open until data is available or a timeout occurs.

```
GET /api/v1/notifications/poll?timeout=30s&since=2025-03-15T10:00:00Z
→ Server holds connection for up to 30s
→ Returns immediately if new notifications arrive
→ Returns empty array on timeout, client reconnects
```

**When to use:** Near real-time updates without WebSocket infrastructure. Chat applications, notification feeds. When SSE is not supported.

**Trade-offs:**
- Lower latency than regular polling
- Simpler than WebSockets for basic use cases
- Holds server connections open (resource intensive at scale)
- Load balancers and proxies may terminate long-lived connections

---

### 11. Server-Sent Events (SSE)

Unidirectional stream from server to client over a persistent HTTP connection.

```
GET /api/v1/events/stream
Accept: text/event-stream

Response:
  event: order.created
  data: {"order_id": "ord_123", "total": 99.99}

  event: order.shipped
  data: {"order_id": "ord_456", "tracking": "1Z999..."}

  :keepalive
```

**When to use:** Live dashboards, notifications, activity feeds. When the client only needs to receive data (not send). Simpler alternative to WebSockets for unidirectional streams.

**Trade-offs:**
- Native browser support via EventSource API
- Automatic reconnection built into the protocol
- Unidirectional only (server to client)
- Limited to text data (no binary)
- Connection limits per domain in browsers (6 in HTTP/1.1)

---

### 12. Bulk / Batch Operations

Process multiple operations in a single request to reduce round trips.

```
POST /api/v1/batch
{
  "operations": [
    { "method": "POST", "path": "/orders", "body": { ... } },
    { "method": "PATCH", "path": "/orders/123", "body": { "status": "shipped" } },
    { "method": "DELETE", "path": "/orders/456" }
  ]
}
→ {
    "results": [
      { "status": 201, "body": { ... } },
      { "status": 200, "body": { ... } },
      { "status": 204 }
    ]
  }
```

**When to use:** Importing large datasets. Operations that logically belong together. Reducing HTTP overhead for mobile clients.

**Trade-offs:**
- Dramatically reduces round trips
- All-or-nothing vs. partial success semantics must be defined
- Harder to cache individual operations
- Request size limits may apply
- Error handling is more complex (which operations failed?)

---

### 13. Idempotency Keys

Ensure operations can be safely retried without creating duplicates.

```
POST /api/v1/payments
Headers:
  Idempotency-Key: pay_req_abc123
Body:
  { "amount": 99.99, "currency": "USD" }

First call:  → 201 Created, payment processed
Retry call:  → 200 OK, returns same result (no duplicate charge)
```

**When to use:** Any non-idempotent operation that clients may retry (payments, order creation). Network-unreliable environments. Webhook delivery systems.

**Trade-offs:**
- Prevents duplicate operations on retry
- Requires server-side storage of idempotency keys and responses
- Keys must expire after a reasonable period
- Client must generate unique keys (UUIDs recommended)

---

### 14. Pagination: Cursor-Based

Navigate through large datasets using opaque cursors instead of offsets.

```
GET /api/v1/orders?limit=20
→ {
    "data": [...],
    "pagination": {
      "next_cursor": "eyJpZCI6MTAwLCJjcmVhdGVkX2F0IjoiMjAyNS0wMy0xNSJ9",
      "has_more": true
    }
  }

GET /api/v1/orders?cursor=eyJpZCI6MTAw...&limit=20
→ Next page
```

**When to use:** Large or frequently changing datasets. When consistent results matter more than random access. Infinite scroll UIs.

**Trade-offs:**
- Consistent results even with concurrent inserts/deletes
- Efficient at any depth (no OFFSET performance cliff)
- No random page access (cannot jump to page 50)
- Cursor is opaque — clients cannot construct or modify it

---

### 15. Sparse Fieldsets (Field Selection)

Let clients request only the fields they need.

```
GET /api/v1/orders?fields=id,status,total
→ {
    "data": [
      { "id": "ord_123", "status": "shipped", "total": 99.99 },
      { "id": "ord_456", "status": "pending", "total": 49.99 }
    ]
  }

GET /api/v1/orders?fields=id,status&include=items(id,name)
→ Nested field selection
```

**When to use:** Bandwidth-constrained clients (mobile). Resources with many fields where most are unused. Alternative to GraphQL for REST APIs.

**Trade-offs:**
- Reduces payload size and bandwidth
- Complicates caching (different field sets = different cache keys)
- Server must dynamically construct responses
- Validation of allowed fields is required

---

### 16. Hypermedia (HATEOAS)

Responses include links to related resources and available actions.

```
GET /api/v1/orders/123
→ {
    "id": "ord_123",
    "status": "pending",
    "total": 99.99,
    "_links": {
      "self": { "href": "/api/v1/orders/123" },
      "cancel": { "href": "/api/v1/orders/123/cancel", "method": "POST" },
      "items": { "href": "/api/v1/orders/123/items" },
      "customer": { "href": "/api/v1/customers/456" }
    }
  }
```

**When to use:** APIs that need to be self-discoverable. When available actions change based on resource state. Public APIs where clients should not hardcode URLs.

**Trade-offs:**
- Self-documenting, discoverable API
- Decouples clients from URL structure
- Larger response payloads
- Clients must be built to follow links (most are not)
- Few real-world REST APIs fully implement HATEOAS

---

### 17. Versioned Schema Evolution

Evolve API schemas without breaking existing consumers.

```
ADDITIVE CHANGES (non-breaking):
  v1: { "id": "123", "name": "Widget" }
  v1: { "id": "123", "name": "Widget", "sku": "WDG-001" }  ← new field, safe

DEPRECATION WORKFLOW:
  1. Add new field alongside old field
  2. Mark old field as deprecated in docs and response headers
  3. Monitor old field usage
  4. Remove old field after sunset period

Headers:
  Sunset: Sat, 01 Jan 2027 00:00:00 GMT
  Deprecation: true
  Link: </api/v2/products>; rel="successor-version"
```

**When to use:** Any long-lived API. When you cannot force all clients to upgrade simultaneously.

**Trade-offs:**
- Clients continue working through changes
- Additive-only changes are always safe
- Removing or renaming fields is a breaking change
- Requires discipline to avoid accumulating deprecated fields

---

### 18. Rate Limiting with Backpressure

Communicate capacity limits to clients and provide graceful degradation.

```
Response Headers (normal):
  X-RateLimit-Limit: 1000
  X-RateLimit-Remaining: 742
  X-RateLimit-Reset: 1710500400

Response (exceeded):
  429 Too Many Requests
  Retry-After: 30
  {
    "error": {
      "code": "RATE_LIMIT_EXCEEDED",
      "message": "Rate limit exceeded. Retry after 30 seconds.",
      "retry_after": 30
    }
  }
```

**When to use:** Every public API. Internal APIs that need protection against misbehaving clients. Multi-tenant systems where fair sharing matters.

**Trade-offs:**
- Protects backend from overload
- Clients can implement intelligent retry with backoff
- Requires infrastructure (Redis counters, token bucket, etc.)
- Rate limit design (per user, per IP, per API key) affects fairness

---

### 19. Circuit Breaker at API Level

Expose service health to clients so they can fail fast instead of waiting for timeouts.

```
Normal operation:
  GET /api/v1/recommendations → 200 OK

Degraded (circuit open):
  GET /api/v1/recommendations → 503 Service Unavailable
  Headers:
    Retry-After: 60
    X-Circuit-State: open
  Body:
    {
      "error": {
        "code": "SERVICE_DEGRADED",
        "message": "Recommendation service is temporarily unavailable.",
        "fallback": true
      },
      "data": [<cached/default recommendations>]
    }
```

**When to use:** APIs that depend on downstream services which may fail. When providing degraded responses is better than failing entirely. Microservice architectures.

**Trade-offs:**
- Prevents cascade failures
- Clients get fast failures instead of timeouts
- Fallback responses keep UX functional
- Adds complexity to both server and client
- Threshold tuning (when to open/close circuit) requires observation

---

### 20. Content Negotiation

Serve different response formats based on client preferences.

```
Accept: application/json
→ JSON response

Accept: application/xml
→ XML response

Accept: text/csv
→ CSV export

Accept: application/vnd.company.orders.v2+json
→ Versioned JSON with custom media type

Accept: application/pdf
→ Generated PDF report
```

**When to use:** APIs serving multiple client types with different format needs. Export/download endpoints. APIs that evolve through content-type versioning.

**Trade-offs:**
- Single endpoint serves multiple formats
- Standards-compliant (HTTP content negotiation)
- More complex server-side serialization
- Testing matrix grows with each supported format

---

### 21. Expand / Include (Sideloading)

Let clients request related resources inline to avoid N+1 calls.

```
GET /api/v1/orders/123?expand=customer,items.product
→ {
    "id": "ord_123",
    "customer_id": "cust_456",
    "customer": {
      "id": "cust_456",
      "name": "Jane Doe",
      "email": "jane@example.com"
    },
    "items": [
      {
        "id": "item_1",
        "product_id": "prod_789",
        "product": {
          "id": "prod_789",
          "name": "Widget",
          "price": 49.99
        },
        "quantity": 2
      }
    ]
  }
```

**When to use:** REST APIs where clients frequently need related resources. Reducing N+1 API call patterns. Alternative to GraphQL for relationship traversal.

**Trade-offs:**
- Eliminates extra round trips for related data
- Server controls what is expandable (security boundary)
- Response size grows — must set expansion depth limits
- Caching becomes more complex with varying expansion sets

---

### 22. Async Request-Reply

For long-running operations, accept the request and return a status URL.

```
POST /api/v1/reports/generate
{ "type": "annual", "year": 2025 }
→ 202 Accepted
  {
    "job_id": "job_abc123",
    "status": "processing",
    "status_url": "/api/v1/jobs/job_abc123",
    "estimated_completion": "2025-03-15T10:35:00Z"
  }

GET /api/v1/jobs/job_abc123
→ { "status": "processing", "progress": 65 }

GET /api/v1/jobs/job_abc123
→ {
    "status": "completed",
    "result_url": "/api/v1/reports/rpt_xyz789",
    "completed_at": "2025-03-15T10:34:22Z"
  }
```

**When to use:** Report generation, data exports, bulk operations. Any operation that takes more than a few seconds. Video/image processing, ML inference.

**Trade-offs:**
- Clients are not blocked waiting for slow operations
- Progress tracking improves UX
- More complex client implementation (polling or webhook for completion)
- Job state must be persisted and cleaned up

---

## REST vs. GraphQL vs. gRPC Comparison

```
| Criterion | REST | GraphQL | gRPC |
| Transport | HTTP/1.1, HTTP/2 | HTTP/1.1, HTTP/2 | HTTP/2 (required) |
| Data format | JSON (typically) | JSON | Protocol Buffers |
| Schema/Contract | OpenAPI (opt.) | SDL (required) | .proto (required) |
| Type safety | Optional | Built-in | Built-in |
| Over/under-fetching | Common problem | Solved by design | Solved by design |
| Caching | HTTP caching | Complex (POST) | No HTTP caching |
| Real-time | SSE, WebSocket | Subscriptions | Bidirectional |
|  |  |  | streaming |
| Browser support | Native | Via fetch/libs | Requires proxy |
|  |  |  | (grpc-web) |
| File upload | Multipart/form | Multipart spec | Streaming chunks |
| Learning curve | Low | Medium | High |
| Tooling maturity | Excellent | Very good | Good |
| Best for | Public APIs, | Flexible client | Internal service |
|  | simple CRUD | data needs | communication |
```

### When to Choose REST

- Public-facing API consumed by third parties
- Simple CRUD operations on well-defined resources
- HTTP caching is critical for performance
- Team has limited API design experience
- Broad client compatibility required (browsers, mobile, IoT)

### When to Choose GraphQL

- Multiple client types (web, mobile, TV) with different data needs
- Frontend teams want to iterate on queries without backend changes
- Deep, interconnected data graphs (social networks, e-commerce catalogs)
- Aggregating data from multiple backend services into one API
- Subscription-based real-time updates

### When to Choose gRPC

- Service-to-service communication in microservices
- Low-latency, high-throughput requirements
- Bidirectional streaming (chat, live data feeds)
- Strong typing and code generation across polyglot services
- Internal infrastructure where browser support is not needed

---

## Pattern Decision Matrix

Use this matrix to select patterns based on your specific requirements.

```
| Requirement | Recommended Patterns |
| Multiple client types | BFF, GraphQL, Sparse Fieldsets |
| Real-time updates | SSE, WebSocket, Long Polling, gRPC Streaming |
| Third-party integration | Webhooks, REST + OpenAPI, Idempotency Keys |
| Large dataset traversal | Cursor Pagination, Streaming |
| Bandwidth optimization | Sparse Fieldsets, gRPC (protobuf), Compression |
| Long-running operations | Async Request-Reply, Webhooks |
| High write throughput | CQRS, Event-Carried State Transfer, Batch Ops |
| Complex data graphs | GraphQL, Expand/Include, Composite |
| Microservice gateway | Gateway Aggregation, BFF |
| Retry safety | Idempotency Keys, conditional requests (ETags) |
| Public API stability | Versioned Schema Evolution, HATEOAS, Content Neg. |
| Service resilience | Circuit Breaker, Rate Limiting, Backpressure |
| Audit / compliance | Event-Carried State Transfer, Webhooks |
```

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Chatty API | Client makes 10+ calls to render one view | Composite endpoint, GraphQL, or Expand |
| God endpoint | Single endpoint with dozens of query params | Decompose into focused resources |
| Verbs in URLs | `/api/getUsers`, `/api/createOrder` | Use HTTP methods: `GET /users`, `POST /orders` |
| Ignoring idempotency | Retries create duplicate records | Idempotency keys on all mutating operations |
| Synchronous chains | Service A → B → C → D in sequence | Async events, saga pattern, or parallel fan-out |
| No pagination | `GET /items` returns 100K rows | Always paginate list endpoints |
| Exposing internals | API mirrors database schema exactly | Design for consumer use cases, not storage |
| Inconsistent errors | Different error shapes per endpoint | Single error schema across the entire API |
| Missing rate limits | One client can starve all others | Rate limit every endpoint, differentiate by tier |
| Version avoidance | Breaking changes with no versioning | Version from day one, even for internal APIs |
