import SwiftUI

struct ChartSettings: View {
    @EnvironmentObject private var data: mainData

    let offsetRange = -10.0 ... 10.0 // acceptable offset range
    let chartLengthRange = 0 ... 600 // acceptable chartLength range

    var body: some View {
        List {
            Section(header: Text("File Operation:")) {
                Button("Import Music...") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                Button("Import Photo...") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
                Button("Save '.pxf' file...") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                }
            }.textCase(nil)
            Section(header: Text("Information:")) {
                HStack {
                    Text("Music Name:")
                    TextField("Music", text: $data.musicName).foregroundColor(Color.blue)
                }
                HStack {
                    Text("Music Author:")
                    TextField("Author", text: $data.authorName).foregroundColor(Color.blue)
                }
                HStack {
                    Text("Chart Level:")
                    TextField("Level", text: $data.chartLevel).foregroundColor(Color.orange)
                }
                HStack {
                    Text("Chart Author:")
                    TextField("Chart Author", text: $data.chartAuthorName).foregroundColor(Color.orange)
                }
                Menu("Copyright Info") {
                    Button("[Full copyright]", action: {})
                    Button("[Limited copyright]", action: {})
                    Button("[No copyright]", action: {})
                }
            }.textCase(nil)
            Section(header: Text("Variables:")) {
                Stepper(value: $data.offset, in: offsetRange, step: 0.05) {
                    Text("Offset: \(NSString(format: "%.2f", data.offset))s")
                }

                Toggle(isOn: $data.changeBpm) {
                    Text("Allow BPM changes")
                }
                if !data.changeBpm {
                    Stepper(value: $data.bpm) {
                        Text("BPM: \(data.bpm)")
                    }
                } else {
                    // work to be done here. - give a editor on time-changing BPM
                    Button("Edit BPM Props") {
                    }
                }
                Stepper(value: $data.chartLength, in: chartLengthRange) {
                    Text("Length: \(data.chartLength)s")
                }
            }.textCase(nil)
            Section(header: Text("Do not change these:")) {
                Stepper(value: $data.tick) {
                    Text("Tick: \(data.tick)")
                }
            }
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = mainData()
        ChartSettings().environmentObject(tmpData)
    }
}
