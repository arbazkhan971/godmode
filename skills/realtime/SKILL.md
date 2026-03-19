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
- Godmode orchestrator detects polling patterns that should be push-based

## Workflow

### Step 1: Real-time Requirements Assessment

Evaluate the communication needs, constraints, and appropriate protocol:

```
REAL-TIME REQUIREMENTS ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│  Dimension          │ Value                               │
│  ─────────────────────────────────────────────────────── │
│  Use case           │ <notifications | chat | collab |    │
│                     │  live feed | gaming | dashboard>    │
│  Direction          │ <server→client | client→server |    │
│                     │  bidirectional>                     │
│  Concurrent users   │ <expected connected clients>        │
│  Message rate       │ <messages per second>               │
│  Message size       │ <avg payload size>                  │
│  Latency target     │ << 50ms | < 200ms | < 1s>          │
│  Reliability        │ <best-effort | guaranteed |         │
│                     │  ordered + guaranteed>              │
│  Persistence        │ <ephemeral | persisted |            │
│                     │  replay on reconnect>              │
│  Auth required      │ <yes | no | per-channel>            │
│  Existing infra     │ <Redis | none | managed service>    │
│  Client platforms   │ <web | mobile | both | IoT>         │
├──────────────────────────────────────────────────────────┤
│  Recommendation: <protocol and technology selection>      │
└──────────────────────────────────────────────────────────┘
```

#### Protocol Selection Matrix
```
PROTOCOL SELECTION:
┌──────────────────┬──────────────┬───────────┬───────────┬────────────┬──────────┐
│ Protocol         │ Best for     │ Direction │ Browser   │ Complexity │ Scaling  │
├──────────────────┼──────────────┼───────────┼───────────┼────────────┼──────────┤
│ WebSocket        │ Chat, games, │ Bi-dir    │ All       │ Medium     │ Needs    │
│                  │ collaboration│           │           │            │ sticky   │
│                  │              │           │           │            │ sessions │
│                  │              │           │           │            │          │
│ Server-Sent      │ Notifications│ Server→   │ All (no   │ Low        │ Easy     │
│ Events (SSE)     │ live feeds,  │ client    │ IE)       │            │ (HTTP)   │
│                  │ dashboards   │ only      │           │            │          │
│                  │              │           │           │            │          │
│ Long Polling     │ Fallback,    │ Simulated │ All       │ Low        │ Easy     │
│                  │ simple push  │ push      │           │            │ (HTTP)   │
│                  │              │           │           │            │          │
│ WebTransport     │ Low-latency  │ Bi-dir    │ Chrome,   │ High       │ Complex  │
│                  │ gaming, media│ (UDP-     │ Edge      │            │          │
│                  │              │ based)    │           │            │          │
│                  │              │           │           │            │          │
│ gRPC Streaming   │ Service-to-  │ Bi-dir    │ Via proxy │ Medium     │ Standard │
│                  │ service      │           │           │            │ (gRPC)   │
└──────────────────┴──────────────┴───────────┴───────────┴────────────┴──────────┘

Decision tree:
  Server→client only (notifications, feeds)?  → SSE
  Bidirectional + browser + managed?          → Socket.io or Pusher/Ably
  Bidirectional + custom + self-hosted?       → Raw WebSocket + Redis pub/sub
  Simple push + maximum compatibility?        → Long polling (fallback)
  Service-to-service streaming?               → gRPC streaming
  Ultra low latency + modern browsers only?   → WebTransport
```

#### Technology Selection
```
TECHNOLOGY SELECTION:
┌──────────────────┬────────────┬───────────┬──────────┬───────────┬──────────┐
│ Technology       │ Best for   │ Protocol  │ Scale    │ Ops cost  │ Features │
├──────────────────┼────────────┼───────────┼──────────┼───────────┼──────────┤
│ Socket.io        │ Web apps,  │ WS + LP   │ Redis    │ Low       │ Rooms,   │
│                  │ chat, collab│ fallback │ adapter  │ (self)    │ namespaces│
│                  │             │          │          │           │ ack, retry│
│                  │             │          │          │           │          │
│ Pusher           │ Notifs,    │ WS       │ Managed  │ None      │ Channels,│
│                  │ simple push│          │ (hosted) │ (per-conn)│ presence,│
│                  │             │          │          │           │ auth     │
│                  │             │          │          │           │          │
│ Ably             │ Enterprise │ WS       │ Managed  │ None      │ History, │
│                  │ pub/sub    │          │ (global) │ (per-msg) │ presence,│
│                  │             │          │          │           │ rewind   │
│                  │             │          │          │           │          │
│ Supabase         │ DB-driven  │ WS       │ Managed  │ None      │ Row-level│
│ Realtime         │ live queries│         │ (hosted) │ (free tier│ security │
│                  │             │          │          │ avail.)   │          │
│                  │             │          │          │           │          │
│ ws (Node.js)     │ Custom,    │ WS       │ Manual   │ Low       │ Minimal, │
│                  │ low-level  │ (raw)    │ (DIY)    │ (self)    │ fast     │
│                  │             │          │          │           │          │
│ Redis Pub/Sub    │ Backend    │ N/A      │ Redis    │ Low       │ Fan-out, │
│ + WebSocket      │ fan-out    │ (backend)│ cluster  │ (self)    │ channels │
└──────────────────┴────────────┴───────────┴──────────┴───────────┴──────────┘
```

