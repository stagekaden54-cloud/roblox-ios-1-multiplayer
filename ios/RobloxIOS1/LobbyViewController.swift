import UIKit

final class LobbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private let serverAddress: String
    private let displayName: String
    private let client = MultiplayerClient()
    private var players: [LobbyPlayer] = []
    private var lines: [String] = []
    private var connectionLabel = UILabel()
    private let playersTable = UITableView(frame: .zero, style: .plain)
    private let chatView = UITextView()
    private let messageField = UITextField()

    init(serverAddress: String, displayName: String) {
        self.serverAddress = serverAddress
        self.displayName = displayName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ClassicTheme.background
        title = "Lobby"
        buildInterface()
        client.onEvent = { [weak self] event in self?.handle(event) }

        do {
            try client.connect(serverAddress: serverAddress, displayName: displayName)
            connectionLabel.text = "Connecting…"
        } catch {
            connectionLabel.text = "Connection failed"
            appendLine(error.localizedDescription)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            client.disconnect()
        }
    }

    private func buildInterface() {
        let header = UIStackView()
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)

        let titleLabel = UILabel()
        titleLabel.text = "GAMES"
        titleLabel.font = .boldSystemFont(ofSize: 23)
        titleLabel.textColor = ClassicTheme.darkBlue
        header.addArrangedSubview(titleLabel)

        let spacer = UIView()
        header.addArrangedSubview(spacer)

        let backButton = UIButton(type: .system)
        backButton.setTitle("BACK", for: .normal)
        backButton.titleLabel?.font = .boldSystemFont(ofSize: 13)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        header.addArrangedSubview(backButton)

        connectionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        connectionLabel.textColor = ClassicTheme.muted
        connectionLabel.text = "Starting connection…"

        let playersHeading = sectionHeading("PLAYERS IN SERVER")
        playersTable.dataSource = self
        playersTable.delegate = self
        playersTable.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
        playersTable.rowHeight = 42
        playersTable.backgroundColor = .white
        playersTable.layer.borderWidth = 1
        playersTable.layer.borderColor = ClassicTheme.border.cgColor
        playersTable.heightAnchor.constraint(equalToConstant: 132).isActive = true

        let chatHeading = sectionHeading("SERVER CHAT")
        chatView.isEditable = false
        chatView.font = .systemFont(ofSize: 13)
        chatView.textColor = ClassicTheme.text
        chatView.backgroundColor = .white
        chatView.layer.borderWidth = 1
        chatView.layer.borderColor = ClassicTheme.border.cgColor
        chatView.layer.cornerRadius = 3
        chatView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        ClassicTheme.styleTextField(messageField, placeholder: "Write a message…")
        messageField.delegate = self
        messageField.returnKeyType = .send

        let sendButton = ClassicTheme.makeButton(title: "SEND")
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        let messageRow = UIStackView(arrangedSubviews: [messageField, sendButton])
        messageRow.axis = .horizontal
        messageRow.spacing = 8
        messageField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sendButton.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [
            header, connectionLabel, playersHeading, playersTable,
            chatHeading, chatView, messageRow
        ])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -12)
        ])
    }

    private func sectionHeading(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .boldSystemFont(ofSize: 13)
        label.textColor = ClassicTheme.text
        return label
    }

    private func handle(_ event: MultiplayerClient.Event) {
        switch event {
        case .connected(_, let roomID):
            connectionLabel.text = "Connected • Room: \(roomID)"
            appendLine("Welcome, \(displayName)!")

        case .presence(let currentPlayers):
            players = currentPlayers
            playersTable.reloadData()

        case .snapshot(let currentPlayers):
            // Keep lobby list fresh when snapshots arrive
            players = currentPlayers
            playersTable.reloadData()

        case .playerJoined(let player):
            appendLine("\(player.displayName) joined the server.")

        case .playerLeft(let id):
            if let player = players.first(where: { $0.id == id }) {
                appendLine("\(player.displayName) left the server.")
            }

        case .chat(let message):
            appendLine("\(message.displayName): \(message.text)")

        case .error(let message):
            appendLine("Notice: \(message)")

        case .disconnected:
            connectionLabel.text = "Disconnected"
        }
    }

    private func appendLine(_ line: String) {
        lines.append(line)
        if lines.count > 150 {
            lines.removeFirst(lines.count - 150)
        }
        chatView.text = lines.joined(separator: "\n")
        let end = NSRange(location: max(chatView.text.utf16.count - 1, 0), length: 1)
        if chatView.text.utf16.count > 0 {
            chatView.scrollRangeToVisible(end)
        }
    }

    @objc private func sendTapped() {
        client.sendChat(messageField.text ?? "")
        messageField.text = ""
    }

    @objc private func backTapped() {
        client.disconnect()
        navigationController?.popViewController(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendTapped()
        return true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        players.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = players[indexPath.row].displayName
        content.textProperties.font = .systemFont(ofSize: 14)
        content.image = UIImage(systemName: "person.circle.fill")
        content.imageProperties.tintColor = ClassicTheme.blue
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        return cell
    }
}
