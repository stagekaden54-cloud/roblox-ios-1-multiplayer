# Roblox iOS 1.0 — Multiplayer Experiment

An independent preservation and learning project exploring a modern, custom multiplayer companion for the historical Roblox iOS 1.0 app.

This project is **not an official Roblox product** and does not connect to Roblox production services. The multiplayer backend and protocol are original implementations for controlled testing.

## Project status

Early scaffold. The repository currently contains the project plan and a small WebSocket prototype for guest sessions, rooms, presence, and chat. A compatible iOS client and 3D gameplay layer have not been implemented yet.

## Repository layout

- `docs/architecture.md` — system design and message protocol
- `docs/development-plan.md` — staged implementation roadmap
- `multiplayer-server/` — Node.js WebSocket prototype

## Quick start

Requires Node.js 20 or newer.

```sh
cd multiplayer-server
npm install
npm start
```

The server listens on port 8080 by default. Connect a WebSocket client to `ws://localhost:8080`.

## Important notes

- Keep the original IPA unchanged and backed up separately.
- The original app executable is 32-bit; modern iPhones require a 64-bit rebuild or port.
- Do not put Apple signing certificates, private keys, passwords, or personal credentials in this repository.
- Use test display names and test data only.
