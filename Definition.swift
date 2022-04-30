import AVFoundation
import SpriteKit
import SwiftUI

public enum NOTETYPE {
    case Tap
    case Hold
    case Flick
    case Drag
}

enum EASINGTYPE {
    case linear
    case easeInSine
    case easeOutSine
    case easeInOutSine
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    case easeInBack
    case easeOutBack
    case easeInOutBack
    case easeInElastic
    case easeOutElastic
    case easeInOutElastic
    case easeInBounce
    case easeOutBounce
    case easeInOutBounce
}

enum WINDOWSTATUS {
    case pannelNote
    case pannelProp
    case note
    case prop
}

public class Note: Equatable {
    var id: Int? // identify usage
    var noteType: NOTETYPE

    var posX: Double
    var width: Double // relative size to default, keep 1 for most cases

    var isFake: Bool
    var fallSpeed: Double // HSL per tick, relative to default
    var fallSide: Bool

    var timeTick: Int // measured in tick
    var holdTimeTick: Int? // measured in tick, only used for Hold variable
    init(noteType: NOTETYPE, posX: Double, timeTick: Int) {
        self.noteType = noteType

        self.posX = posX
        width = 1.0

        isFake = false
        fallSpeed = 1
        fallSide = true

        self.timeTick = timeTick
    }

    public static func == (l: Note, r: Note) -> Bool {
        return l.id == r.id && l.fallSpeed == r.fallSpeed && l.noteType == r.noteType && l.timeTick == r.timeTick && l.holdTimeTick == r.holdTimeTick && l.posX == r.posX && l.width == r.width && l.fallSide == r.fallSide && l.isFake == r.isFake
    }
}

struct PropStatus {
    var timeTick: Int?
    var value: Int?
    var followingEasing: EASINGTYPE?
}

public class JudgeLine: Identifiable, Equatable {
    class JudgeLineProps {
        var controlX: [PropStatus]?
        var controlY: [PropStatus]?
        var angle: [PropStatus]?
        var speed: [PropStatus]?
        var noteAlpha: [PropStatus]?
        var lineAlpha: [PropStatus]?
        var displayRange: [PropStatus]?
        init() {
            controlX = []
            controlY = []
            angle = []
            speed = []
            noteAlpha = []
            lineAlpha = []
            displayRange = []
        }
    }

    public var id: Int
    var noteList: [Note]
    var props: JudgeLineProps?

    init(id: Int) {
        self.id = id
        noteList = []
    }

    public static func == (l: JudgeLine, r: JudgeLine) -> Bool {
        return l.id == r.id && r.noteList == r.noteList
    }
}

public class ColoredInt: Equatable {
    var value: Int
    var color: Color = .white
    init(value: Int, color: Color = Color.white) {
        self.value = value
        self.color = color
    }

    public static func == (l: ColoredInt, r: ColoredInt) -> Bool {
        return l.value == r.value && l.color == r.color
    }
}

public class DataStructure: ObservableObject {
    // global data structure.
    // @Published meaning the swiftUI should look out if the variable is changing
    // for performance issue, please double check the usage for that
    private var id: Int // mark if it's data(0) or dataK(1)
    private var scheduleTimer = Timer()
    private var timeWhenStartSecond: Double?
    private var lastStartTick = 0.0
    private let updateTimeIntervalSecond = 0.5
    @Published var offsetSecond: Double
    @Published var bpm: Int { // beat per minute
        didSet {
            if id == 0 {
                dataK.bpm = bpm
            }
        }
    }

    @Published var bpmChangeAccrodingToTime: Bool // if bpm is changing according to time
    @Published var tickPerBeat: Int // 1 beat = x ticks
    @Published var highlightedTicks: [ColoredInt] {
        didSet {
            if id == 0 {
                dataK.highlightedTicks = highlightedTicks
            }
        }
    }

    @Published var chartLengthSecond: Int { // in ticks
        didSet {
            if chartLengthSecond < 0 {
                chartLengthSecond = 0
            }
            if id == 0 {
                dataK.chartLengthSecond = chartLengthSecond
            }
        }
    }

    @Published var musicName: String
    @Published var authorName: String
    @Published var audioFileURL: URL? {
        didSet {
            if audioFileURL != nil {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
                    //                    audioPlayer?.prepareToPlay()
                } catch {}
            }
        }
    }

    @Published var audioPlayer: AVAudioPlayer?
    @Published var imageFile: UIImage? {
        didSet {
            if id == 0 {
                dataK.imageFile = imageFile
            }
        }
    }

    @Published var imgFile: URL?
    @Published var chartLevel: String
    @Published var chartAuthorName: String
    @Published var windowStatus: WINDOWSTATUS
    @Published var currentNoteType: NOTETYPE
    @Published var listOfJudgeLines: [JudgeLine]
    @Published var currentTimeTick: Double { // in ticks
        didSet {
            if id == 0 {
                // sync with dataK.
                dataK.currentTimeTick = currentTimeTick
            }
        }
    }

    @Published var isRunning: Bool {
        didSet {
            if id == 0 {
                dataK.isRunning = isRunning
                if isRunning {
                    audioPlayer?.volume = 1.0
                    audioPlayer?.currentTime = currentTimeTick / Double(tickPerBeat) / Double(bpm) * 60.0 - offsetSecond
                    audioPlayer?.play()
                    lastStartTick = currentTimeTick
                    timeWhenStartSecond = Date().timeIntervalSince1970
                    scheduleTimer = Timer.scheduledTimer(timeInterval: updateTimeIntervalSecond, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
                } else {
                    audioPlayer?.stop()
                    if let t = timeWhenStartSecond {
                        currentTimeTick = (Date().timeIntervalSince1970 - t) * Double(tickPerBeat) * Double(bpm) / 60.0 + lastStartTick
                        timeWhenStartSecond = nil
                    }
                }
            }
        }
    }

    @objc func updateCurrentTime() {
        if isRunning {
            currentTimeTick = (Date().timeIntervalSince1970 - timeWhenStartSecond!) * Double(tickPerBeat) * Double(bpm) / 60.0 + lastStartTick
            if(currentTimeTick > Double(chartLengthSecond * tickPerBeat * bpm / 60)){
                isRunning = false
            }
        }
    }

    init(_id: Int) {
        id = _id
        offsetSecond = 0.0
        bpm = 160
        bpmChangeAccrodingToTime = false
        tickPerBeat = 48
        highlightedTicks = [ColoredInt(value: 2, color: Color.blue), ColoredInt(value: 4, color: Color.red)]
        chartLengthSecond = 180
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        windowStatus = WINDOWSTATUS.pannelNote
        listOfJudgeLines = [JudgeLine(id: 0)]
        currentTimeTick = 0.0
        currentNoteType = NOTETYPE.Tap
        isRunning = false
    }
}
