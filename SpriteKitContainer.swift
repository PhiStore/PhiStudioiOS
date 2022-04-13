import SpriteKit
import SwiftUI

struct SpriteKitContainer: UIViewRepresentable {
    typealias UIViewType = SKView

    var skScene: SKScene!

    init(scene: SKScene) {
        skScene = scene
        skScene.scaleMode = .resizeFill
    }

    class Coordinator: NSObject {
        var scene: SKScene?
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.scene = skScene
        return coordinator
    }

    func makeUIView(context _: Context) -> SKView {
        let view = SKView(frame: .zero)
        view.preferredFramesPerSecond = 120
        // debug settings, remove when not needed
        view.showsFPS = true
        view.showsNodeCount = true
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        view.presentScene(context.coordinator.scene)
    }
}
