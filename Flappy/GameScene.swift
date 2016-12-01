//
//  GameScene.swift
//  Flappy
//
//  Created by fullmoon on 8/21/16.
//  Copyright (c) 2016 appfactory. All rights reserved.
//

import SpriteKit

struct physicsCategories{
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let scoreLine: UInt32 = 0x1 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Variables
    
    var ground = SKSpriteNode()
    var ghost = SKSpriteNode()
    var wallPair = SKNode()
    // var moveRemoveSeqAction = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartBtn = SKSpriteNode()
    
    
    
    // MARK: Scene methods and functions
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self
        
        gameStarted = false
        addScoreLbl()
        addGhost()
        addGround()
        addBackrnd()
        
    }// end didMoveToView
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        if !died{
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
        }
        else{
            
        }
        
        if !gameStarted{
            
            gameStarted = true
            
            ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                ()in
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnSequence = SKAction.sequence([spawn, delay])
            let spawn4ever = SKAction.repeatForever(spawnSequence)
            self.run(spawn4ever)
            
        }
        
        for touch in touches{
            let location = touch.location(in: self) // get the location of the touch
            if died{
                if restartBtn.contains(location){ // if the button contains the touch point
                    restartScene()
                }
            }
        }
        
    }
    
    
    
    func addGround(){
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: self.frame.width/2, y: 0 + ground.frame.height/2)
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = physicsCategories.ground
        ground.physicsBody?.collisionBitMask = physicsCategories.ghost
        ground.physicsBody?.contactTestBitMask = physicsCategories.ghost
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.zPosition = 5
        self.addChild(ground)
        
    }
    
    
    
    func addGhost(){
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: self.frame.width/2 - ghost.frame.width, y: self.frame.height/2)
        
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height/2)
        ghost.physicsBody?.categoryBitMask = physicsCategories.ghost
        ghost.physicsBody?.collisionBitMask = physicsCategories.ground | physicsCategories.wall
        ghost.physicsBody?.contactTestBitMask = physicsCategories.ground | physicsCategories.wall | physicsCategories.scoreLine
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.isDynamic = true
        ghost.zPosition = 4
        
        self.addChild(ghost)
    }
    
    
    
    func createWalls() {
        
        let scoreLine = SKSpriteNode()
        scoreLine.size = CGSize(width: 1, height: 200) // 350 + 350 (margins) = 700, 700 - 500(wall length) = 200
        scoreLine.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreLine.physicsBody = SKPhysicsBody(rectangleOf: scoreLine.size)
        scoreLine.physicsBody?.affectedByGravity = false
        scoreLine.physicsBody?.isDynamic = false
        scoreLine.physicsBody?.categoryBitMask = physicsCategories.scoreLine
        scoreLine.physicsBody?.collisionBitMask = 0
        scoreLine.physicsBody?.contactTestBitMask = physicsCategories.ghost
        // scoreLine.color = SKColor.cyanColor()
        
        wallPair = SKNode()
        wallPair.name = "WallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height/2 + 350)
        topWall.setScale(0.5)
        topWall.zRotation = CGFloat(M_PI)
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.frame.size)
        topWall.physicsBody?.categoryBitMask = physicsCategories.wall
        topWall.physicsBody?.collisionBitMask = physicsCategories.ghost
        topWall.physicsBody?.contactTestBitMask = physicsCategories.ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height/2 - 350)
        btmWall.setScale(0.5)
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = physicsCategories.wall
        btmWall.physicsBody?.collisionBitMask = physicsCategories.ghost
        btmWall.physicsBody?.contactTestBitMask = physicsCategories.ghost
        btmWall.physicsBody?.affectedByGravity = false
        btmWall.physicsBody?.isDynamic = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        wallPair.addChild(scoreLine)
        
        
        // in the very back of the scene, z axis is projected toward the viewer so that nodes with larger z values are closer to the viewer.
        wallPair.zPosition = 3
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        // Create action sequence
        let distance = CGFloat(self.frame.width + wallPair.frame.width)
        let moveAction = SKAction.moveBy(x: -distance - 50, y: 0, duration: TimeInterval(0.01 * distance))
        let removeAction = SKAction.removeFromParent()
        
        let moveRemoveActionSeq = SKAction.sequence([moveAction, removeAction])
        wallPair.run(moveRemoveActionSeq)
        
        self.addChild(wallPair)
        
    }
    
    
    
    func addScoreLbl(){
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height/2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 60
        scoreLbl.color = SKColor.cyan
        scoreLbl.zPosition = 2
        self.addChild(scoreLbl)
        
    }
    
    
    
    func createRestartBtn(){
        restartBtn = SKSpriteNode(imageNamed: "Restart")
        restartBtn.size = CGSize(width: 250, height: 125)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        restartBtn.run(SKAction.scale(to: 1.0, duration: 0.3))
        self.addChild(restartBtn)
        
    }
    
    
    func restartScene(){
        score = 0
        gameStarted = false
        died = false
        self.removeAllActions()
        self.removeAllChildren()
        addGround()
        addGhost()
        addScoreLbl()
        addBackrnd()
    }
    
    
    func addBackrnd(){
        for i in 0..<2 {
            let backrnd = SKSpriteNode(imageNamed: "Backrnd")
            backrnd.anchorPoint = CGPoint.zero
            backrnd.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            backrnd.name = "Backrnd"
            backrnd.size = (self.view?.bounds.size)!
            backrnd.zPosition = 1
            self.addChild(backrnd)
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted{
            if !died{
                enumerateChildNodes(withName: "Backrnd", using: ({
                    (node, error) in
                    
                    let backrnd = node as! SKSpriteNode
                    
                    backrnd.position = CGPoint(x: backrnd.position.x - 2, y: backrnd.position.y)
                    
                    if backrnd.position.x <= -backrnd.size.width{
                        backrnd.position = CGPoint(x: backrnd.position.x + backrnd.size.width * 2, y: backrnd.position.y)
                    }
                    
                }))
            }
        }
        
    }
    
    
    
    
    // MARK: SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == physicsCategories.ghost && bodyB.categoryBitMask == physicsCategories.scoreLine
            || bodyA.categoryBitMask == physicsCategories.scoreLine && bodyB.categoryBitMask == physicsCategories.ghost{
            
            score += 1
            scoreLbl.text = "\(score)"
        }
        
        if bodyA.categoryBitMask == physicsCategories.ghost && bodyB.categoryBitMask == physicsCategories.wall
            || bodyA.categoryBitMask == physicsCategories.wall && bodyB.categoryBitMask == physicsCategories.ghost{
            
            
            enumerateChildNodes(withName: "WallPair", using: ({
                (node, error) in
                node.speed = 0
                self.removeAllActions() }))
            
            if died == false{
                ghost.texture = SKTexture(imageNamed: "GhostDead")
                died = true
                createRestartBtn()
            }
            
            
            
        }// end if
        
        
        
        
        
    }// End didBeginContact
    
    
    
    
    
    
    
    
    
    
}
