# Architecture

## Goals

1. Preserve the historical app's visual identity and document its original behavior.
2. Build an independent multiplayer service for controlled experiments.
3. Keep the server protocol small, explicit, and versioned.
4. Rebuild the iOS experience for modern 64-bit devices rather than attempting to run the original 32-bit executable unchanged.

## Components

- **iOS client (planned):** a modern iOS app that recreates selected historical screens and connects to the custom service.
- **WebSocket server (prototype):** owns room membership, guest sessions, presence, and chat fan-out.
- **Persistence (later):** optional database for room metadata or test profiles. The first prototype is intentionally in-memory.

## First protocol draft

Messages are JSON objects with a `type` field.

Client to server:

- `{ "type": "join", "displayName": "Guest" }`
- `{ "type": "chat", "text": "Hello" }`
- `{ "type": "move", "x": 0, "y": 0, "z": 0 }` (reserved for a later 3D prototype)

Server to client:

- `{ "type": "welcome", "playerId": "...", "roomId": "lobby" }`
- `{ "type": "presence", "players": [...] }`
- `{ "type": "chat", "playerId": "...", "displayName": "...", "text": "..." }`
- `{ "type": "error", "message": "..." }`

## Initial security boundaries

- Guest identities are temporary and are not Roblox accounts.
- Never request or store Roblox passwords, cookies, or authentication tokens.
- Validate message types, text lengths, and numeric values on the server.
- The server is authoritative for room membership and player identity.
- Prototype rooms are in-memory and reset when the server restarts.
- Do not expose the prototype server publicly until rate limits, origin policy, abuse handling, and transport security are reviewed.

## Non-goals

- Reproducing Roblox's private production protocol.
- Connecting to Roblox production accounts or services.
- Shipping an altered Roblox-branded app as an official client.
