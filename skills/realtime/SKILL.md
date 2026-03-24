---
name: realtime
description: |
  Real-time communication skill. Activates when teams need to design, build, or scale real-time features. Covers WebSocket architecture, Server-Sent Events (SSE), long polling, pub/sub patterns (Socket.io, Pusher, Ably), real-time collaboration (CRDT, Operational Transform), presence systems, typing indicators, live notifications, scaling real-time with Redis pub/sub and sticky sessions, and connection management. Triggers on: /godmode:realtime, "add websockets", "real-time updates", "live notifications", "typing indicator", "collaborative editing", or when the application needs bidirectional or server-push communication.
---

# Realtime — Real-time Communication & Collaboration

## When to Activate
- User invokes `/godmode:realtime`
- User says "add websockets", "real-time updates", "live notifications"
- User says "typing indicator", "presence system", "who's online"
- User says "collaborative editing", "real-time sync", "live cursors"
- User says "push notifications", "server-sent events", "live feed"
- User needs bidirectional communication between client and server
- User needs to broadcast updates to multiple connected clients
- Application has features that require instant data synchronization
- Godmode orchestrator detects polling patterns that need conversion to push-based delivery

## Workflow

### Step 1: Real-time Requirements Assessment

Evaluate the communication needs, constraints, and correct protocol:

```
REAL-TIME REQUIREMENTS ASSESSMENT:
| Dimension | Value |
```

#### Protocol Selection Matrix
```
PROTOCOL SELECTION:
| Protocol | Best for | Direction | Browser | Complexity | Scaling |
```

#### Technology Selection
```
TECHNOLOGY SELECTION:
| Technology | Best for | Protocol | Scale | Ops cost | Features |
```

### Step 2: Connection Architecture

Design the WebSocket or SSE connection lifecycle:

```
CONNECTION ARCHITECTURE:
```

#### Socket.io Server Implementation
```typescript
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
```

#### Server-Sent Events Implementation
```typescript
import express from 'express';

const app = express();
```

### Step 3: Pub/Sub & Channel Design

Design the channel structure and message routing:

```
CHANNEL ARCHITECTURE:
| Channel Pattern | Example | Use case |
```

### Step 4: Presence System

Design online/offline status and presence tracking:

```
PRESENCE SYSTEM:
| Component | Implementation |
```

#### Presence Implementation
```typescript
class PresenceManager {
  constructor(private redis: Redis, private io: Server) {}

```

### Step 5: Typing Indicators & Ephemeral State

Design real-time ephemeral state broadcasting:

```
TYPING INDICATOR DESIGN:
| Behavior | Implementation |
```

#### Client-Side Typing Indicator
```typescript
class TypingIndicator {
  private typingTimeout: ReturnType<typeof setTimeout> | null = null;
  private isTyping = false;
```

### Step 6: Real-time Collaboration (CRDT & OT)

Design collaborative editing with conflict resolution:

```
COLLABORATION STRATEGY SELECTION:
| Strategy | Best for | Complexity |
```

#### CRDT Implementation with Yjs
```typescript
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';

```

#### Collaboration Architecture
```
COLLABORATION ARCHITECTURE:
```

### Step 7: Scaling Real-time Systems

Design for horizontal scaling across multiple server instances:

```
SCALING ARCHITECTURE:
```

#### Nginx WebSocket Configuration
```nginx
upstream websocket_backend {
    # Sticky sessions using IP hash
    ip_hash;
```

#### Connection Scaling Metrics
```
SCALING TARGETS:
| Metric | Per Instance | Cluster Total |
```

### Step 8: Client-Side Connection Management

Design resilient client-side connection handling:

```
CLIENT CONNECTION MANAGEMENT:
| Scenario | Behavior |
```

#### Reconnection Logic
```typescript
class RealtimeClient {
  private socket: Socket | null = null;
  private reconnectAttempts = 0;
```

### Step 9: Commit and Transition

```
1. Save WebSocket/SSE server config as `realtime/server.ts`
2. Save channel definitions as `realtime/channels.ts`
3. Save presence system as `realtime/presence.ts`
```

## Autonomous Operation
- Loop until target or budget. Never pause.
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors

