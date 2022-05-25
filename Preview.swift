// Preview.swift
// Author: TianKai Ma
// Last Reviewed: NONE
import SpriteKit
import SwiftUI

let _refreshTick = 2.0

class ChartPreviewScene: SKScene {
    var data: DataStructure?
    var judgeLineNodeTemplate: SKShapeNode?
    var noteNodeTemplate: SKShapeNode?
    var backgroundImageNodeTemplate: SKSpriteNode?
    var timeLintNodeTemplate: SKLabelNode?

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
        if judgeLineNodeTemplate != nil {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }

        judgeLineNodeTemplate = {
            let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: 2))
            judgeLineNodeTemplate.fillColor = SKColor.white
            judgeLineNodeTemplate.name = "judgeLine"
            judgeLineNodeTemplate.alpha = 1.0
            return judgeLineNodeTemplate
        }()
    }

    func prepareStaticJudgeLines() {
        if size.width == 0 || size.height == 0 || data == nil {
            return
        }
        if judgeLineNodeTemplate == nil {
            judgeLineNodeTemplate = {
                let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: 2))
                judgeLineNodeTemplate.fillColor = SKColor.white
                judgeLineNodeTemplate.name = "judgeLine"
                judgeLineNodeTemplate.alpha = 1.0
                return judgeLineNodeTemplate
            }()
        } else {
            removeNodesLinked(to: judgeLineNodeTemplate!)
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
        for judgeLine in data!.listOfJudgeLines {
            let judgeLineNode = judgeLineNodeTemplate!.copy() as! SKShapeNode
            let judgeLinePosX = judgeLine.props.calculateValue(.controlX, data!.currentTimeTick) * size.width
            let judgeLinePosY = judgeLine.props.calculateValue(.controlY, data!.currentTimeTick) * size.width
            let judgeLineAngle = judgeLine.props.calculateValue(.angle, data!.currentTimeTick) * 2.0 * .pi
            judgeLineNode.position = CGPoint(x: judgeLinePosX, y: judgeLinePosY)
            judgeLineNode.zRotation = judgeLineAngle
            link(nodeA: judgeLineNode, to: judgeLineNodeTemplate!)
            addChild(judgeLineNode)
            for note in judgeLine.noteList {
                if note.noteType == .Hold {
                    if Double(note.timeTick + note.holdTimeTick) <= data!.currentTimeTick {
                        continue
                    }
                } else if Double(note.timeTick) <= data!.currentTimeTick {
                    continue
                }
                var noteNode = noteNodeTemplate!.copy() as! SKShapeNode
                let noteRelativePosition = judgeLine.props.calculateNoteDistance(data!.currentTimeTick, Double(note.timeTick)) * _distance
                let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                if note.noteType == .Hold {
                    let topColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.0)
                    let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                    texture.filteringMode = .nearest
                    noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + Int(_distance) * note.holdTimeTick), cornerRadius: _noteCornerRadius)
                    noteNode.fillTexture = texture
                    noteNode.fillColor = .white
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2) * _distance * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.name = "note"
                    noteNode.alpha = 1.0
                    noteNode.lineWidth = 8
                } else {
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    switch note.noteType {
                    case .Tap: noteNode.fillColor = SKColor.blue
                    case .Hold: continue
                    case .Drag: noteNode.fillColor = SKColor.yellow
                    case .Flick: noteNode.fillColor = SKColor.red
                    }
                }
                link(nodeA: noteNode, to: noteNodeTemplate!)
                addChild(noteNode)
            }
        }
    }

    func startRunning() {
        if data == nil {
            return
        }
        if size.width == 0 || size.height == 0 || data == nil {
            return
        }
        if judgeLineNodeTemplate == nil {
            judgeLineNodeTemplate = {
                let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: 2))
                judgeLineNodeTemplate.fillColor = SKColor.white
                judgeLineNodeTemplate.name = "judgeLine"
                judgeLineNodeTemplate.alpha = 1.0
                return judgeLineNodeTemplate
            }()
        } else {
            removeNodesLinked(to: judgeLineNodeTemplate!)
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
        for judgeLine in data!.listOfJudgeLines {
            let judgeLineNode = judgeLineNodeTemplate!.copy() as! SKShapeNode
            let judgeLinePosX = judgeLine.props.calculateValue(.controlX, data!.currentTimeTick) * size.width
            let judgeLinePosY = judgeLine.props.calculateValue(.controlY, data!.currentTimeTick) * size.width
            let judgeLineAngle = judgeLine.props.calculateValue(.angle, data!.currentTimeTick) * 2.0 * .pi
            judgeLineNode.position = CGPoint(x: judgeLinePosX, y: judgeLinePosY)
            judgeLineNode.zRotation = judgeLineAngle

            var indexK = 0
            var movingActions: [SKAction] = []
            judgeLine.props.controlX = judgeLine.props.controlX.sorted { $0.timeTick < $1.timeTick }
            judgeLine.props.controlY = judgeLine.props.controlY.sorted { $0.timeTick < $1.timeTick }
            judgeLine.props.angle = judgeLine.props.angle.sorted { $0.timeTick < $1.timeTick }
            if judgeLine.props.controlX.count > 1, Double(judgeLine.props.controlX[judgeLine.props.controlX.count - 1].timeTick) > data!.currentTimeTick {
                // only one propStatus -> don't need to be updated
                indexK = 0
                var moveActionsX: [SKAction] = []
                for index in 0 ..< judgeLine.props.controlX.count {
                    if Double(judgeLine.props.controlX[index].timeTick) > data!.currentTimeTick {
                        break
                    }
                    indexK += 1
                }
                // [indexK - 1] - currentTimeTick - [indexK]
                if indexK < judgeLine.props.controlX.count {
                    let tmpAction = SKAction.moveTo(x: judgeLine.props.controlX[indexK].value * size.width, duration: data!.tickToSecond(Double(judgeLine.props.controlX[indexK].timeTick) - data!.currentTimeTick))
                    tmpAction.timingFunction = { time in
                        let p = (self.data!.currentTimeTick - Double(judgeLine.props.controlX[indexK - 1].timeTick)) / (Double(judgeLine.props.controlX[indexK].timeTick) - Double(judgeLine.props.controlX[indexK - 1].timeTick))
                        let t = (1.0 - p) * Double(time) + p
                        let ft = calculateEasing(x: t, type: judgeLine.props.controlX[indexK - 1].followingEasing)
                        let fpt = (ft - judgeLine.props.calculateValue(.controlX, self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(.controlX, self.data!.currentTimeTick))
                        return Float(fpt)
                    }
                    moveActionsX.append(tmpAction)
                    for index in indexK + 1 ..< judgeLine.props.controlX.count {
                        let tmpAction = SKAction.moveTo(x: (judgeLine.props.controlX[index].value) * size.width, duration: data!.tickToSecond(Double(judgeLine.props.controlX[index].timeTick) - Double(judgeLine.props.controlX[index - 1].timeTick)))
                        tmpAction.timingFunction = { time in
                            Float(calculateEasing(x: Double(time), type: judgeLine.props.controlX[index - 1].followingEasing))
                        }
                        moveActionsX.append(tmpAction)
                    }
                    movingActions.append(SKAction.sequence(moveActionsX))
                }
            }

            if judgeLine.props.controlY.count > 1, Double(judgeLine.props.controlY[judgeLine.props.controlY.count - 1].timeTick) > data!.currentTimeTick {
                // only one propStatus -> don't need to be updated
                indexK = 0
                var moveActionsY: [SKAction] = []
                for index in 0 ..< judgeLine.props.controlY.count {
                    if Double(judgeLine.props.controlY[index].timeTick) > data!.currentTimeTick {
                        break
                    }
                    indexK += 1
                }
                // [indexK - 1] - currentTimeTick - [indexK]
                if indexK < judgeLine.props.controlY.count {
                    let tmpAction = SKAction.moveTo(y: (judgeLine.props.controlY[indexK].value) * size.width, duration: data!.tickToSecond(Double(judgeLine.props.controlY[indexK].timeTick) - data!.currentTimeTick))
                    tmpAction.timingFunction = { time in
                        let p = (self.data!.currentTimeTick - Double(judgeLine.props.controlY[indexK - 1].timeTick)) / (Double(judgeLine.props.controlY[indexK].timeTick) - Double(judgeLine.props.controlY[indexK - 1].timeTick))
                        let t = (1.0 - p) * Double(time) + p
                        let ft = calculateEasing(x: t, type: judgeLine.props.controlY[indexK - 1].followingEasing)
                        let fpt = (ft - judgeLine.props.calculateValue(.controlY, self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(.controlY, self.data!.currentTimeTick))
                        return Float(fpt)
                    }
                    moveActionsY.append(tmpAction)
                    for index in indexK + 1 ..< judgeLine.props.controlY.count {
                        let tmpAction = SKAction.moveTo(y: (judgeLine.props.controlY[index].value) * size.width, duration: data!.tickToSecond(Double(judgeLine.props.controlY[index].timeTick) - Double(judgeLine.props.controlY[index - 1].timeTick)))
                        tmpAction.timingFunction = { time in
                            Float(calculateEasing(x: Double(time), type: judgeLine.props.controlY[index - 1].followingEasing))
                        }
                        moveActionsY.append(tmpAction)
                    }
                    movingActions.append(SKAction.sequence(moveActionsY))
                }
            }

            if judgeLine.props.angle.count > 1, Double(judgeLine.props.angle[judgeLine.props.angle.count - 1].timeTick) > data!.currentTimeTick {
                // only one propStatus -> don't need to be updated
                indexK = 0
                var moveActionsAngle: [SKAction] = []
                for index in 0 ..< judgeLine.props.angle.count {
                    if Double(judgeLine.props.angle[index].timeTick) > data!.currentTimeTick {
                        break
                    }
                    indexK += 1
                }
                // [indexK - 1] - currentTimeTick - [indexK]
                if indexK < judgeLine.props.angle.count {
                    let tmpAction = SKAction.rotate(toAngle: judgeLine.props.angle[indexK].value * 2.0 * .pi, duration: data!.tickToSecond(Double(judgeLine.props.angle[indexK - 1].timeTick) - data!.currentTimeTick))
                    tmpAction.timingFunction = { time in
                        let p = (self.data!.currentTimeTick - Double(judgeLine.props.angle[indexK - 1].timeTick)) / (Double(judgeLine.props.angle[indexK].timeTick) - Double(judgeLine.props.angle[indexK - 1].timeTick))
                        let t = (1.0 - p) * Double(time) + p
                        let ft = calculateEasing(x: t, type: judgeLine.props.angle[indexK - 1].followingEasing)
                        let fpt = (ft - judgeLine.props.calculateValue(.angle, self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(.angle, self.data!.currentTimeTick))
                        return Float(fpt)
                    }
                    moveActionsAngle.append(tmpAction)
                    for index in indexK + 1 ..< judgeLine.props.angle.count {
                        let tmpAction = SKAction.rotate(toAngle: judgeLine.props.angle[index].value * 2.0 * .pi, duration: data!.tickToSecond(Double(judgeLine.props.angle[index].timeTick) - Double(judgeLine.props.angle[index - 1].timeTick)))
                        tmpAction.timingFunction = { time in
                            Float(calculateEasing(x: Double(time), type: judgeLine.props.angle[index - 1].followingEasing))
                        }
                        moveActionsAngle.append(tmpAction)
                    }
                    movingActions.append(SKAction.sequence(moveActionsAngle))
                }
            }
            let groupAction = SKAction.group(movingActions)
            judgeLineNode.run(groupAction, withKey: "movingJudgeLine")
            link(nodeA: judgeLineNode, to: judgeLineNodeTemplate!)
            addChild(judgeLineNode)

            for note in judgeLine.noteList {
                var noteMoveFunctions: [SKAction] = []
                if note.noteType == .Hold {
                    if Double(note.timeTick + note.holdTimeTick) <= data!.currentTimeTick {
                        continue
                    }
                } else if Double(note.timeTick) <= data!.currentTimeTick {
                    continue
                }
                var noteNode = noteNodeTemplate!.copy() as! SKShapeNode
                let noteRelativePosition = judgeLine.props.calculateNoteDistance(data!.currentTimeTick, Double(note.timeTick)) * _distance
                let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                if note.noteType == .Hold {
                    let topColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.0)
                    let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                    texture.filteringMode = .nearest
                    noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + Int(_distance) * note.holdTimeTick), cornerRadius: _noteCornerRadius)
                    noteNode.fillTexture = texture
                    noteNode.fillColor = .white
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2) * _distance * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.name = "note"
                    noteNode.alpha = 1.0
                    noteNode.lineWidth = 8
                    var noteMoveAction: [SKAction] = []
                    var tmpTick = data!.currentTimeTick
                    while tmpTick < Double(note.timeTick + note.holdTimeTick) {
                        tmpTick += _refreshTick
                        let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                        let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                        let judgeLinePosY = judgeLine.props.calculateValue(.controlY, tmpTick) * size.width
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                        let tmpActionX = SKAction.moveTo(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionY = SKAction.moveTo(y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAngle = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(_refreshTick))

                        noteMoveAction.append(SKAction.group([tmpActionX, tmpActionY, tmpActionAngle]))
                    }
                    noteMoveFunctions.append(SKAction.sequence([SKAction.wait(forDuration: data!.tickToSecond(Double(note.timeTick) - data!.currentTimeTick)), SKAction.fadeOut(withDuration: data!.tickToSecond(Double(note.holdTimeTick)))]))
                    noteMoveFunctions.append(SKAction.sequence(noteMoveAction))
                } else {
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    switch note.noteType {
                    case .Tap: noteNode.fillColor = SKColor.blue
                    case .Hold: continue
                    case .Drag: noteNode.fillColor = SKColor.yellow
                    case .Flick: noteNode.fillColor = SKColor.red
                    }
                    var noteMoveAction: [SKAction] = []
                    var tmpTick = data!.currentTimeTick
                    while tmpTick < Double(note.timeTick) {
                        tmpTick += _refreshTick
                        let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                        let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                        let judgeLinePosY = judgeLine.props.calculateValue(.controlY, tmpTick) * size.width
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                        let tmpActionX = SKAction.moveTo(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionY = SKAction.moveTo(y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAngle = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(_refreshTick))

                        noteMoveAction.append(SKAction.group([tmpActionX, tmpActionY, tmpActionAngle]))
                    }
                    noteMoveAction.append(SKAction.removeFromParent())
                    noteMoveFunctions.append(SKAction.sequence(noteMoveAction))
                }
                let noteGroupAction = SKAction.group(noteMoveFunctions)
                noteNode.run(noteGroupAction, withKey: "movingNote")
                link(nodeA: noteNode, to: noteNodeTemplate!)
                addChild(noteNode)
            }
        }
    }

    func pauseRunning() {
        if data == nil {
            return
        }
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == judgeLineNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == judgeLineNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.removeAllActions()
        }
    }
}

struct ChartPreview: View {
    @EnvironmentObject private var data: DataStructure
    var body: some View {
        SpriteView(scene: data.chartPreviewScene)
    }
}
