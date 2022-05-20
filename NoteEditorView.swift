import CoreMedia
import SpriteKit
import SwiftUI

let _distance = 5.0
let _maxAcceptableNotes = 10.0
let _noteWidth = 120
let _noteHeight = 15
let _noteCornerRadius = 4.0

class NoteEditorScene: SKScene {
    var data: DataStructure?

    var judgeLineNodeTemplate: SKShapeNode?
    var judgeLineLabelNodeTemplate: SKLabelNode?
    var noteNodeTemplate: SKShapeNode?
    var backgroundImageNodeTemplate: SKSpriteNode?
    var lintNodeTemplate: SKShapeNode?

    var moveStartPoint: CGPoint?
    var moveStartTimeTick: Double?

    var nodeLinks: [(SKNode, SKNode)] = []
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

    func updateCanvasSize() {
        judgeLineNodeTemplate = {
            let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
            judgeLineNodeTemplate.fillColor = SKColor.white
            judgeLineNodeTemplate.name = "judgeLine"
            judgeLineNodeTemplate.alpha = 0.2
            return judgeLineNodeTemplate
        }()
    }

    func clearAndMakeJudgeLines() {
        if size.width == 0 || size.height == 0 || data == nil {
            return
        }

        if judgeLineNodeTemplate == nil {
            judgeLineNodeTemplate = {
                let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
                judgeLineNodeTemplate.fillColor = SKColor.white
                judgeLineNodeTemplate.name = "judgeLine"
                judgeLineNodeTemplate.alpha = 0.2
                return judgeLineNodeTemplate
            }()
        } else {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }

        if judgeLineLabelNodeTemplate == nil {
            judgeLineLabelNodeTemplate = {
                let judgeLineLabelNodeTemplate = SKLabelNode(fontNamed: "AmericanTypewriter")
                judgeLineLabelNodeTemplate.fontSize = 15
                judgeLineLabelNodeTemplate.fontColor = SKColor.white
                judgeLineLabelNodeTemplate.name = "judgeLineLabel"
                judgeLineLabelNodeTemplate.horizontalAlignmentMode = .left
                return judgeLineLabelNodeTemplate
            }()
        } else {
            removeNodesLinked(to: judgeLineLabelNodeTemplate!)
        }

        let RelativePostionY = 50 + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        let RelativeTick = Int(data!.currentTimeTick)

        for currentLineTick in 0 ..< data!.chartLengthTick() + 1 {
            var indexedInt: Int?
            var indexedColor: Color?
            for _highLightTick in data!.highlightedTicks {
                if currentLineTick % (data!.tickPerBeat / _highLightTick.value) == 0 {
                    if indexedInt == nil || indexedInt! > _highLightTick.value {
                        indexedInt = _highLightTick.value
                        indexedColor = _highLightTick.color
                    }
                }
            }

            if indexedInt == nil {
                continue
            }

            let judgeLineNode = judgeLineNodeTemplate!.copy() as! SKShapeNode
            judgeLineNode.position = CGPoint(x: size.width / 2, y: RelativePostionY + CGFloat(currentLineTick - RelativeTick) * _distance)

            if currentLineTick % data!.tickPerBeat == 0 {
                judgeLineNode.alpha = 1.0
            } else {
                judgeLineNode.fillColor = SKColor(indexedColor!)
            }

            link(nodeA: judgeLineNode, to: judgeLineLabelNodeTemplate!)
            addChild(judgeLineNode)

            if currentLineTick % data!.tickPerBeat == 0 {
                let judgeLineLabelNode = judgeLineLabelNodeTemplate!.copy() as! SKLabelNode
                judgeLineLabelNode.text = String(currentLineTick) + "/" + String(currentLineTick / data!.tickPerBeat)
                judgeLineLabelNode.position = CGPoint(x: 0, y: RelativePostionY + CGFloat(currentLineTick - RelativeTick) * _distance)
                link(nodeA: judgeLineLabelNode, to: judgeLineLabelNodeTemplate!)
                addChild(judgeLineLabelNode)
            }
        }
    }

