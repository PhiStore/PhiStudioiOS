import SpriteKit
import SwiftUI

let _distanceH = 5.0

class PropEditorScene: SKScene {
    var data: DataStructure?

    var controlNodeTemplate: SKShapeNode?
    var indexLineNodeTemplate: SKShapeNode?
    var indexLineLabelNodeTemplate: SKLabelNode?
    var lintNodeTemplate: SKShapeNode?

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

    func clearAndMakeIndexLines() {
        if size.width == 0 || size.height == 0 || data == nil {
            return
        }

        if indexLineNodeTemplate == nil {
            indexLineNodeTemplate = {
                let indexLineNodeTemplate = SKShapeNode(rectOf: CGSize(width: 2, height: size.height))
                indexLineNodeTemplate.fillColor = SKColor.white
                indexLineNodeTemplate.name = "indexLine"
                indexLineNodeTemplate.alpha = 0.2
                return indexLineNodeTemplate
            }()
        } else {
            removeNodesLinked(to: indexLineNodeTemplate!)
        }

        if indexLineLabelNodeTemplate == nil {
            indexLineLabelNodeTemplate = {
                let lintNodeTemplate = SKLabelNode(fontNamed: "AmericanTypewriter")
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

            if currentLineTick % data!.tickPerBeat == 0 {
                indexLineNode.alpha = 1.0
            } else {
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
        if size.width == 0 || size.height == 0 || data == nil {
            return
        }

        if controlNodeTemplate == nil {
            controlNodeTemplate = {
                let controlNodeTemplate = SKShapeNode(circleOfRadius: 10)
                controlNodeTemplate.fillColor = .red
                controlNodeTemplate.strokeColor = .white
                controlNodeTemplate.lineWidth = 2
                controlNodeTemplate.alpha = 0.8
                return controlNodeTemplate
            }()
        } else {
            removeNodesLinked(to: controlNodeTemplate!)
        }

        let RelativePostionX = 50 + _distanceH * (data!.currentTimeTick - Double(Int(data!.currentTimeTick)))

        for propType in PROPTYPE.allCases {
            var prop = data!.listOfJudgeLines[data!.editingJudgeLineNumber].props.returnProp(type: propType)
            if prop == nil {
                continue
            }
            prop = prop?.sorted(by: { propA, propB in
                propA.timeTick < propB.timeTick
            })
            for indexI in 0 ..< prop!.count {
                var controlNode: SKShapeNode

                controlNode = controlNodeTemplate!.copy() as! SKShapeNode
                controlNode.position = CGPoint(x: CGFloat(prop![indexI].timeTick - Int(data!.currentTimeTick)) * _distanceH + RelativePostionX, y: size.height * prop![indexI].value)
                link(nodeA: controlNode, to: controlNodeTemplate!)
                addChild(controlNode)
            }
        }
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

    override func didMove(to _: SKView) {}

    override func update(_: TimeInterval) {}

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {}
}

struct PropEditorView: View {
    @EnvironmentObject private var data: DataStructure

    var body: some View {
        SpriteView(scene: data.propEditScene)
    }
}

struct PropEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let tmpData = DataStructure()
        PropEditorView().environmentObject(tmpData)
    }
}
