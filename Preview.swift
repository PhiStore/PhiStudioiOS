/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SpriteKit
import SwiftUI

let _refreshTick = 5.0

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

    func initJudgeLineNodeTemplate() {
        judgeLineNodeTemplate = {
            let judgeLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: size.width * 3, height: 2))
            judgeLineNodeTemplate.fillColor = SKColor.white
            judgeLineNodeTemplate.name = "judgeLine"
            judgeLineNodeTemplate.alpha = 1.0
            return judgeLineNodeTemplate
        }()
    }

    func initNoteNodeTemplate() {
        noteNodeTemplate = {
            let noteNodeTemplate = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight), cornerRadius: _noteCornerRadius)
            noteNodeTemplate.name = "note"
            noteNodeTemplate.alpha = 1.0
            noteNodeTemplate.lineWidth = 5
            return noteNodeTemplate
        }()
    }

    func updateCanvasSize() {
        if judgeLineNodeTemplate != nil {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }

        initJudgeLineNodeTemplate()
    }

    func prepareStaticJudgeLines() {
        if judgeLineNodeTemplate == nil {
            initJudgeLineNodeTemplate()
        } else {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }
        if noteNodeTemplate == nil {
            initNoteNodeTemplate()
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
                    if Double(note.timeTick + note.holdTimeTick) < data!.currentTimeTick {
                        continue
                    }
                } else if Double(note.timeTick) < data!.currentTimeTick {
                    continue
                }

                var noteNode = noteNodeTemplate!.copy() as! SKShapeNode

                let noteRelativePosition = judgeLine.props.calculateNoteDistance(data!.currentTimeTick, Double(note.timeTick)) * _distance
                let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)

                if note.noteType == .Hold {
                    let topColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.0)
                    let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                    texture.filteringMode = .nearest
                    noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + _distance * Double(note.holdTimeTick)), cornerRadius: _noteCornerRadius)

                    noteNode.fillTexture = texture
                    noteNode.fillColor = .white
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2) * _distance * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.name = "note"
                    noteNode.alpha = 1.0
                    noteNode.lineWidth = 5
                } else {
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.fillColor = noteColor(type: note.noteType)
                }
                link(nodeA: noteNode, to: noteNodeTemplate!)
                addChild(noteNode)
            }
        }
    }

    func startRunning() {
        if judgeLineNodeTemplate == nil {
            initJudgeLineNodeTemplate()
        } else {
            removeNodesLinked(to: judgeLineNodeTemplate!)
        }
        if noteNodeTemplate == nil {
            initNoteNodeTemplate()
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

            var movingActions: [SKAction] = []
            var tmpTick = data!.currentTimeTick
            while tmpTick < Double(data!.chartLengthTick()) {
                let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                let judgeLinePosY = judgeLine.props.calculateValue(.controlY, tmpTick) * size.width
                let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                let judgeLineAlpha = judgeLine.props.calculateValue(.lineAlpha, tmpTick)

                let tmpActionX = SKAction.moveTo(x: judgeLinePosX, duration: data!.tickToSecond(_refreshTick))
                let tmpActionY = SKAction.moveTo(y: judgeLinePosY, duration: data!.tickToSecond(_refreshTick))
                let tmpActionRotation = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(_refreshTick))
                let tmpActionAlpha = SKAction.fadeAlpha(to: judgeLineAlpha, duration: data!.tickToSecond(_refreshTick))
                movingActions.append(SKAction.group([tmpActionX, tmpActionY, tmpActionRotation, tmpActionAlpha]))
                tmpTick += _refreshTick
            }
            let groupAction = SKAction.sequence(movingActions)
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
                    let topColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.0)
                    let texture = SKTexture(size: CGSize(width: 200, height: 200), color1: topColor, color2: bottomColor, direction: GradientDirection.up)
                    texture.filteringMode = .nearest
                    noteNode = SKShapeNode(rectOf: CGSize(width: _noteWidth, height: _noteHeight + _distance * Double(note.holdTimeTick)), cornerRadius: _noteCornerRadius)
                    noteNode.fillTexture = texture
                    noteNode.fillColor = .white
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2) * _distance * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.name = "note"
                    noteNode.alpha = 1.0
                    noteNode.lineWidth = 8
                    var noteMoveAction: [SKAction] = []
                    var tmpTick = data!.currentTimeTick
                    while tmpTick <= Double(note.timeTick + note.holdTimeTick) {
                        let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                        let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                        let judgeLinePosY = judgeLine.props.calculateValue(.controlY, tmpTick) * size.width
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                        let noteAlpha = judgeLine.props.calculateValue(.noteAlpha, tmpTick)

                        let tmpActionX = SKAction.moveTo(x: (note.fallSide ? -1.0 : 1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionY = SKAction.moveTo(y: (note.fallSide ? 1.0 : -1.0) * (noteRelativePosition + Double(note.holdTimeTick) / 2 * _distance) * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAngle = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAlpha = SKAction.fadeAlpha(to: noteAlpha, duration: data!.tickToSecond(_refreshTick))

                        noteMoveAction.append(SKAction.group([tmpActionX, tmpActionY, tmpActionAngle, tmpActionAlpha]))
                        tmpTick += _refreshTick
                    }
                    noteMoveFunctions.append(SKAction.sequence([SKAction.wait(forDuration: data!.tickToSecond(Double(note.timeTick) - data!.currentTimeTick)), SKAction.fadeOut(withDuration: data!.tickToSecond(Double(note.holdTimeTick))), SKAction.removeFromParent()]))
                    noteMoveFunctions.append(SKAction.sequence(noteMoveAction))
                } else {
                    noteNode.position = CGPoint(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY)
                    noteNode.zRotation = judgeLineAngle
                    noteNode.fillColor = noteColor(type: note.noteType)
                    var noteMoveAction: [SKAction] = []
                    var tmpTick = data!.currentTimeTick
                    while tmpTick <= Double(note.timeTick) {
                        let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                        let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                        let judgeLinePosY = judgeLine.props.calculateValue(.controlY, tmpTick) * size.width
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 1 / 2) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 1 / 2) * size.width * sin(judgeLineAngle)
                        let noteAlpha = judgeLine.props.calculateValue(.noteAlpha, tmpTick)

                        let tmpActionX = SKAction.moveTo(x: (note.fallSide ? -1.0 : 1.0) * noteRelativePosition * sin(judgeLineAngle) + judgeLinePosX + noteDeltaX, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionY = SKAction.moveTo(y: (note.fallSide ? 1.0 : -1.0) * noteRelativePosition * cos(judgeLineAngle) + judgeLinePosY + noteDeltaY, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAngle = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(_refreshTick))

                        let tmpActionAlpha = SKAction.fadeAlpha(to: noteAlpha, duration: data!.tickToSecond(_refreshTick))

                        noteMoveAction.append(SKAction.group([tmpActionX, tmpActionY, tmpActionAngle, tmpActionAlpha]))
                        tmpTick += _refreshTick
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