### Step 2: Connection Architecture

Design the WebSocket or SSE connection lifecycle:

```
CONNECTION ARCHITECTURE:
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  Client                    Server                   Backend          │
│  ──────                    ──────                   ───────          │
│                                                                      │
│  Connect ──────────────>  Authenticate             Redis Pub/Sub    │
│  (WS handshake + token)   Validate token           ──────────────   │
│                           Create session            Subscribe to    │
│  <───────────────────── Connected (session_id)     user channels    │
│                                                                      │
│  Subscribe ────────────> Join channel/room          Subscribe to    │
│  ("chat:room-123")       Add to room set            room channel    │
│  <───────────────────── Subscribed + history                        │
│                                                                      │
│  Send ─────────────────> Validate + process         Publish to      │
│  (message payload)       Persist to DB              room channel    │
│                          Broadcast to room                          │
│  <───────────────────── Message (from others)       Fan-out to all  │
│                                                     server instances│
│                                                                      │
│  Heartbeat ────────────> Ping/pong (30s)                            │
│  <───────────────────── Pong                                        │
│                                                                      │
│  Disconnect ───────────> Cleanup session            Unsubscribe     │
│  (close/timeout)         Remove from rooms          Publish offline │
│                          Broadcast presence                          │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

#### Socket.io Server Implementation
```typescript
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';

const io = new Server(httpServer, {
  cors: {
    origin: process.env.CLIENT_ORIGIN || 'http://localhost:3000',
    methods: ['GET', 'POST'],
  },
  pingInterval: 25000,   // Heartbeat every 25s
  pingTimeout: 20000,     // Timeout after 20s without pong
  maxHttpBufferSize: 1e6, // 1MB max message size
  transports: ['websocket', 'polling'], // WebSocket preferred, polling fallback
});

// Redis adapter for multi-server scaling
const pubClient = createClient({ url: process.env.REDIS_URL });
const subClient = pubClient.duplicate();
await Promise.all([pubClient.connect(), subClient.connect()]);
io.adapter(createAdapter(pubClient, subClient));

// Authentication middleware
io.use(async (socket, next) => {
  const token = socket.handshake.auth.token;
  if (!token) {
    return next(new Error('Authentication required'));
  }
  try {
    const user = await verifyToken(token);
    socket.data.user = user;
    next();
  } catch (err) {
    next(new Error('Invalid token'));
  }
});

// Connection handler
io.on('connection', (socket) => {
  const user = socket.data.user;
  console.log(`User ${user.id} connected (socket: ${socket.id})`);

  // Join user's personal channel
  socket.join(`user:${user.id}`);

  // Room management
  socket.on('join-room', async (roomId: string) => {
    // Verify access
    const hasAccess = await checkRoomAccess(user.id, roomId);
    if (!hasAccess) {
      socket.emit('error', { message: 'Access denied' });
      return;
    }

    socket.join(`room:${roomId}`);

    // Notify room members
    socket.to(`room:${roomId}`).emit('user-joined', {
      userId: user.id,
      name: user.name,
      timestamp: Date.now(),
    });

    // Send recent history
    const history = await getRecentMessages(roomId, 50);
    socket.emit('room-history', { roomId, messages: history });
  });

  // Message handling
  socket.on('message', async (data: { roomId: string; content: string }) => {
    const message = {
      id: generateId(),
      userId: user.id,
      userName: user.name,
      roomId: data.roomId,
      content: data.content,
      timestamp: Date.now(),
    };

    // Persist
    await saveMessage(message);

    // Broadcast to room (including sender for confirmation)
    io.to(`room:${data.roomId}`).emit('message', message);
  });

  // Typing indicator
  socket.on('typing-start', (roomId: string) => {
    socket.to(`room:${roomId}`).emit('typing', {
      userId: user.id,
      name: user.name,
      isTyping: true,
    });
  });

  socket.on('typing-stop', (roomId: string) => {
    socket.to(`room:${roomId}`).emit('typing', {
      userId: user.id,
      name: user.name,
      isTyping: false,
    });
  });

  // Disconnect
  socket.on('disconnect', (reason) => {
    console.log(`User ${user.id} disconnected: ${reason}`);
    // Broadcast offline status to all rooms
    for (const room of socket.rooms) {
      if (room !== socket.id) {
        socket.to(room).emit('user-left', {
          userId: user.id,
          timestamp: Date.now(),
        });
      }
    }
  });
});
```

#### Server-Sent Events Implementation
```typescript
import express from 'express';

const app = express();
const clients = new Map<string, express.Response>();

