# Recipe: Building a Real-Time Chat App

> WebSocket architecture, presence, typing indicators, message delivery guarantees. From design to shipped.

---

## Context

Real-time chat is deceptively complex. The basic version (send message, receive message) takes a day. The production version (delivery receipts, typing indicators, presence, offline message queue, reconnection, moderation, search, file uploads) takes weeks. This recipe walks through the full architecture and builds it incrementally with Godmode.

## The Chain

```
think → architect → realtime → auth → schema → build → e2e → ship
```

## When to Use This Recipe

- Building a standalone chat application (Slack-like, Discord-like)
- Adding real-time messaging to an existing product
- Building a customer support chat widget
- Building a collaborative tool that needs real-time communication
- Any feature that requires WebSocket architecture with presence

---

## Session Transcript

### Phase 1: Think (Design the Chat System)

```
> /godmode:think I need to build a real-time chat feature for our SaaS
  platform. Users should be able to message each other in channels
  (like Slack). We expect ~5,000 concurrent users initially, scaling
  to 50,000.

Godmode: Researching real-time architecture patterns...

One question: Do you need 1:1 direct messages, group channels, or both?

> Both. Channels for team communication, DMs for private conversations.

Godmode: Writing spec...

CHAT FEATURES (MVP):
  Core:
    - Channels: create, join, leave, archive
    - Direct messages: 1:1 conversations
    - Send text messages (with Markdown support)
    - Real-time delivery (< 100ms latency)
    - Message history (infinite scroll, lazy load)
    - Unread count per channel

  Presence:
    - Online/offline status
    - Typing indicators ("Alice is typing...")
    - Last seen timestamp

  Delivery:
    - Sent/delivered/read receipts
    - Offline message queue (receive messages when back online)
    - Message ordering (server-assigned timestamps)

  Files:
    - Image upload (in-chat preview)
    - File attachment (up to 25MB)

  Moderation:
    - Edit own messages (within 15 minutes)
    - Delete own messages
    - Admin: delete any message, ban users

  OUT OF SCOPE (post-MVP):
    - Threads (reply to message)
    - Reactions (emoji)
    - Search across messages
    - Voice/video calls
    - End-to-end encryption
    - Message pinning

Saved: docs/specs/realtime-chat.md
Commit: "spec: real-time chat — channels, DMs, presence, delivery receipts"
```

### Phase 2: Architecture

```
> /godmode:architect

Godmode: Designing real-time architecture...

ARCHITECTURE DECISION: WebSocket Protocol

  Option A: Socket.IO (Node.js)
    + Automatic reconnection, room abstraction, fallback to polling
    + Large ecosystem, easy to get started
    - Not a standard protocol (custom on top of WebSocket/polling)
    - Harder to scale beyond single process without Redis adapter

  Option B: Native WebSocket + Custom Protocol
    + Standards-based, works with any language/client
    + Full control over message format and protocol
    - Must implement reconnection, heartbeat, room management
    - More code to write and maintain

  Option C: Ably / Pusher / PubNub (managed)
    + Zero infrastructure, handles scale automatically
    + Built-in presence, history, push notifications
    - Per-message pricing ($0.000025-0.00015 per message)
    - Vendor lock-in, less control

  Option D: Elixir Phoenix Channels
    + Exceptional WebSocket performance (millions of connections per node)
    + Built-in presence tracking (CRDT-based)
    - Requires Elixir/Erlang expertise
    - Smaller ecosystem than Node.js

RECOMMENDATION: Socket.IO with Redis adapter (Option A)
  Why: Fastest to build, handles reconnection and rooms out of the box.
  Redis adapter enables horizontal scaling across multiple server instances.
  At 50K concurrent users, 3-5 Node.js instances with Redis pub/sub is sufficient.

  If scale exceeds 50K: migrate Socket.IO to Option D (Phoenix) or add
  a dedicated message broker (Redis Streams or NATS).

SYSTEM ARCHITECTURE:
| Client | ────→ | Load Balancer | ────→ | WS Server |
| (React) | ←──── | (sticky) | ←──── | (Socket.IO) |
  └─────────┘     └─────────────┘     └─────┬─────┘
                          ┌──────────────────┼──────────────┐
                    ┌─────▼─────┐   ┌───────▼──────┐  ┌───▼────┐
| Redis |  | PostgreSQL |  | S3 |
| Pub/Sub |  | Messages |  | Files |
| + Presence |  | + Users |  |  |
  Key decisions:
    - Sticky sessions: WebSocket connections must stay on the same server
    - Redis pub/sub: broadcasts messages across server instances
    - PostgreSQL: persistent message storage (not Redis — messages are durable)
    - S3/R2: file uploads (pre-signed URLs, no files through WebSocket)
    - Load balancer: NGINX or ALB with WebSocket support

Saved: docs/adrs/adr-chat-architecture.md
Commit: "architect: WebSocket chat — Socket.IO + Redis + PostgreSQL"
```

