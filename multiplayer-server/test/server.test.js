import test from "node:test";
import assert from "node:assert/strict";
import WebSocket from "ws";
import { createMultiplayerServer } from "../src/server.js";

function waitFor(socket, type, timeoutMs = 2000) {
  return new Promise((resolve, reject) => {
    const timeout = setTimeout(() => {
      socket.off("message", onMessage);
      reject(new Error("Timed out waiting for " + type));
    }, timeoutMs);

    function onMessage(raw) {
      let payload;
      try {
        payload = JSON.parse(raw.toString());
      } catch {
        return;
      }
      if (payload.type === type) {
        clearTimeout(timeout);
        socket.off("message", onMessage);
        resolve(payload);
      }
    }

    socket.on("message", onMessage);
  });
}

async function startTestServer() {
  const server = createMultiplayerServer({
    port: 0,
    host: "127.0.0.1",
    heartbeatIntervalMs: 0,
    snapshotIntervalMs: 0 // disable during tests unless needed
  });

  await new Promise((resolve, reject) => {
    server.wss.once("listening", resolve);
    server.wss.once("error", reject);
  });

  const address = server.wss.address();
  return { server, url: `ws://127.0.0.1:${address.port}` };
}

function connect(url) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(url);
    socket.once("open", () => resolve(socket));
    socket.once("error", reject);
  });
}

function send(socket, payload) {
  socket.send(JSON.stringify(payload));
}

test("two guests join, see presence, chat, and leave", async (t) => {
  const { server, url } = await startTestServer();
  t.after(async () => server.close());

  const first = await connect(url);
  const firstWelcome = waitFor(first, "welcome");
  const firstPresence = waitFor(first, "presence");

  send(first, { type: "join", displayName: "  Player One  " });
  const welcome1 = await firstWelcome;
  assert.equal(welcome1.roomId, "lobby");
  assert.ok(welcome1.playerId);
  assert.equal((await firstPresence).players[0].displayName, "Player One");

  const second = await connect(url);
  const joinedNotice = waitFor(first, "player-joined");
  const secondWelcome = waitFor(second, "welcome");
  const secondPresence = waitFor(second, "presence");

  send(second, { type: "join", displayName: "Player Two" });
  const welcome2 = await secondWelcome;
  assert.equal((await secondPresence).players.length, 2);
  assert.equal((await joinedNotice).player.displayName, "Player Two");

  const chatNotice = waitFor(second, "chat");
  send(first, { type: "chat", text: "Hello from player one" });
  const chat = await chatNotice;
  assert.equal(chat.playerId, welcome1.playerId);
  assert.equal(chat.displayName, "Player One");
  assert.equal(chat.text, "Hello from player one");

  const leftNotice = waitFor(first, "player-left");
  const updatedPresence = waitFor(first, "presence");
  second.close();
  assert.equal((await leftNotice).playerId, welcome2.playerId);
  assert.equal((await updatedPresence).players.length, 1);

  first.close();
});

test("state updates are accepted and reflected in presence shape", async (t) => {
  const { server, url } = await startTestServer();
  t.after(async () => server.close());

  const client = await connect(url);
  const welcome = waitFor(client, "welcome");
  send(client, { type: "join", displayName: "Mover" });
  await welcome;

  send(client, {
    type: "state",
    x: 10,
    y: 0,
    z: -5,
    rotY: 1.57,
    anim: "walk"
  });

  // Give the server a moment to store state
  await new Promise((r) => setTimeout(r, 30));

  // Trigger presence by having another player join
  const other = await connect(url);
  const presence = waitFor(other, "presence");
  send(other, { type: "join", displayName: "Observer" });
  const list = await presence;

  const mover = list.players.find((p) => p.displayName === "Mover");
  assert.ok(mover);
  assert.equal(mover.x, 10);
  assert.equal(mover.z, -5);
  assert.equal(mover.anim, "walk");

  client.close();
  other.close();
});

test("chat burst is rate limited without disconnecting", async (t) => {
  const { server, url } = await startTestServer();
  t.after(async () => server.close());

  const client = await connect(url);
  const welcome = waitFor(client, "welcome");
  send(client, { type: "join", displayName: "Rate Test" });
  await welcome;

  const rateError = waitFor(client, "error");
  for (let i = 0; i < 6; i++) {
    send(client, { type: "chat", text: "message " + i });
  }

  assert.match((await rateError).message, /too quickly/i);
  assert.equal(client.readyState, WebSocket.OPEN);
  client.close();
});

test("unknown message types receive a structured error", async (t) => {
  const { server, url } = await startTestServer();
  t.after(async () => server.close());

  const client = await connect(url);
  const welcome = waitFor(client, "welcome");
  send(client, { type: "join", displayName: "Tester" });
  await welcome;

  const error = waitFor(client, "error");
  send(client, { type: "not-a-real-message" });
  assert.match((await error).message, /unknown message type/i);
  client.close();
});
