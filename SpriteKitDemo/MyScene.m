//
//  MyScene.m
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/9/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "MyScene.h"
#import "Monkey.h"
#import "Asteroid.h"
#import "Banana.h"
#import "PowerUpHeart.h"
#import <GLKit/GLKit.h>

@import AVFoundation;

#define ARC4RANDOM_MAX 0x100000000

@implementation MyScene {
    SKNode *_spaceDustLayer; //this moves like a tread on a tank

    //used to mange the time for the background, monkey movement, etc.
    NSTimeInterval _timeInterval;
    NSTimeInterval _timeLastUpdated;
    
    //used to play the background music
    AVAudioPlayer *_musicPlayer;
    
    //HUD elements
    SKTexture *_heartFullTexture;
    SKTexture *_heartEmptyTexture;
    SKLabelNode *_scoreNode;
    SKLabelNode *_gameOverNode;
    float _score;
    
    
    //Game Objects
    Monkey *_monkey;
    CGPoint _movementDelta;
    
    Asteroid *_asteroid;
    Banana *_banana;
    PowerUpHeart *_powerUpHeart;
    

    //Reusable actions Actions
    SKAction *_scoreChangeAction;
    SKAction *_lowHealthWarningAction;
    
    BOOL _gameRunning;
    
}

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //there is no gravity in space...
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        //Setup the different layers of space
        [self setupSpaceSceneLayers];
        [self setupGameObjects];
        [self setupHUD];
        [self playMusic:@"bgMusic.mp3"];
        _gameRunning = YES;
    }
    return self;
}

- (void)setupGameObjects {
    
    
    //Setup the damage layer for aliens and asteroids
    _layerGamePlayNode = [SKNode new];
    [self addChild:_layerGamePlayNode];
    
    //Setup the asteroids...these cause damage to the monkey!
    SKAction *spawnAsteroidAction = [SKAction performSelector:@selector(spawnAsteroid) onTarget:self];
    SKAction *waitAction1 = [SKAction waitForDuration:5 withRange:10];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[spawnAsteroidAction, waitAction1]]]];
    
    //Setup the bananas.  These add points to the total score
    SKAction *spawnBananaAction = [SKAction performSelector:@selector(spawnBanana) onTarget:self];
    SKAction *waitAction2 = [SKAction waitForDuration:.5 withRange:3];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[spawnBananaAction, waitAction2]]]];
    
    //Setup hearts.  These restore health to the monkey
    SKAction *spawnHealthUpHeartAction = [SKAction performSelector:@selector(spawnHealthUpHeart) onTarget:self];
    SKAction *waitAction3 = [SKAction waitForDuration:25 withRange:30];
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[spawnHealthUpHeartAction, waitAction3]]]];
    
    //Setup the monkey
    _layerPlayerNode = [SKNode new];
    _monkey = [[Monkey alloc] initWithPosition:CGPointMake((self.size.width / 2), 120)];
    [_layerPlayerNode addChild:_monkey];
    [_monkey startFlyAnimation];
    
    [self addChild:_layerPlayerNode];
}

- (void)spawnHealthUpHeart {
    
    float diffX = self.frame.size.width - 80;
    float diffY = self.frame.size.height - 80;
    CGFloat xPosition = floorf(((double)arc4random() / ARC4RANDOM_MAX) * diffX + 80);
    CGFloat yPosition = floorf(((double)arc4random() / ARC4RANDOM_MAX) * diffY + 80);
    
    _powerUpHeart = [[PowerUpHeart alloc] initWithPosition:CGPointMake(xPosition, yPosition)
                                           withHeartHealth:_monkey.heartHealthValue];
    [_powerUpHeart setColor:[SKColor redColor]];
    _powerUpHeart.colorBlendFactor = 1.0f;
    _powerUpHeart.zRotation = -M_PI / 16;
    [_powerUpHeart setScale:0];
    [_layerGamePlayNode addChild:_powerUpHeart];
    
    SKAction *scalePopIn = [SKAction scaleTo:1.3 duration:.5];
    SKAction *rotateRight = [SKAction rotateByAngle:M_PI_4 duration:.5];
    SKAction *rotateLeft = [rotateRight reversedAction];
    SKAction *powerUpSequence = [SKAction sequence:@[scalePopIn,
                                                     [SKAction sequence:@[rotateRight, rotateLeft]]]];
    
    [_powerUpHeart runAction:[SKAction repeatActionForever:powerUpSequence]];
}

