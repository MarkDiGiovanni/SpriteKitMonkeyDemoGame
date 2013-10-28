//
//  Asteroids.m
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/12/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "Asteroid.h"

@implementation Asteroid

- (id)initWithPosition:(CGPoint)position {
    
    if(self = [super initWithPosition:position]) {
        
        //Name the asteroid and reduce it's size to 70%--it looks about right.
        self.name = @"asteroid";
        [self setScale:0.70f];
        [self configureCollisionBody];
    }
    
    return self;
}



- (void)configureCollisionBody {
    
    /*
     This asteroid will collide with the monkey, but will not move itself--it will push the monkey out of the way.  This is accomplished by setting the collisionBitMask to 0, but setting the contactTestBitMask to the monkey.
    */
    self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:45.0f];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = CollisionTypeAsteroid;
    self.physicsBody.collisionBitMask = 0;
    self.physicsBody.contactTestBitMask = CollisionTypeMonkey;
}

+ (SKTexture *)createTexture {
    
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        texture = [SKTexture textureWithImageNamed:@"asteroid_2"];
        texture.filteringMode = SKTextureFilteringNearest;
        
    });

    return texture;
    
}

@end
