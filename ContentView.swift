// ContentView.swift
// Author: TianKai Ma
// Last Reviewed: 2022-05-22 20:37
import SwiftUI

struct ContentView: View {
    // These variables are used for location and alignment
    // Guide: reserve size*2 for boundaries, keep everything fit in place
    var screenHeight = UIScreen.main.bounds.height
    var screenWidth = UIScreen.main.bounds.width
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100

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
        case .note: return "Note Editor (on Line \(data.editingJudgeLineNumber))"
        case .pannelNote: return "Note Editor (on Line \(data.editingJudgeLineNumber))"
        case .prop: return "Prop Editor (on Line \(data.editingJudgeLineNumber))"
        case .pannelProp: return "Prop Editor (on Line \(data.editingJudgeLineNumber))"
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
        case .preview: return "gamecontroller"
        case .pannelPreview: return "gamecontroller"
        }
    }

    @ViewBuilder
    func workSpace() -> some View {
        if data.windowStatus == .pannelNote || data.windowStatus == .note {
            NoteEditorView().environmentObject(data)
                .frame(width: (data.windowStatus == .pannelNote) ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        } else {
            if data.windowStatus == .pannelProp || data.windowStatus == .prop {
                PropEditorView().environmentObject(data)
                    .frame(width: (data.windowStatus == .pannelProp) ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                    .fixedSize()
            } else {
                if data.windowStatus == .pannelPreview || data.windowStatus == .preview {
                    ChartPreview().environmentObject(data)
                        .frame(width: (data.windowStatus == .pannelPreview) ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                        .fixedSize()
                }
            }
        }
    }

    var body: some View {
        ZStack(alignment: .center) {
            // left pannel
            if shouldShowPannel() {
                LazyVStack(alignment: .leading) {
                    // title
                    Text("PhiStudio").font(.title2).fontWeight(.bold)
                    TabView {
                        ChartSettings().environmentObject(data)
                            .tabItem {
                                Label("Chart", systemImage: "command")
                            }
                        JudgeLineSettings().environmentObject(data)
                            .tabItem {
                                Label("JudgeLine", systemImage: "pencil.tip.crop.circle")
                            }
                        if data.windowStatus == .note || data.windowStatus == .pannelNote {
                            NoteSettingsView().environmentObject(data)
                                .tabItem {
                                    Label("Notes", systemImage: "bolt.horizontal")
                                }
                        } else {
                            if data.windowStatus == .prop || data.windowStatus == .pannelProp {
                                PropSettingsView().environmentObject(data)
                                    .tabItem {
                                        Label("Props", systemImage: "pencil.and.outline")
                                    }
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
            LazyVStack(alignment: .leading) {
                Text("\(workSpaceTitle()): @ \(NSString(format: "%.3f", data.currentTimeTick))T/\(NSString(format: "%.3f", data.currentTimeTick / Double(data.tickPerBeat)))B").font(.title2).fontWeight(.bold)
                workSpace()
            }
            .frame(width: shouldShowPannel() ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
            .offset(x: shouldShowPannel() ? screenWidth / 8 + size : 0, y: size * 2)
            .fixedSize()
            .onAppear(perform: {
                data.rebuildScene()
            })
            Image(systemName: shouldShowPannel() ? "command.circle" : "command.circle.fill").resizable()
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 3, y: -screenHeight / 2 + size * 3)
                .onTapGesture {
                    // change if pannel is shown
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
                .offset(x: -screenWidth / 2 + size * 6, y: -screenHeight / 2 + size * 3)
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
                .offset(x: -screenWidth / 2 + size * 9, y: -screenHeight / 2 + size * 3)
                .onTapGesture {
                    data.rebuildScene()
                    data.objectWillChange.send()
                }
            Image(systemName: data.locked ? "lock.circle.fill" : "lock.circle").resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 12, y: -screenHeight / 2 + size * 3)
                .onTapGesture {
                    data.locked.toggle()
                }
            Image(systemName: workSpaceIcon()).resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 15, y: -screenHeight / 2 + size * 3)
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
                    .frame(width: size * 1, height: size * 1)
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
                       in: 0 ... Double(data.chartLengthSecond * data.tickPerBeat * data.bpm / 60)).frame(width: screenWidth / 2 - 3 / 2 * size)
            }.frame(width: screenWidth / 2 + size * 4, height: size * 2)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .offset(x: screenWidth / 4 - size * 4, y: -screenHeight / 2 + size * 3)
                .fixedSize()
        }
    }
}
