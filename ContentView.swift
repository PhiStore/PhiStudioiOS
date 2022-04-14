// this is the main editor's entrance here
import SwiftUI

public var time_p: Double = 0.0 // time copy in ticks
public var isRunning: Bool = false

struct ContentView: View {
    // these variables are used for location and alignment
    // guide: reserve size*2 for boundaries, and keep everything fit in place
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100
    var height_s = UIScreen.main.bounds.height
    var width_s = UIScreen.main.bounds.width

    @StateObject private var data = mainData()

    var pannelGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                // switch the pannel Status
                switch data.windowStatus {
                case .pannelProp: data.windowStatus = WINDOWSTATUS.prop
                case .prop: data.windowStatus = WINDOWSTATUS.pannelProp
                case .pannelNote: data.windowStatus = WINDOWSTATUS.note
                case .note: data.windowStatus = WINDOWSTATUS.pannelNote
                }
            }
    }

    func pannelStatus() -> Bool {
        // returns true if the left pannel show
        return (data.windowStatus == WINDOWSTATUS.pannelNote || data.windowStatus == WINDOWSTATUS.pannelProp)
    }

    var body: some View {
        ZStack(alignment: .center) {
            // left pannel
            if pannelStatus() {
                LazyVStack(alignment: .leading) {
                    // title
                    Text("PhiStudio").font(.title2).fontWeight(.bold)
                    // FIXME: The tabItem is showing different on iPad, especially when you add four tabs and more, I'm not sure whether that is a feature or a bug, but please take care
                    TabView {
                        ChartSettings().environmentObject(data)
                            .tabItem {
                                Label("Chart", systemImage: "command")
                            }
                        JudgeLineSettings().environmentObject(data)
                            .tabItem {
                                Label("JudgeLine", systemImage: "pencil.tip.crop.circle")
                            }
                        // unfinished section - reserved for Note
                        Text("Unfinished Part")
                            .tabItem {
                                Label("Notes", systemImage: "bolt.horizontal")
                            }
                    }
                    .frame(width: width_s / 4, height: height_s - size * 8)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                    .fixedSize()
                }
                .frame(width: width_s / 4)
                .offset(x: -width_s * 3 / 8 + size * 2, y: size * 2)
                .fixedSize()
            }

            // Note editor & Prop Editor
            if data.windowStatus == WINDOWSTATUS.pannelNote || data.windowStatus == WINDOWSTATUS.note {
                // Note editor
                LazyVStack(alignment: .leading) {
                    Text("Note Editor").font(.title2).fontWeight(.bold)
                    NoteEditorView()
                        .frame(width: pannelStatus() ? width_s * 3 / 4 - size * 6 : width_s - size * 4, height: height_s - size * 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.blue))
                        .fixedSize()
                }
                .frame(width: pannelStatus() ? width_s * 3 / 4 - size * 6 : width_s - size * 4, height: height_s - size * 8)
                .offset(x: pannelStatus() ? width_s / 8 + size : 0, y: size * 2)
                .fixedSize()
            } else {
                // Prop Editor
                LazyVStack(alignment: .leading) {
                    Text("Prop Editor").font(.title2).fontWeight(.bold)
                    PropEditorView()
                        .frame(width: pannelStatus() ? width_s * 3 / 4 - size * 6 : width_s - size * 4, height: height_s - size * 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.blue))
                        .fixedSize()
                }
                .frame(width: pannelStatus() ? width_s * 3 / 4 - size * 6 : width_s - size * 4, height: height_s - size * 8)
                .offset(x: pannelStatus() ? width_s / 8 + size : 0, y: size * 2)
                .fixedSize()
            }

            // Switch to toggle the pannel on or off
            if pannelStatus() {
                Image(systemName: "command.circle").resizable()
                    .frame(width: size * 2, height: size * 2)
                    .offset(x: -width_s / 2 + size * 3, y: -height_s / 2 + size * 3)
                    .gesture(pannelGesture)
            } else {
                Image(systemName: "command.circle.fill").resizable()
                    .frame(width: size * 2, height: size * 2)
                    .offset(x: -width_s / 2 + size * 3, y: -height_s / 2 + size * 3)
                    .gesture(pannelGesture)
            }

            // Slidebar to control the time being showed
            LazyVStack {
                Slider(value: $data.time,
                       in: 0 ... Double(data.chartLength * data.tick),
                       onEditingChanged: { _ in
                           time_p = data.time
                       }).frame(width: width_s / 2 - 2 * size)
                // need to add control buttons here
            }.frame(width: width_s / 2, height: size * 2)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .offset(x: width_s / 4 - size * 2, y: -height_s / 2 + size * 3)
                .fixedSize()
        }
    }
}
