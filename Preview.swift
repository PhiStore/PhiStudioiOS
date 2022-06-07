/**
 * Created on Fri Jun 03 2022
 *
 * Copyright (c) 2022 TianKaiMa
 */
import SpriteKit
import SwiftUI

let _refreshTick = 5.0
let updateFreq = 10

class ChartPreviewScene: SKScene {
    var data: DataStructure?
    var judgeLineNodeTemplate: SKShapeNode?
    var noteNodeTemplate: SKShapeNode?
    var backgroundImageNodeTemplate: SKSpriteNode?
    var controlNodeTemplate: SKShapeNode?
    var timeLintNodeTemplate: SKLabelNode?
    var timeDemoNodeTemplate: SKShapeNode?
    var authorLintNodeTemplate: SKLabelNode?
    var scoreLintNodeTemplate: SKLabelNode?

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

    func createLintNodes() {
        if authorLintNodeTemplate == nil {
            authorLintNodeTemplate = {
                let authorLintNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
                authorLintNodeTemplate.fontSize = 15
                authorLintNodeTemplate.fontColor = SKColor.white
                authorLintNodeTemplate.name = "authorLint"
                authorLintNodeTemplate.verticalAlignmentMode = .bottom
                authorLintNodeTemplate.horizontalAlignmentMode = .left
                return authorLintNodeTemplate
            }()
        } else {
            removeNodesLinked(to: authorLintNodeTemplate!)
        }

        if scoreLintNodeTemplate == nil {
            scoreLintNodeTemplate = {
                let scoreLintNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
                scoreLintNodeTemplate.fontSize = 15
                scoreLintNodeTemplate.fontColor = SKColor.white
                scoreLintNodeTemplate.name = "scoreLint"
                scoreLintNodeTemplate.verticalAlignmentMode = .center
                scoreLintNodeTemplate.horizontalAlignmentMode = .left
                return scoreLintNodeTemplate
            }()
        } else {
            removeNodesLinked(to: scoreLintNodeTemplate!)
        }
        updateTimeDemoOnly()
        let authorLintNode = authorLintNodeTemplate!.copy() as! SKLabelNode
        authorLintNode.text = """
        PhiStudio Preview [Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Not Found"), Device: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)],
        Music name: \(data!.musicName) by \(data!.authorName) [Copyright:\(String(describing: data!.copyright).capitalizingFirstLetter())],
        Chart by \(data!.chartAuthorName),
        Level: \(data!.chartLevel)
        """
        authorLintNode.numberOfLines = 0
        authorLintNode.preferredMaxLayoutWidth = size.width / 2
        authorLintNode.position = CGPoint(x: 0, y: 0)
        link(nodeA: authorLintNode, to: authorLintNodeTemplate!)
        addChild(authorLintNode)
        updateTimeLabelOnly()
    }

    func updateTimeLabelOnly() {
        if timeLintNodeTemplate == nil {
            timeLintNodeTemplate = {
                let timeLintNodeTemplate = SKLabelNode(fontNamed: "ChalkboardSE-Light")
                timeLintNodeTemplate.fontSize = 30
                timeLintNodeTemplate.fontColor = SKColor.white
                timeLintNodeTemplate.name = "timeLint"
                timeLintNodeTemplate.verticalAlignmentMode = .top
                timeLintNodeTemplate.horizontalAlignmentMode = .right
                return timeLintNodeTemplate
            }()
        } else {
            removeNodesLinked(to: timeLintNodeTemplate!)
        }

        let timeLintNode = timeLintNodeTemplate!.copy() as! SKLabelNode
        timeLintNode.text = "Time: \(NSString(format: "%.2f", data!.tickToSecond(data!.currentTimeTick)))/\(data!.chartLengthSecond)"
        timeLintNode.position = CGPoint(x: size.width, y: size.height)
        link(nodeA: timeLintNode, to: timeLintNodeTemplate!)
        addChild(timeLintNode)
    }

