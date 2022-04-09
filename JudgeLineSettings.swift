import SwiftUI

struct JudgeLineSettings: View {
    @EnvironmentObject private var data: mainData

    var body: some View {
        List {
            Section(header: Text("New")) {
                // TODO: add contents here.
                Button("Create New JudgeLine") {
                    data.lines.append(judgeLine(_id: data.lines[data.lines.count - 1].id + 1))
                }
            }
            ForEach(data.lines, id: \.id){ _judgeLine in 
                Section(header: Text("JudgeLine \(String(_judgeLine.id))")){
                    Button("Edit Notes"){
                    }
                    Button("Edit Props"){

                    }
                }.textCase(nil)
            }
        }
    }
}

struct JudgeLineSettings_Previews: PreviewProvider {
    static var previews: some View {
        JudgeLineSettings()
    }
}