// SSE connection endpoint
app.get('/api/events', authenticateRequest, (req, res) => {
  const userId = req.user.id;

  // SSE headers
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no', // Disable Nginx buffering
  });

  // Send initial connection event
  res.write(`event: connected\ndata: ${JSON.stringify({ userId })}\n\n`);

  // Store client connection
  clients.set(userId, res);

  // Heartbeat every 30 seconds (keeps connection alive through proxies)
  const heartbeat = setInterval(() => {
    res.write(': heartbeat\n\n');
  }, 30000);

  // Cleanup on disconnect
  req.on('close', () => {
    clearInterval(heartbeat);
    clients.delete(userId);
  });
});

// Send event to specific user
function sendToUser(userId: string, event: string, data: any) {
  const client = clients.get(userId);
  if (client) {
    client.write(`event: ${event}\ndata: ${JSON.stringify(data)}\nid: ${Date.now()}\n\n`);
  }
}

// Broadcast to all connected clients
function broadcast(event: string, data: any) {
  for (const [, client] of clients) {
    client.write(`event: ${event}\ndata: ${JSON.stringify(data)}\nid: ${Date.now()}\n\n`);
  }
}

// Client-side SSE
// const eventSource = new EventSource('/api/events');
// eventSource.addEventListener('notification', (e) => {
//   const data = JSON.parse(e.data);
//   showNotification(data);
// });
// eventSource.addEventListener('connected', (e) => console.log('SSE connected'));
// eventSource.onerror = () => console.log('SSE reconnecting...');
```

### Step 3: Pub/Sub & Channel Design

Design the channel structure and message routing:

```
CHANNEL ARCHITECTURE:
┌──────────────────────────────────────────────────────────┐
│  Channel Pattern      │ Example              │ Use case   │
│  ─────────────────────────────────────────────────────── │
│  user:<id>            │ user:12345           │ Personal   │
│                       │                      │ notifs,    │
│                       │                      │ DMs        │
│                       │                      │            │
│  room:<id>            │ room:general         │ Chat rooms,│
│                       │                      │ group      │
│                       │                      │ channels   │
│                       │                      │            │
│  document:<id>        │ document:doc-456     │ Collab     │
│                       │                      │ editing    │
│                       │                      │            │
│  feed:<type>          │ feed:global          │ Activity   │
│                       │ feed:team-7          │ feeds      │
│                       │                      │            │
│  dashboard:<id>       │ dashboard:metrics    │ Live       │
│                       │                      │ dashboards │
│                       │                      │            │
│  presence:<scope>     │ presence:room-123    │ Online     │
│                       │                      │ status     │
│                       │                      │            │
│  typing:<scope>       │ typing:room-123      │ Typing     │
│                       │                      │ indicators │
└──────────────────────────────────────────────────────────┘

Channel authorization:
  - Public channels: Any authenticated user can subscribe
  - Private channels: Server validates membership on join
  - Presence channels: Same as private + track online members
  - User channels: Only the user themselves (server-side auth)

Message format:
  {
    "event": "<event-type>",
    "channel": "<channel-name>",
    "data": { ... },
    "timestamp": <unix-ms>,
    "sender": "<user-id>",
    "id": "<message-uuid>"
  }
```

### Step 4: Presence System

Design online/offline status and presence tracking:

```
PRESENCE SYSTEM:
┌──────────────────────────────────────────────────────────┐
│  Component          │ Implementation                      │
│  ─────────────────────────────────────────────────────── │
│  Online status      │ Redis SET per channel with TTL      │
│                     │ Key: presence:<scope>                │
│                     │ Members: { userId, socketId, meta }  │
│                     │ TTL: refreshed on heartbeat          │
│                     │                                     │
│  Join event         │ Add to presence set                 │
│                     │ Broadcast "user_joined" to channel  │
│                     │ Include current member list          │
│                     │                                     │
│  Leave event        │ Remove from presence set            │
│                     │ Broadcast "user_left" to channel    │
│                     │ Debounce: 5s delay (for reconnects) │
│                     │                                     │
│  Status types       │ online | away | busy | offline      │
│                     │ Auto-away after 5 min idle          │
│                     │ Auto-offline after connection drop   │
│                     │                                     │
│  Multi-device       │ User can be on multiple devices     │
│                     │ Online if ANY device is connected    │
│                     │ Offline only when ALL disconnect     │
│                     │                                     │
│  Heartbeat          │ Client sends ping every 30s         │
│                     │ Server expires presence after 60s   │
│                     │ Handles ungraceful disconnects      │
└──────────────────────────────────────────────────────────┘
```

#### Presence Implementation
```typescript
class PresenceManager {
  constructor(private redis: Redis, private io: Server) {}

