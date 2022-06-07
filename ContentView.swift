/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SwiftUI
struct ContentView: View {
    // These variables are used for location and alignment
    // Guide: reserve size*2 for boundaries, keep everything fit in place
    // On iOS 16.0, we find this a problem, since the window is resized, and it's a whole disaster...
    var screenHeight = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    var screenWidth = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100

    let orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()

    @StateObject private var data = DataStructure()

    func shouldShowPannel() -> Bool {
        return (data.windowStatus == WINDOWSTATUS.pannelNote || data.windowStatus == WINDOWSTATUS.pannelProp || data.windowStatus == WINDOWSTATUS.pannelPreview)
    }

    func getColor() -> Color {
        if data.windowStatus == .pannelNote || data.windowStatus == .note {
            switch data.currentNoteType {
            case .Tap: return Color.blue
            case .Hold: return Color.green
            case .Flick: return Color.red
            case .Drag: return Color.yellow
            }
        } else if data.windowStatus == .pannelProp || data.windowStatus == .prop {
            switch data.currentPropType {
            case .controlX: return Color.blue
            case .controlY: return Color.green
            case .angle: return Color.red
            case .speed: return Color.yellow
            case .noteAlpha: return Color.orange
            case .lineAlpha: return Color.purple
            case .displayRange: return Color.pink
            }
        } else if data.windowStatus == .pannelPreview || data.windowStatus == .preview {
            return Color.red
        } else {
            return Color.yellow
        }
    }

    func workSpaceTitle() -> String {
        switch data.windowStatus {
        case .note: return "Note Editor (on Line \(data.editingJudgeLineNumber) / \(data.listOfJudgeLines[data.editingJudgeLineNumber].description)"
        case .pannelNote: return "Note Editor (on Line \(data.editingJudgeLineNumber)) / \(data.listOfJudgeLines[data.editingJudgeLineNumber].description)"
        case .prop: return "Prop Editor (on Line \(data.editingJudgeLineNumber)) / \(data.listOfJudgeLines[data.editingJudgeLineNumber].description)"
        case .pannelProp: return "Prop Editor (on Line \(data.editingJudgeLineNumber)) / \(data.listOfJudgeLines[data.editingJudgeLineNumber].description)"
        case .preview: return "Preview"
        case .pannelPreview: return "Preview"
        }
    }

    func workSpaceIcon() -> String {
        switch data.windowStatus {
        case .note: return "sun.min"
        case .pannelNote: return "sun.min"
        case .prop: return "sun.max.fill"
        case .pannelProp: return "sun.max.fill"
        case .preview: return "sparkles"
        case .pannelPreview: return "sparkles"
        }
    }

    func paintIcon() -> String {
        switch data.windowStatus {
        case .note: return "paintbrush.pointed"
        case .pannelNote: return "paintbrush.pointed"
        case .prop: return "paintbrush.pointed.fill"
        case .pannelProp: return "paintbrush.pointed.fill"
        case .preview: return "lasso"
        case .pannelPreview: return "lasso"
        }
    }

    @ViewBuilder
    func workSpace() -> some View {
        if data.windowStatus == .pannelNote || data.windowStatus == .note {
            NoteEditorView().environmentObject(data)
        } 
        else {
            if data.windowStatus == .pannelProp || data.windowStatus == .prop {
                PropEditorView().environmentObject(data)
            }
            else {
                if data.windowStatus == .pannelPreview || data.windowStatus == .preview {
                    ChartPreview().environmentObject(data)
                }
                else {
                    Text("Error or not done yet")
                }
            }
        }
    }

