import Foundation

struct LobbyPlayer: Equatable {
    let id: String
    let displayName: String
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    var rotY: Double = 0
    var anim: String = "idle"
}

struct LobbyChatMessage {
    let playerID: String
    let displayName: String
    let text: String
}

@MainActor
final class MultiplayerClient {
    enum Event {
        case connected(playerID: String, roomID: String)
        case presence([LobbyPlayer])
        case snapshot([LobbyPlayer])
        case playerJoined(LobbyPlayer)
        case playerLeft(String)
        case chat(LobbyChatMessage)
        case error(String)
        case disconnected
    }

    var onEvent: ((Event) -> Void)?

    private var webSocket: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private(set) var localPlayerID: String?

    func connect(serverAddress: String, displayName: String) throws {
        guard let url = URL(string: serverAddress),
              let scheme = url.scheme?.lowercased(),
              scheme == "ws" || scheme == "wss",
              url.host != nil else {
            throw ClientError.invalidAddress
        }

        disconnect()

        let session = URLSession(configuration: .default)
        let task = session.webSocketTask(with: url)
        webSocket = task
        task.resume()

        let joinObject: [String: String] = [
            "type": "join",
            "displayName": displayName
        ]

        guard let joinData = try? JSONSerialization.data(withJSONObject: joinObject),
              let joinText = String(data: joinData, encoding: .utf8) else {
            throw ClientError.invalidAddress
        }

        receiveTask = Task { [weak self] in
            guard let self, let activeSocket = self.webSocket else { return }
            do {
                try await activeSocket.send(.string(joinText))
                await self.receiveMessages()
            } catch {
                if !Task.isCancelled {
                    self.onEvent?(.error("Connection failed: \(error.localizedDescription)"))
                    self.onEvent?(.disconnected)
                }
            }
        }
    }

    /// Send local player state (position + animation) to the server.
    func sendState(x: Double, y: Double, z: Double, rotY: Double, anim: String) {
        let payload: [String: Any] = [
            "type": "state",
            "x": x,
            "y": y,
            "z": z,
            "rotY": rotY,
            "anim": anim
        ]
        sendJSON(payload)
    }

    func sendChat(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        sendJSON([
            "type": "chat",
            "text": String(trimmed.prefix(240))
        ])
    }

    func disconnect() {
        receiveTask?.cancel()
        receiveTask = nil
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        localPlayerID = nil
    }

    // MARK: - Private

    private func sendJSON(_ object: [String: Any]) {
        guard let webSocket,
              let data = try? JSONSerialization.data(withJSONObject: object),
              let text = String(data: data, encoding: .utf8) else { return }

        webSocket.send(.string(text)) { [weak self] error in
            guard let error else { return }
            Task { @MainActor in
                self?.onEvent?(.error("Couldn't send the message: \(error.localizedDescription)"))
            }
        }
    }

    private func receiveMessages() async {
        while !Task.isCancelled, let webSocket {
            do {
                let message = try await webSocket.receive()
                switch message {
                case .string(let text):
                    handle(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        handle(text)
                    }
                @unknown default:
                    break
                }
            } catch {
                if !Task.isCancelled {
                    onEvent?(.error("Connection ended: \(error.localizedDescription)"))
                    onEvent?(.disconnected)
                }
                return
            }
        }
    }

    private func handle(_ text: String) {
        guard let data = text.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = object["type"] as? String else { return }

        switch type {
        case "welcome":
            let playerID = object["playerId"] as? String ?? ""
            localPlayerID = playerID
            onEvent?(.connected(
                playerID: playerID,
                roomID: object["roomId"] as? String ?? "lobby"
            ))

        case "presence":
            onEvent?(.presence(parsePlayers(object["players"])))

        case "snapshot":
            onEvent?(.snapshot(parsePlayers(object["players"])))

        case "player-joined":
            if let item = object["player"] as? [String: Any],
               let player = parsePlayer(item) {
                onEvent?(.playerJoined(player))
            }

        case "player-left":
            if let id = object["playerId"] as? String {
                onEvent?(.playerLeft(id))
            }

        case "chat":
            if let id = object["playerId"] as? String,
               let name = object["displayName"] as? String,
               let message = object["text"] as? String {
                onEvent?(.chat(LobbyChatMessage(
                    playerID: id,
                    displayName: name,
                    text: message
                )))
            }

        case "error":
            onEvent?(.error(object["message"] as? String ?? "The server rejected a request."))

        default:
            break
        }
    }

    private func parsePlayers(_ raw: Any?) -> [LobbyPlayer] {
        guard let array = raw as? [[String: Any]] else { return [] }
        return array.compactMap { parsePlayer($0) }
    }

    private func parsePlayer(_ item: [String: Any]) -> LobbyPlayer? {
        guard let id = item["id"] as? String,
              let name = item["displayName"] as? String else { return nil }

        return LobbyPlayer(
            id: id,
            displayName: name,
            x: item["x"] as? Double ?? 0,
            y: item["y"] as? Double ?? 0,
            z: item["z"] as? Double ?? 0,
            rotY: item["rotY"] as? Double ?? 0,
            anim: item["anim"] as? String ?? "idle"
        )
    }

    enum ClientError: LocalizedError {
        case invalidAddress

        var errorDescription: String? {
            "Enter a valid WebSocket address beginning with ws:// or wss://."
        }
    }
}