  async userJoined(scope: string, userId: string, meta: Record<string, any> = {}) {
    const key = `presence:${scope}`;
    const memberData = JSON.stringify({
      userId,
      joinedAt: Date.now(),
      status: 'online',
      ...meta,
    });

    // Add to presence set with score as timestamp
    await this.redis.zadd(key, Date.now(), `${userId}:${memberData}`);
    await this.redis.expire(key, 300); // 5 min TTL, refreshed by heartbeat

    // Get current members
    const members = await this.getMembers(scope);

    // Broadcast join
    this.io.to(scope).emit('presence:join', {
      userId,
      members,
      timestamp: Date.now(),
    });
  }

  async userLeft(scope: string, userId: string) {
    const key = `presence:${scope}`;

    // Debounce: wait 5 seconds for potential reconnect
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Check if user reconnected during debounce window
    const members = await this.redis.zrangebyscore(key, '-inf', '+inf');
    const stillConnected = members.some(m => m.startsWith(`${userId}:`));
    if (stillConnected) return; // User reconnected, do not broadcast leave

    // Remove all entries for this user
    const toRemove = members.filter(m => m.startsWith(`${userId}:`));
    if (toRemove.length > 0) {
      await this.redis.zrem(key, ...toRemove);
    }

    // Broadcast leave
    this.io.to(scope).emit('presence:leave', {
      userId,
      members: await this.getMembers(scope),
      timestamp: Date.now(),
    });
  }

  async heartbeat(scope: string, userId: string) {
    const key = `presence:${scope}`;
    // Refresh TTL and timestamp
    const members = await this.redis.zrangebyscore(key, '-inf', '+inf');
    const entry = members.find(m => m.startsWith(`${userId}:`));
    if (entry) {
      await this.redis.zadd(key, Date.now(), entry);
      await this.redis.expire(key, 300);
    }
  }

  async getMembers(scope: string): Promise<PresenceMember[]> {
    const key = `presence:${scope}`;
    const cutoff = Date.now() - 60000; // 60s timeout
    const entries = await this.redis.zrangebyscore(key, cutoff, '+inf');
    return entries.map(entry => {
      const [, ...jsonParts] = entry.split(':');
      return JSON.parse(jsonParts.join(':'));
    });
  }
}
```

### Step 5: Typing Indicators & Ephemeral State

Design real-time ephemeral state broadcasting:

```
TYPING INDICATOR DESIGN:
┌──────────────────────────────────────────────────────────┐
│  Behavior            │ Implementation                     │
│  ─────────────────────────────────────────────────────── │
│  Start typing        │ Client sends "typing-start" on    │
│                      │ first keystroke (debounced)        │
│                      │                                   │
│  Continue typing     │ Refresh every 3s while typing     │
│                      │                                   │
│  Stop typing         │ Client sends "typing-stop" when:  │
│                      │   - 3s since last keystroke        │
│                      │   - Message sent (clear indicator) │
│                      │   - Input cleared                  │
│                      │                                   │
│  Auto-expire         │ Server expires after 5s without   │
│                      │ refresh (handles disconnects)     │
│                      │                                   │
│  Display             │ "Alice is typing..."              │
│                      │ "Alice and Bob are typing..."     │
│                      │ "3 people are typing..."          │
│                      │                                   │
│  Broadcast scope     │ Room only (not user channel)      │
│  Persistence         │ None — ephemeral, never stored     │
│  Rate limit          │ Max 1 event per 2s per user       │
└──────────────────────────────────────────────────────────┘
```

#### Client-Side Typing Indicator
```typescript
class TypingIndicator {
  private typingTimeout: ReturnType<typeof setTimeout> | null = null;
  private isTyping = false;
  private lastSent = 0;
  private readonly SEND_INTERVAL = 2000; // Min 2s between events
  private readonly STOP_DELAY = 3000;    // Stop after 3s idle

  constructor(private socket: Socket, private roomId: string) {}

  onKeystroke() {
    const now = Date.now();

    // Send typing-start if not already typing or interval elapsed
    if (!this.isTyping || now - this.lastSent > this.SEND_INTERVAL) {
      this.socket.emit('typing-start', this.roomId);
      this.isTyping = true;
      this.lastSent = now;
    }

    // Reset stop timer
    if (this.typingTimeout) clearTimeout(this.typingTimeout);
    this.typingTimeout = setTimeout(() => {
      this.stop();
    }, this.STOP_DELAY);
  }

  stop() {
    if (this.isTyping) {
      this.socket.emit('typing-stop', this.roomId);
      this.isTyping = false;
    }
    if (this.typingTimeout) {
      clearTimeout(this.typingTimeout);
      this.typingTimeout = null;
    }
  }

