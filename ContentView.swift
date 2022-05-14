// this is the editor's main entrance here
import SwiftUI

struct ContentView: View {
    // these variables are used for location and alignment
    // guide: reserve size*2 for boundaries, keep everything fit in place
    var screenHeight = UIScreen.main.bounds.height
    var screenWidth = UIScreen.main.bounds.width
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100

    @StateObject private var data = DataStructure()
    @State private var updateToggle = false

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
                case .pannelPreview: data.windowStatus = WINDOWSTATUS.preview
                case .preview: data.windowStatus = WINDOWSTATUS.pannelPreview
                }
                // FIXME: Logic problem here, editor size not changing properly when the button is handled
                data.objectWillChange.send()
                updateToggle.toggle()
            }
    }

    func shouldShowPannel() -> Bool {
        // returns true if the left pannel show
        return (data.windowStatus == WINDOWSTATUS.pannelNote || data.windowStatus == WINDOWSTATUS.pannelProp || data.windowStatus == WINDOWSTATUS.pannelPreview)
    }

    func shouldShowNote() -> Bool {
        return (data.windowStatus == WINDOWSTATUS.note || data.windowStatus == WINDOWSTATUS.pannelNote)
    }

    func shouldShowProp() -> Bool {
        return (data.windowStatus == WINDOWSTATUS.prop || data.windowStatus == WINDOWSTATUS.pannelProp)
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
            }
    }

    var refreshGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                data.rebuildScene()
                data.objectWillChange.send()
                updateToggle.toggle()
            }
    }

    var changeLockGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                data.locked.toggle()
            }
    }

    var changeEditorGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                data.isRunning = false
                switch data.windowStatus {
                case .note: data.windowStatus = .prop
                case .prop: data.windowStatus = .preview
                case .preview: data.windowStatus = .note
                case .pannelNote: data.windowStatus = .pannelProp
                case .pannelProp: data.windowStatus = .pannelPreview
                case .pannelPreview: data.windowStatus = .pannelNote
                }
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
            if shouldShowPannel() {
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
                        if shouldShowNote() {
                            NoteSettingsView().environmentObject(data)
                                .tabItem {
                                    Label("Notes", systemImage: "bolt.horizontal")
                                }
                        } else {
                            PropSettingsView().environmentObject(data)
                                .tabItem {
                                    Label("Props", systemImage: "pencil.and.outline")
                                }
                        }
                    }
                    .frame(width: screenWidth / 4, height: screenHeight - size * 8)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                    .fixedSize()
                }
                .frame(width: screenWidth / 4)
                .offset(x: -screenWidth * 3 / 8 + size * 2, y: size * 2)
                .fixedSize()
            }

            // Note editor & Prop Editor
            if shouldShowNote() {
                // Note editor
                LazyVStack(alignment: .leading) {
                    Text("Note Editor: on Line \(data.editingJudgeLineNumber) @ \(NSString(format: "%.3f", data.currentTimeTick))T/\(NSString(format: "%.3f", data.currentTimeTick / Double(data.tickPerBeat)))B").font(.title2).fontWeight(.bold)
                    NoteEditorView().environmentObject(data)
                        .frame(width: shouldShowPannel() ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                        .fixedSize()
                }
                .frame(width: shouldShowPannel() ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                .offset(x: shouldShowPannel() ? screenWidth / 8 + size : 0, y: size * 2)
                .fixedSize()
                .onAppear(perform: {
                    data.rebuildScene()
                })
            } else {
                if shouldShowProp() {
                    // Prop Editor
                    LazyVStack(alignment: .leading) {
                        Text("Prop Editor").font(.title2).fontWeight(.bold)
                        PropEditorView().environmentObject(data)
                            .frame(width: shouldShowPannel() ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                            .fixedSize()
                    }
                    .frame(width: shouldShowPannel() ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                    .offset(x: shouldShowPannel() ? screenWidth / 8 + size : 0, y: size * 2)
                    .fixedSize()
                }
            }

            // Switch to toggle the pannel on or off
            Image(systemName: shouldShowPannel() ? "command.circle" : "command.circle.fill").resizable()
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 3, y: -screenHeight / 2 + size * 3)
                .gesture(pannelGesture)

            Image(systemName: "paintbrush.pointed").resizable()
                .renderingMode(.template)
                .foregroundColor(getColor())
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 6, y: -screenHeight / 2 + size * 3)
                .gesture(switchColor)

            Image(systemName: "arrow.triangle.2.circlepath").resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 1.8)
                .offset(x: -screenWidth / 2 + size * 9, y: -screenHeight / 2 + size * 3)
                .gesture(refreshGesture)

            Image(systemName: data.locked ? "lock.circle.fill" : "lock.circle").resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 12, y: -screenHeight / 2 + size * 3)
                .gesture(changeLockGesture)

            Image(systemName: shouldShowNote() ? "sun.min" : (shouldShowProp() ? "sun.max.fill" : "sparkles")).resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 15, y: -screenHeight / 2 + size * 3)
                .gesture(changeEditorGesture)

            // Slidebar to control current time
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
                       in: 0 ... Double(data.chartLengthSecond * data.tickPerBeat * data.bpm / 60)).frame(width: screenWidth / 2 - 3 / 2 * size)
            }.frame(width: screenWidth / 2 + size * 4, height: size * 2)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .offset(x: screenWidth / 4 - size * 4, y: -screenHeight / 2 + size * 3)
                .fixedSize()
        }
    }
}
