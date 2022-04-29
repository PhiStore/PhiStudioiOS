import AVFoundation
import CoreGraphics
import CoreMotion
import SpriteKit
import SwiftUI
import UIKit

let _constNoteDiff = 10.0

class NoteEditScene: SKScene {
    var lastTime: Double = 0.0 // copy of time
    var lastWidth: Double = 0.0 // copy of screen width
    var lastPreferedTick: [ColoredInt] = []
    var lastRunning: Bool = false
    var lastImage: UIImage?

    var judgeLineNode: SKShapeNode? // judgeLine
    var judgeLineLabelNode: SKLabelNode? // text on judgeLine
    var noteNode: SKShapeNode? // note
    var backGroundImage: SKSpriteNode? // background image

    // these are used for node copying and management
    var nodeLinks: [(SKNode, SKNode)] = [] // all nodes linked from A to B
    func link(nodeA: SKNode, to nodeB: SKNode) {
        let pair = (nodeA, nodeB)
        nodeLinks.append(pair)
    }

    func removeNodesLinked(to node: SKNode) {
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == node {
                res.insert(pair.1)
            }
            if pair.1 == node {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach { $0.removeFromParent() }
        nodeLinks = nodeLinks.filter { $0.0 != node && $0.1 != node }
    }

    // init functions, since at this time the frame isn't fully rendered, size.width is NOT available, try with update function
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init() {
        super.init()
        setup()
    }

    override init(size: CGSize) {
        super.init(size: size)
        setup()
    }

    func setup() {}

    func createJudgeLines() {
        if size.width == 0 {
            // screen isn't loaded yet
            return
        }
        if judgeLineNode == nil {
            judgeLineNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
            judgeLineNode!.name = "judgeLine"
            judgeLineNode!.fillColor = SKColor.white
            judgeLineNode!.alpha = 0.2
            lastWidth = size.width
        }
        if judgeLineLabelNode == nil {
            judgeLineLabelNode = SKLabelNode(fontNamed: "AmericanTypewriter")
            judgeLineLabelNode!.name = "judgeLineLabel"
            judgeLineLabelNode?.horizontalAlignmentMode = .left
            judgeLineLabelNode?.fontSize = 15
        }

        // re-generate the func
        removeNodesLinked(to: judgeLineNode!)
        removeNodesLinked(to: judgeLineLabelNode!)

        let lineTick = Int(dataK.currentTime) // tick base
        let distance = 5.0 // diff between each line
        let pos_y = 50 + distance * (dataK.currentTime - Double(Int(dataK.currentTime))) // y base
        var indexedInt: Int?
        var indexedColor: Color?

        var currentLineTick = 0

        while currentLineTick <= dataK.tickPerSecond * dataK.chartLength {
            indexedInt = nil
            for preferTick in dataK.preferTicks {
                if currentLineTick % (dataK.tickPerSecond / preferTick.value) == 0 {
                    if indexedInt == nil {
                        indexedInt = preferTick.value
                        indexedColor = preferTick.color
                    }
                    if indexedColor == nil, indexedInt! > preferTick.value {
                        indexedColor = preferTick.color
                    }
                }
            }
            if indexedInt != nil {
                let _judgeLine = judgeLineNode?.copy() as! SKShapeNode
                _judgeLine.position = CGPoint(x: size.width / 2, y: pos_y + distance * Double(currentLineTick - lineTick))
                if currentLineTick % dataK.tickPerSecond == 0 {
                    _judgeLine.alpha = 1.0
                    let _judgeLineLabel = judgeLineLabelNode?.copy() as! SKLabelNode
                    _judgeLineLabel.position = CGPoint(x: 0, y: pos_y + distance * Double(currentLineTick - lineTick))
                    _judgeLineLabel.text = String(currentLineTick / 48)
                    link(nodeA: _judgeLineLabel, to: judgeLineLabelNode!)
                    addChild(_judgeLineLabel)
                } else {
                    _judgeLine.fillColor = SKColor(indexedColor!)
                }
                link(nodeA: _judgeLine, to: judgeLineNode!)
                addChild(_judgeLine)
            }
            currentLineTick += 1
        }
    }

    func createNotes() {
        let distance = 5.0
        let pos_y = 50.0 + distance * (dataK.currentTime - Double(Int(dataK.currentTime)))
        if noteNode == nil {
            noteNode = SKShapeNode(rectOf: CGSize(width: 150, height: 20), cornerRadius: 8)
            noteNode!.lineWidth = 8
            noteNode!.name = "note"
            // noteNode!.fillColor = SKColor.blue
            noteNode!.alpha = 1.0
        }
        removeNodesLinked(to: noteNode!)
        for i in 0 ..< editingJudgeLine.noteList.count {
            let _note = noteNode?.copy() as! SKShapeNode
            _note.position = CGPoint(x: editingJudgeLine.noteList[i].posX * lastWidth, y: pos_y + distance * (Double(editingJudgeLine.noteList[i].time) - dataK.currentTime))
            switch editingJudgeLine.noteList[i].noteType {
            case .Tap: _note.fillColor = SKColor.blue
            case .Hold: _note.fillColor = SKColor.green
            case .Flick: _note.fillColor = SKColor.red
            case .Drag: _note.fillColor = SKColor.yellow
            }
            link(nodeA: _note, to: noteNode!)
            addChild(_note)
        }
    }

    func createBackGroundImage() {
        if backGroundImage != nil {
            removeNodesLinked(to: backGroundImage!)
        }
        lastImage = dataK.imageFile
        let Texture = SKTexture(image: lastImage!)
        Texture.filteringMode = .linear
        backGroundImage = SKSpriteNode(texture: Texture)
        backGroundImage?.scale(to: size)
        backGroundImage?.alpha = 0.5
        backGroundImage?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let _backGroundImage = backGroundImage?.copy() as! SKSpriteNode
        link(nodeA: _backGroundImage, to: backGroundImage!)
        addChild(_backGroundImage)
    }

    override func sceneDidLoad() {}

    override func didMove(to _: SKView) {}

    override func update(_: TimeInterval) {
        if lastTime != dataK.currentTime || lastPreferedTick != dataK.preferTicks {
            lastTime = dataK.currentTime
            lastPreferedTick = dataK.preferTicks
            if !dataK.isRunning {
                createJudgeLines()
                createNotes()
            }
        }
        if lastWidth != size.width {
            // the size of canvas changed (might happen when the left pannel is turnned on or off)
            // this function should only be called when judegeLineNode need to be updated
            if judgeLineNode != nil {
                // remove child of judgeLineNode before, otherwise they won't be recycled
                removeNodesLinked(to: judgeLineNode!)
            }
            judgeLineNode = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
            judgeLineNode!.fillColor = SKColor.white
            judgeLineNode!.alpha = 0.2
            lastWidth = size.width

            createBackGroundImage()
            createJudgeLines()
            createNotes()
        }

        if lastRunning != dataK.isRunning {
            lastRunning = dataK.isRunning
            let distance = 5.0
            let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
                var res = res
                if pair.0 == judgeLineNode || pair.0 == judgeLineLabelNode || pair.0 == noteNode {
                    res.insert(pair.1)
                }
                if pair.1 == judgeLineNode || pair.1 == judgeLineLabelNode || pair.1 == noteNode {
                    res.insert(pair.0)
                }
                return res
            }
            linkedNodes.forEach {
                if lastRunning {
                    $0.run(SKAction.repeatForever(SKAction.move(by: CGVector(dx: 0, dy: -dataK.tickPerSecond * Int(distance)), duration: 1)), withKey: "moving")
                } else {
                    if let _action = $0.action(forKey: "moving") {
                        _action.speed = 0
                    }
                }
            }
            if !lastRunning {
                createJudgeLines()
                createNotes()
            }
        }

        if lastImage != dataK.imageFile {
            createBackGroundImage()
            createJudgeLines()
            createNotes()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let distance = 5.0
        let pos_y = 50.0 + distance * (dataK.currentTime - Double(Int(dataK.currentTime)))

        for _touch in touches {
            let location = _touch.location(in: self)
            // get the nearest tick here:
            let tmpTick: Double = (location.y - pos_y) / distance + dataK.currentTime
            var minTick = 0
            var minTickDistance = Double(dataK.tickPerSecond)
            for preferTick in dataK.preferTicks + [ColoredInt(_value: 1)] {
                let tickDistance: Int = dataK.tickPerSecond / preferTick.value
                if tmpTick.truncatingRemainder(dividingBy: Double(tickDistance)) < minTickDistance {
                    minTickDistance = tmpTick.truncatingRemainder(dividingBy: Double(tickDistance))
                    minTick = Int(tmpTick / Double(tickDistance)) * tickDistance
                }
                if Double(tickDistance) - tmpTick.truncatingRemainder(dividingBy: Double(tickDistance)) < minTickDistance {
                    minTickDistance = Double(tickDistance) - tmpTick.truncatingRemainder(dividingBy: Double(tickDistance))
                    minTick = (Int(tmpTick / Double(tickDistance)) + 1) * tickDistance
                }
            }
            for node in nodes(at: location) {
                if node.name == "note" {
                    node.run(SKAction.fadeOut(withDuration: 0.1))
                    editingJudgeLine.noteList.removeAll(where: { _note in
                        (_note.time == minTick) && abs(node.position.x - _note.posX * lastWidth) < 150
                    })
                    createNotes()
                    return
                }
            }
            // the position touhced is not on any note, so create one.
            // if the position is out of range, do nothing.
            // if the judgeline is running, do nothing.
            if minTick >= 0, minTick <= dataK.tickPerSecond * dataK.chartLength, !lastRunning {
                editingJudgeLine.noteList.append(Note(Type: dataK.currentNoteType, Time: minTick, PosX: Double(Int(location.x / lastWidth * _constNoteDiff)) / _constNoteDiff))
            }
        }
        if !lastRunning {
            createNotes()
        }
    }
}
