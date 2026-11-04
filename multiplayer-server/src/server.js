import { randomUUID } from "node:crypto";
import { WebSocket, WebSocketServer } from "ws";

const MAX_MESSAGE_BYTES = 4 * 1024;
const MAX_CHAT_LENGTH = 240;
const ROOM_ID = "lobby";
const MESSAGE_WINDOW_MS = 10_000;
const MESSAGE_LIMIT = 60;
const CHAT_WINDOW_MS = 5_000;
const CHAT_LIMIT = 5;

function cleanDisplayName(value) {
  if (typeof value !== "string") return "Guest";
  const cleaned = value.replace(/[<>\\u0000-\\u001f\\u007f]/g, "").trim().slice(0, 20);
  return cleaned || "Guest";
}

function cleanChatText(value) {
  if (typeof value !== "string") return "";
  return value.replace(/[\\u0000-\\u0008\\u000b\\u000c\\u000e-\\u001f\\u007f]/g, "")
    .trim()
    .slice(0, MAX_CHAT_LENGTH);
}

function isRateLimited(history, now, windowMs, limit) {
  while (history.length && history[0] <= now - windowMs) history.shift();
  if (history.length >= limit) return true;
  history.push(now);
  return false;
}

/**
 * Create an isolated in-memory multiplayer server.
 * Defaults to loopback so the prototype is not exposed to the public internet.
 */
export function createMultiplayerServer({
  port = Number(process.env.PORT ?? 8080),
  host = process.env.HOST ?? "127.0.0.1",
  heartbeatIntervalMs = 30_000
} = {}) {
  const wss = new WebSocketServer({
    host,
    port,
    maxPayload: MAX_MESSAGE_BYTES
  });
  const players = new Map();

  function send(socket, payload) {
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify(payload));
    }
  }

  function roomPlayers() {
    return [...players.values()].map(({ id, displayName }) => ({ id, displayName }));
  }

  function broadcast(payload, except = null) {
    for (const socket of wss.clients) {
      if (socket !== except) send(socket, payload);
    }
  }

  function sendPresence() {
    broadcast({ type: "presence", players: roomPlayers() });
  }

  wss.on("connection", (socket) => {
    socket.isAlive = true;
    const player = {
      id: randomUUID(),
      displayName: "Guest",
      joined: false,
      messageTimes: [],
      chatTimes: []
    };

    function fail(message) {
      send(socket, { type: "error", message });
    }

    socket.on("pong", () => {
      socket.isAlive = true;
    });

    socket.on("message", (buffer) => {
      const now = Date.now();
      if (isRateLimited(player.messageTimes, now, MESSAGE_WINDOW_MS, MESSAGE_LIMIT)) {
        fail("Too many messages. Slow down and try again.");
        return;
      }

      let message;
      try {
        message = JSON.parse(buffer.toString("utf8"));
      } catch {
        fail("Message must be valid JSON.");
        return;
      }

      if (!message || typeof message !== "object" || Array.isArray(message)) {
        fail("Message must be a JSON object.");
        return;
      }

      if (message.type === "join") {
        if (player.joined) {
          fail("You have already joined the lobby.");
          return;
        }
        player.displayName = cleanDisplayName(message.displayName);
        player.joined = true;
        players.set(player.id, player);
        send(socket, { type: "welcome", playerId: player.id, roomId: ROOM_ID });
        broadcast({
          type: "player-joined",
          player: { id: player.id, displayName: player.displayName }
        }, socket);
        sendPresence();
        return;
      }

      if (!player.joined) {
        fail("Join the lobby before sending this message.");
        return;
      }

      if (message.type === "chat") {
        if (typeof message.text !== "string") {
          fail("Chat text must be a string.");
          return;
        }
        if (isRateLimited(player.chatTimes, now, CHAT_WINDOW_MS, CHAT_LIMIT)) {
          fail("You're sending chat messages too quickly.");
          return;
        }
        const text = cleanChatText(message.text);
        if (!text) return;
        broadcast({
          type: "chat",
          playerId: player.id,
          displayName: player.displayName,
          text
        });
        return;
      }

      if (message.type === "move") {
        fail("Movement messages are reserved until the 3D test scene is implemented.");
        return;
      }

      fail("Unknown message type.");
    });

    socket.on("close", () => {
      if (players.delete(player.id)) {
        broadcast({ type: "player-left", playerId: player.id });
        sendPresence();
      }
    });

    socket.on("error", () => {
      // The close handler performs session cleanup.
    });
  });

  const heartbeat = heartbeatIntervalMs > 0
    ? setInterval(() => {
        for (const socket of wss.clients) {
          if (socket.isAlive === false) {
            socket.terminate();
            continue;
          }
          socket.isAlive = false;
          socket.ping();
        }
      }, heartbeatIntervalMs)
    : null;
  heartbeat?.unref?.();

  return {
    wss,
    async close() {
      if (heartbeat) clearInterval(heartbeat);
      for (const socket of wss.clients) socket.terminate();
      if (wss.clients.size === 0) {
        await new Promise((resolve) => wss.close(resolve));
      } else {
        await new Promise((resolve) => wss.close(resolve));
      }
    }
  };
}

const isMainModule = process.argv[1]
  && new URL(import.meta.url).pathname === new URL(`file://${process.argv[1]}`).pathname;

if (isMainModule) {
  const host = process.env.HOST ?? "127.0.0.1";
  const server = createMultiplayerServer();
  server.wss.on("listening", () => {
    const address = server.wss.address();
    const actualPort = typeof address === "object" && address ? address.port : 8080;
    console.log(`Multiplayer prototype listening on ws://${host}:${actualPort}`);
  });
  server.wss.on("error", (error) => {
    console.error("WebSocket server error:", error);
    process.exitCode = 1;
  });
}
