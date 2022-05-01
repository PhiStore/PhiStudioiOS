import SpriteKit
import SwiftUI

struct NoteSettingsView: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        List {
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].noteList) { $_note in
                Section(header: Text(String(describing: _note.noteType) + " @ Tick [\(_note.timeTick)]")) {
                    // Picker("NoteType", selection: $_note.noteType) {
                    Menu {
                        Picker(String(describing: _note.noteType), selection: $_note.noteType) {
                            ForEach(NOTETYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: _note.noteType))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Stepper(value: $_note.posX, in: 0 ... 1, step: 0.05) {
                        Text("X Position: \(NSString(format: "%.3f", _note.posX))")
                    }
                    Toggle(isOn: $_note.isFake) {
                        Text("Fake")
                    }
                    Toggle(isOn: $_note.fallSide) {
                        Text("Fall Side")
                    }
                    Stepper(value: $_note.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        Text("Time Tick: \(_note.timeTick)")
                    }
                    Stepper(value: $_note.holdTimeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        Text("Hold Time Tick: \(_note.holdTimeTick)")
                    }
                }
            }
        }
    }
}

struct NoteSettings_Previews: PreviewProvider {
    static var previews: some View {
        NoteSettingsView()
    }
}
