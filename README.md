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
- [x] GitHub Action to build unsigned IPA
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

- Node.js 20 or newer (for the server)
- npm
- An iPhone + IPA signing tool (for testing the client)

## Run the server

```sh
cd multiplayer-server
npm install
npm test
npm start
```

Default: `ws://127.0.0.1:8080`  
For local network testing: `HOST=0.0.0.0 npm start`

## Get the iOS app (No Mac needed)

This repo has a GitHub Action that builds an **unsigned IPA**.

1. Go to the repo **Actions** tab
2. Open **Build Unsigned IPA**
3. Run the workflow (or wait for a push to `ios/`)
4. Download the artifact `RobloxIOS1-unsigned-ipa`
5. Sign the IPA on your iPhone with your tools
6. Install and test

Full instructions: [`docs/build-ipa.md`](docs/build-ipa.md)

### In the app
1. Enter a guest name
2. Enter your server address (example: `ws://192.168.1.25:8080`)
3. Tap **ENTER WORLD**

Controls:
- Drag to look
- WASD / Arrow keys to move (simulator / keyboard)
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
├── .github/workflows/      # Unsigned IPA builder
├── docs/
└── README.md
```
