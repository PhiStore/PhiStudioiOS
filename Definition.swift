import AVFoundation
import SpriteKit
import SwiftUI
import ZIPFoundation

let _defaultTickPerBeat = 48
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

public enum NOTETYPE: String, Equatable, CaseIterable, Codable {
    case Tap
    case Hold
    case Flick
    case Drag
}

enum EASINGTYPE: String, Equatable, CaseIterable, Codable {
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
}

func calculateEasing(x: Double, type: EASINGTYPE) -> Double {
    switch type {
    case .linear:
        return x
    case .easeInSine:
        return 1 - cos(x * Double.pi / 2)
    case .easeOutSine:
        return sin(x * Double.pi / 2)
    case .easeInOutSine:
        return -(cos(Double.pi * x) - 1) / 2
    case .easeInQuad:
        return x * x
    case .easeOutQuad:
        return 1 - (1 - x) * (1 - x)
    case .easeInOutQuad:
        return (x < 0.5) ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2
    case .easeInCubic:
        return x * x * x
    case .easeOutCubic:
        return 1 - pow(1 - x, 3)
    case .easeInOutCubic:
        return (x < 0.5) ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    case .easeInQuart:
        return x * x * x * x
    case .easeOutQuart:
        return 1 - pow(1 - x, 4)
    case .easeInOutQuart:
        return (x < 0.5) ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2
    case .easeInQuint:
        return x * x * x * x * x
    case .easeOutQuint:
        return 1 - pow(1 - x, 5)
    case .easeInOutQuint:
        return (x < 0.5) ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2
    case .easeInExpo:
        return (x == 0) ? 0 : pow(2, 10 * x - 10)
    case .easeOutExpo:
        return (x == 1) ? 1 : 1 - pow(2, -10 * x)
    case .easeInOutExpo:
        return (x == 0) ? 0 : ((x == 1) ? 1 : ((x < 0.5) ? pow(2, 20 * x - 10) / 2 : (2 - pow(2, -20 * x + 10)) / 2))
    case .easeInCirc:
        return 1 - sqrt(1 - pow(x, 2))
    case .easeOutCirc:
        return sqrt(1 - pow(x - 1, 2))
    case .easeInOutCirc:
        return (x < 0.5) ? (1 - sqrt(1 - pow(2 * x, 2))) / 2 : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
    case .easeInBack:
        return 2.70158 * x * x * x - 1.70158 * x * x
    case .easeOutBack:
        return 1 + 2.70158 * pow(x - 1, 3) + 1.70158 * pow(x - 1, 2)
    case .easeInOutBack:
        return (x < 0.5) ? (pow(2 * x, 2) * (7.189819 * x - 2.5949095)) / 2 : (pow(2 * x - 2, 2) * (3.5949095 * (x * 2 - 2) + 2.5949095) + 2) / 2
    }
}

enum WINDOWSTATUS: String, Equatable, CaseIterable, Codable {
    case pannelNote
    case pannelProp
    case pannelPreview
    case note
    case prop
    case preview
}

public class Note: Equatable, Identifiable, ObservableObject, Codable {
    @Published public var id: Int // identify usage
    @Published var noteType: NOTETYPE
    @Published var posX: Double
    @Published var width: Double // relative size to default, keep 1 for most cases
    @Published var isFake: Bool
    @Published var fallSpeed: Double // HSL per tick, relative to default
    @Published var fallSide: Bool
    @Published var timeTick: Int // measured in tick
    @Published var holdTimeTick: Int // measured in tick, only used for Hold variable
    init(id: Int, noteType: NOTETYPE, posX: Double, timeTick: Int) {
        self.id = id
        self.noteType = noteType
        self.posX = posX
        width = 1.0
        isFake = false
        fallSpeed = 1
        fallSide = true
        self.timeTick = timeTick
        holdTimeTick = _defaultTickPerBeat
    }

    public static func == (l: Note, r: Note) -> Bool {
        return l.id == r.id && l.fallSpeed == r.fallSpeed && l.noteType == r.noteType && l.timeTick == r.timeTick && l.holdTimeTick == r.holdTimeTick && l.posX == r.posX && l.width == r.width && l.fallSide == r.fallSide && l.isFake == r.isFake
    }

