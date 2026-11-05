import SceneKit

/// Simple blocky character used for both local and remote players.
final class PlayerNode: SCNNode {
    let playerID: String
    private(set) var displayName: String
    private(set) var currentAnim: String = "idle"

    private let body = SCNNode()
    private let nameLabel = SCNNode()

    init(playerID: String, displayName: String, isLocal: Bool = false) {
        self.playerID = playerID
        self.displayName = displayName
        super.init()

        name = isLocal ? "localPlayer" : "player_\(playerID)"

        // Body (torso)
        let torso = SCNBox(width: 0.8, height: 1.0, length: 0.45, chamferRadius: 0.05)
        torso.firstMaterial?.diffuse.contents = isLocal
            ? UIColor(red: 0.20, green: 0.55, blue: 0.90, alpha: 1)
            : UIColor(red: 0.85, green: 0.35, blue: 0.25, alpha: 1)
        let torsoNode = SCNNode(geometry: torso)
        torsoNode.position = SCNVector3(0, 1.1, 0)
        body.addChildNode(torsoNode)

        // Head
        let head = SCNBox(width: 0.55, height: 0.55, length: 0.55, chamferRadius: 0.06)
        head.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.86, blue: 0.70, alpha: 1)
        let headNode = SCNNode(geometry: head)
        headNode.position = SCNVector3(0, 1.9, 0)
        body.addChildNode(headNode)

        // Legs
        let legGeo = SCNBox(width: 0.28, height: 0.7, length: 0.28, chamferRadius: 0.04)
        legGeo.firstMaterial?.diffuse.contents = UIColor(red: 0.25, green: 0.35, blue: 0.55, alpha: 1)

        let leftLeg = SCNNode(geometry: legGeo)
        leftLeg.position = SCNVector3(-0.22, 0.35, 0)
        body.addChildNode(leftLeg)

        let rightLeg = SCNNode(geometry: legGeo)
        rightLeg.position = SCNVector3(0.22, 0.35, 0)
        body.addChildNode(rightLeg)

        // Arms
        let armGeo = SCNBox(width: 0.22, height: 0.7, length: 0.22, chamferRadius: 0.04)
        armGeo.firstMaterial?.diffuse.contents = UIColor(red: 1.0, green: 0.86, blue: 0.70, alpha: 1)

        let leftArm = SCNNode(geometry: armGeo)
        leftArm.position = SCNVector3(-0.55, 1.15, 0)
        body.addChildNode(leftArm)

        let rightArm = SCNNode(geometry: armGeo)
        rightArm.position = SCNVector3(0.55, 1.15, 0)
        body.addChildNode(rightArm)

        addChildNode(body)

        // Name tag
        let text = SCNText(string: displayName, extrusionDepth: 0.05)
        text.font = UIFont.boldSystemFont(ofSize: 0.35)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.firstMaterial?.isDoubleSided = true

        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.4, 0.4, 0.4)

        // Center the text
        let (min, max) = textNode.boundingBox
        let dx = (max.x - min.x) / 2
        textNode.position = SCNVector3(-dx * 0.4, 2.4, 0)

        // Billboard so name always faces camera
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = .Y
        textNode.constraints = [constraint]

        nameLabel.addChildNode(textNode)
        addChildNode(nameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDisplayName(_ name: String) {
        displayName = name
        // Simple approach: rebuild label later if needed
    }

    func setAnimation(_ anim: String) {
        currentAnim = anim
        // Basic visual feedback for now (scale bounce on jump)
        switch anim {
        case "jump":
            body.position.y = 0.25
        case "walk":
            body.position.y = 0.05
        default:
            body.position.y = 0
        }
    }

    func applyState(x: Double, y: Double, z: Double, rotY: Double, anim: String) {
        position = SCNVector3(x, y, z)
        eulerAngles.y = Float(rotY)
        setAnimation(anim)
    }
}
