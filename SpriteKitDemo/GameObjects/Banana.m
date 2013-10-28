//
//  Banana.m
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/15/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "Banana.h"
#import "MyScene.h"

@implementation Banana {
    
    SKAction *_bananaSoundAction;
}

- (id)initWithPosition:(CGPoint)position {
    
    if(self = [super initWithPosition:position]) {
        
        self.name = @"banana";
        [self setScale:0.40f];
        [self configureCollisionBody];
        _bananaSoundAction = [SKAction playSoundFileNamed:@"Menu Choice.mp3" waitForCompletion:NO];
    }
    
    return self;
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
    /*
     When it collides with the monkey, the score will be increased and it will be removed from the scene.
     */
    if(contact.bodyA.categoryBitMask == CollisionTypeMonkey || contact.bodyB.categoryBitMask == CollisionTypeMonkey){
        
        [(MyScene *)self.scene increaseScoreBy:5];
        [self runAction:_bananaSoundAction completion:^(void) {
            [self removeAllActions];
            [self removeFromParent];
        }];
    }
}

- (void)configureCollisionBody {
    
    /*
     This banana will collide with the monkey, and will disappear.  This is accomplished by setting the contactTestBitMask to the monkey.  Physics do not need to be applied--set the collisionBitMask to 0.
     */
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = CollisionTypeBanana;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = CollisionTypeMonkey;
}

+ (SKTexture *)createTexture {
    
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        texture = [SKTexture textureWithImageNamed:@"banana"];
        texture.filteringMode = SKTextureFilteringNearest;
        
    });
    
    return texture;
    
}

@end
