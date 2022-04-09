import SwiftUI

enum NOTETYPE{
    case Tap
    case Hold
    case Flick
    case Drag
}

enum EASINGTYPE{
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

enum WINDOWSTATUS{
    case pannelNote
    case pannelProp
    case note
    case prop
}

class note{
    var id: Int?
    var speed: Double? // HSL per tick
    @Published var type: NOTETYPE?
    @Published var time: Int? // measured in tick
    @Published var holdTime: Int? // measured in tick, only used for Hold variable
    @Published var x: Double?
    @Published var width: Double?
    @Published var side: Bool?
    @Published var isFake: Bool?
    init(){
        width = 1
        side = true
        isFake = false
    }
    
    func defaultInit(){
        id = 1
        speed = 1
        type = NOTETYPE.Tap
        time = 1
        x = 0
        width = 1
        side = true
        isFake = false
    }
}

class propStatus{
    var time: Int?
    var value: Int?
    var easing: EASINGTYPE?
}

class judgeLine{
    class judgeLineProps{
        var controlX: [propStatus]?
        var controlY: [propStatus]?
        var angle: [propStatus]?
        var speed: [propStatus]?
        var noteAlpha: [propStatus]?
        var lineAlpha: [propStatus]?
        var displayRange:[propStatus]?
        init(){
            controlX = []
            controlY = []
            angle = []
            speed = []
            noteAlpha = []
            lineAlpha = []
            displayRange = []
        }
    }
    var id: Int?
    var NoteList: [note]?
    var props: judgeLineProps?
    
    func defaultInit(){
        id = 1
        let n = note()
        n.defaultInit()
        NoteList = [n]
        props = judgeLineProps()
    }
}

class mainData: ObservableObject{
    // global data structure.
    // @Published meaning the swiftUI should look out if the variable is changing
    // for performance issue, please double check the usage for that
    @Published var offset: Double
    @Published var bpm: Int
    @Published var changeBpm: Bool // if bpm is changing according to time
    @Published var tick: Int
    @Published var chartLength: Int
    @Published var musicName: String
    @Published var authorName: String
    @Published var chartLevel: String
    @Published var chartAuthorName: String
    @Published var windowStatus: WINDOWSTATUS
    @Published var time: Double
    @Published var judgeLines: [judgeLine]
    init(){
        offset = 0.0
        bpm = 96
        changeBpm = false
        tick = 48
        chartLength = 120
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        windowStatus = WINDOWSTATUS.pannelNote
        time = 0.0
        judgeLines = []
    }
    
    func defaultInit(){
        let j = judgeLine()
        j.defaultInit()
        judgeLines = [j]
    }
}