  onMessageSent() {
    this.stop(); // Clear typing indicator when message is sent
  }
}
```

### Step 6: Real-time Collaboration (CRDT & OT)

Design collaborative editing with conflict resolution:

```
COLLABORATION STRATEGY SELECTION:
┌──────────────────────────────────────────────────────────┐
│  Strategy              │ Best for         │ Complexity    │
│  ─────────────────────────────────────────────────────── │
│  Operational Transform │ Text editing     │ High          │
│  (OT)                  │ (Google Docs     │ Requires      │
│                        │  model)          │ central server│
│                        │                  │               │
│  CRDT                  │ Decentralized    │ Medium-High   │
│  (Conflict-free        │ collaboration,   │ No central    │
│   Replicated Data      │ offline-first,   │ server needed │
│   Types)               │ P2P sync         │               │
│                        │                  │               │
│  Last-write-wins       │ Simple forms,    │ Low           │
│  (LWW)                 │ settings, non-   │ May lose      │
│                        │ concurrent edits │ concurrent    │
│                        │                  │ changes       │
│                        │                  │               │
│  Lock-based            │ Spreadsheet      │ Low           │
│  (pessimistic)         │ cells, single-   │ Blocks        │
│                        │ field editing    │ concurrent    │
│                        │                  │ access        │
└──────────────────────────────────────────────────────────┘

Decision tree:
  Text document, real-time co-editing?           → CRDT (Yjs) or OT
  Offline-first + sync?                          → CRDT (Yjs, Automerge)
  Simple field-level editing?                    → Last-write-wins
  Spreadsheet-style cell editing?                → Lock per cell
  Whiteboard/drawing/diagram?                    → CRDT (Yjs)
```

#### CRDT Implementation with Yjs
```typescript
import * as Y from 'yjs';
import { WebsocketProvider } from 'y-websocket';

// Server-side: y-websocket server
// npx y-websocket --port 1234

// Client-side: Connect to collaborative document
const ydoc = new Y.Doc();
const provider = new WebsocketProvider(
  'ws://localhost:1234',
  'document-123', // Room/document ID
  ydoc,
);

// Shared text type (like Google Docs)
const ytext = ydoc.getText('content');

// Observe changes from all peers
ytext.observe((event) => {
  // event.delta contains the change operations
  // [{ retain: 5 }, { insert: 'hello' }, { delete: 3 }]
  applyToEditor(event.delta);
});

// Local edit (automatically synced to all peers)
ytext.insert(0, 'Hello, world!');

// Shared map type (like a shared state object)
const ymap = ydoc.getMap('metadata');
ymap.set('title', 'Untitled Document');
ymap.set('lastEditedBy', userId);

// Awareness (cursors, selections, presence)
const awareness = provider.awareness;
awareness.setLocalStateField('cursor', { index: 42, length: 0 });
awareness.setLocalStateField('user', { name: 'Alice', color: '#ff0000' });

// Listen for other users' awareness
awareness.on('change', () => {
  const states = awareness.getStates();
  states.forEach((state, clientId) => {
    if (clientId !== ydoc.clientID) {
      renderRemoteCursor(state.cursor, state.user);
    }
  });
});

// Undo/redo support
const undoManager = new Y.UndoManager(ytext, {
  trackedOrigins: new Set([ydoc.clientID]),
});
// undoManager.undo();
// undoManager.redo();
```

#### Collaboration Architecture
```
COLLABORATION ARCHITECTURE:
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  Client A              Server                  Client B              │
│  ────────              ──────                  ────────              │
│                                                                      │
│  Yjs Doc ──── WS ───> y-websocket server <─── WS ──── Yjs Doc      │
│  (local CRDT)         (merge + relay)          (local CRDT)         │
│                       Persistence:                                   │
│                       - LevelDB (snapshots)                          │
│                       - PostgreSQL (via adapter)                      │
│                                                                      │
│  Edit at pos 5 ─────> Merge update ──────────> Apply at pos 5       │
│  "insert 'a'"         (CRDT: no conflicts)     "insert 'a'"         │
│                                                                      │
│  Awareness ──────────> Relay awareness ───────> Show cursor          │
│  (cursor pos 5)        (no persistence)         (Alice at pos 5)     │
│                                                                      │
│  Offline edits         Queued locally           (not connected)      │
│  stored in CRDT        Synced on reconnect                           │
│  ── Reconnect ───────> Merge all pending ─────> Receive merged       │
│                        (CRDT resolves all)      (no conflicts)       │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### Step 7: Scaling Real-time Systems

Design for horizontal scaling across multiple server instances:

```
SCALING ARCHITECTURE:
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  Clients              Load Balancer            Server Instances      │
│  ───────              ─────────────            ────────────────      │
│                                                                      │
│  Client A ──────┐     Nginx / ALB              ┌── Server 1         │
│  Client B ──────┼──>  (sticky sessions         ├── Server 2         │
│  Client C ──────┤      via cookie or IP)       ├── Server 3         │
│  Client D ──────┘                              └── Server 4         │
│                                                    │   │   │   │    │
│                                                    └───┼───┼───┘    │
│                                                        │   │        │
│                                                   Redis Pub/Sub     │
│                                                   (message bus)     │
│                                                                      │
│  Flow: Client A (Server 1) sends message to room                     │
│        Server 1 publishes to Redis                                   │
│        All servers receive via Redis subscription                    │
│        Servers 2,3,4 deliver to their local clients in that room    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

SCALING CHECKLIST:
  [ ] Sticky sessions configured (WebSocket requires connection affinity)
  [ ] Redis adapter for Socket.io (or equivalent pub/sub layer)
  [ ] Stateless server design (no in-memory state beyond connections)
  [ ] Health check endpoint that verifies Redis + WebSocket connectivity
  [ ] Connection count monitoring per instance
  [ ] Auto-scaling based on connection count (not CPU)
  [ ] Graceful shutdown: drain connections before termination
  [ ] Connection limit per instance (prevent single-instance overload)
```

