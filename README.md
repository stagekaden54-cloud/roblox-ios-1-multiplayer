# Roblox iOS 1.0 — Multiplayer Experiment

An independent preservation and learning project exploring a modern, custom multiplayer companion for the historical Roblox iOS 1.0 app.

This project is **not an official Roblox product** and does not connect to Roblox production services. The multiplayer backend and protocol are original implementations for controlled testing.

## Current status

- [x] Repository architecture and staged plan
- [x] Local WebSocket server with temporary guest identities
- [x] One in-memory lobby, presence updates, and chat
- [x] Heartbeat cleanup and basic message/chat rate limits
- [x] Automated tests for two-client join, presence, chat, leave, and error handling
- [x] Manual two-client demo script
- [ ] Native iOS client and 3D test scene
- [ ] Device build and signed IPA

## Requirements

- Node.js 20 or newer
- npm (included with Node.js)

## Run locally

```sh
cd multiplayer-server
npm install
npm test
npm start
```

The server binds to `127.0.0.1:8080` by default, so it is reachable only from the same device/computer. Set `PORT` to change the port. To bind to another interface for a trusted local-network test, set `HOST=0.0.0.0`; do not expose this prototype to the public internet.

In a second terminal, run the two-client demonstration:

```sh
cd multiplayer-server
npm run demo
```

To connect a client on a different device on your local network, use the host computer's LAN address in `SERVER_URL`, for example:

```sh
SERVER_URL=ws://192.168.1.25:8080 npm run demo
```

Replace that example address with the host computer's actual LAN address.

## Protocol

Client messages:

- `{ "type": "join", "displayName": "Guest" }`
- `{ "type": "chat", "text": "Hello" }`

Server messages:

- `welcome` — temporary player ID and room ID
- `presence` — current players in the lobby
- `player-joined` / `player-left` — lobby membership events
- `chat` — chat message with server-assigned player identity
- `error` — rejected or invalid request

Movement is intentionally not implemented until an independent 3D test scene exists.

## Safety and preservation notes

- Keep the original IPA unchanged and backed up separately.
- The historical app binary is not made modern by signing it; a supported 64-bit client must be rebuilt.
- This server uses temporary guest identities, not Roblox accounts.
- Never put Apple signing certificates, private keys, passwords, Roblox cookies, or authentication tokens in this repository.
- The server is a learning prototype, not production-ready. It has no durable accounts, moderation dashboard, TLS deployment, or robust distributed abuse controls.


## Native iOS client

The first Swift + UIKit client scaffold is now under `ios/`.

- Open `ios/RobloxIOS1.xcodeproj` in Xcode.
- Select the `RobloxIOS1` scheme and an iPhone simulator or device.
- See `ios/README.md` for local multiplayer connection instructions.

The client currently includes a classic-inspired guest welcome screen, configurable WebSocket server address, lobby player list, and chat. It is an independent modern app and does not embed or patch the historical IPA. The app has not yet been compiled or device-tested.
