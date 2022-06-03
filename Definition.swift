/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import AVFoundation
import SpriteKit
import SwiftUI
import ZIPFoundation

let _defaultTickPerBeat = 48

// add 'capitalizingFirstLetter()' func for string operations
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }
}

// Used for encoding color, a better solution is wanted.
public struct CodableColor {
    let color: UIColor
}

extension CodableColor: Encodable {
    public func encode(to encoder: Encoder) throws {
        let nsCoder = NSKeyedArchiver(requiringSecureCoding: true)
        color.encode(with: nsCoder)
        var container = encoder.unkeyedContainer()
        try container.encode(nsCoder.encodedData)
    }
}

extension CodableColor: Decodable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let decodedData = try container.decode(Data.self)
        let nsCoder = try NSKeyedUnarchiver(forReadingFrom: decodedData)
        guard let color = UIColor(coder: nsCoder) else {
            struct UnexpectedlyFoundNilError: Error {}
            throw UnexpectedlyFoundNilError()
        }
        self.color = color
    }
}

public extension UIColor {
    func codable() -> CodableColor {
        return CodableColor(color: self)
    }
}

// All currently supported note type
public enum NOTETYPE: String, Equatable, CaseIterable, Codable {
    case Tap, Hold, Flick, Drag
}

func noteColor(type: NOTETYPE) -> SKColor {
    switch type {
    case .Tap: return SKColor(cgColor: CGColor(srgbRed: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1))
    case .Hold: return SKColor(cgColor: CGColor(srgbRed: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1))
    case .Flick: return SKColor(cgColor: CGColor(srgbRed: 234.0 / 255.0, green: 84.0 / 255.0, blue: 104.0 / 255.0, alpha: 1))
    case .Drag: return SKColor(cgColor: CGColor(srgbRed: 239.0 / 255.0, green: 237.0 / 255.0, blue: 125.0 / 255.0, alpha: 1))
    }
}

public enum EASINGTYPE: String, Equatable, CaseIterable, Codable {
    case linear, easeInSine, easeOutSine, easeInOutSine, easeInQuad, easeOutQuad, easeInOutQuad, easeInCubic, easeOutCubic, easeInOutCubic, easeInQuart, easeOutQuart, easeInOutQuart, easeInQuint, easeOutQuint, easeInOutQuint, easeInExpo, easeOutExpo, easeInOutExpo, easeInCirc, easeOutCirc, easeInOutCirc, easeInBack, easeOutBack, easeInOutBack
}

// The following function gives a func from [0,1] -> [0,1] (usually, sometimes exceed, but f(0)=0, f(1)= 1 always holds)
func calculateEasing(x: Double, type: EASINGTYPE) -> Double {
    switch type {
    case .linear: return x
    case .easeInSine: return 1 - cos(x * Double.pi / 2)
    case .easeOutSine: return sin(x * Double.pi / 2)
    case .easeInOutSine: return -(cos(Double.pi * x) - 1) / 2
    case .easeInQuad: return x * x
    case .easeOutQuad: return 1 - (1 - x) * (1 - x)
    case .easeInOutQuad: return (x < 0.5) ? 2 * pow(x, 2) : 1 - pow(-2 * x + 2, 2) / 2
    case .easeInCubic: return x * x * x
    case .easeOutCubic: return 1 - pow(1 - x, 3)
    case .easeInOutCubic: return (x < 0.5) ? 4 * pow(x, 3) : 1 - pow(-2 * x + 2, 3) / 2
    case .easeInQuart: return x * x * x * x
    case .easeOutQuart: return 1 - pow(1 - x, 4)
    case .easeInOutQuart: return (x < 0.5) ? 8 * pow(x, 4) : 1 - pow(-2 * x + 2, 4) / 2
    case .easeInQuint: return x * x * x * x * x
    case .easeOutQuint: return 1 - pow(1 - x, 5)
    case .easeInOutQuint: return (x < 0.5) ? 16 * pow(x, 5) : 1 - pow(-2 * x + 2, 5) / 2
    case .easeInExpo: return (x == 0) ? 0 : pow(2, 10 * x - 10)
    case .easeOutExpo: return (x == 1) ? 1 : 1 - pow(2, -10 * x)
    case .easeInOutExpo: return (x == 0) ? 0 : ((x == 1) ? 1 : ((x < 0.5) ? pow(2, 20 * x - 10) / 2 : (2 - pow(2, -20 * x + 10)) / 2))
    case .easeInCirc: return 1 - sqrt(1 - pow(x, 2))
    case .easeOutCirc: return sqrt(1 - pow(x - 1, 2))
    case .easeInOutCirc: return (x < 0.5) ? (1 - sqrt(1 - pow(2 * x, 2))) / 2 : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
    case .easeInBack: return 2.70158 * pow(x, 3) - 1.70158 * pow(x, 2)
    case .easeOutBack: return 1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2)
    case .easeInOutBack: return (x < 0.5) ? (pow(2 * x, 2) * (7.189819 * x - 2.5949095)) / 2 : (pow(2 * x - 2, 2) * (3.5949095 * (x * 2 - 2) + 2.5949095) + 2) / 2
    }
}