1. **SSE before WebSocket.** If you only need server-to-client push (notifications, feeds, dashboards), use SSE. It is simpler, works through HTTP proxies, and auto-reconnects. WebSocket is for bidirectional communication.
2. **Authenticate on connect.** WebSocket connections bypass standard HTTP middleware. Authenticate during the handshake, not after. Reject unauthenticated connections immediately.
3. **Heartbeats are mandatory.** Connections silently die (mobile networks, NAT timeouts, proxy kills). Client and server must exchange heartbeats to detect dead connections within 60 seconds.
4. **Design for disconnection.** Every client will disconnect -- network switch, sleep mode, backgrounded tab. Queue messages, track last received ID, sync on reconnect. Assume unreliable connections.
5. **Presence needs debouncing.** Do not broadcast "user left" the instant a WebSocket closes. Wait 3-5 seconds for reconnection. Otherwise, presence flickers on every network blip.
6. **Redis pub/sub for multi-server.** A single server handles thousands of connections. Multiple servers need a message bus. Redis pub/sub is the standard approach for Socket.io scaling.
7. **Typing indicators are ephemeral.** Never persist typing state. Broadcast it, auto-expire it in 5 seconds, and never send it faster than once per 2 seconds. Typing state is noise, not data.
8. **CRDT for collaboration.** If multiple users edit the same document simultaneously, use CRDTs (Yjs, Automerge). They resolve conflicts automatically without a central server making decisions.

## Iterative Implementation Loop

```
current_iteration = 0
max_iterations = 12
tasks_remaining = [list of realtime features to implement]
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER send user credentials in WebSocket messages. Auth happens at connection handshake only.
2. NEVER trust client-sent data without server-side validation.
```

## Keep/Discard Discipline
```
After EACH realtime feature implementation:
  1. MEASURE: Simulate connection drop — does the client reconnect and recover state?
  2. COMPARE: Is latency < 100ms p95, message ordering preserved, presence accurate?
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All requested features work (chat, presence, typing, or notifications)
  - Reconnection with state recovery verified (rooms + missed messages)
```

## Output Format

```
REALTIME SYSTEM COMPLETE:
  Transport: <WebSocket | SSE | Socket.io | WebTransport>
  Events: <N> event types (client→server: <M>, server→client: <K>)
```

## TSV Logging

Log every realtime system session to `.godmode/realtime-results.tsv`:

```
Fields: timestamp\tproject\ttransport\tevent_types\trooms\tpresence\tscaling_backend\treconnection\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-app\twebsocket\t12\t4\tyes\tredis-pubsub\tauto\tabc1234
```

Append after every completed realtime design pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
REALTIME SUCCESS CRITERIA:
|  Criterion                                  | Required         |
```

## Realtime Optimization Loop

When optimizing an existing realtime system, run this systematic audit loop. Each pass targets a specific reliability and performance dimension with measurable before/after metrics.

### Pass 1: WebSocket Connection Management Audit

```
CONNECTION MANAGEMENT AUDIT:
  Step 1: Measure — track active connections, churn rate, duration (median, p95),
    errors, and file descriptor usage per instance.
```

### Pass 2: Message Ordering & Delivery Audit

```
MESSAGE ORDERING & DELIVERY:
  Ordering by channel type:
    Chat messages: Required (per-room sequential via sequence numbers)
```

### Pass 3: Reconnection Strategy Audit

```
RECONNECTION CHECKLIST:
  [ ] Exponential backoff with jitter (base=1s, max=30s, maxAttempts=10)
  [ ] Auth token refreshed before reconnect attempt
```

### Pass 4: Scaling & Load Testing Audit

```
SCALING AUDIT:
  Multi-instance test:
    Client A on Instance 1, Client B on Instance 2, same room → verify cross-instance delivery.
```

### Optimization Loop Summary

```
REALTIME OPTIMIZATION REPORT:
  Metric                       │  Before  │  After   │  Target
  Connection churn rate (/min) │  <N>     │  <N>     │  Minimal
```


## Error Recovery
| Failure | Action |
|--|--|
| WebSocket connections drop frequently | Implement automatic reconnection with exponential backoff. Check for idle timeouts on load balancers. Send heartbeat/ping frames. |
| Messages delivered out of order | Add sequence numbers. Buffer and reorder on client. Use ordered channels/topics where available. |
| Server memory grows with connected clients | Check for event listener leaks. Limit per-connection buffer size. Implement connection limits. Use pub/sub pattern to avoid per-connection state. |
| Real-time updates not reaching all clients | Verify pub/sub fan-out. Check subscription filters. Verify sticky sessions or shared state across server instances. |
