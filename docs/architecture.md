# Architecture

## Goals

1. Deliver a nostalgic + modern multiplayer foundation inspired by early Roblox iOS.
2. Keep the protocol small, explicit, and easy to evolve.
3. Prioritize solid basics (session, character, animation, camera, movement, sync) before advanced systems.
4. Remain fully independent from official Roblox services.

## High-Level Components

- **iOS Client (Swift)**  
  Native UI, camera, local input, rendering, and presentation of remote players.

- **Multiplayer Server (currently Node.js)**  
  Owns sessions, room state, authoritative player state, and broadcasting.

- **Protocol**  
  Explicit JSON messages over WebSocket. Designed to grow cleanly as movement and animation are added.

## Current Responsibilities

### Server
- Guest session creation
- Presence and chat
- Rate limiting and basic validation
- Heartbeat / stale connection cleanup
- Future: authoritative position + animation state, snapshot broadcasting

### Client
- Guest login / connection flow
- Lobby UI + chat (current)
- Future: character, animations, camera, local movement prediction, interpolation of remote players

## Protocol Direction (Foundation)

### Existing
- `join`
- `chat`
- `welcome`
- `presence`
- `player-joined` / `player-left`
- `error`

### Planned for Foundation Phase
- Client input or state messages for movement
- Server snapshots containing position + animation state
- Clear separation between local player and remote players

Movement and animation messages will be added only after the basic 3D character and camera exist.

## Design Principles

- Server is authoritative for shared state
- Clients handle presentation, camera, and local feel
- Animation state is networked so all players see consistent character behavior
- Prefer simple, readable systems over premature complexity
- Keep guest-only identity for the foundation phase

## Non-Goals (for now)

- Official Roblox protocol or services
- Full account system
- Complex physics
- Large open worlds
- Scripting layer
- Heavy customization

## Future Consideration

Once the foundation feels solid, we may evaluate moving the core simulation and networking to C++ or Rust for better performance and control, while keeping the iOS frontend in Swift.
