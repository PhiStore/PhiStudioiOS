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

    var time: Int // measured in tick
    var holdTime: Int? // measured in tick, only used for Hold variable
    init(Type: NOTETYPE, Time: Int, PosX: Double) {
        noteType = Type

        posX = PosX
        width = 1.0

        isFake = false
        fallSpeed = 1
        fallSide = true

        time = Time
    }

    func defaultInit() {
        id = 1
        noteType = NOTETYPE.Tap

        posX = 0
        width = 1.0

        isFake = false
        fallSpeed = 1
        fallSide = true

        time = 1
    }

    public static func == (l: Note, r: Note) -> Bool {
        return l.id == r.id && l.fallSpeed == r.fallSpeed && l.noteType == r.noteType && l.time == r.time && l.holdTime == r.holdTime && l.posX == r.posX && l.width == r.width && l.fallSide == r.fallSide && l.isFake == r.isFake
    }
}

struct PropStatus {
    var time: Int? // in Tick
    var value: Int?
    var nextEasing: EASINGTYPE?
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

    init(_id: Int) {
        id = _id
        noteList = []
    }

    public static func == (l: JudgeLine, r: JudgeLine) -> Bool {
        return l.id == r.id && r.noteList == r.noteList
    }
}

public class ColoredInt: Equatable {
    var value: Int
    var color: Color = .white
    init(_value: Int, _color: Color = Color.white) {
        value = _value
        color = _color
    }

    public static func == (l: ColoredInt, r: ColoredInt) -> Bool {
        return l.value == r.value && l.color == r.color
    }
}

public class DataStructure: ObservableObject {
    // global data structure.
    // @Published meaning the swiftUI should look out if the variable is changing
    // for performance issue, please double check the usage for that
    var id: Int
    @Published var offset: Double
    @Published var bpm: Int // beat per minute
    @Published var changeBpm: Bool // if bpm is changing according to time
    @Published var tickPerSecond: Int // 1 second = x ticks
    @Published var preferTicks: [ColoredInt]
    @Published var chartLength: Int // in ticks
    @Published var musicName: String
    @Published var authorName: String
    @Published var chartLevel: String
    @Published var chartAuthorName: String
    @Published var windowStatus: WINDOWSTATUS
    @Published var listOfJudgeLines: [JudgeLine]
    @Published var currentTime: Double {
        willSet {
            if id == 0 {
                dataK.currentTime = currentTime
            }
        }
    }

    @Published var isRunning: Bool
    @Published var currentLineId: Int?
    init(_id: Int) {
        id = _id
        offset = 0.0
        bpm = 96
        changeBpm = false
        tickPerSecond = 48
        preferTicks = [ColoredInt(_value: 2, _color: Color.blue), ColoredInt(_value: 4, _color: Color.red)]
        chartLength = 120
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        windowStatus = WINDOWSTATUS.pannelNote
        listOfJudgeLines = [JudgeLine(_id: 0)]
        currentTime = 0.0
        isRunning = false
    }
}
