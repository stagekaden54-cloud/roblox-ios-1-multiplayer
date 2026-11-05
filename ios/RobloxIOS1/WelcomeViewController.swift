import UIKit

/// Classic Roblox-inspired mobile home screen.
final class WelcomeViewController: UIViewController {

    private let nameField = UITextField()
    private let serverField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.94, alpha: 1)
        navigationController?.setNavigationBarHidden(true, animated: false)
        buildInterface()
    }

    private func buildInterface() {
        // Top blue bar (classic Roblox style)
        let topBar = UIView()
        topBar.backgroundColor = UIColor(red: 0.05, green: 0.40, blue: 0.73, alpha: 1)
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)

        let logo = UILabel()
        logo.text = "ROBLOX"
        logo.font = .systemFont(ofSize: 20, weight: .black)
        logo.textColor = .white
        logo.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(logo)

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        view.addSubview(scroll)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        // Hello header
        let helloRow = UIStackView()
        helloRow.axis = .horizontal
        helloRow.spacing = 12
        helloRow.alignment = .center

        let avatar = UIView()
        avatar.backgroundColor = UIColor(red: 0.20, green: 0.55, blue: 0.90, alpha: 1)
        avatar.layer.cornerRadius = 28
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 56),
            avatar.heightAnchor.constraint(equalToConstant: 56)
        ])

        let avatarLabel = UILabel()
        avatarLabel.text = "🙂"
        avatarLabel.font = .systemFont(ofSize: 26)
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatar.addSubview(avatarLabel)
        NSLayoutConstraint.activate([
            avatarLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])

        let helloStack = UIStackView()
        helloStack.axis = .vertical
        helloStack.spacing = 2

        let helloLabel = UILabel()
        helloLabel.text = "Hello,"
        helloLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        helloLabel.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)

        let subHello = UILabel()
        subHello.text = "Guest access • Independent server"
        subHello.font = .systemFont(ofSize: 13)
        subHello.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1)

        helloStack.addArrangedSubview(helloLabel)
        helloStack.addArrangedSubview(subHello)

        helloRow.addArrangedSubview(avatar)
        helloRow.addArrangedSubview(helloStack)

        // Join card
        let joinCard = makeCard()
        let joinStack = UIStackView()
        joinStack.axis = .vertical
        joinStack.spacing = 12
        joinStack.translatesAutoresizingMaskIntoConstraints = false
        joinCard.addSubview(joinStack)

        let joinTitle = UILabel()
        joinTitle.text = "Play"
        joinTitle.font = .systemFont(ofSize: 18, weight: .bold)
        joinTitle.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)

        styleField(nameField, placeholder: "Display name")
        nameField.text = "Guest"

        styleField(serverField, placeholder: "Server address (ws://...)")
        serverField.text = "ws://127.0.0.1:8080"
        serverField.keyboardType = .URL
        serverField.autocapitalizationType = .none
        serverField.autocorrectionType = .no

        let playButton = UIButton(type: .system)
        playButton.setTitle("ENTER WORLD", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        playButton.backgroundColor = UIColor(red: 0.05, green: 0.40, blue: 0.73, alpha: 1)
        playButton.layer.cornerRadius = 8
        playButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

        let lobbyButton = UIButton(type: .system)
        lobbyButton.setTitle("Open Lobby Only", for: .normal)
        lobbyButton.setTitleColor(UIColor(red: 0.05, green: 0.40, blue: 0.73, alpha: 1), for: .normal)
        lobbyButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        lobbyButton.addTarget(self, action: #selector(lobbyTapped), for: .touchUpInside)

        joinStack.addArrangedSubview(joinTitle)
        joinStack.addArrangedSubview(nameField)
        joinStack.addArrangedSubview(serverField)
        joinStack.addArrangedSubview(playButton)
        joinStack.addArrangedSubview(lobbyButton)

        NSLayoutConstraint.activate([
            joinStack.topAnchor.constraint(equalTo: joinCard.topAnchor, constant: 16),
            joinStack.leadingAnchor.constraint(equalTo: joinCard.leadingAnchor, constant: 16),
            joinStack.trailingAnchor.constraint(equalTo: joinCard.trailingAnchor, constant: -16),
            joinStack.bottomAnchor.constraint(equalTo: joinCard.bottomAnchor, constant: -16)
        ])

        // Continue Playing style section
        let continueTitle = sectionTitle("Continue Playing")

        let gamesRow = UIScrollView()
        gamesRow.showsHorizontalScrollIndicator = false
        gamesRow.translatesAutoresizingMaskIntoConstraints = false

        let gamesStack = UIStackView()
        gamesStack.axis = .horizontal
        gamesStack.spacing = 12
        gamesStack.translatesAutoresizingMaskIntoConstraints = false
        gamesRow.addSubview(gamesStack)

        let gameNames = ["Baseplate", "Obby", "Plaza", "Classic"]
        let gameColors: [UIColor] = [
            UIColor(red: 0.45, green: 0.70, blue: 0.35, alpha: 1),
            UIColor(red: 0.90, green: 0.45, blue: 0.25, alpha: 1),
            UIColor(red: 0.25, green: 0.55, blue: 0.85, alpha: 1),
            UIColor(red: 0.70, green: 0.40, blue: 0.80, alpha: 1)
        ]

        for (i, name) in gameNames.enumerated() {
            gamesStack.addArrangedSubview(makeGameCard(title: name, color: gameColors[i]))
        }

        NSLayoutConstraint.activate([
            gamesStack.topAnchor.constraint(equalTo: gamesRow.topAnchor),
            gamesStack.leadingAnchor.constraint(equalTo: gamesRow.leadingAnchor),
            gamesStack.trailingAnchor.constraint(equalTo: gamesRow.trailingAnchor),
            gamesStack.bottomAnchor.constraint(equalTo: gamesRow.bottomAnchor),
            gamesStack.heightAnchor.constraint(equalTo: gamesRow.heightAnchor),
            gamesRow.heightAnchor.constraint(equalToConstant: 120)
        ])

        let note = UILabel()
        note.text = "This is an independent multiplayer experiment.\nNot affiliated with Roblox."
        note.font = .systemFont(ofSize: 12)
        note.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1)
        note.numberOfLines = 0
        note.textAlignment = .center

        content.addArrangedSubview(helloRow)
        content.addArrangedSubview(joinCard)
        content.addArrangedSubview(continueTitle)
        content.addArrangedSubview(gamesRow)
        content.addArrangedSubview(note)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),

            logo.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            logo.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -12),

            scroll.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    private func makeCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.06
        card.layer.shadowRadius = 6
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        return card
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)
        return label
    }

    private func makeGameCard(title: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false

        let thumb = UIView()
        thumb.backgroundColor = color
        thumb.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(thumb)
        card.addSubview(label)

        NSLayoutConstraint.activate([
            card.widthAnchor.constraint(equalToConstant: 110),
            card.heightAnchor.constraint(equalToConstant: 120),

            thumb.topAnchor.constraint(equalTo: card.topAnchor),
            thumb.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            thumb.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            thumb.heightAnchor.constraint(equalToConstant: 84),

            label.topAnchor.constraint(equalTo: thumb.bottomAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4)
        ])

        return card
    }

    private func styleField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1)
        field.layer.cornerRadius = 8
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.font = .systemFont(ofSize: 16)
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func validatedCredentials() -> (name: String, address: String)? {
        view.endEditing(true)
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let address = (serverField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else {
            showAlert("Display name required", "Enter a guest display name to continue.")
            return nil
        }
        guard name.count <= 20 else {
            showAlert("Name too long", "Guest display names can be up to 20 characters.")
            return nil
        }
        guard let url = URL(string: address),
              let scheme = url.scheme?.lowercased(),
              (scheme == "ws" || scheme == "wss"),
              url.host != nil else {
            showAlert("Invalid server address", "Use a WebSocket address such as ws://192.168.1.25:8080.")
            return nil
        }
        return (name, address)
    }

    @objc private func playTapped() {
        guard let creds = validatedCredentials() else { return }
        let game = GameViewController(serverAddress: creds.address, displayName: creds.name)
        navigationController?.pushViewController(game, animated: true)
    }

    @objc private func lobbyTapped() {
        guard let creds = validatedCredentials() else { return }
        let lobby = LobbyViewController(serverAddress: creds.address, displayName: creds.name)
        navigationController?.pushViewController(lobby, animated: true)
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