### Phase 3: Real-Time Protocol Design

```
> /godmode:realtime

Godmode: Designing real-time protocol...

WEBSOCKET MESSAGE PROTOCOL:

  Client → Server events:
    message:send         { channelId, content, clientMsgId }
    message:edit         { messageId, content }
    message:delete       { messageId }
    typing:start         { channelId }
    typing:stop          { channelId }
    channel:join         { channelId }
    channel:leave        { channelId }
    presence:heartbeat   { }
    message:read         { channelId, lastReadMessageId }

  Server → Client events:
    message:new          { message, channelId, sender }
    message:updated      { messageId, content, editedAt }
    message:deleted      { messageId, channelId }
    typing:update        { channelId, users[] }
    presence:update      { userId, status, lastSeen }
    channel:updated      { channel }
    unread:update        { channelId, count }
    message:delivered    { messageId, deliveredAt }
    message:read:receipt { messageId, userId, readAt }

  Connection lifecycle:
    1. Client connects with JWT in handshake
    2. Server validates JWT, joins user to their channels
    3. Server sends initial state (unread counts, presence)
    4. Heartbeat every 30 seconds (detect stale connections)
    5. On disconnect: mark user offline after 60s grace period
    6. On reconnect: replay missed messages since lastMessageId

PRESENCE SYSTEM:
  Storage: Redis sorted set per channel
    Key: presence:<channelId>
    Score: timestamp of last heartbeat
    Member: userId

  Online: heartbeat within last 60 seconds
  Away: no heartbeat for 60-300 seconds
  Offline: no heartbeat for 300+ seconds (removed from set)

  Broadcast: presence changes debounced to 5-second intervals
    (prevents flood when 100 users join a channel simultaneously)

TYPING INDICATORS:
  Client sends typing:start when user begins typing
  Client sends typing:stop when user stops or sends message
  Server broadcasts to channel: "Alice, Bob are typing..."
  Timeout: auto-stop after 5 seconds of no typing:start events
  Debounce: typing:start sent at most once per 3 seconds

MESSAGE ORDERING:
  Server-assigned timestamps (not client timestamps)
  Tie-breaking: server sequence number (monotonically increasing)
  Client displays messages in (timestamp, sequence) order
  Optimistic send: show message immediately, reconcile on server ack

DELIVERY GUARANTEES:
  At-least-once: server ACKs every message:send
  Client retries unACKed messages on reconnect
  Deduplication: clientMsgId prevents duplicate messages
  Offline queue: messages stored in PostgreSQL, delivered on reconnect

Commit: "realtime: WebSocket protocol — messages, presence, typing, delivery"
```

### Phase 4: Auth

```
> /godmode:auth --websocket

Godmode: Configuring WebSocket authentication...

WEBSOCKET AUTH:
  Handshake: JWT token sent in auth.token during Socket.IO connection
  Validation: RS256 signature verified on connection
  Middleware: socket.use() validates before any event processing
  Token refresh: client disconnects → refreshes JWT → reconnects

  Channel authorization:
    Public channels: any authenticated user can join
    Private channels: membership check against channel_members table
    DMs: only the two participants can join

  Rate limiting (per connection):
    message:send: 30/minute (1 message every 2 seconds)
    typing:start: 20/minute
    channel:join: 10/minute

  Connection limit:
    Max 5 concurrent WebSocket connections per user
    Oldest connection closed when limit exceeded

Commit: "auth: WebSocket JWT auth, channel authorization, rate limiting"
```

### Phase 5: Schema

