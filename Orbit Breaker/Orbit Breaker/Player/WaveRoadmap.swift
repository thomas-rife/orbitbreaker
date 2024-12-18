//
//  WaveRoadmap.swift
//  Orbit Breaker
//
//  Created by August Wetterau on 11/30/24.
//
import SpriteKit

class WaveRoadmap {
    private weak var scene: SKScene?
    private var roadmapNodes: [SKNode] = []
    private var stageDots: [SKShapeNode] = []
    private var currentStageIndicator: SKShapeNode?
    private let stageCount = 6  // 5 stages + boss
    private var enemyManager: EnemyManager
    
    init(scene: SKScene, enemyManager: EnemyManager) {
        self.scene = scene
        self.enemyManager = enemyManager
        setupRoadmap()
    }
    
    private func setupRoadmap() {
        guard let scene = scene else { return }
        
        // Ensure thorough cleanup before setting up
        cleanup()
        
        let spacing: CGFloat = 50
        let dotRadius: CGFloat = 15
        let topMargin: CGFloat = 80
        let centerX: CGFloat = 45
        let startY = scene.size.height - topMargin - (CGFloat(stageCount - 1) * spacing)
        
        // Create connecting "space path" with enhanced visibility
        let path = CGMutablePath()
        path.move(to: CGPoint(x: centerX, y: startY))
        path.addLine(to: CGPoint(x: centerX, y: startY + CGFloat(stageCount - 1) * spacing))
        
        // Add glowing background to path
        let glowPath = SKShapeNode(path: path)
        glowPath.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 0.2)
        glowPath.lineWidth = 12
        glowPath.lineCap = .round
        glowPath.zPosition = 1
        
        let mainPath = SKShapeNode(path: path)
        mainPath.strokeColor = SKColor(red: 0.3, green: 0.4, blue: 0.8, alpha: 0.4)
        mainPath.lineWidth = 4
        mainPath.lineCap = .round
        mainPath.zPosition = 2
        
        scene.addChild(glowPath)
        scene.addChild(mainPath)
        roadmapNodes.append(glowPath)
        roadmapNodes.append(mainPath)
        
        // Add starfield effect
        let starsNode = SKNode()
        for _ in 0..<15 {
            let star = SKShapeNode(circleOfRadius: 1)
            star.fillColor = .white
            star.strokeColor = .white
            star.position = CGPoint(
                x: centerX + CGFloat.random(in: -15...15),
                y: startY + CGFloat.random(in: 0...spacing * CGFloat(stageCount - 1))
            )
            star.alpha = CGFloat.random(in: 0.3...0.8)
            starsNode.addChild(star)
            
            let twinkle = SKAction.sequence([
                SKAction.fadeOut(withDuration: CGFloat.random(in: 0.5...1.5)),
                SKAction.fadeIn(withDuration: CGFloat.random(in: 0.5...1.5))
            ])
            star.run(SKAction.repeatForever(twinkle))
        }
        scene.addChild(starsNode)
        roadmapNodes.append(starsNode)
        
        // Create stage indicators
        for i in 0..<stageCount {
            let y = startY + CGFloat(i) * spacing
            let stageContainer = SKNode()
            stageContainer.position = CGPoint(x: centerX, y: y)
            
            let stageMarker = createStageMarker(for: i, radius: dotRadius)
            stageContainer.addChild(stageMarker)
            stageDots.append(stageMarker)
            
            scene.addChild(stageContainer)
            roadmapNodes.append(stageContainer)
        }
        
