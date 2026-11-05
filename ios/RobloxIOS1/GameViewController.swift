import UIKit
import SceneKit

/// Basic 3D world with local player, camera, movement, and remote player sync.
final class GameViewController: UIViewController {

    private let serverAddress: String
    private let displayName: String
    private let client = MultiplayerClient()

    private var scnView: SCNView!
    private var scene: SCNScene!
    private var localPlayer: PlayerNode?
    private var remotePlayers: [String: PlayerNode] = [:]

    // Movement
    private var moveForward = false
    private var moveBack = false
    private var moveLeft = false
    private var moveRight = false
    private var wantsJump = false

    private var velocityY: Float = 0
    private let gravity: Float = -18
    private let jumpStrength: Float = 7.5
    private let moveSpeed: Float = 5.5

    private var cameraNode = SCNNode()
    private var cameraDistance: Float = 8
    private var cameraYaw: Float = 0
    private var cameraPitch: Float = -0.35

    private var lastUpdate = Date()
    private var stateSendAccumulator: TimeInterval = 0

    // UI
    private let statusLabel = UILabel()
    private let chatButton = UIButton(type: .system)

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
        view.backgroundColor = .black

        setupScene()
        setupCamera()
        setupWorld()
        setupLocalPlayer()
        setupUI()
        setupGestures()

        client.onEvent = { [weak self] event in
            self?.handle(event)
        }

        do {
            try client.connect(serverAddress: serverAddress, displayName: displayName)
            statusLabel.text = "Connecting…"
        } catch {
            statusLabel.text = "Connection failed"
        }