    @ViewBuilder
    func sideNote() -> some View {
        VStack {
            Group {
                Image(systemName: "arrow.triangle.2.circlepath").resizable()
                    .renderingMode(.template)
                    .frame(width: size * 2, height: size * 1.8)
                    .foregroundColor(.red)
                Text("Turn around your iPad")
                    .foregroundColor(.red)
            }
            Group {
                Text("Sponsors:")
                    .font(.title2)
                    .padding(20)
                Text("Naptie, Eroslon Network, Amaterus")
            }
            Group {
                Text("Dev Team:")
                    .font(.title2)
                    .padding(20)
                Text("TianKaiM, ZeroAurora, water_lift")
            }
            Group {
                Text("Charting Team:")
                    .font(.title2)
                    .padding(20)
                Text("TimiTini, IcedDog, nugget233, Naptie")
            }
            Group {
                Text("Sponsor Link:")
                    .font(.title2)
                    .padding(20)
                Text(#"https://afdian.net/@tiankaima"#)
            }
            Group {
                Text("Home Page:")
                    .font(.title2)
                    .padding(20)
                Text("https://github.com/tiankaima/PhiStudioiOS")
            }
        }
    }

    var body: some View {
        Group {
            if UIScreen.main.bounds.height < UIScreen.main.bounds.width {
                VStack (alignment: .center){
                    HStack (alignment: .center, spacing: size) {
                        Image(systemName: shouldShowPannel() ? "command.circle" : "command.circle.fill").resizable()
                            .frame(width: size * 2, height: size * 2)
                            .onTapGesture {
                                switch data.windowStatus {
                                case .pannelProp: data.windowStatus = .prop
                                case .prop: data.windowStatus = .pannelProp
                                case .pannelNote: data.windowStatus = .note
                                case .note: data.windowStatus = .pannelNote
                                case .pannelPreview: data.windowStatus = .preview
                                case .preview: data.windowStatus = .pannelPreview
                                }
                            }
                        Image(systemName: paintIcon()).resizable()
                            .renderingMode(.template)
                            .foregroundColor(getColor())
                            .frame(width: size * 2, height: size * 1.8)
                            .onTapGesture {
                                if data.windowStatus == .pannelNote || data.windowStatus == .note {
                                    switch data.currentNoteType {
                                    case .Tap: data.currentNoteType = .Hold
                                    case .Hold: data.currentNoteType = .Flick
                                    case .Flick: data.currentNoteType = .Drag
                                    case .Drag: data.currentNoteType = .Tap
                                    }
                                } else if data.windowStatus == .pannelProp || data.windowStatus == .prop {
                                    switch data.currentPropType {
                                    case .controlX: data.currentPropType = .controlY
                                    case .controlY: data.currentPropType = .angle
                                    case .angle: data.currentPropType = .speed
                                    case .speed: data.currentPropType = .noteAlpha
                                    case .noteAlpha: data.currentPropType = .lineAlpha
                                    case .lineAlpha: data.currentPropType = .displayRange
                                    case .displayRange: data.currentPropType = .controlX
                                    }
                                }
                            }
                        Image(systemName: "arrow.triangle.2.circlepath").resizable()
                            .renderingMode(.template)
                            .frame(width: size * 2, height: size * 1.8)
                            .onTapGesture {
                                data.rebuildScene()
                                data.objectWillChange.send()
                            }
                        Image(systemName: data.locked ? "lock.circle.fill" : "lock.circle").resizable()
                            .renderingMode(.template)
                            .frame(width: size * 2, height: size * 2)
                            .onTapGesture {
                                data.locked.toggle()
                            }
                        Image(systemName: workSpaceIcon()).resizable()
                            .renderingMode(.template)
                            .frame(width: size * 2, height: size * 2)
                            .onTapGesture {
                                switch data.windowStatus {
                                case .note: data.windowStatus = .prop
                                case .pannelNote: data.windowStatus = .pannelProp
                                case .prop: data.windowStatus = .preview
                                case .pannelProp: data.windowStatus = .pannelPreview
                                case .preview: data.windowStatus = .note
                                case .pannelPreview: data.windowStatus = .pannelNote
                                }
                            }
                        Spacer()
                        HStack(spacing: size / 2) {
                            Image(systemName: "gobackward.5").resizable()
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                                .frame(width: size * 1, height: size * 1)
                                .onTapGesture {
                                    data.isRunning = false
                                    data.currentTimeTick -= Double(data.tickPerBeat / 2)
                                }
                            Image(systemName: !data.isRunning ? "play.circle" : "pause.circle").resizable()
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                                .frame(width: size * 1.2, height: size * 1.2)
                                .onTapGesture {
                                    data.isRunning.toggle()
                                }
                            Image(systemName: "goforward.5").resizable()
                                .renderingMode(.template)
                                .foregroundColor(.blue)
                                .frame(width: size * 1, height: size * 1)
                                .onTapGesture {
                                    data.isRunning = false
                                    data.currentTimeTick += Double(data.tickPerBeat / 2)
                                }
                            Slider(value: $data.currentTimeTick,
                                   in: 0 ... Double(data.chartLengthSecond * data.tickPerBeat * data.bpm / 60))
                        }
                        .padding([.leading,.trailing], size / 2)
                        .padding([.top,.bottom], size / 2)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                    }
                    
                    Spacer(minLength: size)
                    
                    HStack (alignment: .center, spacing: 0) {
                        Group {
                            if shouldShowPannel() {
                                VStack(alignment: .leading) {
                                    // title
                                    Text("PhiStudio / \(String(describing: data.windowStatus).capitalizingFirstLetter())").font(.title2).fontWeight(.bold)
                                    TabView {
                                        NoteSettingsView().environmentObject(data)
                                            .tabItem {
                                                Label("Notes", systemImage: "bolt.horizontal")
                                            }
                                        PropSettingsView().environmentObject(data)
                                            .tabItem {
                                                Label("Props", systemImage: "pencil.and.outline")
                                            }
                                        ChartSettings().environmentObject(data)
                                            .tabItem {
                                                Label("Chart", systemImage: "command")
                                            }
                                        JudgeLineSettings().environmentObject(data)
                                            .tabItem {
                                                Label("JudgeLine", systemImage: "pencil.tip.crop.circle")
                                            }
                                    }
                                    .frame(idealWidth: UIScreen.main.bounds.width / 5 ,maxWidth: UIScreen.main.bounds.width / 4, minHeight: 200, maxHeight: UIScreen.main.bounds.height)
                                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                                }
                                Spacer(minLength: size)
                            }
                        }
                        VStack(alignment: .leading) {
                            Text("\(workSpaceTitle()): @ \(NSString(format: "%.3f", data.currentTimeTick))T/\(NSString(format: "%.3f", data.currentTimeTick / Double(data.tickPerBeat)))B").font(.title2).fontWeight(.bold)
                            workSpace()
                        }
                        .frame(minWidth: 400, maxWidth: UIScreen.main.bounds.width, minHeight: 200, maxHeight: UIScreen.main.bounds.height)
                        .onAppear(perform: {
                            data.rebuildScene()
                        })
                    }
                }
            } else {
                sideNote()
            }
        }
        .padding([.leading,.trailing,.top],size)
        .padding(.bottom,size/2)
        .onReceive(orientationChanged) { _ in
            data.objectWillChange.send()
        }
    }
}
