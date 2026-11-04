import WebSocket from "ws";

const url = process.env.SERVER_URL ?? "ws://127.0.0.1:8080";

function connectGuest(displayName) {
  return new Promise((resolve, reject) => {
    const socket = new WebSocket(url);
    socket.once("open", () => {
      socket.on("message", (raw) => {
        try {
          console.log("[" + displayName + "]", JSON.parse(raw.toString()));
        } catch {
          console.log("[" + displayName + "] Received a non-JSON message");
        }
      });
      socket.send(JSON.stringify({ type: "join", displayName }));
      resolve(socket);
    });
    socket.once("error", reject);
  });
}

const first = await connectGuest("Demo One");
const second = await connectGuest("Demo Two");

setTimeout(() => {
  first.send(JSON.stringify({ type: "chat", text: "Hello from Demo One!" }));
}, 250);

setTimeout(() => {
  second.send(JSON.stringify({ type: "chat", text: "Demo Two received you." }));
}, 500);

setTimeout(() => {
  first.close();
  second.close();
}, 1500);
