//
//  Monkey.h
//  SpriteKitDemo
//
//  Created by Mark DiGiovanni on 10/11/13.
//  Copyright (c) 2013 CapTech Ventures, Inc. All rights reserved.
//

#import "GameObject.h"

@interface Monkey : GameObject

@property (assign, nonatomic) int heartCount;
@property (assign, nonatomic) int heartHealthValue;

- (void)startFlyAnimation;
- (void)stopFlyAnimation;
- (void)startDeathAnimation;

@end