        // Game loop
        let displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink.add(to: .main, forMode: .common)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            client.disconnect()
        }
    }

    // MARK: - Scene Setup

    private func setupScene() {
        scnView = SCNView(frame: view.bounds)
        scnView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scnView.backgroundColor = UIColor(red: 0.55, green: 0.75, blue: 0.95, alpha: 1)
        scnView.allowsCameraControl = false
        scnView.showsStatistics = false
        view.addSubview(scnView)

        scene = SCNScene()
        scnView.scene = scene
        scnView.delegate = self
    }

    private func setupCamera() {
        let camera = SCNCamera()
        camera.fieldOfView = 60
        camera.zNear = 0.1
        camera.zFar = 200
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        scnView.pointOfView = cameraNode
    }

    private func setupWorld() {
        // Simple ground plane (baseplate feel)
        let ground = SCNBox(width: 40, height: 0.5, length: 40, chamferRadius: 0)
        ground.firstMaterial?.diffuse.contents = UIColor(red: 0.45, green: 0.70, blue: 0.35, alpha: 1)
        let groundNode = SCNNode(geometry: ground)
        groundNode.position = SCNVector3(0, -0.25, 0)
        scene.rootNode.addChildNode(groundNode)

        // A few blocky props for reference
        addBlock(at: SCNVector3(4, 0.5, 3), color: .systemOrange)
        addBlock(at: SCNVector3(-3, 0.5, 5), color: .systemPurple)
        addBlock(at: SCNVector3(0, 0.5, -6), color: .systemTeal)

        // Soft lighting
        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 600
        scene.rootNode.addChildNode(ambient)

        let sun = SCNNode()
        sun.light = SCNLight()
        sun.light?.type = .directional
        sun.light?.intensity = 900
        sun.eulerAngles = SCNVector3(-0.8, 0.4, 0)
        scene.rootNode.addChildNode(sun)
    }

    private func addBlock(at position: SCNVector3, color: UIColor) {
        let box = SCNBox(width: 1.2, height: 1.2, length: 1.2, chamferRadius: 0.05)
        box.firstMaterial?.diffuse.contents = color
        let node = SCNNode(geometry: box)
        node.position = position
        scene.rootNode.addChildNode(node)
    }

    private func setupLocalPlayer() {
        let player = PlayerNode(playerID: "local", displayName: displayName, isLocal: true)
        player.position = SCNVector3(0, 0, 0)
        scene.rootNode.addChildNode(player)
        localPlayer = player
    }

    // MARK: - UI

    private func setupUI() {
        statusLabel.font = .systemFont(ofSize: 13, weight: .medium)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        statusLabel.layer.cornerRadius = 8
        statusLabel.clipsToBounds = true
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)

        let back = UIButton(type: .system)
        back.setTitle("Leave", for: .normal)
        back.setTitleColor(.white, for: .normal)
        back.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        back.layer.cornerRadius = 8
        back.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        back.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)
        back.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(back)

        // Simple on-screen controls hint
        let hint = UILabel()
        hint.text = "Drag to look  •  WASD / Arrows to move  •  Space to jump"
        hint.font = .systemFont(ofSize: 11)
        hint.textColor = UIColor.white.withAlphaComponent(0.8)
        hint.textAlignment = .center
        hint.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hint)

        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            statusLabel.heightAnchor.constraint(equalToConstant: 28),

            back.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            back.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            hint.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            hint.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Input

    private func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(pan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: scnView)
        cameraYaw += Float(translation.x) * 0.005
        cameraPitch -= Float(translation.y) * 0.005
        cameraPitch = max(-1.1, min(0.2, cameraPitch))
        gesture.setTranslation(.zero, in: scnView)
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "w", modifierFlags: [], action: #selector(keyDownForward)),
            UIKeyCommand(input: "s", modifierFlags: [], action: #selector(keyDownBack)),
            UIKeyCommand(input: "a", modifierFlags: [], action: #selector(keyDownLeft)),
            UIKeyCommand(input: "d", modifierFlags: [], action: #selector(keyDownRight)),
            UIKeyCommand(input: " ", modifierFlags: [], action: #selector(keyJump)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyDownForward)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyDownBack)),
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: [], action: #selector(keyDownLeft)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(keyDownRight))
        ]
    }

    @objc private func keyDownForward() { moveForward = true }
    @objc private func keyDownBack() { moveBack = true }
    @objc private func keyDownLeft() { moveLeft = true }
    @objc private func keyDownRight() { moveRight = true }
    @objc private func keyJump() { wantsJump = true }

    // Note: key up handling is limited with UIKeyCommand; this is acceptable for foundation.

    @objc private func leaveTapped() {
        client.disconnect()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Networking

    private func handle(_ event: MultiplayerClient.Event) {
        switch event {
        case .connected(let playerID, _):
            statusLabel.text = "Connected"
            localPlayer?.name = "local_\(playerID)"

        case .presence(let players), .snapshot(let players):
            syncRemotePlayers(players)

        case .playerJoined(let player):
            statusLabel.text = "\(player.displayName) joined"

        case .playerLeft(let id):
            if let node = remotePlayers.removeValue(forKey: id) {
                node.removeFromParentNode()
            }

        case .chat:
            break

        case .error(let message):
            statusLabel.text = message

        case .disconnected:
            statusLabel.text = "Disconnected"
        }
    }

    private func syncRemotePlayers(_ list: [LobbyPlayer]) {
        guard let localID = client.localPlayerID else { return }

        var seen = Set<String>()

        for p in list where p.id != localID {
            seen.insert(p.id)

            if let existing = remotePlayers[p.id] {
                existing.applyState(x: p.x, y: p.y, z: p.z, rotY: p.rotY, anim: p.anim)
            } else {
                let node = PlayerNode(playerID: p.id, displayName: p.displayName, isLocal: false)
                node.applyState(x: p.x, y: p.y, z: p.z, rotY: p.rotY, anim: p.anim)
                scene.rootNode.addChildNode(node)
                remotePlayers[p.id] = node
            }
        }

        // Remove players who left
        for (id, node) in remotePlayers where !seen.contains(id) {
            node.removeFromParentNode()
            remotePlayers.removeValue(forKey: id)
        }
    }

    // MARK: - Game Loop

    @objc private func tick() {
        let now = Date()
        let dt = Float(now.timeIntervalSince(lastUpdate))
        lastUpdate = now
        guard dt > 0, dt < 0.1 else { return }

        updateLocalPlayer(dt: dt)
        updateCamera()

        // Send state ~15 times per second
        stateSendAccumulator += TimeInterval(dt)
        if stateSendAccumulator >= 1.0 / 15.0 {
            stateSendAccumulator = 0
            sendLocalState()
        }
    }

    private func updateLocalPlayer(dt: Float) {
        guard let player = localPlayer else { return }

        var inputX: Float = 0
        var inputZ: Float = 0

        if moveForward { inputZ -= 1 }
        if moveBack { inputZ += 1 }
        if moveLeft { inputX -= 1 }
        if moveRight { inputX += 1 }

        // Normalize
        let len = sqrt(inputX * inputX + inputZ * inputZ)
        if len > 0 {
            inputX /= len
            inputZ /= len
        }

        // Move relative to camera yaw
        let yaw = cameraYaw
        let forwardX = sin(yaw)
        let forwardZ = cos(yaw)
        let rightX = cos(yaw)
        let rightZ = -sin(yaw)

        let moveX = (forwardX * -inputZ + rightX * inputX) * moveSpeed * dt
        let moveZ = (forwardZ * -inputZ + rightZ * inputX) * moveSpeed * dt

        var pos = player.position
        pos.x += moveX
        pos.z += moveZ

        // Simple gravity + jump
        if wantsJump && pos.y <= 0.05 {
            velocityY = jumpStrength
            wantsJump = false
        }

        velocityY += gravity * dt
        pos.y += velocityY * dt

        if pos.y < 0 {
            pos.y = 0
            velocityY = 0
        }

        player.position = pos

        // Face movement direction
        if len > 0.1 {
            player.eulerAngles.y = yaw + atan2(inputX, -inputZ)
        }

        // Animation state
        let anim: String
        if pos.y > 0.15 {
            anim = velocityY > 0 ? "jump" : "fall"
        } else if len > 0.1 {
            anim = "walk"
        } else {
            anim = "idle"
        }
        player.setAnimation(anim)

        // Clear one-shot keys (basic)
        moveForward = false
        moveBack = false
        moveLeft = false
        moveRight = false
    }

    private func updateCamera() {
        guard let player = localPlayer else { return }

        let target = player.position
        let offsetX = sin(cameraYaw) * cameraDistance
        let offsetZ = cos(cameraYaw) * cameraDistance
        let offsetY = sin(-cameraPitch) * cameraDistance + 2.2

        let desired = SCNVector3(
            target.x + offsetX,
            target.y + offsetY,
            target.z + offsetZ
        )

        // Simple spring follow
        let current = cameraNode.position
        let lerp: Float = 0.15
        cameraNode.position = SCNVector3(
            current.x + (desired.x - current.x) * lerp,
            current.y + (desired.y - current.y) * lerp,
            current.z + (desired.z - current.z) * lerp
        )

        cameraNode.look(at: SCNVector3(target.x, target.y + 1.4, target.z))
    }

    private func sendLocalState() {
        guard let player = localPlayer else { return }
        client.sendState(
            x: Double(player.position.x),
            y: Double(player.position.y),
            z: Double(player.position.z),
            rotY: Double(player.eulerAngles.y),
            anim: player.currentAnim
        )
    }
}

extension GameViewController: SCNSceneRendererDelegate {}