    func updateTimeDemoOnly() {
        if timeDemoNodeTemplate == nil {
            timeDemoNodeTemplate = {
                let timeDemoNodeTemplate = SKShapeNode(rectOf: CGSize(width: 40, height: size.height))
                timeDemoNodeTemplate.name = "timeDemo"
                timeDemoNodeTemplate.alpha = 0.2
                timeDemoNodeTemplate.fillColor = .blue
                return timeDemoNodeTemplate
            }()
        } else {
            removeNodesLinked(to: timeDemoNodeTemplate!)
        }

        let timeDemoNode = timeDemoNodeTemplate!.copy() as! SKShapeNode
        timeDemoNode.position = CGPoint(x: 0, y: (data!.tickToSecond(data!.currentTimeTick) / Double(data!.chartLengthSecond) - 0.5) * size.height)
        link(nodeA: timeDemoNode, to: timeDemoNodeTemplate!)
        addChild(timeDemoNode)
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
            let judgeLinePosY = (judgeLine.props.calculateValue(.controlY, data!.currentTimeTick) - 0.5) * size.width + 0.5 * size.height
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
                let noteDeltaX = (note.posX - 0.5) * size.width * cos(judgeLineAngle)
                let noteDeltaY = (note.posX - 0.5) * size.width * sin(judgeLineAngle)

                if note.noteType == .Hold {
                    let topColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.4)
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

    func clearAndMakeBackgroundImage() {
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

        let linkedNodes = nodeLinks.reduce(Set<SKNode>()) { res, pair -> Set<SKNode> in
            var res = res
            if pair.0 == timeDemoNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == timeDemoNodeTemplate {
                res.insert(pair.0)
            }
            return res
        }
        linkedNodes.forEach {
            $0.run(SKAction.move(by: CGVector(dx: 0, dy: size.height), duration: Double(data!.chartLengthSecond)), withKey: "moving")
        }
        for judgeLine in data!.listOfJudgeLines {
            let judgeLineNode = judgeLineNodeTemplate!.copy() as! SKShapeNode
            let judgeLinePosX = judgeLine.props.calculateValue(.controlX, data!.currentTimeTick) * size.width
            let judgeLinePosY = (judgeLine.props.calculateValue(.controlY, data!.currentTimeTick) - 0.5) * size.width + 0.5 * size.height
            let judgeLineAngle = judgeLine.props.calculateValue(.angle, data!.currentTimeTick) * 2.0 * .pi
            let judgeLineAlpha = judgeLine.props.calculateValue(.lineAlpha, data!.currentTimeTick)

            judgeLineNode.position = CGPoint(x: judgeLinePosX, y: judgeLinePosY)
            judgeLineNode.zRotation = judgeLineAngle
            judgeLineNode.alpha = judgeLineAlpha

            var movingActions: [SKAction] = []

            var shouldControlXUpdateTimeTick: [Double] = []
            var controlXUpdateAction: [SKAction] = []
            judgeLine.props.controlX = judgeLine.props.controlX.sorted { $0.timeTick < $1.timeTick }
            for index in 0 ..< (judgeLine.props.controlX.count - 1) {
                if judgeLine.props.controlX[index].followingEasing == .linear {
                    shouldControlXUpdateTimeTick.append(Double(judgeLine.props.controlX[index + 1].timeTick))
                    continue
                }
                for i in 0 ... updateFreq {
                    shouldControlXUpdateTimeTick.append(Double(judgeLine.props.controlX[index].timeTick) + Double(i / updateFreq) * Double(judgeLine.props.controlX[index + 1].timeTick - judgeLine.props.controlX[index].timeTick))
                }
            }
            shouldControlXUpdateTimeTick.append(data!.currentTimeTick)
            shouldControlXUpdateTimeTick = shouldControlXUpdateTimeTick.filterDuplicates { $0 }
            shouldControlXUpdateTimeTick.sort()
            shouldControlXUpdateTimeTick.removeAll(where: { $0 < data!.currentTimeTick })
            for index in 0 ..< (shouldControlXUpdateTimeTick.count - 1) {
                let judgeLinePosX = judgeLine.props.calculateValue(.controlX, shouldControlXUpdateTimeTick[index + 1]) * size.width
                let tmpAction = SKAction.moveTo(x: judgeLinePosX, duration: data!.tickToSecond(shouldControlXUpdateTimeTick[index + 1] - shouldControlXUpdateTimeTick[index]))
                controlXUpdateAction.append(tmpAction)
            }
            if controlXUpdateAction.count > 0 {
                movingActions.append(SKAction.sequence(controlXUpdateAction))
            }

            var shouldControlYUpdateTimeTick: [Double] = []
            var controlYUpdateAction: [SKAction] = []
            judgeLine.props.controlY = judgeLine.props.controlY.sorted { $0.timeTick < $1.timeTick }
            for index in 0 ..< (judgeLine.props.controlY.count - 1) {
                if judgeLine.props.controlY[index].followingEasing == .linear {
                    shouldControlYUpdateTimeTick.append(Double(judgeLine.props.controlY[index + 1].timeTick))
                    continue
                }
                for i in 0 ... updateFreq {
                    shouldControlYUpdateTimeTick.append(Double(judgeLine.props.controlY[index].timeTick) + Double(i / updateFreq) * Double(judgeLine.props.controlY[index + 1].timeTick - judgeLine.props.controlY[index].timeTick))
                }
            }
            shouldControlYUpdateTimeTick.append(data!.currentTimeTick)
            shouldControlYUpdateTimeTick = shouldControlYUpdateTimeTick.filterDuplicates { $0 }
            shouldControlYUpdateTimeTick.sort()
            shouldControlYUpdateTimeTick.removeAll(where: { $0 < data!.currentTimeTick })
            for index in 0 ..< (shouldControlYUpdateTimeTick.count - 1) {
                let judgeLinePosY = (judgeLine.props.calculateValue(.controlY, shouldControlYUpdateTimeTick[index + 1]) - 0.5) * size.width + 0.5 * size.height
                let tmpAction = SKAction.moveTo(y: judgeLinePosY, duration: data!.tickToSecond(shouldControlYUpdateTimeTick[index + 1] - shouldControlYUpdateTimeTick[index]))
                controlYUpdateAction.append(tmpAction)
            }
            if controlYUpdateAction.count > 0 {
                movingActions.append(SKAction.sequence(controlYUpdateAction))
            }

            var shouldAngleUpdateTimeTick: [Double] = []
            var angleUpdateAction: [SKAction] = []
            judgeLine.props.angle = judgeLine.props.angle.sorted { $0.timeTick < $1.timeTick }
            for index in 0 ..< (judgeLine.props.angle.count - 1) {
                if judgeLine.props.angle[index].followingEasing == .linear {
                    shouldAngleUpdateTimeTick.append(Double(judgeLine.props.angle[index + 1].timeTick))
                    continue
                }
                for i in 0 ... updateFreq {
                    shouldAngleUpdateTimeTick.append(Double(judgeLine.props.angle[index].timeTick) + Double(i / updateFreq) * Double(judgeLine.props.angle[index + 1].timeTick - judgeLine.props.angle[index].timeTick))
                }
            }
            shouldAngleUpdateTimeTick.append(data!.currentTimeTick)
            shouldAngleUpdateTimeTick = shouldAngleUpdateTimeTick.filterDuplicates { $0 }
            shouldAngleUpdateTimeTick.sort()
            shouldAngleUpdateTimeTick.removeAll(where: { $0 < data!.currentTimeTick })
            for index in 0 ..< (shouldAngleUpdateTimeTick.count - 1) {
                let judgeLineAngle = judgeLine.props.calculateValue(.angle, shouldAngleUpdateTimeTick[index + 1]) * 2.0 * .pi
                let tmpAction = SKAction.rotate(toAngle: judgeLineAngle, duration: data!.tickToSecond(shouldAngleUpdateTimeTick[index + 1] - shouldAngleUpdateTimeTick[index]))
                angleUpdateAction.append(tmpAction)
            }
            if angleUpdateAction.count > 0 {
                movingActions.append(SKAction.sequence(angleUpdateAction))
            }

            var shouldAlphaUpdateTimeTick: [Double] = []
            var alphaUpdateAction: [SKAction] = []
            judgeLine.props.lineAlpha = judgeLine.props.lineAlpha.sorted { $0.timeTick < $1.timeTick }
            for index in 0 ..< (judgeLine.props.lineAlpha.count - 1) {
                if judgeLine.props.lineAlpha[index].followingEasing == .linear {
                    shouldAlphaUpdateTimeTick.append(Double(judgeLine.props.lineAlpha[index + 1].timeTick))
                    continue
                }
                for i in 0 ... updateFreq {
                    shouldAlphaUpdateTimeTick.append(Double(judgeLine.props.lineAlpha[index].timeTick) + Double(i / updateFreq) * Double(judgeLine.props.lineAlpha[index + 1].timeTick - judgeLine.props.lineAlpha[index].timeTick))
                }
            }
            shouldAlphaUpdateTimeTick.append(data!.currentTimeTick)
            shouldAlphaUpdateTimeTick = shouldAlphaUpdateTimeTick.filterDuplicates { $0 }
            shouldAlphaUpdateTimeTick.sort()
            shouldAlphaUpdateTimeTick.removeAll(where: { $0 < data!.currentTimeTick })
            for index in 0 ..< (shouldAlphaUpdateTimeTick.count - 1) {
                let judgeLineAlpha = judgeLine.props.calculateValue(.lineAlpha, shouldAlphaUpdateTimeTick[index + 1])
                let tmpAction = SKAction.fadeAlpha(to: judgeLineAlpha, duration: data!.tickToSecond(shouldAlphaUpdateTimeTick[index + 1] - shouldAlphaUpdateTimeTick[index]))
                alphaUpdateAction.append(tmpAction)
            }
            if alphaUpdateAction.count > 0 {
                movingActions.append(SKAction.sequence(alphaUpdateAction))
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
                let noteDeltaX = (note.posX - 0.5) * size.width * cos(judgeLineAngle)
                let noteDeltaY = (note.posX - 0.5) * size.width * sin(judgeLineAngle)
                if note.noteType == .Hold {
                    let topColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
                    let bottomColor = CIColor(red: 22.0 / 255.0, green: 176.0 / 255.0, blue: 248.0 / 255.0, alpha: 0.4)
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
                        let judgeLinePosY = (judgeLine.props.calculateValue(.controlY, tmpTick) - 0.5) * size.width + 0.5 * size.height
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 0.5) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 0.5) * size.width * sin(judgeLineAngle)
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
                    noteNode.blendMode = .replace
                    noteNode.fillColor = noteColor(type: note.noteType)
                    var noteMoveAction: [SKAction] = []
                    var tmpTick = data!.currentTimeTick
                    while tmpTick <= Double(note.timeTick) {
                        let judgeLineAngle = judgeLine.props.calculateValue(.angle, tmpTick) * 2.0 * .pi
                        let judgeLinePosX = judgeLine.props.calculateValue(.controlX, tmpTick) * size.width
                        let judgeLinePosY = (judgeLine.props.calculateValue(.controlY, tmpTick) - 0.5) * size.width + 0.5 * size.height
                        let noteRelativePosition = judgeLine.props.calculateNoteDistance(tmpTick, Double(note.timeTick)) * _distance
                        let noteDeltaX = (note.posX - 0.5) * size.width * cos(judgeLineAngle)
                        let noteDeltaY = (note.posX - 0.5) * size.width * sin(judgeLineAngle)
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
            if pair.0 == timeDemoNodeTemplate {
                res.insert(pair.1)
            }
            if pair.1 == timeDemoNodeTemplate {
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
