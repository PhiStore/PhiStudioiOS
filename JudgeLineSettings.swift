import SwiftUI

public var editingJudgeLine = judgeLine(_id: 0)
struct JudgeLineSettings: View {
    @EnvironmentObject private var data: mainData

    var body: some View {
        List {
            Section(header: Text("Global Operations")) {
                Button("New JudgeLine") {
                    // automatically append to the end,
                    // new judgeLine's id will be the last id + 1
                    data.lines.append(judgeLine(_id: data.lines[data.lines.count - 1].id + 1))
                    for i in 0..<data.lines.count {
                        data.lines[i].id = i
                    }
                }
//                Button("Organize JudgeLines"){
//                    // assgin the judgeLine's numbers according to order in memory
//                    for i in 0..<data.lines.count {
//                        data.lines[i].id = i
//                    }
//                }
            }.textCase(nil)
            ForEach(data.lines, id: \.id) { _judgeLine in
                Section(header: Text("JudgeLine \(String(_judgeLine.id))")) {
                    Button("Edit Notes") {}
                    Button("Edit Props") {}
                    
                    Button(action: { data.lines.removeAll(where: { $0.id == _judgeLine.id && $0.id != 0 }) }) {
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
        let tmpData = mainData(_id: 0)
        JudgeLineSettings().environmentObject(tmpData)
    }
}