```
> /godmode:schema

Godmode: Designing chat database schema...

SCHEMA:

  users:
    id            UUID PRIMARY KEY
    email         TEXT UNIQUE NOT NULL
    display_name  TEXT NOT NULL
    avatar_url    TEXT
    status        TEXT DEFAULT 'offline'   -- online, away, offline, dnd
    last_seen_at  TIMESTAMP
    created_at    TIMESTAMP DEFAULT NOW()

  channels:
    id            UUID PRIMARY KEY
    name          TEXT NOT NULL
    description   TEXT
    type          TEXT NOT NULL             -- public, private, dm
    created_by    UUID REFERENCES users
    archived_at   TIMESTAMP
    created_at    TIMESTAMP DEFAULT NOW()

  channel_members:
    channel_id    UUID REFERENCES channels
    user_id       UUID REFERENCES users
    role          TEXT DEFAULT 'member'     -- member, admin, owner
    joined_at     TIMESTAMP DEFAULT NOW()
    last_read_at  TIMESTAMP
    PRIMARY KEY (channel_id, user_id)

  messages:
    id            UUID PRIMARY KEY
    channel_id    UUID REFERENCES channels NOT NULL
    sender_id     UUID REFERENCES users NOT NULL
    content       TEXT NOT NULL
    type          TEXT DEFAULT 'text'       -- text, image, file, system
    file_url      TEXT
    file_name     TEXT
    file_size     INTEGER
    edited_at     TIMESTAMP
    deleted_at    TIMESTAMP                 -- soft delete
    created_at    TIMESTAMP DEFAULT NOW()
    sequence      BIGSERIAL                 -- ordering within channel

  message_reads:
    channel_id    UUID REFERENCES channels
    user_id       UUID REFERENCES users
    last_read_id  UUID REFERENCES messages
    read_at       TIMESTAMP DEFAULT NOW()
    PRIMARY KEY (channel_id, user_id)

  INDEXES:
    messages(channel_id, created_at DESC)     -- channel history
    messages(channel_id, sequence DESC)       -- ordered message fetch
    messages(sender_id, created_at DESC)      -- user's messages
    channel_members(user_id)                  -- user's channels
    messages(channel_id, deleted_at)          -- exclude deleted
      WHERE deleted_at IS NULL               -- partial index

  PARTITIONING:
    messages table: range partition by created_at (monthly)
    Keeps queries on recent messages fast even at billions of rows

Commit: "schema: chat database — users, channels, messages, reads, partitioned"
```

### Phase 6: Build

```
> /godmode:build

Godmode: Executing build plan...

SERVER (Node.js + Socket.IO + Express):
  ✓ WebSocket server with Redis adapter
  ✓ REST API for channel CRUD, user management, message history
  ✓ Message handler: validate → store → broadcast → ACK
  ✓ Presence manager: heartbeat → Redis sorted set → broadcast
  ✓ Typing manager: debounced broadcasting
  ✓ Unread counter: per-channel, updated on read receipt
  ✓ File upload: pre-signed S3 URLs via REST, URL shared via WebSocket
  ✓ Reconnection handler: replay missed messages

CLIENT (React):
  ✓ Socket.IO client with auto-reconnection
  ✓ Channel list with unread badges
  ✓ Message list with infinite scroll (older messages)
  ✓ Message composer with Markdown preview
  ✓ Typing indicator ("Alice is typing...")
  ✓ Presence dots (green=online, yellow=away, gray=offline)
  ✓ Image preview in chat
  ✓ File attachment with progress bar
  ✓ Message edit/delete (own messages)
  ✓ Delivery receipts (sent ✓, delivered ✓✓, read ✓✓ blue)

TESTS:
  Unit: 48 tests (message handling, presence, authorization)
  Integration: 12 tests (WebSocket connection, message flow, reconnection)

BUILD COMPLETE: Server + Client functional

Commit: "build: real-time chat — server, client, presence, typing, file upload"
```

### Phase 7: End-to-End Testing

```
> /godmode:e2e

Godmode: Running end-to-end chat tests...

E2E SCENARIOS (Playwright):

  Scenario 1: Basic messaging
    ✓ User A sends message in #general
    ✓ User B sees message appear in real-time (< 200ms)
    ✓ Message persists after page reload
    ✓ Message appears in channel history

  Scenario 2: Presence
    ✓ User A connects → shows as online to User B
    ✓ User A closes tab → shows as offline after 60s
    ✓ User A reconnects → shows as online again

  Scenario 3: Typing indicators
    ✓ User A starts typing → User B sees "Alice is typing..."
    ✓ User A stops typing → indicator disappears after 5s
    ✓ Multiple users typing → "Alice, Bob are typing..."

  Scenario 4: Offline + reconnect
    ✓ User A goes offline (network disconnect simulated)
    ✓ User B sends 3 messages while A is offline
    ✓ User A reconnects → receives all 3 messages in order
    ✓ Unread count shows 3 for the channel

  Scenario 5: Message editing and deletion
    ✓ User A sends message → edits it → User B sees updated content
    ✓ User A deletes message → User B sees "message deleted"

  Scenario 6: Channel operations
    ✓ User A creates private channel
    ✓ User A invites User B → B can see and join channel
    ✓ User C (not invited) cannot see private channel

  Scenario 7: File upload
    ✓ User A uploads image → preview appears in chat
    ✓ User B clicks image → opens full-size in lightbox
    ✓ User A uploads PDF → download link appears in chat

  Scenario 8: Concurrent load
    ✓ 50 simulated users sending messages simultaneously
    ✓ All messages delivered to all channel members
    ✓ Message order consistent across all clients
    ✓ No duplicate messages

  Scenario 9: Direct messages
    ✓ User A opens DM with User B
    ✓ Messages only visible to A and B
    ✓ DM appears in sidebar for both users

E2E RESULTS: 9 scenarios, 32 assertions, ALL PASSING
Latency: p50 = 45ms, p95 = 120ms, p99 = 280ms

Commit: "e2e: 9 chat scenarios — messaging, presence, offline, files, load"
```

