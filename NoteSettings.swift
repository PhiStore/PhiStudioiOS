/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SwiftUI

struct NoteSettingsView: View {
    @EnvironmentObject private var data: DataStructure
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()

    var body: some View {
        List {
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].noteList) { $_note in
                Section(header: Text("\(String(describing: _note.noteType)) @ Tick [\(_note.timeTick)]")) {
                    Menu {
                        Picker(String(describing: _note.noteType), selection: $_note.noteType) {
                            ForEach(NOTETYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: _note.noteType))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: _note.noteType, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(_note.timeTick)
                    }
                    Button("Delete Note") {
                        data.listOfJudgeLines[data.editingJudgeLineNumber].noteList.removeAll(where: { $0.timeTick == _note.timeTick && $0.posX == _note.posX })
                        data.rebuildLineAndNote() // refresh spriteKit side
                        data.objectWillChange.send() // refresh swiftUI side
                    }.foregroundColor(Color.red)
                    Toggle(isOn: $_note.isFake) {
                        Text("Fake")
                    }
                    Toggle(isOn: $_note.fallSide) {
                        Text("Fall Side")
                    }
                    Stepper(value: $_note.posX, in: 0 ... 1, step: 0.05) {
                        HStack {
                            Text("Pos:")
                            TextField("[Double]", value: $_note.posX, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: _note.posX, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $_note.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $_note.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: _note.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if _note.noteType == .Hold {
                            Stepper(value: $_note.holdTimeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                                HStack {
                                    Text("Hold Time:")
                                    TextField("[Int]/T", value: $_note.holdTimeTick, formatter: numberFormatter)
                                }
                            }
                            .foregroundColor(.cyan)
                            .onChange(of: _note.holdTimeTick, perform: { _ in
                                data.rebuildLineAndNote()
                            })
                        }
                    }
                }
            }
        }
    }
}
