/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SpriteKit
import SwiftUI

struct PropSettingsView: View {
    @EnvironmentObject private var data: DataStructure
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()

    @ViewBuilder
    func currentPropList() -> some View {
        switch data.currentPropType {
        case .controlX:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlX, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlX.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .controlY:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlY, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlY.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .angle:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.angle, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.angle.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .speed:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.speed, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.speed.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .noteAlpha:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.noteAlpha, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.noteAlpha.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .lineAlpha:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.lineAlpha, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.lineAlpha.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        case .displayRange:
            ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.displayRange, id: \.timeTick) { $prop in
                Section("@[\(String(prop.timeTick))]") {
                    Stepper(value: $prop.timeTick, in: 0 ... data.chartLengthTick(), step: 1) {
                        HStack {
                            Text("Tick:")
                            TextField("[Int]/T", value: $prop.timeTick, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.timeTick, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                        HStack {
                            Text("Value:")
                            TextField("[Double]", value: $prop.value, formatter: numberFormatter)
                        }
                    }
                    .foregroundColor(.cyan)
                    .onChange(of: prop.value, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Group {
                        if prop.nextJumpValue == nil {
                            Button("Jump value") {
                                prop.nextJumpValue = prop.value
                                data.objectWillChange.send()
                            }
                        }
                        if prop.nextJumpValue != nil {
                            Group {
                                Stepper(value: $prop.nextJumpValue ?? 0.0, step: 0.01, onEditingChanged: { _ in }) {
                                    HStack {
                                        Text("After Jump value:")
                                        TextField("[Double]", value: $prop.nextJumpValue ?? 0.0, formatter: numberFormatter)
                                    }
                                }
                                .foregroundColor(.cyan)
                                .onChange(of: prop.nextJumpValue ?? 0.0, perform: { _ in
                                    data.rebuildLineAndNote()
                                })

                                Button("Remove Jump") {
                                    prop.nextJumpValue = nil
                                    data.objectWillChange.send()
                                    data.rebuildLineAndNote()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                    Menu {
                        Picker(String(describing: prop.followingEasing), selection: $prop.followingEasing) {
                            ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                Text(String(describing: type))
                            }
                        }
                    } label: {
                        Text(String(describing: prop.followingEasing))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }.onChange(of: prop.followingEasing, perform: { _ in
                        data.rebuildLineAndNote()
                    })
                    Button("Quick Jump") {
                        data.currentTimeTick = Double(prop.timeTick)
                    }
                    Button("Delete Prop") {
                        if prop.timeTick != 0 {
                            data.listOfJudgeLines[data.editingJudgeLineNumber].props.displayRange.removeAll(where: { $0.timeTick == prop.timeTick })
                            data.objectWillChange.send()
                            data.rebuildLineAndNote()
                        }
                    }.foregroundColor(Color.red)
                }
            }
        }
    }

    var body: some View {
        VStack {
            List {
                Picker("currentPropType", selection: $data.currentPropType) {
                    ForEach(PROPTYPE.allCases, id: \.self) { type in
                        Text(String(describing: type))
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
                Text(descriptionForPropType(type: data.currentPropType))
                currentPropList()
                    .textCase(nil)
            }
        }
    }
}
