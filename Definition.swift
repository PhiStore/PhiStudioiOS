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

public class note: Equatable {
    var id: Int?
    var speed: Double? // HSL per tick
    @Published var type: NOTETYPE
    @Published var time: Int // measured in tick
    @Published var holdTime: Int? // measured in tick, only used for Hold variable
    @Published var x: Double
    @Published var width: Double
    @Published var side: Bool
    @Published var isFake: Bool
    init(Type: NOTETYPE,Time: Int, PosX: Double) {
        type = Type
        width = 1.0
        x = PosX
        side = true
        isFake = false
        time = Time
    }

    func defaultInit() {
        id = 1
        speed = 1
        type = NOTETYPE.Tap
        time = 1
        x = 0
        width = 1.0
        side = true
        isFake = false
    }
    public static func == (l:note,r:note) -> Bool{
        return l.id == r.id && l.speed == r.speed && l.type == r.type && l.time == r.time && l.holdTime == r.holdTime && l.x == r.x && l.width == r.width && l.side == r.side && l.isFake == r.isFake
    }
    
}

struct propStatus {
    var time: Int?
    var value: Int?
    var easing: EASINGTYPE?
}

public class judgeLine: Identifiable, Equatable {
    class judgeLineProps {
        var controlX: [propStatus]?
        var controlY: [propStatus]?
        var angle: [propStatus]?
        var speed: [propStatus]?
        var noteAlpha: [propStatus]?
        var lineAlpha: [propStatus]?
        var displayRange: [propStatus]?
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
    var NoteList: [note]
    var props: judgeLineProps?

    init(_id: Int) {
        id = _id
        NoteList = []
    }
    public static func == (l:judgeLine, r:judgeLine) -> Bool{
        return l.id == r.id && r.NoteList == r.NoteList
    }
}

public class coloredInt : Equatable {
    var value: Int
    var color: Color = .white
    init(_value: Int, _color: Color = Color.white) {
        value = _value
        color = _color
    }
    public static func == (l:coloredInt,r:coloredInt) -> Bool{
        return l.value == r.value && l.color == r.color
    }
}

public class mainData: ObservableObject {
    // global data structure.
    // @Published meaning the swiftUI should look out if the variable is changing
    // for performance issue, please double check the usage for that
    var id: Int
    @Published var offset: Double
    @Published var bpm: Int // beat per minute
    @Published var changeBpm: Bool // if bpm is changing according to time
    @Published var tick: Int // 1 second = x ticks
    @Published var preferTicks: [coloredInt]
    @Published var chartLength: Int // in ticks
    @Published var musicName: String
    @Published var authorName: String
    @Published var chartLevel: String
    @Published var chartAuthorName: String
    @Published var windowStatus: WINDOWSTATUS
    @Published var lines: [judgeLine]
    @Published var time: Double {
        willSet{
            if(self.id == 0){
                data_copy.time = time
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
        tick = 48
        preferTicks = [coloredInt(_value: 2, _color: Color.blue), coloredInt(_value: 4, _color: Color.red)]
        chartLength = 120
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        windowStatus = WINDOWSTATUS.pannelNote
        lines = [judgeLine(_id: 0)]
        time = 0.0
        isRunning = false
    }
}
