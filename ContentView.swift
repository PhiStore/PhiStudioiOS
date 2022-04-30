// this is the main editor's entrance here
import SwiftUI
public var dataK = DataStructure(_id: 1)

struct ContentView: View {
    // these variables are used for location and alignment
    // guide: reserve size*2 for boundaries, and keep everything fit in place
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100
    var height_s = UIScreen.main.bounds.height
    var width_s = UIScreen.main.bounds.width

    @StateObject private var data = DataStructure(_id: 0)

    var pannelGesture: some Gesture {
        // this toggles the left pannel on or off
        TapGesture(count: 1)
            .onEnded { _ in
                data.isRunning = false
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

    func getColor() -> Color {
        switch data.currentNoteType {
        case .Tap: return Color.blue
        case .Hold: return Color.green
        case .Flick: return Color.red
        case .Drag: return Color.yellow
        }
    }

    var switchColor: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                switch data.currentNoteType {
                case .Tap: data.currentNoteType = NOTETYPE.Hold
                case .Hold: data.currentNoteType = NOTETYPE.Flick
                case .Flick: data.currentNoteType = NOTETYPE.Drag
                case .Drag: data.currentNoteType = NOTETYPE.Tap
                }
                dataK.currentNoteType = data.currentNoteType
            }
    }

    var playOrStop: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                data.isRunning.toggle()
            }
    }

    var fowardFive: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                data.isRunning = false
                data.currentTimeTick += 5.0
            }
    }

    var backwardFive: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                data.isRunning = false
                data.currentTimeTick -= 5.0
            }
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
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
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
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                        .fixedSize()
                }
                .frame(width: pannelStatus() ? width_s * 3 / 4 - size * 6 : width_s - size * 4, height: height_s - size * 8)
                .offset(x: pannelStatus() ? width_s / 8 + size : 0, y: size * 2)
                .fixedSize()
            }

            // Switch to toggle the pannel on or off
            Image(systemName: pannelStatus() ? "command.circle" : "command.circle.fill").resizable()
                .frame(width: size * 2, height: size * 2)
                .offset(x: -width_s / 2 + size * 3, y: -height_s / 2 + size * 3)
                .gesture(pannelGesture)

            Image(systemName: "paintbrush.pointed").resizable()
                .renderingMode(.template)
                .foregroundColor(getColor())
                .frame(width: size * 2, height: size * 2)
                .offset(x: -width_s / 2 + size * 6, y: -height_s / 2 + size * 3)
                .gesture(switchColor)

            // Slidebar to control the time being showed
            HStack(spacing: size / 2) {
                Image(systemName: "gobackward.5").resizable()
                    .renderingMode(.template)
                    .foregroundColor(.blue)
                    .frame(width: size * 1, height: size * 1)
                    .gesture(backwardFive)
                Image(systemName: !data.isRunning ? "play.circle" : "pause.circle").resizable()
                    .renderingMode(.template)
                    .foregroundColor(.blue)
                    .frame(width: size * 1, height: size * 1)
                    .gesture(playOrStop)
                Image(systemName: "goforward.5").resizable()
                    .renderingMode(.template)
                    .foregroundColor(.blue)
                    .frame(width: size * 1, height: size * 1)
                    .gesture(fowardFive)

                Slider(value: $data.currentTimeTick,
                       in: 0 ... Double(data.chartLengthSecond * data.tickPerBeat * data.bpm / 60)).frame(width: width_s / 2 - 3 / 2 * size)
                // need to add control buttons here
            }.frame(width: width_s / 2 + size * 4, height: size * 2)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .offset(x: width_s / 4 - size * 4, y: -height_s / 2 + size * 3)
                .fixedSize()
        }
    }
}