#### Nginx WebSocket Configuration
```nginx
upstream websocket_backend {
    # Sticky sessions using IP hash
    ip_hash;

    server ws-server-1:3000;
    server ws-server-2:3000;
    server ws-server-3:3000;
}

server {
    listen 80;
    server_name ws.example.com;

    location /socket.io/ {
        proxy_pass http://websocket_backend;
        proxy_http_version 1.1;

        # WebSocket upgrade headers
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Forward client info
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Timeouts (keep connections alive)
        proxy_read_timeout 86400s;  # 24 hours
        proxy_send_timeout 86400s;

        # Disable buffering for real-time
        proxy_buffering off;
    }
}
```

#### Connection Scaling Metrics
```
SCALING TARGETS:
┌──────────────────────────────────────────────────────────┐
│  Metric                    │ Per Instance│ Cluster Total │
│  ─────────────────────────────────────────────────────── │
│  Max connections           │ 10,000      │ 100,000       │
│  Target connections        │ 5,000       │ 50,000        │
│  Scale-up threshold        │ 7,000       │ —             │
│  Scale-down threshold      │ 2,000       │ —             │
│  Memory per connection     │ ~10KB       │ —             │
│  Memory per instance       │ 512MB       │ 5GB           │
│  Messages per second       │ 5,000       │ 50,000        │
│  Redis pub/sub throughput  │ —           │ 100,000 msg/s │
│  Latency (same instance)   │ < 5ms       │ —             │
│  Latency (cross instance)  │ < 20ms      │ —             │
│  Reconnect time            │ < 3s        │ —             │
└──────────────────────────────────────────────────────────┘
```

### Step 8: Client-Side Connection Management

Design resilient client-side connection handling:

```
CLIENT CONNECTION MANAGEMENT:
┌──────────────────────────────────────────────────────────┐
│  Scenario              │ Behavior                         │
│  ─────────────────────────────────────────────────────── │
│  Initial connect       │ Connect with auth token          │
│                        │ Subscribe to channels            │
│                        │ Request missed messages (last ID)│
│                        │                                 │
│  Disconnect detected   │ Show "reconnecting..." UI       │
│                        │ Queue outgoing messages locally  │
│                        │                                 │
│  Reconnect attempt     │ Exponential backoff:             │
│                        │ 1s, 2s, 4s, 8s, 16s, 30s (cap) │
│                        │ Add jitter: +/- 20%             │
│                        │                                 │
│  Reconnect success     │ Re-authenticate                 │
│                        │ Re-subscribe to channels         │
│                        │ Request messages since last ID   │
│                        │ Flush queued messages            │
│                        │ Show "connected" UI             │
│                        │                                 │
│  Permanent failure     │ After 10 attempts or 5 min:     │
│                        │ Show "connection lost" UI        │
│                        │ Offer manual reconnect button   │
│                        │                                 │
│  Tab backgrounded      │ Reduce heartbeat frequency      │
│                        │ Disconnect after 5 min (mobile) │
│                        │ Reconnect on tab focus           │
│                        │                                 │
│  Token expired         │ Refresh token, then reconnect   │
│                        │ If refresh fails: redirect login │
└──────────────────────────────────────────────────────────┘
```

#### Reconnection Logic
```typescript
class RealtimeClient {
  private socket: Socket | null = null;
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 10;
  private messageQueue: Array<{ event: string; data: any }> = [];
  private lastMessageId: string | null = null;

  connect(token: string) {
    this.socket = io(WS_URL, {
      auth: { token },
      reconnection: true,
      reconnectionAttempts: this.maxReconnectAttempts,
      reconnectionDelay: 1000,      // Start at 1s
      reconnectionDelayMax: 30000,   // Cap at 30s
      randomizationFactor: 0.2,      // +/- 20% jitter
    });

    this.socket.on('connect', () => {
      this.reconnectAttempts = 0;
      this.onConnected();
    });

    this.socket.on('disconnect', (reason) => {
      if (reason === 'io server disconnect') {
        // Server kicked us — need to reconnect manually
        this.socket!.connect();
      }
      // Otherwise Socket.io handles reconnection automatically
      this.onDisconnected(reason);
    });

    this.socket.on('connect_error', (error) => {
      this.reconnectAttempts++;
      if (error.message === 'Invalid token') {
        // Token expired — refresh and retry
        this.refreshTokenAndReconnect();
      }
    });

    // Track last received message for gap detection
    this.socket.onAny((event, data) => {
      if (data?.id) {
        this.lastMessageId = data.id;
      }
    });
  }

  private async onConnected() {
    // Re-subscribe to channels
    for (const channel of this.subscribedChannels) {
      this.socket!.emit('subscribe', channel);
    }

    // Request missed messages
    if (this.lastMessageId) {
      this.socket!.emit('sync', { since: this.lastMessageId });
    }

    // Flush queued messages
    while (this.messageQueue.length > 0) {
      const msg = this.messageQueue.shift()!;
      this.socket!.emit(msg.event, msg.data);
    }
  }

  send(event: string, data: any) {
    if (this.socket?.connected) {
      this.socket.emit(event, data);
    } else {
      // Queue for delivery after reconnect
      this.messageQueue.push({ event, data });
    }
  }
}
```

