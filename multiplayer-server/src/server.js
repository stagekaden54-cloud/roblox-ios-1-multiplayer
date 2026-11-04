import { randomUUID } from "node:crypto";
import { WebSocketServer, WebSocket } from "ws";

const PORT = Number(process.env.PORT ?? 8080);
const MAX_MESSAGE_BYTES = 4 * 1024;
const MAX_CHAT_LENGTH = 240;
const ROOM_ID = "lobby";

const wss = new WebSocketServer({
  port: PORT,
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

function cleanDisplayName(value) {
  if (typeof value !== "string") return "Guest";
  const cleaned = value.replace(/[<>\u0000-\u001f]/g, "").trim().slice(0, 20);
  return cleaned || "Guest";
}

wss.on("connection", (socket) => {
  const player = {
    id: randomUUID(),
    displayName: "Guest",
    joined: false
  };

  function fail(message) {
    send(socket, { type: "error", message });
  }

  socket.on("message", (buffer) => {
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
      send(socket, { type: "presence", players: roomPlayers() });
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
      const text = message.text.trim().slice(0, MAX_CHAT_LENGTH);
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

wss.on("listening", () => {
  console.log(`Multiplayer prototype listening on ws://localhost:${PORT}`);
});
