import SwiftUI

public var editingJudgeLine = JudgeLine(id: 0)
struct JudgeLineSettings: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        List {
            Section(header: Text("Global Operations")) {
                Button("New JudgeLine") {
                    // automatically append to the end,
                    // new judgeLine's id will be the last id + 1
                    data.listOfJudgeLines.append(JudgeLine(id: data.listOfJudgeLines[data.listOfJudgeLines.count - 1].id + 1))
                    for i in 0 ..< data.listOfJudgeLines.count {
                        data.listOfJudgeLines[i].id = i
                    }
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
                    Button("Edit Notes") {}
                    Button("Edit Props") {}

                    Button(action: { data.listOfJudgeLines.removeAll(where: { $0.id == _judgeLine.id && $0.id != 0 }) }) {
                        // couldn't delte id = 0 judgeLine.
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

struct JudgeLineSettings_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = DataStructure(_id: 0)
        JudgeLineSettings().environmentObject(tmpData)
    }
}
