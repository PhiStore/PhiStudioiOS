import SpriteKit
import SwiftUI

class ChartPreviewScene: SKScene {
    var data: DataStructure?
}

struct ChartPreview: View {
    @EnvironmentObject private var data: DataStructure
    var body: some View {
        SpriteView(scene: data.propEditScene)
    }
}
