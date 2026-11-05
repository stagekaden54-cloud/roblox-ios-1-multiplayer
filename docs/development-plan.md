# Development Plan

## Vision

Build a nostalgic + modern multiplayer experience inspired by early Roblox iOS.

- **Nostalgic**: Blocky characters, classic proportions, clean early-mobile influence, simple world language.
- **Modern**: Smooth animations, good camera feel, responsive controls, solid multiplayer foundation.

We complete the **basic foundation** first. Advanced systems are paused until explicitly approved.

---

## Phase 1 — Foundation (Current Focus)

### 1. Authentication & Session
- [x] Temporary guest identities
- [x] Cleaner guest login flow
- [x] Stable session handling
- [x] Better connection / reconnection behavior (client side)
- [x] Clear error states on the client

### 2. Character Foundation
- [x] Simple blocky character model (`PlayerNode`)
- [x] Name tag above character
- [x] Local player vs other player distinction
- [x] Basic color support (local vs remote)

### 3. Core Animations
- [x] Idle
- [x] Walk
- [x] Jump
- [x] Fall
- [x] Animation state driven by movement
- [x] Networked animation state so others see the correct animation

### 4. Camera
- [x] Third-person follow camera
- [x] Smooth spring / lag
- [x] Rotate via touch drag
- [ ] Limited zoom (next polish pass)

### 5. Movement
- [x] Walk
- [x] Jump
- [x] Basic gravity
- [x] Simple ground collision
- [x] Keyboard controls (WASD / arrows + space)
- [ ] Better touch joystick (next polish pass)

### 6. Multiplayer Sync
- [x] Server stores position + animation state
- [x] 20Hz snapshot broadcasting
- [x] Client can send state updates
- [x] Client receives presence + snapshots
- [x] Remote players appear and update in the world
- [ ] Client-side interpolation (next polish pass)
- [x] Join / leave still works cleanly

### 7. UI Foundation
- [x] Welcome / guest join screen
- [x] Lobby + chat (still available)
- [x] In-game status + leave button
- [ ] Smooth UI transitions
- [x] Clear connection status

---

## Phase 2 — Advanced (Paused)

These will not be started until Phase 1 polish is in a good state and explicitly approved:

- Multiple rooms / instances
- Improved physics and collision
- Character customization
- Particles and visual effects
- Sound design
- Emotes
- More complex world interactions
- Possible migration of core to C++ or Rust for performance
- Account system (beyond guests)

---

## Current Tech Stack

- **Server**: Node.js + WebSocket (state + 20Hz snapshots)
- **Client**: Swift + UIKit + SceneKit
- Future consideration: C++ or Rust core for simulation + networking

---

## Rules for this phase

- Prefer working, feel-good basics over incomplete advanced systems
- Keep the protocol clean and explicit
- Do not add account systems or external services yet
- Keep the project independent from official Roblox services
