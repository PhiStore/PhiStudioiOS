import SpriteKit
import SwiftUI

struct NoteSettingsView: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        List{
//            ForEach(editingJudgeLine.noteList.indices){ index in
//                Toggle(isOn: editingJudgeLine.noteList[index].$isFake){
//                    Text("Fake Note")
//                }
//
//            }
        }
    }
}

struct NoteSettings_Previews: PreviewProvider {
    static var previews: some View {
        NoteSettingsView()
    }
}
