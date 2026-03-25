---
name: realtime
description: Real-time communication -- WebSocket, SSE,
  pub/sub, collaboration, presence systems.
---

## Activate When
- `/godmode:realtime`, "add websockets", "real-time"
- "live notifications", "typing indicator", "presence"
- "collaborative editing", "live cursors", "SSE"
- Polling patterns that need push-based delivery

## Workflow

### 1. Requirements Assessment
```bash
grep -r "socket.io\|ws\|websocket\|sse\|EventSource" \
  --include="*.ts" --include="*.js" -l 2>/dev/null
grep -r "redis.*pub\|redis.*sub\|createAdapter" \
  --include="*.ts" --include="*.js" -l 2>/dev/null
```
```
Direction: server->client | bidirectional | both
Latency: <100ms | <1s | <30s
Concurrency: <1K | 1K-10K | 10K-100K | >100K
Persistence: ephemeral | replay needed
```

### 2. Protocol Selection
- **SSE**: server->client only, auto-reconnect, works
  through HTTP proxies. Use for notifications, feeds.
- **WebSocket**: bidirectional, low latency. Use for
  chat, collaboration, gaming.
- **Socket.io**: WebSocket + fallback, rooms, namespace.
  Use for most real-time web apps.
- **WebTransport**: HTTP/3, multi-stream. Bleeding edge.

IF only server->client push: use SSE (simpler).
IF bidirectional needed: use WebSocket/Socket.io.

### 3. Connection Architecture
Authenticate during handshake (not after). Reject
unauthenticated connections immediately.
Heartbeat: client+server exchange every 30s.
Dead connection detection within 60s.

### 4. Pub/Sub & Channel Design
Channel patterns: `room:{id}`, `user:{id}`,
`team:{id}`, `presence:{room}`, `typing:{room}`.
Use Redis pub/sub for multi-server fan-out.

### 5. Presence System
Track online/offline per user+room in Redis sorted set.
Score = last-seen timestamp. Expire after 60s.
Debounce "user left" by 3-5s (prevents flicker on
network blips).

### 6. Typing Indicators
Ephemeral state. Never persist. Broadcast at most
once per 2s. Auto-expire after 5s. Send `stop_typing`
on blur or submit.

### 7. Collaboration (CRDT/OT)
- **CRDT (Yjs, Automerge)**: automatic conflict
  resolution, no central server. Best for concurrent
  editing (docs, whiteboards).
- **OT (ShareJS)**: server-based transforms. Older
  approach, more complex.
- **Last-write-wins**: simplest. Use for settings,
  non-collaborative fields.

IF multiple users edit same document: use CRDT (Yjs).
IF simple form fields: last-write-wins sufficient.

### 8. Scaling
Redis pub/sub adapter for Socket.io multi-instance.
Sticky sessions (IP hash) for WebSocket at LB.
Per-instance: ~10K connections. Cluster: scale
horizontally with Redis adapter.

```nginx
upstream websocket_backend {
    ip_hash;
    server ws1:3000;
    server ws2:3000;
}
```

### 9. Client Reconnection
Exponential backoff: base=1s, max=30s, max attempts=10.
On reconnect: re-authenticate, rejoin rooms, fetch
missed messages by last-received ID. Queue messages
during disconnection.

### 10. Validation
```
[ ] Auth on handshake
[ ] Heartbeat configured (30s interval)
[ ] Reconnection with state recovery
[ ] Redis pub/sub for multi-instance
[ ] Presence with debounce (3-5s)
[ ] Rate limiting on incoming messages
[ ] Server-side message validation
```

## Hard Rules
1. NEVER send credentials in WebSocket messages.
2. NEVER trust client data without server validation.
3. ALWAYS authenticate on connection handshake.
4. ALWAYS implement heartbeat (detect dead connections).
5. ALWAYS design for disconnection (queue + sync).
6. NEVER persist typing state.
7. ALWAYS use Redis pub/sub for multi-server.
8. Rate limit incoming messages per connection.

## TSV Logging
Append `.godmode/realtime-results.tsv`:
```
timestamp	transport	event_types	rooms	presence	scaling	reconnection	status
```

## Keep/Discard
```
KEEP if: reconnection recovers state AND latency
  < 100ms p95 AND ordering preserved.
DISCARD if: messages lost on reconnect
  OR cross-instance delivery fails.
```

## Stop Conditions
```
STOP when FIRST of:
  - All features work (chat, presence, typing)
  - Reconnection with state recovery verified
  - Cross-instance delivery confirmed
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Connections drop often | Heartbeat + backoff reconnect |
| Out-of-order messages | Add sequence numbers, reorder |
| Memory grows per client | Check listener leaks, limit buffers |
| Updates not reaching all | Verify Redis pub/sub fan-out |
