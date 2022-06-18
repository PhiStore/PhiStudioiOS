/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SpriteKit
import SwiftUI

let _distance = 5.0 // distance (in pixel) per timeTick (this might have issue when user change the tickPerBeat option...)
let _yBaseLine = 50.0 // the relative postion of the currentTimeTick judgeLine

// parameters about judgeLine
let _judgeLineHeight = 2.0
let _lintNodeHeight = 4.0

// parameters about note
let _noteWidth = 150.0
let _noteHeight = 20.0
let _noteCornerRadius = 4.0

class NoteEditorScene: SKScene {
    var data: DataStructure?

    // several templates the program uses, notice that all templates and its subsets should be linked to each other
    var judgeLineNodeTemplate: SKShapeNode?
    var judgeLineLabelNodeTemplate: SKLabelNode?
    var noteNodeTemplate: SKShapeNode?
    var backgroundImageNodeTemplate: SKSpriteNode?
    var lintNodeTemplate: SKShapeNode?
    var soundNode = SKNode()

    // moveStartPoint and moveStartTimeTick are used for scroll the view
    var lastTouchLocation: CGPoint?
    var lastTouchTimeTick: Double?

    // for fast hold
    var lastHitTimeTick: Int?

    var nodeLinks: [(SKNode, SKNode)] = []
    func link(nodeA: SKNode, to nodeB: SKNode) {
        let pair = (nodeA, nodeB)
        nodeLinks.append(pair)
    }

    func removeNodesLinked(to node: SKNode) {
        // remove all the nodes from view if they're linked to the given node, used for refreshing the whole scene
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

    func initTemplates() {
        // Plz notice that the background image node is NOT handled here
        if judgeLineNodeTemplate != nil {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }
        judgeLineNodeTemplate = {
            let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width, height: 2))
            judgeLineNodeTemplate.fillColor = SKColor.white
            judgeLineNodeTemplate.name = "judgeLine"
            judgeLineNodeTemplate.alpha = 1.0
            return judgeLineNodeTemplate
        }()

        if lintNodeTemplate != nil {
            removeNodesLinked(to: lintNodeTemplate!)
        }
        lintNodeTemplate = {
            let lintNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
            lintNodeTemplate.fillColor = .red
            lintNodeTemplate.name = "lint"
            lintNodeTemplate.alpha = 0.4
            lintNodeTemplate.position = CGPoint(x: size.width / 2, y: 50)
            lintNodeTemplate.zPosition = 100
            return lintNodeTemplate
        }()

        if judgeLineLabelNodeTemplate != nil {
            removeNodesLinked(to: judgeLineLabelNodeTemplate!)
        }

        judgeLineLabelNodeTemplate = {
            let judgeLineLabelNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
            judgeLineLabelNodeTemplate.fontSize = 15
            judgeLineLabelNodeTemplate.fontColor = SKColor.white
            judgeLineLabelNodeTemplate.name = "judgeLineLabel"
            judgeLineLabelNodeTemplate.horizontalAlignmentMode = .left
            return judgeLineLabelNodeTemplate
        }()

