//
//  GameScene.swift
//  MegaRun
//
//  Created by Kyle Tsuyemura on 7/15/16.
//  Copyright (c) 2016 Kyle Tsuyemura. All rights reserved.
//

import SpriteKit
import CoreMotion
import AVFoundation

struct Physics{
    static let player : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let leftwall : UInt32 = 0x1 << 4
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    var deathSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "mp3")!)
    var bgMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    var backgroundPlayer = AVAudioPlayer()
    let manager = CMMotionManager()
    var player = SKSpriteNode()
    var Ground = SKSpriteNode()
    var topWall = SKSpriteNode()
    var btmWall = SKSpriteNode()
    var volBtn = SKSpriteNode()
    var wallPair = SKNode()
    var leftwall = SKSpriteNode()
    var rightwall = SKSpriteNode()
    var startbutton = SKNode()
    var restartbutton = SKNode()
    var moveAndRemove = SKAction()
    var playing = false
    var destX: CGFloat  = 0.0
    var dextY: CGFloat = 0.0
    var start = false
    var dead = false
    
    func createWorld() {
        volBtn = SKSpriteNode(imageNamed: "volume")
        volBtn.size = CGSize(width: 50, height: 50)
        volBtn.position = CGPoint(x: self.frame.width - 100, y: self.frame.height - 170)
        volBtn.zPosition = 12
        self.addChild(volBtn)
//        do {
            //            audioPlayer = try AVAudioPlayer(contentsOfURL: jumpSound)
            //            audioPlayer.volume = 0.1
            //            audioPlayer.prepareToPlay()
            //        }
            //        catch let error {
            //            // handle error
            //        }
            //        audioPlayer.prepareToPlay()
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL: deathSound)
            audioPlayer.prepareToPlay()
        }
        catch let error {
            // handle error
        }
   

        self.physicsWorld.contactDelegate = self
        
        /* Setup your scene here */
        
        
        leftwall = SKSpriteNode(imageNamed:"Wall")
        leftwall.size = CGSize(width: 100, height: self.frame.height)
        leftwall.position = CGPoint(x: leftwall.frame.width/6, y: leftwall.frame.height/2)
        leftwall.physicsBody = SKPhysicsBody(rectangleOfSize: leftwall.size)
        leftwall.physicsBody?.categoryBitMask = Physics.leftwall
        leftwall.physicsBody?.collisionBitMask = Physics.player
        leftwall.physicsBody?.contactTestBitMask = Physics.player
        leftwall.physicsBody?.dynamic = false
        leftwall.physicsBody?.affectedByGravity = false
        let burstPath = NSBundle.mainBundle().pathForResource(
            "fire", ofType: "sks")
        
        if burstPath != nil {
            let burstNode =
                NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
                    as! SKEmitterNode
            burstNode.position = CGPointMake(leftwall.position.x, 50)
            burstNode.zPosition = 7
            self.addChild(burstNode)
            
        }

        self.addChild(leftwall)
        rightwall = SKSpriteNode(imageNamed:"Wall")
        rightwall.size = CGSize(width: 100, height: self.frame.height)
        rightwall.position = CGPoint(x: self.frame.width, y: rightwall.frame.height/2)
        rightwall.physicsBody = SKPhysicsBody(rectangleOfSize: rightwall.size)
        rightwall.physicsBody?.categoryBitMask = Physics.leftwall
        rightwall.physicsBody?.collisionBitMask = Physics.player
        rightwall.physicsBody?.contactTestBitMask = Physics.player
        rightwall.physicsBody?.dynamic = false
        rightwall.physicsBody?.affectedByGravity = false
        self.addChild(rightwall)
        let burstPath2 = NSBundle.mainBundle().pathForResource(
            "fire", ofType: "sks")
        
        if burstPath2 != nil {
            let burstNode2 =
                NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath2!)
                    as! SKEmitterNode
            burstNode2.position = CGPointMake(rightwall.position.x, 50)
            burstNode2.zPosition = 7
            self.addChild(burstNode2)
            
        }


        
        Ground = SKSpriteNode(imageNamed:"Ground")
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height)
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = Physics.Ground
        Ground.physicsBody?.collisionBitMask = Physics.player
        Ground.physicsBody?.contactTestBitMask = Physics.player
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        Ground.zPosition = 3
        self.addChild(Ground)
        
        player = SKSpriteNode(imageNamed: "MegaChoi")
        player.position = CGPoint(x: size.width * 0.4, y: size.width * 0.3)
        player.setScale(0.5)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.frame.height / 2)
        player.physicsBody?.categoryBitMask = Physics.player
        player.physicsBody?.collisionBitMask = Physics.Ground | Physics.Wall | Physics.leftwall
        player.physicsBody?.contactTestBitMask = Physics.Ground | Physics.Wall | Physics.leftwall
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.dynamic = true
        
        self.addChild(player)
        
    }
    
    func startGame(){
        
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.02
        manager.startAccelerometerUpdatesToQueue(NSOperationQueue()){
            (data, error) in
            if self.start == true {
                self.physicsWorld.gravity = CGVectorMake(CGFloat((data?.acceleration.y)!) * 10,
                                                         -9.81)
            }
            
        }
        if manager.deviceMotionAvailable {
            manager.deviceMotionUpdateInterval = 0.02
            manager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:{
                data, error in
                if self.start == true {
                    if data?.userAcceleration.z < -1.8 {
                        self.player.physicsBody?.velocity = CGVectorMake(0,0)
                        self.player.physicsBody?.applyImpulse(CGVectorMake(0, 500))
                    }
                }
                
            })
        }
        
        if self.start == true{
            let spawn = SKAction.runBlock({
                () in
                self.createWalls()
                
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let SpawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(SpawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 40, y:0, duration: NSTimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
        }

    }
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        start = true
        createWorld()
        startGame()
    }

    
    override func didMoveToView(view: SKView) {
        createWorld()
        startbutton = SKNode()
        let startbackground = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: 200, height:100))
        startbackground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        startbackground.zPosition = 6
        startbutton.addChild(startbackground)
        
        let startLabel = SKLabelNode()
        startLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 20)
        startLabel.text = "Start"
        startLabel.fontSize = 40
        startLabel.zPosition = 7
        startbutton.addChild(startLabel)
        self.addChild(startbutton)

    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        if firstBody.categoryBitMask == Physics.player && secondBody.categoryBitMask == Physics.leftwall || secondBody.categoryBitMask == Physics.player && firstBody.categoryBitMask == Physics.leftwall{
            dead = true
            audioPlayer.play()
            let burstPath = NSBundle.mainBundle().pathForResource(
                "smoke", ofType: "sks")
            
            if burstPath != nil {
                let burstNode =
                    NSKeyedUnarchiver.unarchiveObjectWithFile(burstPath!)
                        as! SKEmitterNode
                burstNode.position = CGPointMake(player.position.x, player.position.y)
                burstNode.zPosition = 7
                self.addChild(burstNode)
                
            }
            self.player.removeFromParent()
            restartbutton = SKNode()
            let startbackground = SKSpriteNode(color: SKColor.blackColor(), size: CGSize(width: 200, height:100))
            startbackground.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            startbackground.zPosition = 6
            restartbutton.addChild(startbackground)
            
            let startLabel = SKLabelNode()
            startLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 20)
            startLabel.text = "Restart"
            startLabel.fontSize = 40
            startLabel.zPosition = 7
            restartbutton.addChild(startLabel)
            self.addChild(restartbutton)


        }
        
        
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            for touch in touches {
            let location = touch.locationInNode(self)
            
            if start == false{
                if startbutton.containsPoint(location){
                    start = true
                    playing = true
                    self.startbutton.removeFromParent()
                    do{
                        backgroundPlayer = try AVAudioPlayer(contentsOfURL: bgMusic)
                        backgroundPlayer.volume = 0.8
                        backgroundPlayer.numberOfLoops = -1
                        backgroundPlayer.prepareToPlay()
                        backgroundPlayer.play()
                    }
                    catch let error {
                        // handle error
                    }
                    startGame()
                }
            }
            else{
                if restartbutton.containsPoint(location){
                    dead = false
                    start = false
                    self.restartbutton.removeFromParent()
                    restartScene()
                    
                }
                else if volBtn.containsPoint(location){
                    if playing == true{
                        volBtn.texture = SKTexture(imageNamed:"Mute")
                        backgroundPlayer.stop()
                        playing = false
                    }
                    else{
                        volBtn.texture = SKTexture(imageNamed:"volume")
                        backgroundPlayer.play()
                        playing = true
                    }
                }
            }
        }
    }

   
    override func update(currentTime: CFTimeInterval) {
        
    }
    func createWalls(){
        
//        let scoreNode = SKSpriteNode()
//        
//        scoreNode.size = CGSize(width:1, height: 200)
//        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
//        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
//        scoreNode.physicsBody?.affectedByGravity = false
//        scoreNode.physicsBody?.dynamic = false
//        scoreNode.physicsBody?.categoryBitMask = Physics.Score
//        scoreNode.physicsBody?.collisionBitMask = 0
//        scoreNode.physicsBody?.contactTestBitMask = Physics.Ghost
        
//        wallPair = SKNode()
        
        
        wallPair = SKNode()
        
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 380)
        btmWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 400)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = Physics.Wall
        topWall.physicsBody?.collisionBitMask = Physics.player
        topWall.physicsBody?.contactTestBitMask = Physics.player
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = Physics.Wall
        btmWall.physicsBody?.collisionBitMask = Physics.player
        btmWall.physicsBody?.contactTestBitMask = Physics.player
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -50, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }

}

