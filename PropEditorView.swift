import SpriteKit
import SwiftUI

class PropEditorScene: SKScene {
    var data: DataStructure?

    override func didMove(to _: SKView) {}

    override func update(_: TimeInterval) {}

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {}
}

struct PropEditorView: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        SpriteView(scene: data.propEditScene)
    }
}

struct PropEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = DataStructure()
        PropEditorView().environmentObject(tmpData)
    }
}
