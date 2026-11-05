# Roblox iOS 1.0 — Multiplayer Experiment

An independent preservation and learning project exploring a modern, custom multiplayer companion inspired by the historical Roblox iOS 1.0 era.

This project is **not an official Roblox product** and does not connect to Roblox production services. All multiplayer systems are original.

## Vision

Create a **nostalgic + modern** multiplayer experience:
- Classic early-Roblox feel (blocky characters, simple world language, clean mobile-inspired UI)
- Modern execution (smooth animations, good camera, responsive controls, solid netcode)

We are building the **foundation first**. Advanced systems come later.

## Current Foundation Goals

### Phase 1 — Core Basics (In Progress)
- [x] WebSocket server with guest identities, presence, and chat
- [x] Basic iOS client (welcome screen, lobby, chat)
- [ ] Improved authentication / guest session flow
- [ ] Basic character representation
- [ ] Core animations (idle, walk, jump, fall)
- [ ] Third-person camera
- [ ] Local movement
- [ ] Multiplayer position + animation sync
- [ ] Clean UI foundation with transitions

### Phase 2 — Advanced (Paused — waiting for approval)
- Better physics & collision
- Multiple rooms / instances
- Character customization
- Particles, effects, sound
- Deeper world interactions
- Possible C++/Rust core migration for performance

## Requirements

- Node.js 20 or newer (current server)
- Xcode 15+ (iOS client)
- npm

## Run the server

```sh
cd multiplayer-server
npm install
npm test
npm start
```

Default: `ws://127.0.0.1:8080`  
For local network testing: `HOST=0.0.0.0 npm start`

## iOS Client

```sh
open ios/RobloxIOS1.xcodeproj
```

See `ios/README.md` for connection instructions.

## Protocol (Current)

**Client → Server**
- `{ "type": "join", "displayName": "Guest" }`
- `{ "type": "chat", "text": "Hello" }`

**Server → Client**
- `welcome` — player ID + room ID
- `presence` — current players
- `player-joined` / `player-left`
- `chat`
- `error`

Movement and animation messages will be added during the foundation phase.

## Safety Notes

- Temporary guest identities only
- No Roblox accounts, cookies, or credentials
- Do not commit secrets, certificates, or private keys
- This is an independent learning project

## Project Structure

```
roblox-ios-1-multiplayer/
├── multiplayer-server/     # Current Node.js prototype server
├── ios/                    # Swift + UIKit client
├── docs/                   # Architecture & planning
└── README.md
```
