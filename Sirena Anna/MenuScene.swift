//
//  MenuScene.swift
//  Sirena Anna
//
//  Created by Carol on 1/13/17.
//  Copyright © 2017 Katuri & Nana. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var playButton = SKSpriteNode()
    let playButtonTex = SKTexture(imageNamed: "play")
    
    override func didMoveToView(view: SKView) {
        
        playButton = SKSpriteNode(texture: playButtonTex)
        playButton.position = CGPointMake(frame.MidX, frame.midY)
        self.addChild(playButton)
        
        
        override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
            
            
            if let touch = touches.first as? UITouch {
                let pos = touch.locationInNode(self)
                let node = self.nodeAtPoint(pos)
                
                if node == playButton {
                    if let view = view {
                        let scene = GameScene.unarchiveFromFile("GameScene") as! GameScene
                        scene.scaleMode = SKSceneScaleMode.AspectFill
                        view.presentScene(scene)   
                    }   
                }   
            }       
}
