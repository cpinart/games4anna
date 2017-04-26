//
//  GameScene.swift
//  Sirena Anna
//
//  Created by Carol on 1/10/17.
//  Copyright © 2017 Katuri & Nana. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import CoreGraphics

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Class viariables and constants
    var underSeaField:SKEmitterNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "ANNA: \(score)"
        }
    }
    var gameTimer:Timer!
    var possibleEnemies = ["crancEnfadat", "medusaEnfadada", "tauroEnfadat"]
    
    let enemyCategory:UInt32 = 0x1 << 1 // Unique ID for each category
    let photonTorpedoCategory:UInt32 = 0x1 << 0 // Unique ID for each category
    
    let motionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    var backgroundImage = SKSpriteNode(imageNamed: "fonsiPhone6_clar")

    
    override func didMove(to view: SKView) {
        
        // Set background with image and bubbles
        backgroundImage.position = CGPoint(x: 0, y: 0)
        backgroundImage.xScale = 0.5
        backgroundImage.yScale = 0.5
        self.addChild(backgroundImage)
        backgroundImage.zPosition = -1 // Always behind everything else
        underSeaField = SKEmitterNode(fileNamed: "UnderTheSea")
        underSeaField.position = CGPoint(x:0, y:1334) // 1334 for my iPhone 6
        underSeaField.advanceSimulationTime(10) // Skip 10 sec ahead to always have bubbles going
        self.addChild(underSeaField)
        //underSeaField.zPosition = -1
        
        // Set player
        player = SKSpriteNode(imageNamed: "sirenaAnna")
        player.xScale = 1.5
        player.yScale = 1.5
               
        // Center and add 20px vertical space. Note that default anchor point from SKS file is set to (0.5, 0.5)
        player.position.y = -self.frame.size.height / 2.0 + player.size.height/2.0 + 20.0
        self.addChild(player)
        player.zPosition = 1 // Always on top
        
        self.physicsWorld.gravity = CGVector (dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        // Score label
        scoreLabel = SKLabelNode(text: "ANNA: 0")
        scoreLabel.position.y = self.frame.size.height / 2.0 - 100.0 // set to top - 100px, x-centered
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 40
        scoreLabel.fontColor = UIColor.black
        score = 0
        self.addChild(scoreLabel)
        
        // Fire a new enemy every 1.5 seconds
        gameTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(addEnemy), userInfo: nil, repeats: true)
        
        // Add movement to player
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {
            (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        
    }
    
    func addEnemy(){
        possibleEnemies = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleEnemies) as! [String]
        
        let enemy = SKSpriteNode(imageNamed: possibleEnemies[0])
        let randomEnemyPosition = GKRandomDistribution(lowestValue: 0, highestValue: 750) // Along the x axis of iPhone 6 portrait
        let position = CGFloat (randomEnemyPosition.nextInt())
        
        // Size and starting position
        enemy.xScale = 1.5
        enemy.yScale = 1.5
        enemy.position.x = position - self.frame.size.width/2
        enemy.position.y = -self.frame.size.height/2 + self.frame.size.height + enemy.size.height
       
        
        // Physics body
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        
        // Calculate when we're hitting enemies with torpedos
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = photonTorpedoCategory
        enemy.physicsBody?.collisionBitMask = 0
        
        self.addChild(enemy)
        
        // Actions for each enemy
        let animationDuration:TimeInterval = 10
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: position - self.frame.size.width/2, y: -self.frame.size.height/2), duration: animationDuration)) // Run vertically to the bottom during the time interval
        actionArray.append(SKAction.removeFromParent())
        
        enemy.run(SKAction.sequence(actionArray))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
    func fireTorpedo(){
        
        self.run(SKAction.playSoundFileNamed("bombolla.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "bolaGroga")
        //torpedoNode.xScale = 1.5
        //torpedoNode.yScale = 1.5
        
        torpedoNode.position = player.position
        torpedoNode.position.y += 5 // Shift it a bit from the player
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        // Calculate when we're hitting enemies with torpedos
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = enemyCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        // Animate torpedo
        let animationDuration:TimeInterval = 0.3
        var actionArray = [SKAction]()
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.size.height/2 + 10), duration: animationDuration)) // Fire vertically to the top during the time interval
        actionArray.append(SKAction.removeFromParent())
        
       torpedoNode.run(SKAction.sequence(actionArray))
        
    }
    
    // Identify collisions and make enemies explode
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
            
        }
        else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & enemyCategory) != 0{
            torpedoDidCollideWithEnemy(torpedoNode: firstBody.node as! SKSpriteNode, enemyNode: secondBody.node as! SKSpriteNode)
        }
    }
    
    func torpedoDidCollideWithEnemy (torpedoNode:SKSpriteNode, enemyNode:SKSpriteNode){
        
        let explosion = SKEmitterNode(fileNamed: "MyParticle")!
        explosion.position = enemyNode.position
        self.addChild(explosion)
        
        self.run(SKAction.playSoundFileNamed("TomaLRvolUp.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        enemyNode.removeFromParent()
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
        
        score += 5
        
    }
    
    override func didSimulatePhysics(){
        player.position.x += xAcceleration * 50
        
        // Keep player within screen bounds
        if player.position.x < 20 - self.size.width / 2{
            player.position = CGPoint(x:  -self.size.width / 2 + 20, y: player.position.y)
        }
        else if player.position.x > self.size.width / 2 {
            player.position = CGPoint(x: self.size.width / 2 - 20, y: player.position.y)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
