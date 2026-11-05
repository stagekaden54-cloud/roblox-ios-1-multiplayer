# Roblox iOS 1.0 — Multiplayer Experiment

An independent preservation and learning project exploring a modern, custom multiplayer companion inspired by the historical Roblox iOS 1.0 era.

This project is **not an official Roblox product** and does not connect to Roblox production services. All multiplayer systems are original.

## Vision

Create a **nostalgic + modern** multiplayer experience:
- Classic early-Roblox feel (blocky characters, simple world language, clean mobile-inspired UI)
- Modern execution (smooth animations, good camera, responsive controls, solid netcode)

## Current Foundation Progress

### Phase 1 — Core Basics (Mostly Complete)
- [x] WebSocket server with guest identities, presence, and chat
- [x] Basic iOS client (welcome screen, lobby, chat)
- [x] Improved authentication / guest session flow
- [x] Server-side player state (position + animation)
- [x] 20Hz snapshot broadcasting
- [x] Client support for sending/receiving state
- [x] Basic blocky character (`PlayerNode`)
- [x] Core animations (idle, walk, jump, fall)
- [x] Third-person camera with spring follow
- [x] Local movement + jump + gravity
- [x] Remote players appear and sync in the world
- [ ] Client-side interpolation (polish)
- [ ] Touch joystick (polish)
- [ ] Limited camera zoom (polish)

### Phase 2 — Advanced (Paused)
- Better physics & collision
- Multiple rooms / instances
- Character customization
- Particles, effects, sound
- Deeper world interactions
- Possible C++/Rust core migration for performance

## Requirements

- Node.js 20 or newer
- Xcode 15+
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

1. Enter a guest name
2. Enter the server address
3. Tap **ENTER WORLD**

Controls:
- Drag to look
- WASD / Arrow keys to move
- Space to jump

## Protocol

**Client → Server**
- `join`
- `chat`
- `state` `{ x, y, z, rotY, anim }`

**Server → Client**
- `welcome`
- `presence`
- `snapshot` (20Hz)
- `player-joined` / `player-left`
- `chat`
- `error`

## Safety Notes

- Temporary guest identities only
- No Roblox accounts, cookies, or credentials
- Do not commit secrets, certificates, or private keys

## Project Structure

```
roblox-ios-1-multiplayer/
├── multiplayer-server/     # Node.js server (state + snapshots)
├── ios/                    # Swift + SceneKit client
│   └── RobloxIOS1/
│       ├── GameViewController.swift
│       ├── PlayerNode.swift
│       ├── MultiplayerClient.swift
│       └── ...
├── docs/
└── README.md
```