    func clearAndMakeNotes() {
        if data == nil {
            return
        }
        if noteNodeTemplate == nil {
            noteNodeTemplate = {
                let noteNodeTemplate = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight), cornerRadius: _noteCornerRadius)
                noteNodeTemplate.name = "note"
                noteNodeTemplate.alpha = 1.0
                noteNodeTemplate.lineWidth = 8
                return noteNodeTemplate
            }()
        } else {
            removeNodesLinked(to: noteNodeTemplate!)
        }

        let RelativePostionY = 50 + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))

        for note in data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList {
            var noteNode: SKShapeNode

            if note.noteType == .Hold {
                let topColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                let bottomColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.0)

                let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                texture.filteringMode = .nearest

                noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + Int(_distance) * note.holdTimeTick), cornerRadius: _noteCornerRadius)
                noteNode.fillTexture = texture
                noteNode.fillColor = .white
                noteNode.position = CGPoint(x: note.posX * size.width, y: RelativePostionY + (CGFloat(note.timeTick) - data!.currentTimeTick + CGFloat(note.holdTimeTick) / 2) * _distance)
                noteNode.name = "note"
                noteNode.alpha = 1.0
                noteNode.lineWidth = 8

            } else {
                noteNode = noteNodeTemplate!.copy() as! SKShapeNode
                noteNode.position = CGPoint(x: note.posX * size.width, y: RelativePostionY + CGFloat(note.timeTick - Int(data!.currentTimeTick)) * _distance)
                switch note.noteType {
                case .Tap: noteNode.fillColor = SKColor.blue
                case .Flick: noteNode.fillColor = SKColor.red
                case .Drag: noteNode.fillColor = SKColor.yellow
                case .Hold: continue
                }
            }

            if !note.fallSide {
                noteNode.alpha /= 2
            }
            if note.isFake {
                noteNode.strokeColor = .purple
            }

            link(nodeA: noteNode, to: noteNodeTemplate!)
            addChild(noteNode)
        }
    }

    func clearAndMakeBackgroundImage() {
        if data == nil {
            return
        }
        if data!.imageFile == nil {
            return
        }

        if backgroundImageNodeTemplate != nil {
            removeNodesLinked(to: backgroundImageNodeTemplate!)
        }
        backgroundImageNodeTemplate = {
            let imageTexture = SKTexture(image: data!.imageFile!)
            imageTexture.filteringMode = .linear
            let backgroundImageNodeTemplate = SKSpriteNode(texture: imageTexture)
            backgroundImageNodeTemplate.scale(to: size)
            backgroundImageNodeTemplate.alpha = 0.2
            backgroundImageNodeTemplate.position = CGPoint(x: size.width / 2, y: size.height / 2)
            backgroundImageNodeTemplate.name = "backgroundImage"
            return backgroundImageNodeTemplate
        }()

        let backgroundImage = backgroundImageNodeTemplate!.copy() as! SKSpriteNode
        link(nodeA: backgroundImage, to: backgroundImageNodeTemplate!)
        addChild(backgroundImage)
    }

    func clearAndMakeLint() {
        if data == nil {
            return
        }
        if lintNodeTemplate == nil {
            lintNodeTemplate = {
                let lintNodeTemplate = SKShapeNode(circleOfRadius: 10)
                lintNodeTemplate.fillColor = SKColor.red
                lintNodeTemplate.name = "lintNode"
                lintNodeTemplate.alpha = 0.5
                lintNodeTemplate.position = CGPoint(x: 0, y: 50)
                return lintNodeTemplate
            }()
        } else {
            removeNodesLinked(to: lintNodeTemplate!)
        }
        let lintNode = lintNodeTemplate!.copy() as! SKShapeNode
        link(nodeA: lintNode, to: lintNodeTemplate!)
        addChild(lintNode)
    }

    func startRunning() {
        if data == nil {
            return
        }
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == judgeLineNodeTemplate || pair.0 == judgeLineLabelNodeTemplate || pair.0 == noteNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == judgeLineNodeTemplate || pair.1 == judgeLineLabelNodeTemplate || pair.1 == noteNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.run(SKAction.repeatForever(SKAction.move(by: CGVector(dx: 0, dy: Double(-data!.tickPerBeat) * _distance), duration: 60.0 / Double(data!.bpm))), withKey: "moving")
        }
    }

    func pauseRunning() {
        if data == nil {
            return
        }
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == judgeLineNodeTemplate || pair.0 == judgeLineLabelNodeTemplate || pair.0 == noteNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == judgeLineNodeTemplate || pair.1 == judgeLineLabelNodeTemplate || pair.1 == noteNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
//            if let _action = $0.action(forKey: "moving") {
//                _action.speed = 0
//            }
            $0.removeAllActions()
        }
    }

    override func didMove(to _: SKView) {}

    override func update(_: TimeInterval) {}

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if data!.isRunning {
            return
        }
        let RelativePostionY = 50 + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        if let _touch = touches.first {
            let touchLocation = _touch.location(in: self)
            if data!.locked {
                moveStartPoint = touchLocation
                moveStartTimeTick = data?.currentTimeTick
                return
            } else {
                moveStartPoint = nil
                moveStartTimeTick = nil
            }
            let tmpTick: Double = (touchLocation.y - RelativePostionY) / _distance + data!.currentTimeTick
            var minTick = 0
            var minTickDistance = Double(data!.tickPerBeat)
            for preferTick in data!.highlightedTicks + [ColoredInt(value: 1)] {
                let tickDistance = Double(data!.tickPerBeat / preferTick.value)
                if tmpTick.truncatingRemainder(dividingBy: tickDistance) < minTickDistance {
                    minTickDistance = tmpTick.truncatingRemainder(dividingBy: tickDistance)
                    minTick = Int(tmpTick / tickDistance) * Int(tickDistance)
                }
                if (tickDistance - tmpTick.truncatingRemainder(dividingBy: tickDistance)) < minTickDistance {
                    minTickDistance = Double(tickDistance) - tmpTick.truncatingRemainder(dividingBy: Double(tickDistance))
                    minTick = (Int(tmpTick / tickDistance) + 1) * Int(tickDistance)
                }
            }
            for node in nodes(at: touchLocation) {
                if node.name == "note" {
                    node.run(SKAction.fadeOut(withDuration: 0.1))
                    data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.removeAll(where: { $0.timeTick == minTick && (fabs($0.posX * size.width - node.position.x) < 75) })
                    clearAndMakeNotes()
                    return
                }
            }
            if minTick >= 0, minTick <= data!.tickPerBeat * data!.chartLengthSecond * data!.bpm / 60 {
                let tmpID = data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.count

                // this logic ... might have problems ??? but I'm not sure.
                // it is working now, so check this for another time maybe
                data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.append(Note(id: tmpID, noteType: data!.currentNoteType, posX: (Double(Int(touchLocation.x / size.width * _maxAcceptableNotes)) - 0.5) / _maxAcceptableNotes + 1.0 / _maxAcceptableNotes, timeTick: minTick))

                data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.sort(by: { noteA, noteB -> Bool in
                    if noteA.timeTick != noteB.timeTick {
                        return noteA.timeTick < noteB.timeTick
                    } else {
                        return noteA.posX < noteB.posX
                    }
                })
                for i in 0 ..< data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.count {
                    data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList[i].id = i
                }
                clearAndMakeNotes()
                return
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if !data!.locked || data!.isRunning {
            return
        }

        if moveStartPoint == nil || moveStartTimeTick == nil {
            return
        }

        if let _touch = touches.first {
            let touchLocation = _touch.location(in: self)
            let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
                var res = res
                if pair.0 == judgeLineNodeTemplate || pair.0 == judgeLineLabelNodeTemplate || pair.0 == noteNodeTemplate {
                    res.insert(pair.1)
                }
                if pair.1 == judgeLineNodeTemplate || pair.1 == judgeLineLabelNodeTemplate || pair.1 == noteNodeTemplate {
                    res.insert(pair.0)
                }
                return res
            }
            linkedNodes.forEach {
                $0.run(SKAction.move(by: CGVector(dx: 0, dy: min(touchLocation.y - moveStartPoint!.y, moveStartTimeTick! * _distance)), duration: 0))
            }
            data!.shouldUpdateFrame = false
            data!.currentTimeTick = moveStartTimeTick! - (touchLocation.y - moveStartPoint!.y) / _distance
            data!.shouldUpdateFrame = true

            moveStartPoint = touchLocation
            moveStartTimeTick = data!.currentTimeTick
            return
        }
    }
}

struct NoteEditorView: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        SpriteView(scene: data.noteEditScene).onAppear {
            data.rebuildScene()
            data.objectWillChange.send()
        }
    }
}
