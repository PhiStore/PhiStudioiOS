import SpriteKit
import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var data: mainData
    
    var body: some View {
        SpriteKitContainer(scene: NoteEditScene())
    }
}

struct NoteEditor_Previews: PreviewProvider {
    static var previews: some View {
        NoteEditorView()
    }
}