    enum CodingKeys: String, CodingKey {
        case id, noteType, posX, width, isFake, fallSpeed, fallSide, timeTick, holdTimeTick
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        noteType = try values.decode(NOTETYPE.self, forKey: .noteType)
        posX = try values.decode(Double.self, forKey: .posX)
        width = try values.decode(Double.self, forKey: .width)
        isFake = try values.decode(Bool.self, forKey: .isFake)
        fallSpeed = try values.decode(Double.self, forKey: .fallSpeed)
        fallSide = try values.decode(Bool.self, forKey: .fallSide)
        timeTick = try values.decode(Int.self, forKey: .timeTick)
        holdTimeTick = try values.decode(Int.self, forKey: .holdTimeTick)
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

class PropStatus: Codable {
    var timeTick: Int
    var value: Double
    var followingEasing: EASINGTYPE

    init(timeTick: Int, value: Double, followingEasing: EASINGTYPE) {
        self.timeTick = timeTick
        self.value = value
        self.followingEasing = followingEasing
    }
}

enum PROPTYPE: String, Equatable, CaseIterable, Codable {
    case controlX
    case controlY
    case angle
    case speed
    case noteAlpha
    case lineAlpha
    case displayRange
}

public class JudgeLineProps: Codable {
    @Published var controlX: [PropStatus]
    @Published var controlY: [PropStatus]
    @Published var angle: [PropStatus]
    @Published var speed: [PropStatus]
    @Published var noteAlpha: [PropStatus]
    @Published var lineAlpha: [PropStatus]
    @Published var displayRange: [PropStatus]

    init() {
        controlX = [PropStatus(timeTick: 0, value: 0.5, followingEasing: .linear)]
        controlY = []
        angle = []
        speed = []
        noteAlpha = []
        lineAlpha = []
        displayRange = []
    }

    enum CodingKeys: String, CodingKey {
        case controlX, controlY, angle, speed, noteAlpha, lineAlpha, displayRange
    }

    func returnProp(type: PROPTYPE) -> [PropStatus] {
        switch type {
        case .controlX:
            return controlX
        case .controlY:
            return controlY
        case .angle:
            return angle
        case .speed:
            return speed
        case .noteAlpha:
            return noteAlpha
        case .lineAlpha:
            return lineAlpha
        case .displayRange:
            return displayRange
        }
    }

    func removePropWhere(timeTick: Int, value: Double) {
        controlX.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        controlY.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        angle.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        speed.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        noteAlpha.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        lineAlpha.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
        displayRange.removeAll(where: { $0.timeTick == timeTick && fabs($0.value - value) < 0.1 })
    }

    func removePropAtOffset(type: PROPTYPE, offset: IndexSet) {
        switch type {
        case .controlX:
            controlX.remove(atOffsets: offset)
        case .controlY:
            controlY.remove(atOffsets: offset)
        case .angle:
            angle.remove(atOffsets: offset)
        case .speed:
            speed.remove(atOffsets: offset)
        case .noteAlpha:
            noteAlpha.remove(atOffsets: offset)
        case .lineAlpha:
            lineAlpha.remove(atOffsets: offset)
        case .displayRange:
            displayRange.remove(atOffsets: offset)
        }
    }