func integrateEasing(type: EASINGTYPE) -> Double {
    switch type {
    case .linear: return 0.5
    case .easeInSine: return 1 - 2 / Double.pi
    case .easeOutSine: return 2 / Double.pi
    case .easeInOutSine: return 0.5
    case .easeInQuad: return 1 / 3
    case .easeOutQuad: return 2 / 3
    case .easeInOutQuad: return 0.5
    case .easeInCubic: return 0.25
    case .easeOutCubic: return 0.75
    case .easeInOutCubic: return 0.5
    case .easeInQuart: return 0.2
    case .easeOutQuart: return 0.8
    case .easeInOutQuart: return 0.5
    case .easeInQuint: return 1 / 6
    case .easeOutQuint: return 5 / 6
    case .easeInOutQuint: return 0.5
    case .easeInExpo: return 0.144128615901
    case .easeOutExpo: return 0.855871384099
    case .easeInOutExpo: return 0.5
    case .easeInCirc: return 1 - Double.pi / 4
    case .easeOutCirc: return Double.pi / 4
    case .easeInOutCirc: return 0.5
    case .easeInBack: return 0.108201666667
    case .easeOutBack: return 0.891798333333
    case .easeInOutBack: return 0.5
    }
}

func integrateOverEasing(x: Double, type: EASINGTYPE) -> Double {
    switch type {
    case .linear: return pow(x, 2) / 2
    case .easeInSine: return x - 2 * sin(Double.pi * x / 2) / Double.pi
    case .easeOutSine: return 2 / Double.pi * (1 - cos(Double.pi * x / 2))
    case .easeInOutSine: return x / 2 - sin(Double.pi * x) / (2 * Double.pi)
    case .easeInQuad: return pow(x, 3) / 3
    case .easeOutQuad: return pow(x, 2) * (3 - x) / 3
    case .easeInOutQuad: return (x < 0.5) ? 2 / 3 * pow(x, 3) : (-4 * pow(x, 3) + 12 * pow(x, 2) - 6 * x + 1) / 6
    case .easeInCubic: return pow(x, 4) / 4
    case .easeOutCubic: return (pow(x, 4) - 4 * pow(x, 3) + 6 * pow(x, 2)) / 4
    case .easeInOutCubic: return (x < 0.5) ? pow(x, 4) : pow(x, 4) - 4 * pow(x, 3) + 6 * pow(x, 2) - 3 * x + 0.5
    case .easeInQuart: return pow(x, 5) / 5
    case .easeOutQuart: return (-pow(x, 5) / 5 + pow(x, 4) - 2 * pow(x, 3) + 2 * pow(x, 2))
    case .easeInOutQuart: return (x < 0.5) ? 8 / 5 * pow(x, 5) : (-1.6 * pow(x, 5) + 8 * pow(x, 4) - 16 * pow(x, 3) + 16 * pow(x, 2) - 7 * x + 1.1)
    case .easeInQuint: return pow(x, 6) / 6
    case .easeOutQuint: return (pow(x, 6) - 6 * pow(x, 5) + 15 * pow(x, 4) - 20 * pow(x, 3) + 15 * pow(x, 2)) / 6
    case .easeInOutQuint: return (x < 0.5) ? 8 / 3 * pow(x, 6) : (16 * pow(x, 6) - 96 * pow(x, 5) + 240 * pow(x, 4) - 320 * pow(x, 3) + 240 * pow(x, 2) - 90 * x + 13) / 6
    case .easeInExpo: return (pow(2, 10 * x) - 1) / (10240 * log(2))
    case .easeOutExpo: return x + (pow(2, -10 * x) - 1) / (10 * log(2))
    case .easeInOutExpo: return (x < 0.5) ? pow(2, 20 * x - 10) / (40 * log(2)) - 1 / (40960 * log(2)) : (x - 1 / 2 - 1 / (40960 * log(2)) + pow(2, -20 * x + 10) / (40 * log(2)))
    case .easeInCirc: return x - 1 / 2 * (x * sqrt(1 - x * x) + asin(x))
    case .easeOutCirc: return ((x - 1) * sqrt(-x * x + 2 * x) + asin(x - 1)) / 2 + Double.pi / 4
    case .easeInOutCirc: return (x < 0.5) ? (-2 * x * sqrt(1 - 4 * x * x) - asin(2 * x) + 4 * x) / 8 : sqrt(-4 * x * x + 8 * x - 3) * (x - 1) / 4 + 0.5 * x + asin(2 * x - 2) / 8
    case .easeInBack: return 2.70158 * x * x * x * x / 4 - 1.70158 * x * x * x / 3
    case .easeOutBack: return x + 2.70158 * pow(x - 1, 4) / 4 + 1.70158 * pow(x - 1, 3) / 3
    case .easeInOutBack: return (x < 0.5) ? (7.189819 * pow(x, 4) / 2 - 2.5949095 * pow(x, 3) * 2 / 3) : (1.4379638 * pow(x, 5) - 3.5949095 * pow(x, 4) + 8.91975866667 * pow(x, 3) - 19.569457 * pow(x, 2) + 20.569457 * x - 6.31914922291)
    }
}

enum WINDOWSTATUS: String, Equatable, CaseIterable, Codable {
    case pannelNote, pannelProp, pannelPreview, note, prop, preview
}