- (void)spawnBanana {

    float diffX = self.frame.size.width - 100;
    float diffY = self.frame.size.height - 100;
    CGFloat xPosition = floorf(((double)arc4random() / ARC4RANDOM_MAX) * diffX + 100);
    CGFloat yPosition = floorf(((double)arc4random() / ARC4RANDOM_MAX) * diffY + 100);
    
    _banana = [[Banana alloc] initWithPosition:CGPointMake(xPosition, yPosition)];
    [_banana setScale:0];
    [_layerGamePlayNode addChild:_banana];
    
    SKAction *scalePopIn = [SKAction scaleTo:1.1 duration:.5];
    SKAction *scaleDown = [SKAction scaleTo:0.5 duration:.5];
    SKAction *scaleUpToNormal = [SKAction scaleTo:0.7 duration:.5];
    SKAction *waitAction = [SKAction waitForDuration:3];
    SKAction *scaleOut = [SKAction scaleTo:0.0 duration:.5];
    SKAction *removeBanana = [SKAction removeFromParent];
    SKAction *bananaSequence = [SKAction sequence:@[scalePopIn, scaleDown, scaleUpToNormal, waitAction, scaleOut, removeBanana]];
    
    [_banana runAction:bananaSequence];

}

- (void)spawnAsteroid {
    //create / load at a random x location, and a bit beyond the top y position
    float diff = self.frame.size.width - 30;
    CGFloat xPosition = floorf(((double)arc4random() / ARC4RANDOM_MAX) * diff + 30);
    _asteroid = [[Asteroid alloc] initWithPosition:CGPointMake(xPosition, self.frame.size.height + 150)];
    [_layerGamePlayNode addChild:_asteroid];
    
    //Move the asteroid down the screen and rotate it...these will be grouped
    SKAction *moveAction = [SKAction moveToY:-100 duration:8];
    SKAction *rotateAction = [SKAction rotateByAngle:M_PI_4 / 4 duration:0.5];
    SKAction *moveGroup = [SKAction group:@[moveAction, [SKAction repeatAction:rotateAction count:40]]];
    
    SKAction *removeAsteroid = [SKAction removeFromParent];
    SKAction *asteroidSequence = [SKAction sequence:@[moveGroup, removeAsteroid]];
    
    [_asteroid runAction:asteroidSequence];
}

- (void)setupHUD {
    
    //Add HUD
    _layerHudNode = [SKNode new];
    
    //setup HUD basics
    int hudHeight = 40;
    CGSize bgSize = CGSizeMake(self.size.width, hudHeight);
    SKColor *bgColor = [SKColor colorWithRed:0.5 green:0.5 blue:0.75 alpha:0.70];
    SKSpriteNode *hudBackground = [SKSpriteNode spriteNodeWithColor:bgColor size:bgSize];
    
    hudBackground.position = CGPointMake(0, self.size.height - hudHeight);
    hudBackground.anchorPoint = CGPointZero;
    [_layerHudNode addChild:hudBackground];
    
    //Position the life hearts
    _heartFullTexture = [SKTexture textureWithImageNamed:@"heart"];
    _heartEmptyTexture = [SKTexture textureWithImageNamed:@"heart_empty"];
    int offset = 0;
    for(int i = 1; i <= _monkey.heartCount; i++) {
        SKSpriteNode *heart = [SKSpriteNode spriteNodeWithTexture:_heartFullTexture];
        heart.name = [NSString stringWithFormat:@"health%d", i];
        [heart setScale:0.70];
        [heart setColor:[SKColor redColor]];
        heart.colorBlendFactor = 1.0f;
        heart.position = CGPointMake(self.size.width - (heart.frame.size.width -6 + offset),
                                     self.size.height - heart.frame.size.height + 2);
            
        [_layerHudNode addChild:heart];
        offset += 23;

    }
    
    //Low health warning
    _lowHealthWarningAction = [SKAction sequence:@[[SKAction scaleTo:1.2 duration:.5], [SKAction scaleTo:0.8 duration:.5]]];

    
    _scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _scoreNode.fontSize = 18.0;
    _scoreNode.text = @"Score:0";
    _scoreNode.name = @"scoreNode";
    _scoreNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _scoreNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    
    _scoreNode.position = CGPointMake(6, self.size.height - _scoreNode.frame.size.height -2);
    
    [_layerHudNode addChild:_scoreNode];
    
    //shrink a bit as if the points were dropping in, then spring up with a bounce and settle at 1.0.
    _scoreChangeAction = [SKAction sequence:
                          @[[SKAction scaleXTo:.9 duration:0.1],
                            [SKAction scaleXTo:1.1 duration:0.1],
                            [SKAction scaleXTo:1.0 duration:0.1]]];
    
    [self addChild:_layerHudNode];
    
    //Game over node
    _gameOverNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _gameOverNode.fontSize = 20.0;
    _gameOverNode.text = @"Game Over - Tap to restart";
    _gameOverNode.name = @"gameOverNode";
    _gameOverNode.fontColor = [SKColor redColor];
    _gameOverNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _gameOverNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _gameOverNode.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
}