    func updateProp(type: PROPTYPE, timeTick: Int, value: Double?, followingEasing: EASINGTYPE?) {
        switch type {
        case .controlX:
            if value != nil {
                controlX.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                controlX.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .controlY:
            if value != nil {
                controlY.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                controlY.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .angle:
            if value != nil {
                angle.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                angle.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .speed:
            if value != nil {
                speed.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                speed.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .noteAlpha:
            if value != nil {
                noteAlpha.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                noteAlpha.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .lineAlpha:
            if value != nil {
                lineAlpha.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                lineAlpha.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
        case .displayRange:
            if value != nil {
                displayRange.first(where: { $0.timeTick == timeTick })?.value = value!
            }
            if followingEasing != nil {
                displayRange.first(where: { $0.timeTick == timeTick })?.followingEasing = followingEasing!
            }
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
        controlX = try values.decode([PropStatus].self, forKey: .controlX)
        controlY = try values.decode([PropStatus].self, forKey: .controlY)
        angle = try values.decode([PropStatus].self, forKey: .angle)
        speed = try values.decode([PropStatus].self, forKey: .speed)
        noteAlpha = try values.decode([PropStatus].self, forKey: .noteAlpha)
        lineAlpha = try values.decode([PropStatus].self, forKey: .lineAlpha)
        displayRange = try values.decode([PropStatus].self, forKey: .displayRange)
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
    @Published var noteList: [Note]
    @Published public var props: JudgeLineProps

    init(id: Int) {
        self.id = id
        noteList = []
        props = JudgeLineProps()
    }

    public static func == (l: JudgeLine, r: JudgeLine) -> Bool {
        return l.id == r.id && l.noteList == r.noteList
    }

    enum CodingKeys: String, CodingKey {
        case id, noteList, props
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        noteList = try values.decode([Note].self, forKey: .noteList)
        do {
            props = try values.decode(JudgeLineProps.self, forKey: .props)
        } catch {
            props = JudgeLineProps()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
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
        value = try values.decode(Int.self, forKey: .value)
        color = Color(try values.decode(CodableColor.self, forKey: .color).color)
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
    private let updateTimeIntervalSecond = 0.5
    @Published var offsetSecond: Double
    @Published var bpm: Int {
        didSet {
            rebuildScene()
        }
    }

    @Published var bpmChangeAccrodingToTime: Bool // if bpm is changing according to time
    @Published var tickPerBeat: Int { // 1 beat = x ticks
        didSet {
            rebuildScene()
        }
    }

    @Published var highlightedTicks: [ColoredInt] {
        didSet {
            rebuildScene()
        }
    }

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
                } catch {}
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
            objectWillChange.send()
            rebuildScene()
        }
    }

    @Published var locked: Bool
    @Published var currentNoteType: NOTETYPE
    @Published var currentPropType: PROPTYPE {
        didSet {
            rebuildScene()
        }
    }

    @Published var listOfJudgeLines: [JudgeLine]
    @Published var editingJudgeLineNumber: Int
    @Published var shouldUpdateFrame: Bool = true // tmp variable passed to identify whether the frame should be refreshed, this should NOT be included in the exportFile
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
                noteEditScene.startRunning()
                propEditScene.startRunning()
                lastStartTick = currentTimeTick
                timeWhenStartSecond = Date().timeIntervalSince1970
                scheduleTimer = Timer.scheduledTimer(timeInterval: updateTimeIntervalSecond, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
                audioPlayer?.volume = 1.0
                audioPlayer?.currentTime = currentTimeTick / Double(tickPerBeat) / Double(bpm) * 60.0 - offsetSecond
                audioPlayer?.play()
            } else {
                noteEditScene.pauseRunning()
                propEditScene.pauseRunning()
                if let t = timeWhenStartSecond {
                    shouldUpdateFrame = false
                    currentTimeTick = min((Date().timeIntervalSince1970 - t) * Double(tickPerBeat) * Double(bpm) / 60.0 + lastStartTick, Double(chartLengthTick()))
                    timeWhenStartSecond = nil
                    shouldUpdateFrame = true
                }
                audioPlayer?.stop()
            }
        }
    }

    var noteEditScene: NoteEditorScene
    var propEditScene: PropEditorScene

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

    func rebuildScene() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let size = (screenWidth + screenHeight) / 100
        let canvasSize = CGSize(width: (windowStatus == .pannelNote || windowStatus == .pannelProp) ? screenWidth * 3 / 4 - size * 6 : screenWidth - size * 4, height: screenHeight - size * 8)
        noteEditScene.size = canvasSize
        noteEditScene.data = self
        noteEditScene.scaleMode = .aspectFit
        noteEditScene.updateCanvasSize()
        noteEditScene.clearAndMakeBackgroundImage()
        noteEditScene.clearAndMakeLint()
        noteEditScene.clearAndMakeJudgeLines()
        noteEditScene.clearAndMakeNotes()
//        noteEditScene.view?.showsFPS = true
//        noteEditScene.view?.showsNodeCount = true
        propEditScene.size = canvasSize
        propEditScene.data = self
        propEditScene.scaleMode = .aspectFit
        propEditScene.clearAndMakeIndexLines()
        propEditScene.clearAndMakePropControlNodes()
        propEditScene.clearAndMakeLint()
    }

    func rebuildLineAndNote() {
        noteEditScene.clearAndMakeJudgeLines()
        noteEditScene.clearAndMakeNotes()
        propEditScene.clearAndMakeIndexLines()
        propEditScene.clearAndMakePropControlNodes()
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
        try fm.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.unzipItem(at: archiveURL, to: tmpDirURL)
        try _ = loadCache()
        return true
    }

    func loadCache() throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let tmpDirURL = url.appendingPathComponent("tmp")
            try fm.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
            let jsonFileURL = tmpDirURL.appendingPathComponent("tmp.json")
            if fm.fileExists(atPath: jsonFileURL.path) {
                let resolvedData = try String(contentsOf: jsonFileURL)
                let resolvedObject = try JSONDecoder().decode(DataStructure.self, from: resolvedData.data(using: .utf8)!)
                offsetSecond = resolvedObject.offsetSecond
                bpm = resolvedObject.bpm
                bpmChangeAccrodingToTime = resolvedObject.bpmChangeAccrodingToTime
                tickPerBeat = resolvedObject.tickPerBeat
                highlightedTicks = resolvedObject.highlightedTicks
                chartLengthSecond = resolvedObject.chartLengthSecond
                musicName = resolvedObject.musicName
                authorName = resolvedObject.authorName
                chartLevel = resolvedObject.chartLevel
                chartAuthorName = resolvedObject.chartAuthorName
                windowStatus = resolvedObject.windowStatus
                locked = resolvedObject.locked
                currentNoteType = resolvedObject.currentNoteType
                currentPropType = resolvedObject.currentPropType
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
        chartLengthSecond = 180
        musicName = ""
        authorName = ""
        chartLevel = ""
        chartAuthorName = ""
        copyright = .full
        windowStatus = WINDOWSTATUS.pannelNote
        listOfJudgeLines = [JudgeLine(id: 0)]
        editingJudgeLineNumber = 0
        currentTimeTick = 0.0
        locked = false
        currentNoteType = NOTETYPE.Tap
        currentPropType = PROPTYPE.controlX
        isRunning = false
        noteEditScene = NoteEditorScene()
        propEditScene = PropEditorScene()
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
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offsetSecond = try container.decode(Double.self, forKey: .offsetSecond)
        bpm = try container.decode(Int.self, forKey: .bpm)
        bpmChangeAccrodingToTime = try container.decode(Bool.self, forKey: .bpmChangeAccrodingToTime)
        tickPerBeat = try container.decode(Int.self, forKey: .tickPerBeat)
        highlightedTicks = try container.decode([ColoredInt].self, forKey: .highlightedTicks)
        chartLengthSecond = try container.decode(Int.self, forKey: .chartLengthSecond)
        musicName = try container.decode(String.self, forKey: .musicName)
        authorName = try container.decode(String.self, forKey: .authorName)
        chartLevel = try container.decode(String.self, forKey: .chartLevel)
        chartAuthorName = try container.decode(String.self, forKey: .chartAuthorName)
        copyright = try container.decode(COPYRIGHTTYPE.self, forKey: .copyright)
        windowStatus = try container.decode(WINDOWSTATUS.self, forKey: .windowStatus)
        listOfJudgeLines = try container.decode([JudgeLine].self, forKey: .listOfJudgeLines)
        editingJudgeLineNumber = try container.decode(Int.self, forKey: .editingJudgeLineNumber)
        currentTimeTick = try container.decode(Double.self, forKey: .currentTimeTick)
        locked = try container.decode(Bool.self, forKey: .locked)
        currentNoteType = try container.decode(NOTETYPE.self, forKey: .currentNoteType)
        currentPropType = try container.decode(PROPTYPE.self, forKey: .currentPropType)
        noteEditScene = NoteEditorScene()
        propEditScene = PropEditorScene()
        isRunning = false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offsetSecond, forKey: .offsetSecond)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(bpmChangeAccrodingToTime, forKey: .bpmChangeAccrodingToTime)
        try container.encode(tickPerBeat, forKey: .tickPerBeat)
        try container.encode(highlightedTicks, forKey: .highlightedTicks)
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
    }
}