### Phase 8: Ship

```
> /godmode:ship --pr

Godmode: Running pre-ship checks...

PRE-SHIP:
  ✓ 48 unit tests passing
  ✓ 12 integration tests passing
  ✓ 9 e2e scenarios passing (32 assertions)
  ✓ Lint clean
  ✓ TypeScript: no errors
  ✓ Security: no vulnerabilities in dependencies
  ✓ WebSocket protocol: documented
  ✓ Database migrations: applied cleanly

DEPLOYMENT REQUIREMENTS:
  Infrastructure:
    - 2+ WebSocket server instances (for redundancy)
    - Redis instance (pub/sub + presence)
    - PostgreSQL (messages + users)
    - S3 bucket (file uploads)
    - Load balancer with sticky sessions + WebSocket support

  Environment variables:
    DATABASE_URL, REDIS_URL, JWT_SECRET, S3_BUCKET,
    S3_ACCESS_KEY, S3_SECRET_KEY, CORS_ORIGIN

PR #52 created: "Real-time chat: channels, DMs, presence, typing, file upload"
CI: ✓ All checks passing

Commit: "ship: real-time chat PR — all tests passing, deployment docs"
```

---

## WebSocket Scaling Guide

### Single Server (< 5K concurrent)

```
SINGLE SERVER:
  1 Node.js process handles all WebSocket connections.
  Redis not required (in-memory pub/sub is sufficient).
  Simple deployment: single container or VM.

  Limits:
    Node.js can handle ~10K concurrent WebSocket connections per process.
    But at 5K+, you want redundancy (single point of failure).
```

### Horizontal Scaling (5K-100K concurrent)

```
HORIZONTAL SCALING:
  Multiple Node.js processes behind a load balancer.
  Redis pub/sub for cross-process message broadcasting.
  Sticky sessions: WebSocket connections stay on one server.

  Architecture:
    LB (sticky) → Server 1 (2K connections)
                → Server 2 (2K connections)
                → Server 3 (2K connections)
                       ↓
                Redis pub/sub (broadcasts across servers)

  Load balancer config:
    NGINX: ip_hash or sticky cookie
    ALB: target group stickiness (application cookie)
    Kubernetes: sessionAffinity: ClientIP

  Scaling trigger: add server when CPU > 70% or connections > 8K per instance
```

### Large Scale (100K+ concurrent)

```
LARGE SCALE:
  Dedicated message broker (Redis Streams, NATS, or Kafka).
  Separate connection servers from message processing.
  Consider Elixir/Phoenix or Go for connection handling.

  Architecture:
    LB → Connection Servers (handle WebSocket, lightweight)
              ↓
         Message Broker (NATS / Redis Streams)
              ↓
         Worker Servers (process messages, store, fan-out)
              ↓
         PostgreSQL (persistent storage)

  At this scale, also consider:
    - Sharding channels across server groups
    - Edge servers for geographic distribution
    - Message batching (combine multiple messages into one broadcast)
```

---

## Common Pitfalls

### 1. Client timestamps for message ordering
Never trust the client's clock. Server-assigned timestamps with sequence numbers are the only reliable ordering. Two messages sent at the "same time" from different clients need deterministic ordering.

### 2. No offline queue
If a user is disconnected and someone sends them a message, that message must not be lost. Store all messages in the database. On reconnect, query for messages since the user's last known message ID.

### 3. Presence storms
When 500 users join a channel, don't broadcast 500 individual presence events. Batch presence updates into a single broadcast every 5 seconds. Debounce aggressively.

### 4. Unbounded message history loading
Loading an entire channel's history (100K messages) into memory crashes the client. Paginate: load the most recent 50 messages, load more on scroll.

### 5. Files through WebSocket
Never send file bytes over the WebSocket connection. Use pre-signed S3 URLs: client uploads directly to S3, then shares the URL via WebSocket message. Keeps the WebSocket connection fast and lightweight.

### 6. No reconnection strategy
WebSocket connections drop. Networks switch. Laptops sleep. Your client must automatically reconnect with exponential backoff, re-authenticate, and request missed messages. Socket.IO handles this — if you use raw WebSocket, you must build it yourself.

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:realtime`, `/godmode:e2e`
- [Skill Chains](../skill-chains.md) — full-stack chain
- [Building an API Gateway](api-gateway.md) — WebSocket routing through gateway
- [Building an MVP](startup-mvp.md) — If chat is the MVP
