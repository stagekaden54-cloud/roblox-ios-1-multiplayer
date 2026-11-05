import { randomUUID } from "node:crypto";
import { WebSocket, WebSocketServer } from "ws";

const MAX_MESSAGE_BYTES = 4 * 1024;
const MAX_CHAT_LENGTH = 240;
const ROOM_ID = "lobby";
const MESSAGE_WINDOW_MS = 10_000;
const MESSAGE_LIMIT = 80;
const CHAT_WINDOW_MS = 5_000;
const CHAT_LIMIT = 5;
const STATE_WINDOW_MS = 1_000;
const STATE_LIMIT = 30; // max state updates per second-ish

const DEFAULT_STATE = {
  x: 0,
  y: 0,
  z: 0,
  rotY: 0,
  anim: "idle"
};

function cleanDisplayName(value) {
  if (typeof value !== "string") return "Guest";
  const cleaned = value.replace(/[<>\u0000-\u001f\u007f]/g, "").trim().slice(0, 20);
  return cleaned || "Guest";
}

function cleanChatText(value) {
  if (typeof value !== "string") return "";
  return value.replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/g, "")
    .trim()
    .slice(0, MAX_CHAT_LENGTH);
}

function cleanAnim(value) {
  const allowed = new Set(["idle", "walk", "jump", "fall"]);
  return allowed.has(value) ? value : "idle";
}

function isRateLimited(history, now, windowMs, limit) {
  while (history.length && history[0] <= now - windowMs) history.shift();
  if (history.length >= limit) return true;
  history.push(now);
  return false;
}

function sanitizeState(raw) {
  if (!raw || typeof raw !== "object") return { ...DEFAULT_STATE };

  const num = (v, fallback = 0) =>
    typeof v === "number" && Number.isFinite(v) ? v : fallback;

  return {
    x: num(raw.x),
    y: num(raw.y),
    z: num(raw.z),
    rotY: num(raw.rotY),
    anim: cleanAnim(raw.anim)
  };
}

export function createMultiplayerServer({
  port = Number(process.env.PORT ?? 8080),
  host = process.env.HOST ?? "127.0.0.1",
  heartbeatIntervalMs = 30_000,
  snapshotIntervalMs = 50 // 20 Hz
} = {}) {
  const wss = new WebSocketServer({ host, port, maxPayload: MAX_MESSAGE_BYTES });
  const players = new Map(); // id -> player data

  function send(socket, payload) {
    if (socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify(payload));
    }
  }

  function publicPlayer(player) {
    return {
      id: player.id,
      displayName: player.displayName,
      x: player.state.x,
      y: player.state.y,
      z: player.state.z,
      rotY: player.state.rotY,
      anim: player.state.anim
    };
  }

  function roomPlayers() {
    return [...players.values()].map(publicPlayer);
  }

  function broadcast(payload, except = null) {
    for (const socket of wss.clients) {
      if (socket !== except) send(socket, payload);
    }
  }

  function sendPresence() {
    broadcast({ type: "presence", players: roomPlayers() });
  }

  // Fixed-rate snapshot broadcast for smooth multiplayer
  const snapshotTimer = setInterval(() => {
    if (players.size === 0) return;
    broadcast({
      type: "snapshot",
      roomId: ROOM_ID,
      players: roomPlayers()
    });
  }, snapshotIntervalMs);
  snapshotTimer.unref?.();

  wss.on("connection", (socket) => {
    socket.isAlive = true;

    const player = {
      id: randomUUID(),
      displayName: "Guest",
      joined: false,
      state: { ...DEFAULT_STATE },
      messageTimes: [],
      chatTimes: [],
      stateTimes: []
    };

    const fail = (message) => send(socket, { type: "error", message });

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

      // --- Join ---
      if (message.type === "join") {
        if (player.joined) {
          fail("You have already joined.");
          return;
        }

        player.displayName = cleanDisplayName(message.displayName);
        player.joined = true;
        player.state = { ...DEFAULT_STATE };
        players.set(player.id, player);

        send(socket, {
          type: "welcome",
          playerId: player.id,
          roomId: ROOM_ID,
          state: player.state
        });

        broadcast(
          {
            type: "player-joined",
            player: publicPlayer(player)
          },
          socket
        );

        sendPresence();
        return;
      }

      if (!player.joined) {
        fail("Join before sending this message.");
        return;
      }

      // --- Chat ---
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

      // --- State update (position + animation) ---
      if (message.type === "state") {
        if (isRateLimited(player.stateTimes, now, STATE_WINDOW_MS, STATE_LIMIT)) {
          return; // silently drop excess state updates
        }

        player.state = sanitizeState(message);
        // Authoritative state is stored. Snapshots will broadcast it.
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
      // close handler cleans up
    });
  });

  const heartbeat =
    heartbeatIntervalMs > 0
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
      clearInterval(snapshotTimer);
      if (heartbeat) clearInterval(heartbeat);
      for (const socket of wss.clients) socket.terminate();
      await new Promise((resolve) => wss.close(resolve));
    }
  };
}

const isMainModule =
  process.argv[1] &&
  new URL(import.meta.url).pathname === new URL(`file://${process.argv[1]}`).pathname;

if (isMainModule) {
  const host = process.env.HOST ?? "127.0.0.1";
  const server = createMultiplayerServer();
  server.wss.on("listening", () => {
    const address = server.wss.address();
    const actualPort = typeof address === "object" && address ? address.port : 8080;
    console.log(`Multiplayer server listening on ws://${host}:${actualPort}`);
  });
  server.wss.on("error", (error) => {
    console.error("WebSocket server error:", error);
    process.exitCode = 1;
  });
}
