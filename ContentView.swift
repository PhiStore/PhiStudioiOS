// ContentView.swift
// Author: TianKai Ma
// Last Reviewed: 2022-05-17 00:38
import SwiftUI

struct ContentView: View {
    // These variables are used for location and alignment
    // Guide: reserve size*2 for boundaries, keep everything fit in place
    var screenHeight = UIScreen.main.bounds.height
    var screenWidth = UIScreen.main.bounds.width
    var size = (UIScreen.main.bounds.width + UIScreen.main.bounds.height) / 100
    
    @StateObject private var data = DataStructure()
    @State private var updateToggle = false
    
    var pannelGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                data.isRunning = false
                switch data.windowStatus {
                case .pannelProp: data.windowStatus = .prop
                case .prop: data.windowStatus = .pannelProp
                case .pannelNote: data.windowStatus = .note
                case .note: data.windowStatus = .pannelNote
                case .pannelPreview: data.windowStatus = .preview
                case .preview: data.windowStatus = .pannelPreview
                }
                // FIXME: Logic problem here, editor size not changing properly when the button is handled; the problem here might be the refresh is called before the canvas realize it size is updated, so a fix to call the following function somewhere in definition.swift might help...
                data.objectWillChange.send()
                updateToggle.toggle()
            }
    }
    
    func shouldShowPannel() -> Bool {
        return (data.windowStatus == WINDOWSTATUS.pannelNote || data.windowStatus == WINDOWSTATUS.pannelProp || data.windowStatus == WINDOWSTATUS.pannelPreview)
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
                case .Tap: data.currentNoteType = .Hold
                case .Hold: data.currentNoteType = .Flick
                case .Flick: data.currentNoteType = .Drag
                case .Drag: data.currentNoteType = .Tap
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
    
    func workSpaceTitle() -> String {
        switch data.windowStatus {
        case .note: return "Note Editor (on Line \(data.editingJudgeLineNumber))"
        case .pannelNote: return "Note Editor (on Line \(data.editingJudgeLineNumber))"
        case .prop: return "Prop Editor"
        case .pannelProp: return "Prop Editor"
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
    
    @ViewBuilder
    func workSpace() -> some View {
        switch data.windowStatus {
        case .pannelNote:
            NoteEditorView().environmentObject(data)
                .frame(width: screenWidth * 3 / 4 - size * 6, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        case .note:
            NoteEditorView().environmentObject(data)
                .frame(width: screenWidth - size * 4, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        case .pannelProp:
            PropEditorView().environmentObject(data)
                .frame(width: screenWidth * 3 / 4 - size * 6, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        case .prop:
            PropEditorView().environmentObject(data)
                .frame(width: screenWidth - size * 4, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        case .pannelPreview:
            ChartPreview().environmentObject(data)
                .frame(width: screenWidth * 3 / 4 - size * 6, height: screenHeight - size * 8)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.blue))
                .fixedSize()
        case .preview: Text("Unfinished")
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            // left pannel
            if shouldShowPannel() {
                LazyVStack(alignment: .leading) {
                    // title
                    Text("PhiStudio").font(.title2).fontWeight(.bold)
                    // FIXME: The tabItem is showing different on iPad, especially when you add four tabs and more (the VStack will then turns into a HStack... for some reason), I'm not sure whether that is a feature or a bug, but please take care (I've searched a lot about these and the following code might be the best way Apple intended, but the problem just won't fix itself)
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
            Image(systemName: workSpaceIcon()).resizable()
                .renderingMode(.template)
                .frame(width: size * 2, height: size * 2)
                .offset(x: -screenWidth / 2 + size * 15, y: -screenHeight / 2 + size * 3)
                .gesture(changeEditorGesture)
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