public class Note: Equatable, Identifiable, ObservableObject, Codable {
    @Published public var id: Int // identify usage
    @Published var noteType: NOTETYPE
    @Published var posX: Double
    @Published var width: Double // relative size to default, not implented actually
    @Published var isFake: Bool
    @Published var fallSpeed: Double // HSL per tick, relative to default
    @Published var fallSide: Bool
    @Published var timeTick: Int // measured in tick
    @Published var holdTimeTick: Int // measured in tick, only used for Hold variable
    init(id: Int, noteType: NOTETYPE, posX: Double, timeTick: Int, holdTimeTick: Int) {
        self.id = id
        self.noteType = noteType
        self.posX = posX
        width = 1.0
        isFake = false
        fallSpeed = 1
        fallSide = true
        self.timeTick = timeTick
        self.holdTimeTick = holdTimeTick
    }

    public static func == (l: Note, r: Note) -> Bool {
        return l.id == r.id && l.fallSpeed == r.fallSpeed && l.noteType == r.noteType && l.timeTick == r.timeTick && l.holdTimeTick == r.holdTimeTick && l.posX == r.posX && l.width == r.width && l.fallSide == r.fallSide && l.isFake == r.isFake
    }

    enum CodingKeys: String, CodingKey {
        case id, noteType, posX, width, isFake, fallSpeed, fallSide, timeTick, holdTimeTick
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        noteType = try values.decodeIfPresent(NOTETYPE.self, forKey: .noteType) ?? .Tap
        posX = try values.decodeIfPresent(Double.self, forKey: .posX) ?? 0.5
        width = try values.decodeIfPresent(Double.self, forKey: .width) ?? 1.0
        isFake = try values.decodeIfPresent(Bool.self, forKey: .isFake) ?? false
        fallSpeed = try values.decodeIfPresent(Double.self, forKey: .fallSpeed) ?? 1
        fallSide = try values.decodeIfPresent(Bool.self, forKey: .fallSide) ?? true
        timeTick = try values.decodeIfPresent(Int.self, forKey: .timeTick) ?? 0
        holdTimeTick = try values.decodeIfPresent(Int.self, forKey: .holdTimeTick) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(noteType, forKey: .noteType)
        try container.encode(posX, forKey: .posX)
        try container.encode(width, forKey: .width)
        try container.encode(isFake, forKey: .isFake)
        try container.encode(fallSpeed, forKey: .fallSpeed)
        try container.encode(fallSide, forKey: .fallSide)
        try container.encode(timeTick, forKey: .timeTick)
        try container.encode(holdTimeTick, forKey: .holdTimeTick)
    }
}

class PropStatus: Codable, ObservableObject {
    @Published var timeTick: Int
    @Published var value: Double {
        didSet {
            // limit size to [0,1]
            if value > 1 {
                value = 1
            }
            if value < 0 {
                value = 0
            }
        }
    }

    @Published var followingEasing: EASINGTYPE

    init(timeTick: Int, value: Double, followingEasing: EASINGTYPE) {
        self.timeTick = timeTick
        self.value = value
        self.followingEasing = followingEasing
    }

    enum CodingKeys: String, CodingKey {
        case timeTick, value, followingEasing
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timeTick = try values.decode(Int.self, forKey: .timeTick)
        value = try values.decode(Double.self, forKey: .value)
        followingEasing = try values.decode(EASINGTYPE.self, forKey: .followingEasing)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timeTick, forKey: .timeTick)
        try container.encode(value, forKey: .value)
        try container.encode(followingEasing, forKey: .followingEasing)
    }
}

enum PROPTYPE: String, Equatable, CaseIterable, Codable {
    case controlX, controlY, angle, speed, noteAlpha, lineAlpha, displayRange
}

func descriptionForPropType(type: PROPTYPE) -> String {
    switch type {
    case .controlX:
        return "Control X is to identify the X location of the judgeLine, a number between [0,1], 0 means left and 1 means right, this controls one point on the judgeLine (that is also used to control the movements of other notes)"
    case .controlY:
        return "Control Y is to identify the Y location of the judgeLine, a number between [0,1], 0 means buttom and 1 means top, this controls one point on the judgeLine (that is also used to control the movements of other notes)"
    case .angle:
        return "Angle is to identify the angle of the judgeLine, a number between [0,1), 0 means horizontal and 1/4 means vertical (left being the default fallside) ... eta, this * 2 pi means the angle between the judgeLine and the horizontal line"
    case .speed:
        return "Speed is to control the fallspeed of all notes on the judgeLine, the value should * 10 to get the real result (0.1 means default speed)"
    case .noteAlpha:
        return "Note Alpha is to control the alpha of all notes on the judgeLine, 0 being completely transparent and 1 being completely opaque"
    case .lineAlpha:
        return "Line Alpha is to control the alpha of the judgeLine, 0 being completely transparent and 1 being completely opaque"
    case .displayRange:
        return "Display Range is to control the range of the judgeLine, a number between [0,1], 0 means the note on judgeLine is completely invisible during falldown and 1 means the note on judgeLine is completely visible during falldown, the value is handled with the screen's width"
    }
}

public class JudgeLineProps: Codable, ObservableObject {
    @Published var controlX: [PropStatus]
    @Published var controlY: [PropStatus]
    @Published var angle: [PropStatus]
    @Published var speed: [PropStatus]
    @Published var noteAlpha: [PropStatus]
    @Published var lineAlpha: [PropStatus]
    @Published var displayRange: [PropStatus]

    init() {
        controlX = [PropStatus(timeTick: 0, value: 0.5, followingEasing: .linear)]
        controlY = [PropStatus(timeTick: 0, value: 0.5, followingEasing: .linear)]
        angle = [PropStatus(timeTick: 0, value: 0, followingEasing: .linear)]
        speed = [PropStatus(timeTick: 0, value: 0.1, followingEasing: .linear)]
        noteAlpha = [PropStatus(timeTick: 0, value: 1, followingEasing: .linear)]
        lineAlpha = [PropStatus(timeTick: 0, value: 1, followingEasing: .linear)]
        displayRange = [PropStatus(timeTick: 0, value: 1, followingEasing: .linear)]
    }

