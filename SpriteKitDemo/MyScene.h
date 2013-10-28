//
//  MyScene.h
//  SpriteKitDemo
//

//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

/**
This is the root node of the this demo game.  It will display the game content on the SKView.
 */
@interface MyScene : SKScene <SKPhysicsContactDelegate>

/**
 The layerBackgroundNode node is where the parallax background will be configured.
 */
@property (nonatomic, strong) SKNode *layerBackgroundNode;
/**
 The layerHudNode is positioned at the top of the screen and contains the score and the health of the player.
 */
@property (nonatomic, strong) SKNode *layerHudNode;
/**
 the layerPlayerNode is the node that the monkey is a member of
 */
@property (nonatomic, strong) SKNode *layerPlayerNode;
/**
 The layerGamePlayNode contains the bananas, hearts, and asteroids
 */
@property (nonatomic, strong) SKNode *layerGamePlayNode;

/**
 Increases the score by the amount specified. The HUD layer will be updated to reflect the change.
 */
- (void)increaseScoreBy:(float)amount;
/**
 Increases the health of the monkey by the amount specified when the monkey collides with a heart.
 */
- (void)increaseHealthBy:(float)amount;

@end
