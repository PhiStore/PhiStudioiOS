import SpriteKit
import SwiftUI

struct PropSettingsView: View {
    @EnvironmentObject private var data: DataStructure

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
                // ForEach(PROPTYPE.allCases, id: \.rawValue) { propType in
                Section(header: Text(String(describing: data.currentPropType))) {
                    ForEach(data.listOfJudgeLines[data.editingJudgeLineNumber].props.returnProp(type: data.currentPropType), id: \.timeTick) { prop in
                        // need update here
                        HStack {
                            Text("[" + String(prop.timeTick) + "T]:")
                            Text(String(NSString(format: "%.3f", prop.value)))
                        }
                        HStack {
                            Text(String(describing: prop.followingEasing))
                            Menu("Edit") {
                                ForEach(EASINGTYPE.allCases, id: \.self) { type in
                                    Button(String(describing: type), action: {
                                        data.listOfJudgeLines[data.editingJudgeLineNumber].props.updateProp(type: data.currentPropType, timeTick: prop.timeTick, value: nil, followingEasing: type)
                                        data.objectWillChange.send()
                                        data.rebuildScene()
                                    })
                                }
                            }
                        }
                    }.onDelete(perform: { offset in
                        data.listOfJudgeLines[data.editingJudgeLineNumber].props.removePropAtOffset(type: data.currentPropType, offset: offset)
                        data.rebuildScene()
                        data.objectWillChange.send()
                    })
                }
                .textCase(nil)
                // }
            }
        }
    }
}