    enum CodingKeys: String, CodingKey {
        case controlX, controlY, angle, speed, noteAlpha, lineAlpha, displayRange
    }

    func calculateValue(_ type: PROPTYPE, _ timeTick: Double) -> Double {
        var prop = returnProp(type: type)
        prop = prop.sorted { $0.timeTick < $1.timeTick }
        if timeTick <= Double(prop[0].timeTick) || prop.count == 1 {
            return prop[0].value
        }
        if prop.count > 1 {
            for index in 1 ..< prop.count {
                if Double(prop[index].timeTick) > timeTick {
                    return prop[index - 1].value + calculateEasing(x: (timeTick - Double(prop[index - 1].timeTick)) / Double(prop[index].timeTick - prop[index - 1].timeTick), type: prop[index - 1].followingEasing) * (prop[index].value - prop[index - 1].value)
                }
            }
        }
        return prop[prop.count - 1].value // remain the same at the end
    }

    func calculateNoteDistance(_ startTimeTick: Double, _ endTimeTick: Double) -> Double {
        // this could be improved, using while loops... rewrite it when I have time to do so
        if startTimeTick == endTimeTick {
            return 0
        }
        if startTimeTick > endTimeTick {
            return -calculateNoteDistance(endTimeTick, startTimeTick)
        }
        var result = 0.0
        var indexI = 0
        var indexJ = 0
        speed = speed.sorted { $0.timeTick < $1.timeTick }
        if startTimeTick < Double(speed[0].timeTick) {
            result += speed[0].value * (Double(speed[0].timeTick) - startTimeTick)
        } else {
            for index in 0 ..< speed.count - 1 {
                indexI += 1
                if Double(speed[index].timeTick) < startTimeTick, Double(speed[index + 1].timeTick) > startTimeTick {
                    result += speed[index].value * (Double(speed[index + 1].timeTick) - startTimeTick) + (integrateEasing(type: speed[index].followingEasing) - integrateOverEasing(x: (startTimeTick - Double(speed[index].value)) / Double(speed[index + 1].timeTick - speed[index].timeTick), type: speed[index].followingEasing)) * Double(speed[index + 1].timeTick - speed[index].timeTick) * (speed[index + 1].value - speed[index].value)
                    if Double(speed[index].timeTick) < endTimeTick, Double(speed[index + 1].timeTick) > endTimeTick {
                        return speed[index].value * (endTimeTick - startTimeTick) + (integrateOverEasing(x: (endTimeTick - Double(speed[index].value)) / Double(speed[index + 1].timeTick - speed[index].timeTick), type: speed[index].followingEasing) - integrateOverEasing(x: (startTimeTick - Double(speed[index].value)) / Double(speed[index + 1].timeTick - speed[index].timeTick), type: speed[index].followingEasing)) * Double(speed[index + 1].timeTick - speed[index].timeTick) * (speed[index + 1].value - speed[index].value) * 10
                    }
                    break
                }
            }
            if indexI == speed.count - 1 {
                return speed[speed.count - 1].value * (endTimeTick - startTimeTick) * 10
            }
        }
        indexJ = indexI
        for index in indexI ..< (speed.count - 1) {
            indexJ += 1
            if Double(speed[index + 1].timeTick) < endTimeTick {
                result += speed[index].value * Double(speed[index + 1].timeTick - speed[index].timeTick) + integrateEasing(type: speed[index].followingEasing) * Double(speed[index + 1].timeTick - speed[index].timeTick) * (speed[index + 1].value - speed[index].value)
            } else {
                result += speed[index].value * (endTimeTick - Double(speed[index].timeTick)) + integrateOverEasing(x: (endTimeTick - Double(speed[index].value)) / Double(speed[index + 1].timeTick - speed[index].timeTick), type: speed[index].followingEasing) * (endTimeTick - Double(speed[index].timeTick)) * (speed[index + 1].value - speed[index].value)
                break
            }
        }
        if indexJ == speed.count - 1 {
            result += speed[speed.count - 1].value * (endTimeTick - Double(speed[speed.count - 1].timeTick))
        }
        return result * 10
    }

    // I started these ... as a tmp fix, now that I think about it ... it doesn't really matter (although a bit ugly)
    func returnProp(type: PROPTYPE) -> [PropStatus] {
        switch type {
        case .controlX: return controlX
        case .controlY: return controlY
        case .angle: return angle
        case .speed: return speed
        case .noteAlpha: return noteAlpha
        case .lineAlpha: return lineAlpha
        case .displayRange: return displayRange
        }
    }

    func removePropWhere(type: PROPTYPE, timeTick: Int, value: Double) {
        if timeTick == 0 {
            return
        }
        switch type {
        case .controlX: controlX.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .controlY: controlY.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .angle: angle.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .speed: speed.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .noteAlpha: noteAlpha.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .lineAlpha: lineAlpha.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        case .displayRange: displayRange.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        }
    }

