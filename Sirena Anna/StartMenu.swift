//
//  StartMenu.swift
//  Sirena Anna
//
//  Created by Carol on 1/13/17.
//  Copyright © 2017 Katuri & Nana. All rights reserved.
//

import SpriteKit

class StartMenu: SKScene {
    
    var menuLabel:SKLabelNode!
    var PlayButton:SKSpriteNode!
    var backgroundImage = SKSpriteNode(imageNamed: "fonsiPhone6_clar")
    
    override func didMove(to view: SKView) {
        
        // Set background with image and bubbles
        backgroundImage.position.x = self.frame.size.width / 2
        backgroundImage.position.y = self.frame.size.height / 2
        backgroundImage.xScale = 0.5
        backgroundImage.yScale = 0.5
        self.addChild(backgroundImage)
        backgroundImage.zPosition = -1 // Always behind everything else
        
        // Add play button
        PlayButton = SKSpriteNode(imageNamed: "PlayButton")
        PlayButton.xScale = 0.55
        PlayButton.yScale = 0.55
        
        PlayButton.position.y = self.frame.size.height / 2
        PlayButton.position.x = self.frame.size.width / 2

        self.addChild(PlayButton)

    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nextScene = GameScene(fileNamed: "GameScene")
        self.scene!.view?.presentScene(nextScene)
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered, for now it does nothing
    }

}