- (void)setupSpaceSceneLayers {
    
    _layerBackgroundNode = [SKNode new];
    _layerBackgroundNode.name = @"spaceBackgroundNode";
    
    //The last layer added will be on top...add the smallest (furthest away) stars first
    NSString *largeStar = @"star_1_large.png";
    NSString *smallStar = @"star_2_small.png";
    
    //small star layer 1--furthest away
    SKEmitterNode *layer1 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/5) speed:-8 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:NO];
    
    SKEmitterNode *layer2 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.2 lifetime:(self.frame.size.height/5) speed:-10 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    
    SKEmitterNode *layer3 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.6 lifetime:(self.frame.size.height/8) speed:-12 color:[SKColor darkGrayColor] textureName:smallStar enableStarLight:YES];

    //small star layer 4--closest
    SKEmitterNode *layer4 = [self spaceStarEmitterNodeWithBirthRate:1 scale:0.4 lifetime:(self.frame.size.height/10) speed:-14 color:[SKColor darkGrayColor] textureName:largeStar enableStarLight:YES];
    
    [_layerBackgroundNode addChild:layer1];
    [_layerBackgroundNode addChild:layer2];
    [_layerBackgroundNode addChild:layer3];
    [_layerBackgroundNode addChild:layer4];
    
    //Add space dust
    _spaceDustLayer = [SKNode node];
    
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *spaceDust =
        [SKSpriteNode spriteNodeWithImageNamed:@"bg_iphone_parallax_spacedust"];
        spaceDust.anchorPoint = CGPointZero;
        spaceDust.position = CGPointMake(0, i * spaceDust.size.height);
        spaceDust.name = @"bgSpaceDust";
        [_spaceDustLayer addChild:spaceDust];
    }
    
    
    [_layerBackgroundNode addChild:_spaceDustLayer];
    [self addChild:_layerBackgroundNode];

}

- (SKEmitterNode *)spaceStarEmitterNodeWithBirthRate:(float)birthRate
                                                scale:(float)scale
                                             lifetime:(float)lifetime
                                                speed:(float)speed
                                                color:(SKColor *)color
                                          textureName:(NSString *)textureName
                                      enableStarLight:(BOOL)enableStarLight
{
    SKTexture *starTexture = [SKTexture textureWithImageNamed:textureName];
    starTexture.filteringMode = SKTextureFilteringNearest;
    
    SKEmitterNode *emitterNode = [SKEmitterNode new];
    emitterNode.particleTexture = starTexture;
    emitterNode.particleBirthRate = birthRate;
    emitterNode.particleScale = scale;
    emitterNode.particleLifetime = lifetime;
    emitterNode.particleSpeed = speed;
    emitterNode.particleSpeedRange = 10;
    emitterNode.particleColor = color;
    
    emitterNode.particleColorBlendFactor = 1;
    emitterNode.position = CGPointMake((CGRectGetMidX(self.frame)), CGRectGetMaxY(self.frame));
    
    emitterNode.particlePositionRange = CGVectorMake(CGRectGetMaxX(self.frame), 0);
    [emitterNode advanceSimulationTime:lifetime];
    
    //setup star light
    if(enableStarLight) {
        float lightFluctuations = 15;
        SKKeyframeSequence * lightSequence = [[SKKeyframeSequence alloc] initWithCapacity:lightFluctuations *2];
        
        float lightTime = 1.0/lightFluctuations;
        for (int i = 0; i < lightFluctuations; i++) {
         [lightSequence addKeyframeValue:[SKColor whiteColor] time:((i * 2) * lightTime / 2)];
         [lightSequence addKeyframeValue:[SKColor yellowColor] time:((i * 2 + 2) * lightTime / 2)];
        }
        
        emitterNode.particleColorSequence = lightSequence;
    }
    
    return emitterNode;
}

