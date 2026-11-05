# Building an Unsigned IPA (No Mac Required)

This project includes a GitHub Action that builds an **unsigned IPA** on a cloud Mac runner. You can then sign and install it on your iPhone with your existing tools.

## How to get the IPA

### Option A — Automatic (on push)
Any push that changes files under `ios/` will trigger the workflow.

### Option B — Manual
1. Open the repo on GitHub
2. Go to **Actions**
3. Select **Build Unsigned IPA**
4. Click **Run workflow**
5. Wait for it to finish
6. Download the artifact named `RobloxIOS1-unsigned-ipa`

## After you download the IPA

1. Transfer `RobloxIOS1-unsigned.ipa` to your iPhone
2. Sign it with your preferred tool (ESign, Scarlet, etc.)
3. Install it
4. Run the local multiplayer server on a computer (or host it somewhere reachable)
5. In the app, enter the server address and tap **ENTER WORLD**

## Server reminder

```sh
cd multiplayer-server
npm install
HOST=0.0.0.0 npm start
```

Then use your computer’s LAN IP, for example:

```
ws://192.168.1.25:8080
```

## Notes

- The IPA is intentionally **unsigned**
- You must sign it yourself before installing
- Local network permission is already declared in Info.plist
- This workflow does not use any Apple Developer certificate
