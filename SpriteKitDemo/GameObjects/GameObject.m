//
//  GameObject.m
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/10/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject {
    float _health;
}

- (instancetype) initWithPosition:(CGPoint)position {
    
    if(self = [super init]) {
        
        //All game play objects will instanciate with at lease these basic properties.
        _heading = CGPointZero;
        self.position = position;
        
        self.texture = [[self class] createTexture];
        self.size = self.texture.size;
    }
    
    return self;
}

- (void)setHealth:(float)health {
    if(health > self.maxHealth) {
        _health = self.maxHealth;
    } else {
        _health = health;
    }
}

//to be overridden
- (void)update:(CFTimeInterval)timeSpan {}
- (void)configureCollisionBody {}
- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact *)contact {}
+ (SKTexture *)createTexture {return nil;}
@end