- (void)moveSpaceDust {
    
    //We're basically going to use two space dust images and just cycle them.
    CGPoint velocity = CGPointMake(0, -65);
    CGPoint valueToMove = CGPointMake(velocity.x * _timeInterval, velocity.y * _timeInterval);
    _spaceDustLayer.position = CGPointMake(_spaceDustLayer.position.x + valueToMove.x,
                                           _spaceDustLayer.position.y + valueToMove.y);
    
    
    [_spaceDustLayer enumerateChildNodesWithName:@"bgSpaceDust"
               usingBlock:^(SKNode *node, BOOL *stop){
                   SKSpriteNode * bg = (SKSpriteNode *) node;
                   CGPoint screenPosition = [_spaceDustLayer convertPoint:bg.position toNode:self];
                   if (screenPosition.y <= -bg.size.height) {
                       bg.position = CGPointMake(bg.position.x,
                                                 bg.position.y + bg.size.height * 2);
                   }
               }];
}

- (void)playMusic:(NSString *)filename
{
    NSError *error;
    NSURL *musicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    _musicPlayer.numberOfLoops = -1;
    _musicPlayer.volume = 0.40f; //reduce the volume...it's a bit too loud but you might like it loud.
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
}

- (void)animateLowHealthWarning {
    
    SKSpriteNode *healthNode = (SKSpriteNode *)[_layerHudNode childNodeWithName:
                                                [NSString stringWithFormat:@"health%d", 1]];

    if(_monkey.health > 0 && _monkey.health <= _monkey.maxHealth / 4) {
        
        //activate at or below 25%
        if (![healthNode actionForKey:@"lowHealthAnimation"]) {
            SKAction *alertAction = [SKAction playSoundFileNamed:@"alarm.wav" waitForCompletion:YES];
            [self runAction:alertAction];
            
            [healthNode runAction:[SKAction repeatActionForever:_lowHealthWarningAction] withKey:@"lowHealthAnimation"];
        }
    } else {
        
        if ([healthNode actionForKey:@"lowHealthAnimation"]) {
            [healthNode removeActionForKey:@"lowHealthAnimation"];
            [healthNode runAction:[SKAction scaleTo:0.7 duration:.5]]; //return to normal scale.
        }
    }
}

- (void)setHeartsFull {
    
    //Set all the hearts back to full
    for(int i = _monkey.heartCount; i > 0; i--) {
        
        SKSpriteNode *healthNode = (SKSpriteNode *)[_layerHudNode childNodeWithName: [NSString stringWithFormat:@"health%d", i]];
        [healthNode setTexture:_heartFullTexture];
    }
}

- (void)RestartGame {
    
    _score = 0;
    _scoreNode.text = @"Score:0";
    _monkey.health = _monkey.maxHealth;
    
    [_monkey runAction:[SKAction group:@[[SKAction rotateToAngle:0 duration:.5],
                                         [SKAction moveTo:CGPointMake((self.size.width / 2), 120) duration:1]]]];
    [_monkey startFlyAnimation];
    [self setHeartsFull];
    [[_layerHudNode childNodeWithName:@"gameOverNode"] removeFromParent];
    _gameRunning = YES;
}

- (void)increaseScoreBy:(float)amount
{
    _score += amount;
    _scoreNode.text = [NSString stringWithFormat:@"Score:%1.0f", _score];
}

