import SwiftUI
import Photos
import PhotosUI

struct ChartSettings: View {
    @EnvironmentObject private var data: DataStructure

    let offsetRange = -10.0 ... 10.0 // acceptable offset range
    let chartLengthRange = 0 ... 600 // acceptable chartLength range
    @State private var newPreferTick = 3.0

    
    var body: some View {
        List {
            Section(header: Text("File Operation:")) {
                Button("Import Music...") {
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
                    // use the iTunes Library here... or use the finder app?

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
                    Button("Edit BPM Props") {}
                }
                Stepper(value: $data.chartLength, in: chartLengthRange) {
                    Text("Length: \(data.chartLength)s")
                }
            }.textCase(nil)

            Section(header: Text("Preferred Ticks")) {
                ForEach($data.preferTicks, id: \.value) { $tick in
                    ColorPicker("Tick: 1/" + String(tick.value), selection: $tick.color)

                }.onDelete(perform: { offset in
                    data.preferTicks.remove(atOffsets: offset)
                })

                VStack {
                    Stepper(value: $newPreferTick, in: 0 ... Double(data.tickPerSecond), step: 1) {
                        Text("NewTick: 1/\(Int(newPreferTick))")
                    }
                    Button("Add tick", action: {
                        if data.preferTicks.filter({ $0.value == Int(newPreferTick) }).count != 0 || data.tickPerSecond % Int(newPreferTick) != 0 {
                            return
                        } else {
                            data.preferTicks.append(ColoredInt(_value: Int(newPreferTick), _color: Color(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1))))
                        }

                    })
                }
            }.onChange(of: data.preferTicks) { _ in
                dataK.preferTicks = data.preferTicks
            }.textCase(nil)

            Section(header: Text("Do not change these:")) {
                Stepper(value: $data.tickPerSecond,
                        onEditingChanged: { _ in
                            dataK.tickPerSecond = data.tickPerSecond
                        }) {
                    Text("Tick: \(data.tickPerSecond)")
                }
            }
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = DataStructure(_id: 0)
        ChartSettings().environmentObject(tmpData)
    }
}
