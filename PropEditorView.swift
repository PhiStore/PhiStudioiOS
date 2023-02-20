/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SpriteKit
import SwiftUI

let _distanceH = 5.0
let _renderMin = 10.0

class PropEditorScene: SKScene {
    var data: DataStructure?

    var controlNodeTemplate: SKShapeNode?
    var controlCurveNodeTemplate: SKShapeNode?
    var controlCurveLabelNodeTemplate: SKLabelNode?
    var indexLineNodeTemplate: SKShapeNode?
    var indexLineLabelNodeTemplate: SKLabelNode?
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
        if indexLineNodeTemplate != nil {
            removeNodesLinked(to: indexLineNodeTemplate!)
        }
        indexLineNodeTemplate = {
            let indexLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: 2, height: size.height))
            indexLineNodeTemplate.fillColor = SKColor.white
            indexLineNodeTemplate.name = "indexLine"
            indexLineNodeTemplate.alpha = 1.0
            return indexLineNodeTemplate
        }()
    }

    func clearAndMakeIndexLines() {
        if indexLineNodeTemplate == nil {
            indexLineNodeTemplate = {
                let indexLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: 2, height: size.height))
                indexLineNodeTemplate.fillColor = SKColor.white
                indexLineNodeTemplate.name = "indexLine"
                indexLineNodeTemplate.alpha = 1.0
                return indexLineNodeTemplate
            }()
        } else {
            removeNodesLinked(to: indexLineNodeTemplate!)
        }
        if indexLineLabelNodeTemplate == nil {
            indexLineLabelNodeTemplate = {
                let lintNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
                lintNodeTemplate.fontSize = 15
                lintNodeTemplate.fontColor = SKColor.white
                lintNodeTemplate.name = "indexLineLabel"
                lintNodeTemplate.verticalAlignmentMode = .bottom
                lintNodeTemplate.horizontalAlignmentMode = .left
                return lintNodeTemplate
            }()
        } else {
            removeNodesLinked(to: indexLineLabelNodeTemplate!)
        }
        let RelativePostionX = 50 + _distanceH * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
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
            let indexLineNode = indexLineNodeTemplate!.copy() as! SKShapeNode
            indexLineNode.position = CGPoint(x: RelativePostionX + _distanceH * CGFloat(currentLineTick - RelativeTick), y: size.height / 2)
            if !(currentLineTick % data!.tickPerBeat == 0) {
                indexLineNode.alpha = 0.2
                indexLineNode.fillColor = SKColor(indexedColor!)
            }
            link(nodeA: indexLineNode, to: indexLineNodeTemplate!)
            addChild(indexLineNode)
            if currentLineTick % data!.tickPerBeat == 0 {
                let indexLineLabelNode = indexLineLabelNodeTemplate!.copy() as! SKLabelNode
                indexLineLabelNode.text = String(currentLineTick) + "/" + String(currentLineTick / data!.tickPerBeat)
                indexLineLabelNode.position = CGPoint(x: RelativePostionX + CGFloat(currentLineTick - RelativeTick) * _distance, y: 0)
                link(nodeA: indexLineLabelNode, to: indexLineLabelNodeTemplate!)
                addChild(indexLineLabelNode)
            }
        }
    }

    func clearAndMakePropControlNodes() {
        if controlNodeTemplate == nil {
            controlNodeTemplate = {
                let controlNodeTemplate = SKShapeNode(circleOfRadius: 10)
                controlNodeTemplate.fillColor = .red
                controlNodeTemplate.strokeColor = .white
                controlNodeTemplate.lineWidth = 2
                controlNodeTemplate.alpha = 0.4
                controlNodeTemplate.name = "controlNode"
                return controlNodeTemplate
            }()
        } else {
            removeNodesLinked(to: controlNodeTemplate!)
        }
        if controlCurveNodeTemplate == nil {
            controlCurveNodeTemplate = {
                let controlCurveNodeTemplate = SKShapeNode()
                return controlCurveNodeTemplate
            }()
        } else {
            removeNodesLinked(to: controlCurveNodeTemplate!)
        }
        if controlCurveLabelNodeTemplate == nil {
            controlCurveLabelNodeTemplate = {
                let controlCurveLabelNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
                controlCurveLabelNodeTemplate.fontSize = 15
                controlCurveLabelNodeTemplate.fontColor = SKColor.green
                controlCurveLabelNodeTemplate.name = "controlCurveLabel"
                controlCurveLabelNodeTemplate.verticalAlignmentMode = .center
                controlCurveLabelNodeTemplate.horizontalAlignmentMode = .left
                return controlCurveLabelNodeTemplate
            }()
        } else {
            removeNodesLinked(to: controlCurveLabelNodeTemplate!)
        }
        let RelativePostionX = 50 + _distanceH * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        for propType in PROPTYPE.allCases {
            let besselPath = UIBezierPath()
            var controlNode = SKShapeNode()
            var prop = data!.listOfJudgeLines[data!.editingJudgeLineNumber].props.returnProp(type: propType)
            prop = prop.sorted(by: { propA, propB in
                propA.timeTick < propB.timeTick
            })
            prop = prop.filterDuplicates { $0.timeTick }
            if prop.count != 0 {
                if propType != .speed {
                    besselPath.move(to: CGPoint(x: CGFloat(prop[0].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[0].prefixValue()))

                    for indexI in 0 ..< prop.count {
                        controlNode = controlNodeTemplate!.copy() as! SKShapeNode
                        controlNode.position = CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].value)
                        if propType == data!.currentPropType {
                            controlNode.alpha = 1.0
                        }
                        link(nodeA: controlNode, to: controlNodeTemplate!)
                        addChild(controlNode)
                        besselPath.addLine(to: CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].value))
                        if prop[indexI].nextJumpValue != nil {
                            controlNode = controlNodeTemplate!.copy() as! SKShapeNode
                            controlNode.position = CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].nextJumpValue!)
                            if propType == data!.currentPropType {
                                controlNode.alpha = 1.0
                            }
                            link(nodeA: controlNode, to: controlNodeTemplate!)
                            addChild(controlNode)
                            besselPath.addLine(to: CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].nextJumpValue!))
                        }
                        if indexI != prop.count - 1 {
                            let startX = CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX
                            let endX = CGFloat(prop[indexI + 1].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX
                            let startY = size.height * prop[indexI].prefixValue()
                            let endY = size.height * prop[indexI + 1].value
                            var positionX = startX
                            var positionY = 0.0
                            while positionX < endX {
                                positionX += _renderMin
                                positionY = calculateEasing(x: (positionX - startX) / (endX - startX), type: prop[indexI].followingEasing) * (endY - startY) + startY
                                besselPath.addLine(to: CGPoint(x: positionX, y: positionY))
                            }
                        }
                    }
                } else {
                    besselPath.move(to: CGPoint(x: CGFloat(prop[0].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[0].value))

                    for indexI in 0 ..< prop.count {
                        controlNode = controlNodeTemplate!.copy() as! SKShapeNode
                        controlNode.position = CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].value)
                        if propType == data!.currentPropType {
                            controlNode.alpha = 1.0
                        }
                        link(nodeA: controlNode, to: controlNodeTemplate!)
                        addChild(controlNode)
                        besselPath.addLine(to: CGPoint(x: CGFloat(prop[indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].value))
                        if indexI != prop.count - 1 {
                            besselPath.addLine(to: CGPoint(x: CGFloat(prop[indexI + 1].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop[indexI].value))
                        }
                    }
                }
                besselPath.addLine(to: CGPoint(x: (Double(data!.chartLengthTick()) - data!.currentTimeTick) * _distanceH + RelativePostionX, y: size.height * prop[prop.count - 1].value))
                let controlCurveNode = SKShapeNode()
                controlCurveNode.path = besselPath.cgPath
                controlCurveNode.strokeColor = .white
                controlCurveNode.alpha = (propType == data!.currentPropType) ? 1.0 : 0.4
                controlCurveNode.lineWidth = 8
                addChild(controlCurveNode)
                link(nodeA: controlCurveNode, to: controlCurveNodeTemplate!)
            }
            let controlCurveLabel = controlCurveLabelNodeTemplate!.copy() as! SKLabelNode
            controlCurveLabel.position = CGPoint(x: 50, y: size.height * data!.listOfJudgeLines[data!.editingJudgeLineNumber].props.calculateValue(propType, data!.currentTimeTick))
            controlCurveLabel.text = String(describing: propType)
            link(nodeA: controlCurveLabel, to: controlCurveLabelNodeTemplate!)
            addChild(controlCurveLabel)
        }
    }

    func clearAndMakeLint() {
        if lintNodeTemplate == nil {
            lintNodeTemplate = {
                let lintNodeTemplate = SKShapeNode(circleOfRadius: 10)
                lintNodeTemplate.fillColor = SKColor.red
                lintNodeTemplate.name = "lintNode"
                lintNodeTemplate.alpha = 0.5
                lintNodeTemplate.position = CGPoint(x: 50, y: 0)
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
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == controlNodeTemplate || pair.0 == indexLineNodeTemplate || pair.0 == indexLineLabelNodeTemplate || pair.0 == controlCurveNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == controlNodeTemplate || pair.1 == indexLineNodeTemplate || pair.1 == indexLineLabelNodeTemplate || pair.1 == controlCurveNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.run(SKAction.repeatForever(SKAction.move(by: CGVector(dx: -Double(data!.tickPerBeat * data!.bpm) * _distanceH, dy: 0), duration: 60.0)), withKey: "moving")
        }
    }

    func pauseRunning() {
        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == controlNodeTemplate || pair.0 == indexLineNodeTemplate || pair.0 == indexLineLabelNodeTemplate || pair.0 == controlCurveNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == controlNodeTemplate || pair.1 == indexLineNodeTemplate || pair.1 == indexLineLabelNodeTemplate || pair.1 == controlCurveNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.removeAllActions()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent?) {
        let RelativePositionX = 50 + _distanceH * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchHint = SKShapeNode(circleOfRadius: 10)
            touchHint.fillColor = .green
            touchHint.position = touchLocation
            touchHint.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1), SKAction.removeFromParent()]))
            addChild(touchHint)
            if data!.locked {
                moveStartPoint = touchLocation
                moveStartTimeTick = data?.currentTimeTick
                return
            } else {
                moveStartPoint = nil
                moveStartTimeTick = nil
            }
            let tmpTick = (touchLocation.x - RelativePositionX) / _distanceH + data!.currentTimeTick
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
                if node.name == "controlNode" {
                    node.run(SKAction.fadeOut(withDuration: 0.1))
                    data!.listOfJudgeLines[data!.editingJudgeLineNumber].props.removePropWhere(type: data!.currentPropType, timeTick: minTick, value: touchLocation.y / size.height)
                    clearAndMakePropControlNodes()
                    data!.objectWillChange.send()
                    return
                }
            }
            if minTick >= 0, minTick <= data!.tickPerBeat * data!.chartLengthSecond * data!.bpm / 60 {
                data!.listOfJudgeLines[data!.editingJudgeLineNumber].props.appendNewProp(type: data!.currentPropType, timeTick: minTick, value: touchLocation.y / size.height, followingEasing: .linear)
                clearAndMakePropControlNodes()
                data!.objectWillChange.send()
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
                if pair.0 == controlNodeTemplate || pair.0 == indexLineNodeTemplate || pair.0 == indexLineLabelNodeTemplate || pair.0 == controlCurveNodeTemplate || pair.0 == controlCurveLabelNodeTemplate {
                    res.insert(pair.1)
                }
                if pair.1 == controlNodeTemplate || pair.1 == indexLineNodeTemplate || pair.1 == indexLineLabelNodeTemplate || pair.1 == controlCurveNodeTemplate || pair.1 == controlCurveLabelNodeTemplate {
                    res.insert(pair.0)
                }
                return res
            }
            linkedNodes.forEach {
                $0.run(SKAction.move(by: CGVector(dx: min(touchLocation.x - moveStartPoint!.x, moveStartTimeTick! * _distanceH), dy: 0), duration: 0))
            }
            data!.shouldUpdateFrame = false
            data!.currentTimeTick = moveStartTimeTick! - (touchLocation.x - moveStartPoint!.x) / _distanceH
            data!.shouldUpdateFrame = true
            moveStartPoint = touchLocation
            moveStartTimeTick = data!.currentTimeTick
            return
        }
    }
}

struct PropEditorView: View {
    @EnvironmentObject private var data: DataStructure
    var body: some View {
        SpriteView(scene: data.propEditScene)
    }
}
