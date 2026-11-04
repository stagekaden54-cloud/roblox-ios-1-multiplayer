import UIKit

enum ClassicTheme {
    static let background = UIColor(red: 0.91, green: 0.92, blue: 0.93, alpha: 1)
    static let panel = UIColor.white
    static let border = UIColor(red: 0.70, green: 0.72, blue: 0.75, alpha: 1)
    static let blue = UIColor(red: 0.16, green: 0.42, blue: 0.69, alpha: 1)
    static let darkBlue = UIColor(red: 0.10, green: 0.29, blue: 0.50, alpha: 1)
    static let text = UIColor(red: 0.18, green: 0.20, blue: 0.23, alpha: 1)
    static let muted = UIColor(red: 0.43, green: 0.46, blue: 0.49, alpha: 1)

    static func makePanel() -> UIView {
        let view = UIView()
        view.backgroundColor = panel
        view.layer.borderColor = border.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        return view
    }

    static func makeButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = blue
        config.baseForegroundColor = .white
        config.cornerStyle = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return button
    }

    static func styleTextField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.backgroundColor = .white
        field.textColor = text
        field.font = .systemFont(ofSize: 16)
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}
