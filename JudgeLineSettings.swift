import SwiftUI

public var editingProps: JudgeLineProps = .init()

struct JudgeLineSettings: View {
    @EnvironmentObject private var data: DataStructure
    var body: some View {
        List {
            Section(header: Text("Global Operations")) {
                Button("New JudgeLine") {
                    // Automatically append to the end, new judgeLine's id will be the last id + 1
                    for i in 0 ..< data.listOfJudgeLines.count {
                        data.listOfJudgeLines[i].id = i
                    }
                    data.listOfJudgeLines.append(JudgeLine(id: data.listOfJudgeLines[data.listOfJudgeLines.count - 1].id + 1))
                }
                Button("Organize JudgeLines") {
                    // assgin the judgeLine's numbers according to order in memory
                    for i in 0 ..< data.listOfJudgeLines.count {
                        data.listOfJudgeLines[i].id = i
                    }
                }
            }.textCase(nil)
            ForEach(data.listOfJudgeLines, id: \.id) { _judgeLine in
                Section(header: Text("JudgeLine \(String(_judgeLine.id))")) {
                    Button("Edit Notes") {
                        data.editingJudgeLineNumber = _judgeLine.id
                        data.windowStatus = .pannelNote
                        data.rebuildScene()
                    }
                    Button("Edit Props") {
                        data.editingJudgeLineNumber = _judgeLine.id
                        data.windowStatus = .pannelProp
                        data.rebuildScene()
                    }

                    Button(action: {
                        data.listOfJudgeLines.removeAll(where: { $0.id == _judgeLine.id && $0.id != 0 })
                        // Refuse to delete id = 0 judgeLine.
                        for i in 0 ..< data.listOfJudgeLines.count {
                            data.listOfJudgeLines[i].id = i
                        }
                        data.editingJudgeLineNumber = 0
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.circle")
                            Text("Delete this Line")
                        }
                        .foregroundColor(Color.red)
                    }
                }.textCase(nil)
            }
        }
    }
}