        setupPlayerIndicator(startY: startY, centerX: centerX)
    }
    
    private func createStageMarker(for stage: Int, radius: CGFloat) -> SKShapeNode {
        let marker = SKShapeNode(circleOfRadius: radius)
        marker.lineWidth = 2
        marker.zPosition = 3
        
        if stage == stageCount - 1 {  // Boss stage
            switch enemyManager.bossNum {
            case 2: // Sadness
                marker.fillColor = SKColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.9)
                marker.strokeColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
            case 3: // Disgust
                marker.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.9)
                marker.strokeColor = SKColor(red: 0.3, green: 0.9, blue: 0.3, alpha: 1.0)
            case 4: // Love
                marker.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 0.9)
                marker.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.8, alpha: 1.0)
            default: // Anger (case 1)
                marker.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.9)
                marker.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
            }
            
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 1.0),
                SKAction.scale(to: 1.0, duration: 1.0)
            ])
            marker.run(SKAction.repeatForever(pulse))
        } else if stage == 2 {  // Asteroid field
            let asteroidPath = CGMutablePath()
            let points = 12
            var firstPoint = CGPoint.zero
            
            let radiusVariations: [CGFloat] = [1.0, 0.9, 1.1, 0.95, 1.05, 0.92, 1.08, 0.94, 1.06, 0.96, 1.04, 0.98]
            
            for i in 0..<points {
                let angle = CGFloat(i) * 2 * .pi / CGFloat(points)
                let asteroidRadius = radius * radiusVariations[i]
                let x = cos(angle) * asteroidRadius
                let y = sin(angle) * asteroidRadius
                
                if i == 0 {
                    firstPoint = CGPoint(x: x, y: y)
                    asteroidPath.move(to: firstPoint)
                } else {
                    asteroidPath.addLine(to: CGPoint(x: x, y: y))
                }
            }
            asteroidPath.addLine(to: firstPoint)
            
            marker.path = asteroidPath
            marker.fillColor = SKColor(red: 0.65, green: 0.63, blue: 0.62, alpha: 0.9)
            marker.strokeColor = SKColor(red: 0.75, green: 0.73, blue: 0.72, alpha: 1.0)
            
            let craterPositions: [(radius: CGFloat, x: CGFloat, y: CGFloat)] = [
                (0.25, 0.27, 0.3),
                (0.25, -0.33, 0.05),
                (0.25, 0.34, -0.3)
            ]
            
            for position in craterPositions {
                let crater = SKShapeNode(circleOfRadius: radius * position.radius)
                crater.position = CGPoint(x: radius * position.x, y: radius * position.y)
                crater.fillColor = SKColor(red: 0.55, green: 0.53, blue: 0.52, alpha: 0.7)
                crater.strokeColor = SKColor(red: 0.45, green: 0.43, blue: 0.42, alpha: 0.8)
                crater.name = "crater"  // Add name to identify craters
                marker.addChild(crater)
            }
        } else {  // Enemy waves
            marker.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8)
            marker.strokeColor = SKColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 1.0)
            
            // Create UFO shape
            let ufoBody = SKShapeNode(ellipseOf: CGSize(width: radius * 1.6, height: radius * 0.8))
            ufoBody.fillColor = SKColor(red: 0.5, green: 0.5, blue: 0.7, alpha: 0.6)
            ufoBody.strokeColor = SKColor(red: 0.6, green: 0.6, blue: 0.8, alpha: 0.8)
            
            // Add dome on top
            let dome = SKShapeNode(circleOfRadius: radius * 0.4)
            dome.position = CGPoint(x: 0, y: radius * 0.1)
            dome.fillColor = SKColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 0.6)
            dome.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.7, alpha: 0.8)
            
            ufoBody.addChild(dome)
            marker.addChild(ufoBody)
            
            // Add subtle hover animation
            let hover = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 2, duration: 1.0),
                SKAction.moveBy(x: 0, y: -2, duration: 1.0)
            ])
            ufoBody.run(SKAction.repeatForever(hover))
        }
        
        return marker
    }
    
    
    private func setupPlayerIndicator(startY: CGFloat, centerX: CGFloat) {
        // Create triangular ship shape
        let shipPath = CGMutablePath()
        shipPath.move(to: CGPoint(x: 0, y: 12))  // Top point
        shipPath.addLine(to: CGPoint(x: -8, y: -6))  // Bottom left
        shipPath.addLine(to: CGPoint(x: 8, y: -6))   // Bottom right
        shipPath.closeSubpath()
        
        let ship = SKShapeNode(path: shipPath)
        ship.fillColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.9)
        ship.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        ship.lineWidth = 2
        ship.zPosition = 10
        
        // Add engine glow
        let engineGlow = SKShapeNode(path: CGMutablePath())
        engineGlow.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 0.6)
        engineGlow.strokeColor = .clear
        engineGlow.position = CGPoint(x: 0, y: -8)
        
        let pulseAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.5),
            SKAction.fadeAlpha(to: 0.6, duration: 0.5)
        ])
        engineGlow.run(SKAction.repeatForever(pulseAction))
        
        ship.addChild(engineGlow)
        currentStageIndicator = ship
        currentStageIndicator?.position = CGPoint(x: centerX, y: startY)
        
        if let indicator = currentStageIndicator {
            scene?.addChild(indicator)
            roadmapNodes.append(indicator)
            
            // Add hover animation
            let hover = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 3, duration: 1.0),
                SKAction.moveBy(x: 0, y: -3, duration: 1.0)
            ])
            indicator.run(SKAction.repeatForever(hover))
        }
    }
    
    func updateCurrentWave(_ wave: Int) {
        guard let scene = scene else { return }
        
        // Ensure we don't create duplicate indicators during reset
        if wave == 0 {
            // Remove existing indicator before creating a new one
            currentStageIndicator?.removeAllActions()
            currentStageIndicator?.removeFromParent()
            currentStageIndicator = nil
            
            // Create new indicator at starting position
            let startY = scene.size.height - 80 - (CGFloat(stageCount - 1) * 50)
            setupPlayerIndicator(startY: startY, centerX: 45)
        }
        
        let spacing: CGFloat = 50
        let topMargin: CGFloat = 80
        let startY = scene.size.height - topMargin - (CGFloat(stageCount - 1) * spacing)
        let currentStage = wave == 0 ? 0 : (wave - 1) % stageCount
        let y = startY + CGFloat(currentStage) * spacing
        
        // Update completed stages
        for i in 0..<stageDots.count {
            if i < currentStage {
                // Set the main shape to green
                stageDots[i].fillColor = SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.8)
                stageDots[i].strokeColor = SKColor(red: 0.4, green: 0.9, blue: 0.4, alpha: 1.0)
                
                // If it's the asteroid stage, also update the craters
                if i == 2 {
                    stageDots[i].children.forEach { child in
                        if child.name == "crater" {
                            if let crater = child as? SKShapeNode {
                                crater.fillColor = SKColor(red: 0.3, green: 0.8, blue: 0.3, alpha: 0.7)
                                crater.strokeColor = SKColor(red: 0.4, green: 0.9, blue: 0.4, alpha: 0.8)
                            }
                        }
                    }
                }
            } else {
                // Reset stages after current stage to original colors
                if i == stageCount - 1 {  // Boss stage
                    updateBossStageColor(stageDots[i])
                } else if i == 2 {  // Asteroid stage
                    stageDots[i].fillColor = SKColor(red: 0.65, green: 0.63, blue: 0.62, alpha: 0.9)
                    stageDots[i].strokeColor = SKColor(red: 0.75, green: 0.73, blue: 0.72, alpha: 1.0)
                    // Reset crater colors
                    stageDots[i].children.forEach { child in
                        if child.name == "crater" {
                            if let crater = child as? SKShapeNode {
                                crater.fillColor = SKColor(red: 0.55, green: 0.53, blue: 0.52, alpha: 0.7)
                                crater.strokeColor = SKColor(red: 0.45, green: 0.43, blue: 0.42, alpha: 0.8)
                            }
                        }
                    }
                } else {  // Regular enemy stages
                    stageDots[i].fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8)
                    stageDots[i].strokeColor = SKColor(red: 0.4, green: 0.4, blue: 0.6, alpha: 1.0)
                }
            }
        }
        
        // Move player indicator
        if let indicator = currentStageIndicator {
            let moveAction = SKAction.move(to: CGPoint(x: 45, y: y), duration: 0.8)
            moveAction.timingMode = .easeInEaseOut
            indicator.run(moveAction)
        }
    }

    private func updateBossStageColor(_ marker: SKShapeNode) {
        switch enemyManager.bossNum {
        case 2: // Sadness
            marker.fillColor = SKColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.9)
            marker.strokeColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
        case 3: // Disgust
            marker.fillColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 0.9)
            marker.strokeColor = SKColor(red: 0.3, green: 0.9, blue: 0.3, alpha: 1.0)
        case 4: // Love
            marker.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 0.9)
            marker.strokeColor = SKColor(red: 1.0, green: 0.5, blue: 0.8, alpha: 1.0)
        default: // Anger (case 1)
            marker.fillColor = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.9)
            marker.strokeColor = SKColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
        }
    }
    
    func cleanup() {
        // First remove the current stage indicator and its actions
        currentStageIndicator?.removeAllActions()
        currentStageIndicator?.removeFromParent()
        currentStageIndicator = nil

        // Then clean up all roadmap nodes and their actions
        roadmapNodes.forEach {
            $0.removeAllActions()
            $0.removeFromParent()
        }
        roadmapNodes.removeAll()
        stageDots.removeAll()
    }

    
    func hideRoadmap() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        roadmapNodes.forEach { $0.run(fadeOut) }
    }
    
    func showRoadmap() {
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        roadmapNodes.forEach { $0.run(fadeIn) }
    }
}