### Step 9: Commit and Transition

```
1. Save WebSocket/SSE server config as `realtime/server.ts`
2. Save channel definitions as `realtime/channels.ts`
3. Save presence system as `realtime/presence.ts`
4. Save client connection manager as `realtime/client.ts`
5. Save scaling config (Nginx, Redis adapter) as `realtime/infra/`
6. Commit: "realtime: <feature> — <protocol>, <N> channels, <scale target> connections"
7. If new setup: "Real-time infrastructure configured. <protocol> with <N> channels. Test with /realtime/test."
8. If adding feature: "Feature added: <typing indicators | presence | collaboration>. Verify UX."
9. If scaling: "Scaled to <N> instances via Redis adapter. Sticky sessions configured."
```

## Key Behaviors

1. **SSE before WebSocket.** If you only need server-to-client push (notifications, feeds, dashboards), use SSE. It is simpler, works through HTTP proxies, and auto-reconnects. WebSocket is for bidirectional communication.
2. **Always authenticate on connect.** WebSocket connections bypass standard HTTP middleware. Authenticate during the handshake, not after. Reject unauthenticated connections immediately.
3. **Heartbeats are mandatory.** Connections silently die (mobile networks, NAT timeouts, proxy kills). Client and server must exchange heartbeats to detect dead connections within 60 seconds.
4. **Design for disconnection.** Every client will disconnect — network switch, sleep mode, backgrounded tab. Queue messages, track last received ID, sync on reconnect. Assume unreliable connections.
5. **Presence needs debouncing.** Do not broadcast "user left" the instant a WebSocket closes. Wait 3-5 seconds for reconnection. Otherwise, presence flickers on every network blip.
6. **Redis pub/sub for multi-server.** A single server handles thousands of connections. Multiple servers need a message bus. Redis pub/sub is the standard approach for Socket.io scaling.
7. **Typing indicators are ephemeral.** Never persist typing state. Broadcast it, auto-expire it in 5 seconds, and never send it faster than once per 2 seconds. Typing state is noise, not data.
8. **CRDT for collaboration.** If multiple users edit the same document simultaneously, use CRDTs (Yjs, Automerge). They resolve conflicts automatically without a central server making decisions.

## Example Usage

### Adding real-time notifications
```
User: /godmode:realtime Add live notifications to our web app

Realtime: Assessing real-time requirements...

REQUIREMENTS:
  Use case: Notifications (new messages, updates, alerts)
  Direction: Server → client only
  Concurrent users: ~2,000
  Latency: < 1s
  Reliability: Guaranteed (persist, deliver on reconnect)

Recommendation: Server-Sent Events (SSE)
  Rationale: Server-to-client only, simpler than WebSocket,
  auto-reconnects, works through all proxies and load balancers.
  No need for bidirectional communication.

Setting up SSE...
  Endpoint: GET /api/events (authenticated, per-user stream)
  Events: notification, message, alert, system
  Heartbeat: 30s keepalive
  Reconnect: Auto (EventSource built-in) with Last-Event-Id
  Missed messages: Queried on reconnect via Last-Event-Id header
  Multi-server: Redis pub/sub for fan-out across instances

Client integration:
  EventSource with auth token
  Notification toast component
  Badge counter for unread

SSE ready. Test with: curl -H "Authorization: Bearer <token>" /api/events
```

