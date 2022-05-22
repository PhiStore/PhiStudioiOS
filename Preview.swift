import SpriteKit
import SwiftUI

// let _noteWidth = 120
// let _noteHeight = 15
// let _noteCornerRadius = 4.0

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
            // FIXME: I doubt this part of code really matters, since before this function is called, the updateCanvasSize is always called ahead, therefore judgeLineNodeTemplate is always not nil.
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
            judgeLineNode.position = CGPoint(x: judgeLine.props.calculateValue(type: .controlX, timeTick: data!.currentTimeTick) * size.width, y: judgeLine.props.calculateValue(type: .controlY, timeTick: data!.currentTimeTick) * size.height)
            judgeLineNode.zRotation = judgeLine.props.calculateValue(type: .angle, timeTick: data!.currentTimeTick) * 2.0 * .pi
            link(nodeA: judgeLineNode, to: judgeLineNodeTemplate!)
            addChild(judgeLineNode)
            for note in judgeLine.noteList {
                if Double(note.timeTick) < data!.currentTimeTick {
                    continue
                }
                let noteNode = noteNodeTemplate!.copy() as! SKShapeNode
                noteNode.position = CGPoint(x: -judgeLine.props.calculatePositionX(startTimeTick: data!.currentTimeTick, endTimeTick: Double(note.timeTick) * _distance) + (judgeLine.props.calculateValue(type: .controlX, timeTick: data!.currentTimeTick) + note.posX * cos(judgeLine.props.calculateValue(type: .angle, timeTick: data!.currentTimeTick) * 2.0 * .pi) - 1.0 / 2.0) * size.width, y: judgeLine.props.calculatePositionY(startTimeTick: data!.currentTimeTick, endTimeTick: Double(note.timeTick)) * _distance + (judgeLine.props.calculateValue(type: .controlY, timeTick: data!.currentTimeTick) + note.posX * sin(judgeLine.props.calculateValue(type: .angle, timeTick: data!.currentTimeTick) * 2.0 * .pi)) * size.height)
                noteNode.zRotation = judgeLine.props.calculateValue(type: .angle, timeTick: data!.currentTimeTick) * 2.0 * .pi
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
            // FIXME: I doubt this part of code really matters, since before this function is called, the updateCanvasSize is always called ahead, therefore judgeLineNodeTemplate is always not nil.
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
            judgeLineNode.position = CGPoint(x: judgeLine.props.calculateValue(type: .controlX, timeTick: data!.currentTimeTick) * size.width, y: judgeLine.props.calculateValue(type: .controlY, timeTick: data!.currentTimeTick) * size.height)
            judgeLineNode.zRotation = judgeLine.props.calculateValue(type: .angle, timeTick: data!.currentTimeTick) * 2.0 * .pi
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

                        let fpt = (ft - judgeLine.props.calculateValue(type: .controlX, timeTick: self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(type: .controlX, timeTick: self.data!.currentTimeTick))

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

                        let fpt = (ft - judgeLine.props.calculateValue(type: .controlY, timeTick: self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(type: .controlY, timeTick: self.data!.currentTimeTick))

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

                        let fpt = (ft - judgeLine.props.calculateValue(type: .angle, timeTick: self.data!.currentTimeTick)) / (1 - judgeLine.props.calculateValue(type: .angle, timeTick: self.data!.currentTimeTick))

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

            for note in judgeLine.noteList {}
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
