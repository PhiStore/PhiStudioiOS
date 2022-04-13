import CoreGraphics
import CoreMotion
import SpriteKit
import UIKit

class NoteEditScene: SKScene {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init() {
        super.init()
        setup()
    }

    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }

    func setup() {}

    override func sceneDidLoad() {}

    override func didMove(to _: SKView) {}

    override func update(_: TimeInterval) {}

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let barra = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: 2))
        barra.fillColor = SKColor.white
        barra.position = location
        addChild(barra)
    }
}