### Building collaborative document editing
```
User: /godmode:realtime Add real-time collaborative editing to our notes app

Realtime: Assessing collaboration requirements...

REQUIREMENTS:
  Use case: Collaborative text editing (Google Docs-style)
  Direction: Bidirectional
  Concurrent editors: Up to 20 per document
  Conflict resolution: Must handle simultaneous edits
  Offline support: Yes (sync on reconnect)

Recommendation: CRDT with Yjs + WebSocket
  Rationale: CRDT handles conflict resolution automatically,
  Yjs has excellent performance and offline support,
  WebSocket needed for bidirectional sync.

Setting up collaboration...
  Protocol: WebSocket (via y-websocket)
  CRDT library: Yjs
  Shared types: Y.Text (document content), Y.Map (metadata)
  Awareness: Live cursors, user colors, selection highlights
  Persistence: LevelDB snapshots + PostgreSQL document store
  Undo/redo: Per-user undo stack via Y.UndoManager

Features:
  - Real-time text sync (< 50ms latency)
  - Live cursors with user name and color
  - Typing indicators per paragraph
  - Offline editing with automatic merge on reconnect
  - Conflict-free (CRDT guarantees convergence)

Scaling: y-websocket server with Redis pub/sub for multi-instance.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full real-time architecture design workflow |
| `--protocol <name>` | Target specific protocol (websocket, sse, longpoll) |
| `--tech <name>` | Target specific technology (socketio, pusher, ably, ws) |
| `--presence` | Design presence system only |
| `--collab` | Design real-time collaboration (CRDT/OT) |
| `--notifications` | Design real-time notification system only |
| `--scale` | Design scaling architecture (Redis pub/sub, sticky sessions) |
| `--chat` | Design real-time chat system |
| `--typing` | Design typing indicators |
| `--audit` | Audit existing real-time implementation |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check package.json for ws, socket.io, @socket.io/*, pusher, ably, sse, eventsource
2. Check for existing WebSocket server files: grep for "WebSocketServer", "Server({ port", "io("
3. Detect framework: Next.js (api routes), Express (app.ws), Fastify (fastify-websocket)
4. Check infrastructure: docker-compose.yml for redis (pub/sub), nginx.conf for proxy_pass upgrades
5. Detect client libraries: socket.io-client, pusher-js, ably, @microsoft/signalr
6. Check for CRDT libraries: yjs, y-websocket, automerge
7. Scan for existing presence/notification systems in src/
```

## Iterative Implementation Loop

```
current_iteration = 0
max_iterations = 12
tasks_remaining = [list of realtime features to implement]

WHILE tasks_remaining is not empty AND current_iteration < max_iterations:
    task = tasks_remaining.pop(0)
    1. Design the protocol message schema for this feature
    2. Implement server-side handler (connection, message, disconnect)
    3. Implement client-side hook/listener
    4. Add reconnection + error handling
    5. Test with simulated latency: verify < 100ms p95
    6. Test with connection drop: verify reconnect + state sync
    7. IF tests fail → fix handler logic, re-test
    8. IF tests pass → commit: "realtime: implement <feature>"
    9. current_iteration += 1

POST-LOOP: Load test all features together at 10x expected concurrency
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "realtime-server": server-side handlers, rooms, auth middleware
  Agent 2 — "realtime-client": client hooks, reconnection logic, UI indicators
  Agent 3 — "realtime-infra": Redis pub/sub, scaling config, nginx WebSocket proxy

MERGE ORDER: infra → server → client
CONFLICT ZONES: message schema types (shared contract — define first, then dispatch)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER send user credentials in WebSocket messages. Auth happens at connection handshake only.
2. NEVER trust client-sent data without server-side validation.
3. NEVER store connection state only in application memory. Use Redis or equivalent.
4. NEVER allow unbounded message queues. Set max queue depth per connection.
5. NEVER skip heartbeat/ping-pong. Dead connections leak resources.
6. NEVER broadcast without room/channel scoping. O(n) fan-out kills at scale.
7. NEVER use WebSocket for request-response patterns. Use HTTP for that.
8. NEVER deploy WebSocket without sticky sessions or Redis adapter for multi-instance.
9. EVERY message schema must be versioned. Breaking changes require a new message type.
10. EVERY connection must have an idle timeout. No immortal connections.
```

## Anti-Patterns

- **Do NOT use WebSocket when SSE suffices.** If data flows only from server to client, SSE is simpler, auto-reconnects, works through HTTP/2, and needs no special proxy config. WebSocket adds complexity for no benefit.
- **Do NOT skip authentication on WebSocket connect.** An unauthenticated WebSocket is an open door. Validate the token during the handshake and reject before upgrade.
- **Do NOT broadcast to all connections in a loop.** Use rooms/channels (Socket.io rooms, Redis pub/sub channels). Iterating over all connections and filtering is O(n) per message and does not scale.
- **Do NOT store connection state in application memory.** Server instances restart, scale, and crash. Store presence in Redis, store messages in a database. The WebSocket server should be stateless except for active connections.
- **Do NOT send every keystroke over the wire.** Debounce typing events (2-3 second intervals) and batch document changes. Sending every character creates unnecessary network traffic and server load.
- **Do NOT forget sticky sessions when scaling WebSocket.** WebSocket is a stateful connection. If a client's requests hit different servers, the handshake fails. Configure sticky sessions (IP hash or cookie-based) in your load balancer.
- **Do NOT implement your own CRDT for production.** Use Yjs or Automerge. CRDT implementations are subtle and error-prone. The edge cases around concurrent edits, deletions, and undo will take months to get right.
- **Do NOT ignore connection limits.** Each WebSocket connection consumes memory and a file descriptor. Set per-instance connection limits, monitor connection counts, and auto-scale based on connections, not CPU.
