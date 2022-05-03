import AVFoundation
import SpriteKit
import SwiftUI

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
    case easeInElastic
    case easeOutElastic
    case easeInOutElastic
    case easeInBounce
    case easeOutBounce
    case easeInOutBounce
}

enum WINDOWSTATUS: String, Equatable, CaseIterable, Codable {
    case pannelNote
    case pannelProp
    case note
    case prop
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

struct PropStatus: Codable {
    var timeTick: Int?
    var value: Int?
    var followingEasing: EASINGTYPE?
}

public class JudgeLine: Identifiable, Equatable, ObservableObject, Codable {
    class JudgeLineProps: Codable {
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

    @Published public var id: Int
    @Published var noteList: [Note]
    var props: JudgeLineProps?

    init(id: Int) {
        self.id = id
        noteList = []
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
        do{
            props = try values.decode(JudgeLineProps.self, forKey: .props)
        }catch{
            print(error)
            props = nil
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
        didSet {
            rebuildScene()
        }
        willSet {
            rebuildScene()
        }
    }

    @Published var locked: Bool

    @Published var currentNoteType: NOTETYPE
    @Published var listOfJudgeLines: [JudgeLine]
    @Published var editingJudgeLineNumber: Int
    @Published var currentTimeTick: Double {
        didSet {
            if currentTimeTick < 0 {
                currentTimeTick = 0
                return
            }
            if !isRunning {
                rebuildLineAndNote()
            } else {
                if currentTimeTick >= Double(chartLengthTick()) {
                    isRunning = false
                    currentTimeTick = Double(chartLengthTick())
                }
            }
        }
    }

    @Published var isRunning: Bool {
        didSet {
            noteEditScene.startRunning()
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

    var noteEditScene: NoteEditorScene

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
        let sceneWidth = UIScreen.main.bounds.width
        let sceneHeight = UIScreen.main.bounds.height
        noteEditScene.size = CGSize(width: sceneWidth, height: sceneHeight)
        noteEditScene.data = self
        noteEditScene.scaleMode = .resizeFill
        noteEditScene.clearAndMakeBackgroundImage()
        noteEditScene.clearAndMakeLint()
        noteEditScene.clearAndMakeJudgeLines()
        noteEditScene.clearAndMakeNotes()
    }

    func rebuildLineAndNote() {
        noteEditScene.clearAndMakeJudgeLines()
        noteEditScene.clearAndMakeNotes()
    }

    func saveCache() throws -> Bool {
        // when saving, the imageFile and data itself is handled here, but audioFile is handled when its imported
        let dataEncoded = try JSONEncoder().encode(self)
        let dataEncodedString = String(data: dataEncoded, encoding: .utf8)
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let dirPath = url.appendingPathComponent("tmp")
            if !fm.fileExists(atPath: dirPath.path) {
                try fm.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            let fileURL = url.appendingPathComponent("tmp").appendingPathComponent("tmp.json")
            try dataEncodedString?.write(to: fileURL, atomically: true, encoding: .utf8)
            if let data = imageFile?.pngData(){
                let fileURL = url.appendingPathComponent("tmp").appendingPathComponent("tmp.png")
                try? data.write(to: fileURL)
            }
        }
        return true
    }
    
    func exportZip() throws -> URL {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.first!
        let archiveURL = url.appendingPathComponent("export.zip")
        let tmpDirURL = url.appendingPathComponent("tmp")
        try fm.removeItem(at: archiveURL)
        let coordinator = NSFileCoordinator()
        var error: NSError?
        coordinator.coordinate(readingItemAt: tmpDirURL, options: [.forUploading], error: &error){(zipURL) in
            try! fm.moveItem(at: zipURL, to: archiveURL)
        }
        return archiveURL
    }

    func loadCache() throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let dirPath = url.appendingPathComponent("tmp")
            if !fm.fileExists(atPath: dirPath.path) {
                try fm.createDirectory(at: dirPath, withIntermediateDirectories: true, attributes: nil)
            }
            let fileURL = url.appendingPathComponent("tmp").appendingPathComponent("tmp.json")
            let resolvedData = try String(contentsOf: fileURL)
            let resolvedObject = try JSONDecoder().decode(DataStructure.self, from: resolvedData.data(using: .utf8)!)
            offsetSecond = resolvedObject.offsetSecond
            bpm = resolvedObject.bpm
            bpmChangeAccrodingToTime = resolvedObject.bpmChangeAccrodingToTime
            tickPerBeat = resolvedObject.tickPerBeat
            highlightedTicks = resolvedObject.highlightedTicks
            chartLengthSecond = resolvedObject.chartLengthSecond
            musicName = resolvedObject.musicName
            authorName = resolvedObject.authorName
            audioFileURL = resolvedObject.audioFileURL
            audioPlayer = resolvedObject.audioPlayer
            imageFile = resolvedObject.imageFile
            imgFileURL = resolvedObject.imgFileURL
            chartLevel = resolvedObject.chartLevel
            chartAuthorName = resolvedObject.chartAuthorName
            windowStatus = resolvedObject.windowStatus
            locked = resolvedObject.locked
            currentNoteType = resolvedObject.currentNoteType
            listOfJudgeLines = resolvedObject.listOfJudgeLines
            editingJudgeLineNumber = resolvedObject.editingJudgeLineNumber
            currentTimeTick = resolvedObject.currentTimeTick
            isRunning = resolvedObject.isRunning
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
        windowStatus = WINDOWSTATUS.pannelNote
        listOfJudgeLines = [JudgeLine(id: 0)]
        editingJudgeLineNumber = 0
        currentTimeTick = 0.0
        locked = false
        currentNoteType = NOTETYPE.Tap
        isRunning = false
        noteEditScene = NoteEditorScene()
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
        case chartLevel
        case chartAuthorName
        case windowStatus
        case listOfJudgeLines
        case editingJudgeLineNumber
        case currentTimeTick
        case locked
        case currentNoteType
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
        windowStatus = try container.decode(WINDOWSTATUS.self, forKey: .windowStatus)
        listOfJudgeLines = try container.decode([JudgeLine].self, forKey: .listOfJudgeLines)
        editingJudgeLineNumber = try container.decode(Int.self, forKey: .editingJudgeLineNumber)
        currentTimeTick = try container.decode(Double.self, forKey: .currentTimeTick)
        locked = try container.decode(Bool.self, forKey: .locked)
        currentNoteType = try container.decode(NOTETYPE.self, forKey: .currentNoteType)
        noteEditScene = NoteEditorScene()
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
        try container.encode(windowStatus, forKey: .windowStatus)
        try container.encode(listOfJudgeLines, forKey: .listOfJudgeLines)
        try container.encode(editingJudgeLineNumber, forKey: .editingJudgeLineNumber)
        try container.encode(currentTimeTick, forKey: .currentTimeTick)
        try container.encode(locked, forKey: .locked)
        try container.encode(currentNoteType, forKey: .currentNoteType)
    }
}
