import SpriteKit
import SwiftUI

struct PropSettingsView: View {
    @EnvironmentObject private var data: DataStructure

    func currentPropList() -> some View {
        switch data.currentPropType {
        case .controlX:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlX, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .controlY:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.controlY, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .angle:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.angle, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .speed:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.speed, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .noteAlpha:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.noteAlpha, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .lineAlpha:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.lineAlpha, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        case .displayRange:
            return ForEach($data.listOfJudgeLines[data.editingJudgeLineNumber].props.displayRange, id: \.timeTick) { $prop in
                VStack {
                    HStack {
                        Text("@\(String(prop.timeTick))T:")
                        Stepper(value: $prop.value, in: 0 ... 1, step: 0.01) {
                            Text(String(NSString(format: "%.3f", prop.value)))
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
                    }
                }
            }.onDelete(perform: { offset in
                data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                data.rebuildScene()
                data.objectWillChange.send()
            })
        }
    }

    var body: some View {
        VStack {
            List {
                HStack {
                    Text("Current Prop Type")
                    Picker("currentPropType", selection: $data.currentPropType) {
                        ForEach(PROPTYPE.allCases, id: \.self) { type in
                            Text(String(describing: type))
                                .tag(type)
                        }
                    }
                }
                .pickerStyle(.menu)
                Text(descriptionForPropType(type: data.currentPropType))

                Section(header: Text(String(describing: data.currentPropType))) {
                    currentPropList()
                }
                .textCase(nil)
            }
        }
    }
}
