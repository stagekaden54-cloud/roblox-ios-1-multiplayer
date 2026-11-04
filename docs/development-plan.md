# Development plan

## Phase 0 — Repository and preservation

- [x] Create a private repository.
- [x] Add project architecture and development notes.
- [ ] Keep an untouched backup of the supplied historical IPA outside source control.
- [ ] Record provenance and hashes for files used during analysis.

## Phase 1 — Local server prototype

- [x] Create a WebSocket server scaffold.
- [x] Add a two-client integration test for joining, presence, chat, and leaving.
- [x] Add heartbeat ping/pong and stale-session cleanup.
- [x] Add message-size limits and basic message/chat rate limits.
- [x] Add automated tests for core lobby behavior and invalid message types.
- [x] Add a manual two-client demo command.
- [ ] Install dependencies and run the automated test suite on a machine with network access.
- [ ] Add configurable room capacity and explicit room creation.
- [ ] Add structured logging and deployment-grade graceful shutdown.

## Phase 2 — Client foundation

- [ ] Decide whether to use a native Swift app or a carefully scoped Objective-C/Swift reconstruction.
- [ ] Recreate a small set of historical screens using original resources where permitted.
- [ ] Add a connection screen and guest display name.
- [ ] Connect to the custom WebSocket protocol.
- [ ] Test the client against the local server.

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

## Security and release gate

Do not expose this prototype publicly yet. Before any public deployment, add TLS/WSS, a deliberate origin policy, connection and room limits, stronger abuse controls, moderation/reporting, operational monitoring, and a privacy review. Never collect Roblox passwords, cookies, or tokens.

## Scope guardrails

This is an independent multiplayer experiment, not an attempt to impersonate Roblox services or use real Roblox credentials. Preserve the original IPA and make changes in a separate project.
