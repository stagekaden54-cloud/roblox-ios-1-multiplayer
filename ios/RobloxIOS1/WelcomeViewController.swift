import UIKit

final class WelcomeViewController: UIViewController {
    private let nameField = UITextField()
    private let serverField = UITextField()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ClassicTheme.background
        buildInterface()
    }

    private func buildInterface() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = 18
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 34),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 22),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -22),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -28)
        ])

        let wordmark = UILabel()
        wordmark.text = "ROBLOX"
        wordmark.font = .systemFont(ofSize: 37, weight: .black)
        wordmark.textColor = ClassicTheme.darkBlue
        wordmark.textAlignment = .center
        content.addArrangedSubview(wordmark)

        let subtitle = UILabel()
        subtitle.text = "A classic mobile experience"
        subtitle.font = .systemFont(ofSize: 14)
        subtitle.textColor = ClassicTheme.muted
        subtitle.textAlignment = .center
        content.addArrangedSubview(subtitle)

        let panel = ClassicTheme.makePanel()
        let panelStack = UIStackView()
        panelStack.axis = .vertical
        panelStack.spacing = 12
        panelStack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(panelStack)
        NSLayoutConstraint.activate([
            panelStack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 18),
            panelStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            panelStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            panelStack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -18)
        ])

        let heading = UILabel()
        heading.text = "Welcome"
        heading.font = .boldSystemFont(ofSize: 22)
        heading.textColor = ClassicTheme.text
        panelStack.addArrangedSubview(heading)

        let explanation = UILabel()
        explanation.text = "Join the experiment as a guest. This connects only to the independent test server—not to Roblox accounts or services."
        explanation.font = .systemFont(ofSize: 14)
        explanation.textColor = ClassicTheme.muted
        explanation.numberOfLines = 0
        panelStack.addArrangedSubview(explanation)

        ClassicTheme.styleTextField(nameField, placeholder: "Guest display name")
        nameField.text = "Guest"
        nameField.returnKeyType = .done
        panelStack.addArrangedSubview(nameField)

        ClassicTheme.styleTextField(serverField, placeholder: "WebSocket server address")
        serverField.text = "ws://127.0.0.1:8080"
        serverField.keyboardType = .URL
        serverField.autocorrectionType = .no
        panelStack.addArrangedSubview(serverField)

        let connectButton = ClassicTheme.makeButton(title: "PLAY AS GUEST")
        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        panelStack.addArrangedSubview(connectButton)

        statusLabel.text = "Prototype build • Guest access"
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = ClassicTheme.muted
        statusLabel.textAlignment = .center
        panelStack.addArrangedSubview(statusLabel)

        content.addArrangedSubview(panel)

        let footer = UILabel()
        footer.text = "Independent preservation experiment"
        footer.font = .systemFont(ofSize: 12)
        footer.textColor = ClassicTheme.muted
        footer.textAlignment = .center
        content.addArrangedSubview(footer)
    }

    @objc private func connectTapped() {
        view.endEditing(true)
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let address = (serverField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            showAlert("Display name required", "Enter a guest display name to continue.")
            return
        }
        guard name.count <= 20 else {
            showAlert("Name too long", "Guest display names can be up to 20 characters.")
            return
        }
        guard let url = URL(string: address),
              let scheme = url.scheme?.lowercased(),
              (scheme == "ws" || scheme == "wss"),
              url.host != nil else {
            showAlert("Invalid server address", "Use a WebSocket address such as ws://192.168.1.25:8080.")
            return
        }

        let lobby = LobbyViewController(serverAddress: address, displayName: name)
        navigationController?.pushViewController(lobby, animated: true)
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