- (void)increaseHealthBy:(float)amount {
    
    _monkey.health += amount;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if(!_gameRunning) {
        [self RestartGame];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
   
    CGPoint currentPoint = [[touches anyObject] locationInNode:self];
    CGPoint previousPoint = [[touches anyObject] previousLocationInNode:self];
    
    _movementDelta = CGPointMake(currentPoint.x - previousPoint.x,
                                 currentPoint.y - previousPoint.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _movementDelta = CGPointZero;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _movementDelta = CGPointZero;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {

    if(_gameRunning) {
    
        SKNode *contactNode = contact.bodyA.node;
        if([contactNode isKindOfClass:[GameObject class]]) {
            [(GameObject *)contactNode collidedWith:contact.bodyB contact:contact];
        }
        contactNode = contact.bodyB.node;
        if([contactNode isKindOfClass:[GameObject class]]) {
            [(GameObject *)contactNode collidedWith:contact.bodyA contact:contact];
        }
    }
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
    //rotate our monkey back to zero after contact has ended...
    [_monkey runAction:[SKAction rotateToAngle:0 duration:.5]];
}

- (void)update:(CFTimeInterval)currentTime {
    
    //Set the time update interval
    if (_timeLastUpdated) {
        _timeInterval = (currentTime - _timeLastUpdated);
    } else {
        _timeInterval = 0;
    }
    _timeLastUpdated = currentTime;
    
    if(_gameRunning) {
    
        //Move the space dust!  Space dust doesn't stay still--I know from experience
        [self moveSpaceDust];
        
        //Update the monkey's position
        CGPoint newLocation = CGPointMake(_monkey.position.x + _movementDelta.x,
                                          _monkey.position.y + _movementDelta.y);
        
        _monkey.position = newLocation;
        
        //Bind the monkey in the screen...he can't escape.
        //There are better ways to do this such as using a custom utility class for math calculations
        [self confineToBounds];
        
        //Update the monkey
        [_monkey update:_timeInterval];
        
        //Update health--opportunity to refactor out of this method!
        float maxHealth = _monkey.maxHealth;
        float heartCount = _monkey.heartCount;
        float currentHealth = _monkey.health;
        float maxHealthFraction = maxHealth / heartCount;
        //Update life hearts
        for(int i = heartCount; i > 0; i--) {
            
            SKSpriteNode *healthNode = (SKSpriteNode *)[_layerHudNode childNodeWithName: [NSString stringWithFormat:@"health%d", i]];
            if(currentHealth < maxHealth) {
                //if the current health is less than max health, modify the blend factor
                if(currentHealth > 0) {
                    float minHealthClamp = ((maxHealthFraction) * (i-1)) + 1;
                    float maxHealthClamp =  (maxHealthFraction * i);
                    if(currentHealth > minHealthClamp && currentHealth <= maxHealthClamp) {
                        //Is the heart in the range...such as between 26 and 50 or between 51 and 75
                        //if so, set the color blend
                        [healthNode setTexture:_heartFullTexture];
                        float blendFactor = 1-(((maxHealthFraction * i) - currentHealth) / maxHealthFraction);
                        [healthNode setColorBlendFactor:blendFactor];
                    } else {
                        
                        //The others should either hearts will either be fully red or completely empty.
                        if(currentHealth < (maxHealthFraction * i)) {
                          [healthNode setTexture:_heartEmptyTexture];
                        } else {
                            [healthNode setTexture:_heartFullTexture];
                            [healthNode setColorBlendFactor:1.0f];
                        }
                    }
                    
                } else {
                    //If the current health is equal or less than zero, empty hearts should be displayed
                    [healthNode setTexture:_heartEmptyTexture];
                }
                
            } else {
                //Since they are equal...full health, set them to full color
                [self setHeartsFull];
                [healthNode setColorBlendFactor:1.0];
            }
        }
        
        [self animateLowHealthWarning];
        
        if(_monkey.health <=0) {
            [_monkey startDeathAnimation];
            _gameRunning = NO;
        }
    } else {
        if(!_gameOverNode.parent) {
            [_layerHudNode addChild:_gameOverNode];
        }
    }
}

//Don't let the monkey get lost in space!
- (void)confineToBounds {
    
    CGPoint correctedMonkeyPos = _monkey.position;
    CGPoint lowerLeft = CGPointZero;
    CGPoint upperRight = CGPointMake(self.size.width, self.size.height);
    
    if(correctedMonkeyPos.x <= lowerLeft.x) {correctedMonkeyPos.x = lowerLeft.x;}
    if(correctedMonkeyPos.x >= upperRight.x) {correctedMonkeyPos.x = upperRight.x;}
    if(correctedMonkeyPos.y <= lowerLeft.y) {correctedMonkeyPos.y = lowerLeft.y;}
    if(correctedMonkeyPos.y >= upperRight.y) {correctedMonkeyPos.y = upperRight.y;}
    
    _monkey.position = correctedMonkeyPos;
    
}

@end









