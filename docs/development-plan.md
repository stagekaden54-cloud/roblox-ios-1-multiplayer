# Development plan

## Phase 0 — Repository and preservation

- [x] Create a private repository.
- [x] Add project architecture and development notes.
- [ ] Keep an untouched backup of the supplied historical IPA outside source control.
- [ ] Record provenance and hashes for files used during analysis.

## Phase 1 — Server prototype

- [x] Create a WebSocket server scaffold.
- [ ] Test two local clients joining the same room.
- [ ] Add heartbeat and stale-session cleanup.
- [ ] Add basic rate limiting and message-size limits.
- [ ] Add automated tests for join, leave, presence, and chat.

## Phase 2 — Client foundation

- [ ] Decide whether to use a native Swift app or a carefully scoped Objective-C/Swift reconstruction.
- [ ] Recreate a small set of historical screens using original resources where permitted.
- [ ] Add a connection screen and guest display name.
- [ ] Connect to the custom WebSocket protocol.

## Phase 3 — Multiplayer prototype

- [ ] Add room selection and player presence UI.
- [ ] Add chat UI with safe text handling.
- [ ] Build a simple independent 3D test scene.
- [ ] Add server-authoritative position updates only after the 3D scene exists.

## Phase 4 — iOS packaging

- [ ] Build for a supported 64-bit iOS target.
- [ ] Test on a device with a development-signed build.
- [ ] Package and sign a test IPA.
- [ ] Document ESign installation steps after the build is validated.

## Scope guardrails

This is an independent multiplayer experiment, not an attempt to impersonate Roblox services or use real Roblox credentials. Preserve the original IPA and make changes in a separate project.
