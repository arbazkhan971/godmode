# /godmode:realtime

Design, build, and scale real-time communication features. Covers WebSocket architecture, Server-Sent Events, pub/sub patterns (Socket.io, Pusher, Ably), real-time collaboration (CRDT, OT), presence systems, typing indicators, and scaling with Redis pub/sub.

## Usage

```
/godmode:realtime                          # Full real-time architecture design
/godmode:realtime --protocol sse           # Use Server-Sent Events
/godmode:realtime --protocol websocket     # Use WebSocket (default)
/godmode:realtime --tech socketio          # Target Socket.io specifically
/godmode:realtime --presence               # Design presence system only
/godmode:realtime --collab                 # Design collaborative editing (CRDT/OT)
/godmode:realtime --notifications          # Design real-time notifications only
/godmode:realtime --chat                   # Design real-time chat system
/godmode:realtime --typing                 # Design typing indicators
/godmode:realtime --scale                  # Design scaling architecture
/godmode:realtime --audit                  # Audit existing real-time implementation
```

## What It Does

1. Assesses real-time requirements (direction, concurrency, latency, reliability)
2. Selects the appropriate protocol and technology
3. Designs connection architecture with authentication and lifecycle management
4. Implements pub/sub channel structure with authorization
5. Builds presence system with online/offline tracking and multi-device support
6. Designs typing indicators and ephemeral state broadcasting
7. Implements collaborative editing with CRDT (Yjs) or OT
8. Configures client-side reconnection with backoff and message recovery
9. Designs horizontal scaling with Redis pub/sub and sticky sessions
10. Establishes connection monitoring and capacity planning

## Output
- Server config at `realtime/server.ts`
- Channel definitions at `realtime/channels.ts`
- Presence system at `realtime/presence.ts`
- Client manager at `realtime/client.ts`
- Scaling config at `realtime/infra/`
- Commit: `"realtime: <feature> — <protocol>, <N> channels, <scale target> connections"`

## Next Step
After real-time setup: `/godmode:observe` to monitor connections and latency, or `/godmode:secure` to audit WebSocket authentication.

## Examples

```
/godmode:realtime Add live notifications to our web app
/godmode:realtime --collab Add collaborative editing to our notes app
/godmode:realtime --chat Build real-time chat for our team workspace
/godmode:realtime --presence Add "who's online" to our dashboard
/godmode:realtime --scale Our WebSocket server is hitting connection limits
```