    func removePropAtOffset(type: PROPTYPE, offset: IndexSet) {
        if offset.contains(0) {
            return
        }
        switch type {
        case .controlX: controlX.remove(atOffsets: offset)
        case .controlY: controlY.remove(atOffsets: offset)
        case .angle: angle.remove(atOffsets: offset)
        case .speed: speed.remove(atOffsets: offset)
        case .noteAlpha: noteAlpha.remove(atOffsets: offset)
        case .lineAlpha: lineAlpha.remove(atOffsets: offset)
        case .displayRange: displayRange.remove(atOffsets: offset)
        }
    }

    func appendNewProp(type: PROPTYPE, timeTick: Int, value: Double, followingEasing: EASINGTYPE) {
        switch type {
        case .controlX:
            controlX.removeAll(where: { $0.timeTick == timeTick })
            controlX.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            controlX = controlX.sorted {
                $0.timeTick < $1.timeTick
            }
        case .controlY:
            controlY.removeAll(where: { $0.timeTick == timeTick })
            controlY.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            controlY = controlY.sorted {
                $0.timeTick < $1.timeTick
            }

        case .angle:
            angle.removeAll(where: { $0.timeTick == timeTick })
            angle.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            angle = angle.sorted {
                $0.timeTick < $1.timeTick
            }
        case .speed:
            speed.removeAll(where: { $0.timeTick == timeTick })
            speed.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            speed = speed.sorted {
                $0.timeTick < $1.timeTick
            }
        case .noteAlpha:
            noteAlpha.removeAll(where: { $0.timeTick == timeTick })
            noteAlpha.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            noteAlpha = noteAlpha.sorted {
                $0.timeTick < $1.timeTick
            }
        case .lineAlpha:
            lineAlpha.removeAll(where: { $0.timeTick == timeTick })
            lineAlpha.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            lineAlpha = lineAlpha.sorted {
                $0.timeTick < $1.timeTick
            }
        case .displayRange:
            displayRange.removeAll(where: { $0.timeTick == timeTick })
            displayRange.append(PropStatus(timeTick: timeTick, value: value, followingEasing: followingEasing))
            displayRange = displayRange.sorted {
                $0.timeTick < $1.timeTick
            }
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        controlX = try values.decodeIfPresent([PropStatus].self, forKey: .controlX) ?? []
        controlY = try values.decodeIfPresent([PropStatus].self, forKey: .controlY) ?? []
        angle = try values.decodeIfPresent([PropStatus].self, forKey: .angle) ?? []
        speed = try values.decodeIfPresent([PropStatus].self, forKey: .speed) ?? []
        noteAlpha = try values.decodeIfPresent([PropStatus].self, forKey: .noteAlpha) ?? []
        lineAlpha = try values.decodeIfPresent([PropStatus].self, forKey: .lineAlpha) ?? []
        displayRange = try values.decodeIfPresent([PropStatus].self, forKey: .displayRange) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(controlX, forKey: .controlX)
        try container.encode(controlY, forKey: .controlY)
        try container.encode(angle, forKey: .angle)
        try container.encode(speed, forKey: .speed)
        try container.encode(noteAlpha, forKey: .noteAlpha)
        try container.encode(lineAlpha, forKey: .lineAlpha)
        try container.encode(displayRange, forKey: .displayRange)
    }
}

public class JudgeLine: Identifiable, Equatable, ObservableObject, Codable {
    @Published public var id: Int
    @Published public var description: String
    @Published var noteList: [Note]
    @Published public var props: JudgeLineProps

    init(id: Int) {
        self.id = id
        description = ""
        noteList = []
        props = JudgeLineProps()
    }

    public static func == (l: JudgeLine, r: JudgeLine) -> Bool {
        return l.id == r.id && l.noteList == r.noteList
    }

    enum CodingKeys: String, CodingKey {
        case id, noteList, props, description
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        noteList = try values.decodeIfPresent([Note].self, forKey: .noteList) ?? []
        props = try values.decodeIfPresent(JudgeLineProps.self, forKey: .props) ?? JudgeLineProps()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(description, forKey: .description)
        try container.encode(noteList, forKey: .noteList)
        try container.encode(props, forKey: .props)
    }
}

public class ColoredInt: Equatable, Codable {
    var value: Int
    var color: Color = .white
    init(value: Int, color: Color = Color.white) {
        self.value = value
        self.color = color
    }

    public static func == (l: ColoredInt, r: ColoredInt) -> Bool {
        return l.value == r.value && l.color == r.color
    }

    enum CodingKeys: String, CodingKey {
        case value, color
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        value = try values.decodeIfPresent(Int.self, forKey: .value) ?? 0
        let kColor = try values.decodeIfPresent(CodableColor.self, forKey: .color) ?? CodableColor(color: UIColor.blue)
        color = Color(kColor.color)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(UIColor(color).codable(), forKey: .color)
    }
}

enum COPYRIGHTTYPE: String, Equatable, CaseIterable, Codable {
    case full
    case limited
    case none
}

public class DataStructure: ObservableObject, Codable {
    // global data structure.
    // @Published meaning the swiftUI should look out if the variable is changing
    // for performance issue, please double check the usage for that
    private var scheduleTimer = Timer()
    private var timeWhenStartSecond: Double?
    private var lastStartTick = 0.0
    private let updateTimeIntervalSecond = 0.1
    @Published var offsetSecond: Double
    @Published var bpm: Int {
        didSet {
            rebuildScene()
        }
    }

    @Published var bpmChangeAccrodingToTime: Bool // if bpm is changing according to time
    @Published var tickPerBeat: Int { // 1 beat = x ticks
        didSet {
            defaultHoldTimeTick = tickPerBeat
            rebuildScene()
        }
    }

