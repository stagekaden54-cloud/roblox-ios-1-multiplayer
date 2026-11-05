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
- [ ] Simple blocky character model
- [ ] Name tag above character
- [ ] Local player vs other player distinction
- [ ] Basic color support

### 3. Core Animations
- [ ] Idle
- [ ] Walk
- [ ] Jump
- [ ] Fall / Land
- [ ] Animation state driven by movement
- [ ] Networked animation state so others see the correct animation

### 4. Camera
- [ ] Third-person follow camera
- [ ] Smooth spring / lag
- [ ] Rotate via touch / mouse
- [ ] Limited zoom

### 5. Movement
- [ ] Walk with light acceleration
- [ ] Jump
- [ ] Basic gravity
- [ ] Simple ground collision
- [ ] Responsive controls (touch + keyboard/mouse)

### 6. Multiplayer Sync
- [x] Server stores position + animation state
- [x] 20Hz snapshot broadcasting
- [x] Client can send state updates
- [x] Client receives presence + snapshots
- [ ] Client-side interpolation for remote players
- [x] Join / leave still works cleanly

### 7. UI Foundation
- [x] Welcome / guest join screen
- [x] Lobby + chat
- [ ] In-game HUD
- [ ] Smooth UI transitions
- [x] Clear connection status

---

## Phase 2 — Advanced (Paused)

These will not be started until Phase 1 is in a good state and explicitly approved:

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

- **Server**: Node.js + WebSocket (now with state + snapshots)
- **Client**: Swift + UIKit
- Future consideration: C++ or Rust core for simulation + networking

---

## Rules for this phase

- Prefer working, feel-good basics over incomplete advanced systems
- Keep the protocol clean and explicit
- Do not add account systems or external services yet
- Keep the project independent from official Roblox services
