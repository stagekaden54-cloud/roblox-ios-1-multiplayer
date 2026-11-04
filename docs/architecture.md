# Architecture

## Goals

1. Preserve the historical app's visual identity and document its original behavior.
2. Build an independent multiplayer service for controlled experiments.
3. Keep the server protocol small and explicit.
4. Rebuild the iOS experience for modern 64-bit devices rather than attempting to run the original 32-bit executable unchanged.

## Components

- **iOS client (planned):** a modern iOS app that recreates selected historical screens and connects to the custom service.
- **WebSocket server (prototype):** owns temporary guest sessions, one in-memory lobby, presence, chat fan-out, heartbeat checks, and basic rate limits.
- **Persistence (later):** optional database for room metadata or test profiles. The first prototype is intentionally in-memory.

## Protocol

Client to server:

- `{ "type": "join", "displayName": "Guest" }`
- `{ "type": "chat", "text": "Hello" }`

Server to client:

- `welcome` — temporary player ID and room ID
- `presence` — current lobby members
- `player-joined` / `player-left` — membership events
- `chat` — server-assigned sender identity and message text
- `error` — rejected or invalid request

Movement messages are reserved until an independent 3D test scene exists. Position updates must be validated and server-authoritative when implemented.

## Prototype safeguards

- Guest identities are temporary and are not Roblox accounts.
- Never request or store Roblox passwords, cookies, or authentication tokens.
- The server enforces a 4 KiB message limit, basic per-connection message limits, and a chat burst limit.
- Display names and chat text are length-limited and control characters are filtered.
- Ping/pong heartbeats remove stale connections.
- The default bind address is loopback (127.0.0.1); local network access requires an explicit host override.
- Rooms are in-memory and reset when the server restarts.
- This is not production-ready. Before public hosting, add WSS/TLS, a deliberate origin policy, room and connection caps, stronger abuse controls, moderation, monitoring, and a privacy review.

## Non-goals

- Reproducing Roblox's private production protocol.
- Connecting to Roblox production accounts or services.
- Shipping an altered Roblox-branded app as an official client.