        if noteNodeTemplate != nil {
            removeNodesLinked(to: noteNodeTemplate!)
        }
        noteNodeTemplate = {
            let noteNodeTemplate = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight), cornerRadius: _noteCornerRadius)
            noteNodeTemplate.name = "note"
            noteNodeTemplate.alpha = 1.0
            noteNodeTemplate.lineWidth = 8
            return noteNodeTemplate
        }()
    }

    func addJudgeLinesToView() {
        if judgeLineNodeTemplate == nil || judgeLineLabelNodeTemplate == nil {
            initTemplates()
        }
        removeNodesLinked(to: judgeLineNodeTemplate!)
        removeNodesLinked(to: judgeLineLabelNodeTemplate!)

        let yBaseLine = _yBaseLine + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        let timeTickBaseLine = Int(data!.currentTimeTick)
        for currentLineTick in 0 ... data!.chartLengthTick() {
            // I think some code could be done here to optimize performance... the same cycle is done so many times... completely uncessary
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
            judgeLineNode.position = CGPoint(x: size.width / 2, y: yBaseLine + CGFloat(currentLineTick - timeTickBaseLine) * _distance)
            if !(currentLineTick % data!.tickPerBeat == 0) {
                judgeLineNode.alpha = 0.2
                judgeLineNode.fillColor = SKColor(indexedColor!)
            }
            link(nodeA: judgeLineNode, to: judgeLineLabelNodeTemplate!)
            addChild(judgeLineNode)
            if currentLineTick % data!.tickPerBeat == 0 {
                let judgeLineLabelNode = judgeLineLabelNodeTemplate!.copy() as! SKLabelNode
                judgeLineLabelNode.text = "\(String(currentLineTick))/\(String(currentLineTick / data!.tickPerBeat))"
                judgeLineLabelNode.position = CGPoint(x: 0, y: yBaseLine + CGFloat(currentLineTick - timeTickBaseLine) * _distance)
                link(nodeA: judgeLineLabelNode, to: judgeLineLabelNodeTemplate!)
                addChild(judgeLineLabelNode)
            }
        }
    }

    func addNotesToView() {
        if noteNodeTemplate == nil {
            initTemplates()
        } else {
            removeNodesLinked(to: noteNodeTemplate!)
        }
        let yBaseLine = _yBaseLine + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        let timeTickBaseLine = Int(data!.currentTimeTick)
        for note in data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList {
            var noteNode: SKShapeNode
            if note.noteType == .Hold {
                let topColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                let bottomColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.0)
                let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                texture.filteringMode = .nearest
                noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + _distance * Double(note.holdTimeTick)), cornerRadius: _noteCornerRadius)
                noteNode.fillTexture = texture
                noteNode.fillColor = .white
                noteNode.position = CGPoint(x: note.posX * size.width, y: yBaseLine + (CGFloat(note.timeTick - timeTickBaseLine + note.holdTimeTick / 2) * _distance))
                noteNode.name = "note"
                noteNode.alpha = 1.0
                noteNode.lineWidth = 8
            } else {
                noteNode = noteNodeTemplate!.copy() as! SKShapeNode
                noteNode.position = CGPoint(x: note.posX * size.width, y: yBaseLine + CGFloat(note.timeTick - timeTickBaseLine) * _distance)
                noteNode.fillColor = noteColor(type: note.noteType)
            }
            if !note.fallSide {
                noteNode.alpha /= 2
            }
            if note.isFake {
                noteNode.strokeColor = .green
            }
            link(nodeA: noteNode, to: noteNodeTemplate!)
            addChild(noteNode)
        }
    }

    func addBackgroundImageToView() {
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

    func addLintingToView() {
        if lintNodeTemplate == nil {
            initTemplates()
        } else {
            removeNodesLinked(to: lintNodeTemplate!)
        }
        let lintNode = lintNodeTemplate!.copy() as! SKShapeNode
        link(nodeA: lintNode, to: lintNodeTemplate!)
        addChild(lintNode)
    }

    func startRunning() {
        isPaused = true
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

        let someNode = SKNode()
        var actionList: [SKAction] = []
        let soundAction = SKAction.playSoundFileNamed("HitSong2.mp3", waitForCompletion: false)
        for note in data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList {
            if Double(note.timeTick) < data!.currentTimeTick {
                continue
            }
            actionList.append(SKAction.sequence([SKAction.wait(forDuration: data!.tickToSecond(Double(note.timeTick) - data!.currentTimeTick)), soundAction]))
        }
        someNode.run(SKAction.group(actionList))
        link(nodeA: someNode, to: soundNode)
        addChild(someNode)
        isPaused = false
    }

    func pauseRunning() {
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == judgeLineNodeTemplate || pair.0 == judgeLineLabelNodeTemplate || pair.0 == noteNodeTemplate || pair.0 == soundNode {
                res.insert(pair.1)
            }
            if pair.1 == judgeLineNodeTemplate || pair.1 == judgeLineLabelNodeTemplate || pair.1 == noteNodeTemplate || pair.1 == soundNode {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.removeAllActions()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        if data!.isRunning {
            return
        }
        let RelativePostionY = 50 + _distance * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        if let _touch = touches.first {
            let touchLocation = _touch.location(in: self)
            let touchHint = SKShapeNode(circleOfRadius: 10)
            touchHint.fillColor = .green
            touchHint.position = touchLocation
            touchHint.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.removeFromParent()]))
            addChild(touchHint)
            if data!.locked {
                lastTouchLocation = touchLocation
                lastTouchTimeTick = data?.currentTimeTick
                return
            } else {
                lastTouchLocation = nil
                lastTouchTimeTick = nil
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
                    data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.removeAll(where: {
                        ($0.noteType == .Hold ? (($0.timeTick <= minTick) && (minTick <= $0.timeTick + $0.holdTimeTick)) : ($0.timeTick == minTick)) && (fabs($0.posX * size.width - node.position.x) < 75)
                    })
                    addNotesToView()
                    data!.objectWillChange.send()
                    return
                }
            }
            if minTick >= 0, minTick <= data!.tickPerBeat * data!.chartLengthSecond * data!.bpm / 60 {
                if data!.currentNoteType == .Hold, data!.fastHold {
                    if lastHitTimeTick == nil {
                        lastHitTimeTick = minTick
                        return
                    } else if minTick > lastHitTimeTick! {
                        let tmpID = data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.count
                        data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.append(Note(id: tmpID, noteType: .Hold, posX: (Double(Int(touchLocation.x / size.width * data!.maxAcceptableNotes)) - 0.5) / data!.maxAcceptableNotes + 1.0 / data!.maxAcceptableNotes, timeTick: lastHitTimeTick!, holdTimeTick: minTick - lastHitTimeTick!))
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
                        lastHitTimeTick = nil
                        addNotesToView()
                        data!.objectWillChange.send() // refresh swiftUI side
                        return
                    }
                    return
                } else {
                    let tmpID = data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.count
                    data!.listOfJudgeLines[data!.editingJudgeLineNumber].noteList.append(Note(id: tmpID, noteType: data!.currentNoteType, posX: (Double(Int(touchLocation.x / size.width * data!.maxAcceptableNotes)) - 0.5) / data!.maxAcceptableNotes + 1.0 / data!.maxAcceptableNotes, timeTick: minTick, holdTimeTick: data!.defaultHoldTimeTick))
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
                    addNotesToView()
                    data!.objectWillChange.send() // refresh swiftUI side
                    return
                }
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent?) {
        if !data!.locked || data!.isRunning {
            return
        }
        if lastTouchLocation == nil || lastTouchTimeTick == nil {
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
                $0.run(SKAction.move(by: CGVector(dx: 0, dy: min(touchLocation.y - lastTouchLocation!.y, lastTouchTimeTick! * _distance)), duration: 0))
            }
            data!.shouldUpdateFrame = false
            data!.currentTimeTick = lastTouchTimeTick! - (touchLocation.y - lastTouchLocation!.y) / _distance
            data!.shouldUpdateFrame = true
            lastTouchLocation = touchLocation
            lastTouchTimeTick = data!.currentTimeTick
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
