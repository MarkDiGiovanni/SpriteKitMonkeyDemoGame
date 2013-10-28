//
//  Monkey.m
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/11/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "Monkey.h"
#import "MyScene.h"

@implementation Monkey {
    
    SKAction *_monkeyFlyAnimation;
    SKAction *_monkeyDeathAnimation;
    SKAction *_deathSoundAction;
    SKAction *_hitSoundAction;
    
}

- (instancetype)initWithPosition:(CGPoint)position {
    if(self = [super initWithPosition:position]) {
        self.name = @"monkeySprite";
        self.heartCount = 4;
        self.heartHealthValue = 20;
        self.maxHealth = _heartCount * _heartHealthValue;
        self.health = self.maxHealth;
        [self setScale:0.5];
        
        [self configureSounds];
        [self configureEmitters];
        [self configureMonkeyAnimations];
        [self configureCollisionBody];
        
        
    }
    
    return self;
}

- (void)update:(CFTimeInterval)timeSpan {
    
    //Make sure the trails move when the monkey moves...this gives them some flow
    __block MyScene *scene = (MyScene *)self.scene;
    [self enumerateChildNodesWithName:@"spaceDustTrails" usingBlock:^(SKNode *node, BOOL *stop) {
    
        SKEmitterNode *emitter = (SKEmitterNode *)node;
        if(!emitter.targetNode) {
            emitter.targetNode = [scene layerBackgroundNode];
        }
        
    }];
    
}

- (void)toggleEmitter:(BOOL)pause {
    
    [self enumerateChildNodesWithName:@"spaceDustTrails" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKEmitterNode *emitter = (SKEmitterNode *)node;
        emitter.paused = pause;
    }];
}

- (void)startFlyAnimation {
    
    [self removeActionForKey:@"monkeyDeathSound"];
    [self removeActionForKey:@"monkeyDeath"];
    [self toggleEmitter:NO];
    if (![self actionForKey:@"flyAnimation"]) {
        [self runAction:[SKAction repeatActionForever:_monkeyFlyAnimation] withKey:@"flyAnimation"];
    }
}

- (void)stopFlyAnimation {
    
    [self removeActionForKey:@"flyAnimation"];
    [self toggleEmitter:YES];
}

- (void)startDeathAnimation {
    
    [self runAction:_deathSoundAction withKey:@"monkeyDeathSound"];
    [self stopFlyAnimation];
    [self runAction: _monkeyDeathAnimation withKey:@"monkeyDeath"];
}

- (void)collidedWith:(SKPhysicsBody *)body contact:(SKPhysicsContact*)contact
{
    /*
     Reduce the monkey's health upon contact
     */
    if(contact.bodyA.categoryBitMask == CollisionTypeAsteroid || contact.bodyB.categoryBitMask == CollisionTypeAsteroid){
        
        [self runAction:_hitSoundAction];
        self.health -= 10;
        if(self.health < 0) self.health = 0;
    }
}

- (void)configureSounds {
    _deathSoundAction = [SKAction playSoundFileNamed:@"ghost.wav" waitForCompletion:NO];
    _hitSoundAction = [SKAction playSoundFileNamed:@"Error or failed.mp3" waitForCompletion:NO];
}

- (void)configureCollisionBody {
    
    /*
     This asteroid will collide with the monkey, and the monkey will react by moving according to the appied physics--the default reaction.  This is accomplished by setting the collisionBitMask to CollisionTypeAsteroid, but setting the contactTestBitMask to the CollisionTypeAsteroid.
     */
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.frame.size];
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = CollisionTypeMonkey;
    self.physicsBody.collisionBitMask = CollisionTypeAsteroid;
    self.physicsBody.contactTestBitMask = CollisionTypeAsteroid;
}

- (void)configureEmitters {
    
    //Use the same .sks file for both left and right trails
    SKEmitterNode *bodyEmitterLeft = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MonkeySpaceDustTrails" ofType:@"sks"]];
    
    SKEmitterNode *bodyEmitterRight = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MonkeySpaceDustTrails" ofType:@"sks"]];
    
    bodyEmitterLeft.position = CGPointMake(-40, 10);
    bodyEmitterLeft.name = @"spaceDustTrails";
    bodyEmitterLeft.zPosition = 0;
    [self addChild:bodyEmitterLeft];
    
    bodyEmitterRight.position = CGPointMake(40, 10);
    bodyEmitterRight.name = @"spaceDustTrails";
    bodyEmitterRight.xAcceleration = 65;
    bodyEmitterRight.zPosition = 0;
    [self addChild:bodyEmitterRight];

    
}

- (void)configureMonkeyAnimations {
    
    //Get the monkey's atlas
    SKTextureAtlas *monkeyAtlas = [SKTextureAtlas atlasNamed:@"spacemonkey"];
    
    //Set the fly textures
    NSArray *flyTextures = @[[monkeyAtlas textureNamed:@"spacemonkey_fly_01"],
                             [monkeyAtlas textureNamed:@"spacemonkey_fly_02"]];
    
    //Set the death textures
    NSArray *deathTextures = @[[monkeyAtlas textureNamed:@"spacemonkey_dead_01"],
                             [monkeyAtlas textureNamed:@"spacemonkey_dead_02"]];
    
    _monkeyFlyAnimation = [SKAction animateWithTextures:flyTextures timePerFrame:0.1];
    _monkeyDeathAnimation = [SKAction animateWithTextures:deathTextures timePerFrame:0.1];
}

+ (SKTexture *)createTexture {
    
    //Create the initial monkey texture.  It will be animated upon flying or dying.
    static SKTexture *texture = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        SKTextureAtlas *monkeyAtlas = [SKTextureAtlas atlasNamed:@"spacemonkey"];
        texture = [monkeyAtlas textureNamed:@"spacemonkey_fly_01"];
        texture.filteringMode = SKTextureFilteringNearest;
        
    });
    
    return texture;
}

@end
