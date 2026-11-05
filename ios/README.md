# iOS Client

Native Swift + UIKit client for the multiplayer experiment.

Target: iOS 15+

## Open in Xcode

1. Open `RobloxIOS1.xcodeproj`
2. Select the `RobloxIOS1` scheme
3. Choose an iPhone simulator or device
4. Build and run

## Connect to the server

The welcome screen defaults to `ws://127.0.0.1:8080`.

For testing with a server on your computer:

```sh
cd multiplayer-server
HOST=0.0.0.0 npm start
```

Then enter your computer’s LAN address in the app, for example:

```
ws://192.168.1.25:8080
```

## Current Scope (Foundation Phase)

**Done**
- Guest welcome / join screen
- Configurable WebSocket address
- Lobby presence list
- Chat
- Connection status and basic error handling

**Next (Foundation)**
- Stronger session / connection flow
- Basic blocky character
- Core animations (idle, walk, jump, fall)
- Third-person camera
- Local movement
- Multiplayer position + animation sync
- Cleaner in-game UI foundation

## Style Direction

Nostalgic + modern:
- Blocky character language
- Clean early-mobile inspired UI
- Smooth camera and animation feel

See `docs/art-direction.md` and `docs/development-plan.md` for full details.

## Notes

- This is an independent modern client
- It does not embed or modify any historical IPA
- No Roblox accounts or official services are used