    @Published var highlightedTicks: [ColoredInt] {
        didSet {
            rebuildScene()
        }
    }

    @Published var maxAcceptableNotes: Double = 31.0
    @Published var defaultHoldTimeTick: Int
    @Published var chartLengthSecond: Int { // in ticks
        didSet {
            if chartLengthSecond < 0 {
                chartLengthSecond = 0
            }
        }
    }

    @Published var musicName: String
    @Published var authorName: String
    @Published var copyright: COPYRIGHTTYPE
    @Published var audioFileURL: URL? {
        didSet {
            if audioFileURL != nil {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL!)
                } catch {
                    print(error)
                }
            }
        }
    }

    @Published var audioPlayer: AVAudioPlayer?
    @Published var imageFile: UIImage? {
        didSet {
            if imageFile != nil {
                noteEditScene.clearAndMakeBackgroundImage()
            }
        }
    }

    @Published var imgFileURL: URL?

    @Published var chartLevel: String
    @Published var chartAuthorName: String
    @Published var windowStatus: WINDOWSTATUS {
        willSet {
            isRunning = false
            rebuildScene(_windowStatus: newValue)
        }
    }

    @Published var locked: Bool
    @Published var currentNoteType: NOTETYPE
    @Published var currentPropType: PROPTYPE {
        didSet {
            rebuildScene()
        }
    }

    @Published var fastHold: Bool

    @Published var listOfJudgeLines: [JudgeLine]
    @Published var editingJudgeLineNumber: Int
    @Published var shouldUpdateFrame: Bool = true
    @Published var currentTimeTick: Double {
        didSet {
            if currentTimeTick < 0 {
                currentTimeTick = 0
                return
            }
            if !isRunning, shouldUpdateFrame {
                rebuildLineAndNote()
            } else {
                if currentTimeTick > Double(chartLengthTick()) {
                    isRunning = false
                    currentTimeTick = Double(chartLengthTick())
                }
            }
        }
    }

    @Published var isRunning: Bool {
        didSet {
            if isRunning {
                if windowStatus == .note || windowStatus == .pannelNote {
                    noteEditScene.startRunning()
                }
                if windowStatus == .prop || windowStatus == .pannelProp {
                    propEditScene.startRunning()
                }
                if windowStatus == .preview || windowStatus == .pannelPreview {
                    chartPreviewScene.startRunning()
                }
                lastStartTick = currentTimeTick
                timeWhenStartSecond = Date().timeIntervalSince1970
                scheduleTimer = Timer.scheduledTimer(timeInterval: updateTimeIntervalSecond, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
                audioPlayer?.volume = 1.0
                audioPlayer?.currentTime = currentTimeTick / Double(tickPerBeat) / Double(bpm) * 60.0 - offsetSecond
                audioPlayer?.play()
            } else {
                if timeWhenStartSecond != nil {
                    if windowStatus == .note || windowStatus == .pannelNote {
                        noteEditScene.pauseRunning()
                    }
                    if windowStatus == .prop || windowStatus == .pannelProp {
                        propEditScene.pauseRunning()
                    }
                    if windowStatus == .preview || windowStatus == .pannelPreview {
                        chartPreviewScene.pauseRunning()
                    }
                    timeWhenStartSecond = nil
                }
                audioPlayer?.stop()
                rebuildLineAndNote()
            }
        }
    }

    var noteEditScene: NoteEditorScene
    var propEditScene: PropEditorScene
    var chartPreviewScene: ChartPreviewScene

    @objc func updateCurrentTime() {
        if isRunning {
            currentTimeTick = (Date().timeIntervalSince1970 - timeWhenStartSecond!) * Double(tickPerBeat) * Double(bpm) / 60.0 + lastStartTick
            if currentTimeTick > Double(chartLengthSecond * tickPerBeat * bpm / 60) {
                isRunning = false
            }
        }
    }

    func chartLengthTick() -> Int {
        return chartLengthSecond * tickPerBeat * bpm / 60
    }

    func tickToSecond(_ tick: Double) -> Double {
        return tick / Double(tickPerBeat * bpm) * 60.0
    }

    func rebuildScene(_windowStatus: WINDOWSTATUS? = nil) {
        var renderStatus: WINDOWSTATUS?
        if _windowStatus == nil {
            renderStatus = windowStatus
        } else {
            renderStatus = _windowStatus
        }
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let size = (screenWidth + screenHeight) / 100
        let canvasSize = CGSize(width: (renderStatus == .pannelNote || renderStatus == .pannelProp || renderStatus == .pannelPreview) ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
        if renderStatus == .note || renderStatus == .pannelNote {
            noteEditScene.size = canvasSize
            noteEditScene.data = self
            noteEditScene.scaleMode = .aspectFit
            noteEditScene.updateCanvasSize()
            noteEditScene.clearAndMakeBackgroundImage()
            noteEditScene.clearAndMakeLint()
            noteEditScene.clearAndMakeJudgeLines()
            noteEditScene.clearAndMakeNotes()
        }
        if renderStatus == .prop || renderStatus == .pannelProp {
            propEditScene.size = canvasSize
            propEditScene.data = self
            propEditScene.scaleMode = .aspectFit
            propEditScene.clearAndMakeIndexLines()
            propEditScene.clearAndMakePropControlNodes()
            propEditScene.clearAndMakeLint()
        }
        if renderStatus == .preview || renderStatus == .pannelPreview {
            chartPreviewScene.size = canvasSize
            chartPreviewScene.data = self
            chartPreviewScene.scaleMode = .aspectFit
            chartPreviewScene.updateCanvasSize()
            chartPreviewScene.prepareStaticJudgeLines()
        }
    }

    func rebuildLineAndNote() {
        if windowStatus == .note || windowStatus == .pannelNote {
            noteEditScene.clearAndMakeJudgeLines()
            noteEditScene.clearAndMakeNotes()
        }
        if windowStatus == .prop || windowStatus == .pannelProp {
            propEditScene.clearAndMakeIndexLines()
            propEditScene.clearAndMakePropControlNodes()
        }
        if windowStatus == .preview || windowStatus == .pannelPreview {
            chartPreviewScene.prepareStaticJudgeLines()
        }
    }

    func saveCache() throws -> Bool {
        // when saving, the imageFile and data itself is handled here, but audioFile is handled when its imported
        let dataEncoded = try JSONEncoder().encode(self)
        let dataEncodedString = String(data: dataEncoded, encoding: .utf8)
        let fm = FileManager.default
        if let documentBaseURL = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let tmpDirURL = documentBaseURL.appendingPathComponent("tmp")
            if !fm.fileExists(atPath: tmpDirURL.path) {
                try fm.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
            }
            let jsonFileURL = tmpDirURL.appendingPathComponent("tmp.json")
            try dataEncodedString?.write(to: jsonFileURL, atomically: true, encoding: .utf8)
            let imagePngURL = tmpDirURL.appendingPathComponent("tmp.png")
            if let imgData = imageFile?.pngData() {
                try? imgData.write(to: imagePngURL)
            }
        }
        return true
    }

    func exportZip() throws -> URL {
        try _ = saveCache()
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.first!
        let archiveURL = url.appendingPathComponent("export.zip")
        let tmpDirURL = url.appendingPathComponent("tmp")
        if fm.fileExists(atPath: archiveURL.path) {
            try fm.removeItem(at: archiveURL)
        }
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: tmpDirURL, options: [.forUploading], error: &error) { zipURL in
            try! fm.moveItem(at: zipURL, to: archiveURL)
        }
        return archiveURL
    }

    func importZip() throws -> Bool {
        let fileManager = FileManager()
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.first!
        let archiveURL = url.appendingPathComponent("import.zip")
        let tmpDirURL = url.appendingPathComponent("tmp")
        try fm.removeItem(at: tmpDirURL)
        try fileManager.unzipItem(at: archiveURL, to: url)
        try _ = loadCache()
        return true
    }

    func loadCache() throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let tmpDirURL = url.appendingPathComponent("tmp")
            if !fm.fileExists(atPath: tmpDirURL.path) {
                try fm.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
                // No cache to load
                return false
            }
            let jsonFileURL = tmpDirURL.appendingPathComponent("tmp.json")
            if fm.fileExists(atPath: jsonFileURL.path) {
                let resolvedData = try String(contentsOf: jsonFileURL)
                let resolvedObject = try JSONDecoder().decode(DataStructure.self, from: resolvedData.data(using: .utf8)!)
                offsetSecond = resolvedObject.offsetSecond
                bpm = resolvedObject.bpm
                bpmChangeAccrodingToTime = resolvedObject.bpmChangeAccrodingToTime
                tickPerBeat = resolvedObject.tickPerBeat
                highlightedTicks = resolvedObject.highlightedTicks
                maxAcceptableNotes = resolvedObject.maxAcceptableNotes
                defaultHoldTimeTick = resolvedObject.defaultHoldTimeTick
                chartLengthSecond = resolvedObject.chartLengthSecond
                musicName = resolvedObject.musicName
                authorName = resolvedObject.authorName
                chartLevel = resolvedObject.chartLevel
                chartAuthorName = resolvedObject.chartAuthorName
                windowStatus = resolvedObject.windowStatus
                locked = resolvedObject.locked
                currentNoteType = resolvedObject.currentNoteType
                currentPropType = resolvedObject.currentPropType
                fastHold = resolvedObject.fastHold
                listOfJudgeLines = resolvedObject.listOfJudgeLines
                editingJudgeLineNumber = resolvedObject.editingJudgeLineNumber
                currentTimeTick = resolvedObject.currentTimeTick
            }
            let imgFileURLtmp = tmpDirURL.appendingPathComponent("tmp.png")
            if fm.fileExists(atPath: imgFileURLtmp.path) {
                do {
                    let imageData = try Data(contentsOf: imgFileURLtmp)
                    let loadedImage = UIImage(data: imageData)
                    imageFile = loadedImage
                } catch {}
                imageFile = UIImage(data: try! Data(contentsOf: imgFileURLtmp))
                imgFileURL = imgFileURLtmp
            }
            let audioFileURLtmp = tmpDirURL.appendingPathComponent("tmp.mp3")
            if fm.fileExists(atPath: audioFileURLtmp.path) {
                audioFileURL = audioFileURLtmp
            }
        }
        return true
    }

    init() {
        offsetSecond = 0.0
        bpm = 160
        bpmChangeAccrodingToTime = false
        tickPerBeat = _defaultTickPerBeat
        highlightedTicks = [ColoredInt(value: 2, color: Color.blue), ColoredInt(value: 4, color: Color.red)]
        maxAcceptableNotes = 31.0
        defaultHoldTimeTick = _defaultTickPerBeat
        chartLengthSecond = 180
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        copyright = .full
        windowStatus = .pannelNote
        listOfJudgeLines = {
            let tmp = JudgeLine(id: 0)
            tmp.description = "Main JudgeLine"
            return [tmp]
        }()
        editingJudgeLineNumber = 0
        currentTimeTick = 0.0
        locked = false
        currentNoteType = .Tap
        currentPropType = .controlX
        fastHold = true
        isRunning = false
        noteEditScene = NoteEditorScene()
        propEditScene = PropEditorScene()
        chartPreviewScene = ChartPreviewScene()
        do {
            try _ = loadCache()
        } catch {}
        rebuildScene()
    }

    enum CodingKeys: String, CodingKey {
        case offsetSecond
        case bpm
        case bpmChangeAccrodingToTime
        case tickPerBeat
        case highlightedTicks
        case maxAcceptableNotes
        case defaultHoldTimeTick
        case chartLengthSecond
        case musicName
        case authorName
        case copyright
        case chartLevel
        case chartAuthorName
        case windowStatus
        case listOfJudgeLines
        case editingJudgeLineNumber
        case currentTimeTick
        case locked
        case currentNoteType
        case currentPropType
        case fastHold
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offsetSecond = try container.decodeIfPresent(Double.self, forKey: .offsetSecond) ?? 0.0
        bpm = try container.decodeIfPresent(Int.self, forKey: .bpm) ?? 160
        bpmChangeAccrodingToTime = try container.decodeIfPresent(Bool.self, forKey: .bpmChangeAccrodingToTime) ?? false
        tickPerBeat = try container.decodeIfPresent(Int.self, forKey: .tickPerBeat) ?? _defaultTickPerBeat
        highlightedTicks = try container.decodeIfPresent([ColoredInt].self, forKey: .highlightedTicks) ?? [ColoredInt(value: 2, color: Color.blue), ColoredInt(value: 4, color: Color.red)]
        maxAcceptableNotes = try container.decodeIfPresent(Double.self, forKey: .maxAcceptableNotes) ?? 31.0
        defaultHoldTimeTick = try container.decodeIfPresent(Int.self, forKey: .defaultHoldTimeTick) ?? _defaultTickPerBeat
        chartLengthSecond = try container.decodeIfPresent(Int.self, forKey: .chartLengthSecond) ?? 180
        musicName = try container.decodeIfPresent(String.self, forKey: .musicName) ?? ""
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName) ?? ""
        chartLevel = try container.decodeIfPresent(String.self, forKey: .chartLevel) ?? ""
        chartAuthorName = try container.decodeIfPresent(String.self, forKey: .chartAuthorName) ?? ""
        copyright = try container.decodeIfPresent(COPYRIGHTTYPE.self, forKey: .copyright) ?? .full
        windowStatus = try container.decodeIfPresent(WINDOWSTATUS.self, forKey: .windowStatus) ?? .pannelNote
        listOfJudgeLines = try container.decodeIfPresent([JudgeLine].self, forKey: .listOfJudgeLines) ?? {
            let tmp = JudgeLine(id: 0)
            tmp.description = "Main JudgeLine"
            return [tmp]
        }()
        editingJudgeLineNumber = try container.decodeIfPresent(Int.self, forKey: .editingJudgeLineNumber) ?? 0
        currentTimeTick = try container.decodeIfPresent(Double.self, forKey: .currentTimeTick) ?? 0.0
        locked = try container.decodeIfPresent(Bool.self, forKey: .locked) ?? false
        currentNoteType = try container.decodeIfPresent(NOTETYPE.self, forKey: .currentNoteType) ?? .Tap
        currentPropType = try container.decodeIfPresent(PROPTYPE.self, forKey: .currentPropType) ?? .controlX
        fastHold = try container.decodeIfPresent(Bool.self, forKey: .fastHold) ?? true
        noteEditScene = NoteEditorScene()
        propEditScene = PropEditorScene()
        chartPreviewScene = ChartPreviewScene()
        isRunning = false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offsetSecond, forKey: .offsetSecond)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(bpmChangeAccrodingToTime, forKey: .bpmChangeAccrodingToTime)
        try container.encode(tickPerBeat, forKey: .tickPerBeat)
        try container.encode(highlightedTicks, forKey: .highlightedTicks)
        try container.encode(maxAcceptableNotes, forKey: .maxAcceptableNotes)
        try container.encode(defaultHoldTimeTick, forKey: .defaultHoldTimeTick)
        try container.encode(chartLengthSecond, forKey: .chartLengthSecond)
        try container.encode(musicName, forKey: .musicName)
        try container.encode(authorName, forKey: .authorName)
        try container.encode(chartLevel, forKey: .chartLevel)
        try container.encode(chartAuthorName, forKey: .chartAuthorName)
        try container.encode(copyright, forKey: .copyright)
        try container.encode(windowStatus, forKey: .windowStatus)
        try container.encode(listOfJudgeLines, forKey: .listOfJudgeLines)
        try container.encode(editingJudgeLineNumber, forKey: .editingJudgeLineNumber)
        try container.encode(currentTimeTick, forKey: .currentTimeTick)
        try container.encode(locked, forKey: .locked)
        try container.encode(currentNoteType, forKey: .currentNoteType)
        try container.encode(currentPropType, forKey: .currentPropType)
        try container.encode(fastHold, forKey: .fastHold)
    }
}
