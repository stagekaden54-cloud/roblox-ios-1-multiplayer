# iOS client

This folder contains the first native UIKit reconstruction for the project. It targets iOS 15+ and uses Swift with programmatic UIKit views.

## Open in Xcode

1. Open `RobloxIOS1.xcodeproj`.
2. Select the `RobloxIOS1` scheme.
3. Choose an iPhone simulator or connected iPhone.
4. Build and run.

No storyboard, third-party package, or external image assets are required.

## Connect to the multiplayer server

The welcome screen defaults to `ws://127.0.0.1:8080`. That address means the iPhone itself, so it will not reach a server running on a separate computer.

For a same-Wi-Fi test, run the server on the computer with:

```sh
HOST=0.0.0.0 npm start
```

Then enter the computer's LAN IP address in the app, for example `ws://192.168.1.25:8080`. Replace the example with the computer's actual local address. Both devices must be on the same trusted network. The prototype server is not intended for public internet hosting.

## Current scope

- Classic-inspired welcome screen and guest entry
- Configurable WebSocket address
- Live lobby presence list
- Lobby chat
- Connection and server error feedback

The app does not authenticate with Roblox and does not modify or embed the historical IPA. The interface is a first-pass recreation inspired by the era, not a pixel-perfect copy. Original historical artwork can be considered separately if its provenance and usage rights are clear.
